// Copyright 2021 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you (License). Unless the License provides otherwise, you may not
// use, modify, copy, publish, distribute, disclose or transmit this software or
// the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

#include "OptimizerLTO.h"
#include "BackendUtils.h"
#include "VectorizerUtils.h"

#include "SPIRVLowerConstExpr.h"
#include "SPIRVToOCL.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#ifndef NDEBUG
#include "llvm/IR/Verifier.h"
#endif // #ifndef NDEBUG
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/StandardInstrumentations.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/TargetParser/Triple.h"
#include "llvm/Transforms/IPO/AlwaysInliner.h"
#include "llvm/Transforms/IPO/ArgumentPromotion.h"
#include "llvm/Transforms/IPO/DeadArgumentElimination.h"
#include "llvm/Transforms/IPO/GlobalDCE.h"
#include "llvm/Transforms/IPO/GlobalOpt.h"
#include "llvm/Transforms/IPO/Inliner.h"
#include "llvm/Transforms/IPO/SCCP.h"
#include "llvm/Transforms/InstCombine/InstCombine.h"
#include "llvm/Transforms/Instrumentation/GCOVProfiler.h"
#include "llvm/Transforms/SYCLTransforms/Passes.h"
#include "llvm/Transforms/SYCLTransforms/SGRemapWICall.h"
#include "llvm/Transforms/SYCLTransforms/Utils/CompilationUtils.h"
#include "llvm/Transforms/Scalar/ADCE.h"
#include "llvm/Transforms/Scalar/DCE.h"
#include "llvm/Transforms/Scalar/DeadStoreElimination.h"
#include "llvm/Transforms/Scalar/EarlyCSE.h"
#include "llvm/Transforms/Scalar/GVN.h"
#include "llvm/Transforms/Scalar/InferAddressSpaces.h"
#include "llvm/Transforms/Scalar/InstSimplifyPass.h"
#include "llvm/Transforms/Scalar/JumpThreading.h"
#include "llvm/Transforms/Scalar/LICM.h"
#include "llvm/Transforms/Scalar/LoopDeletion.h"
#include "llvm/Transforms/Scalar/LoopIdiomRecognize.h"
#include "llvm/Transforms/Scalar/LoopUnrollPass.h"
#include "llvm/Transforms/Scalar/Reassociate.h"
#include "llvm/Transforms/Scalar/SROA.h"
#include "llvm/Transforms/Scalar/SimplifyCFG.h"
#include "llvm/Transforms/Utils/Mem2Reg.h"
#include "llvm/Transforms/Utils/NameAnonGlobals.h"
#include "llvm/Transforms/Utils/UnifyFunctionExitNodes.h"
#include "llvm/Transforms/Vectorize/LoopVectorize.h"
#include "llvm/Transforms/Vectorize/VectorCombine.h"

using namespace llvm;

// If set, then optimization passes will process functions as if they have the
// optnone attribute.
extern bool SYCLEnableSubGroupEmulation;

namespace Intel {
namespace OpenCL {
namespace DeviceBackend {

OptimizerLTO::OptimizerLTO(Module &M, SmallVectorImpl<Module *> &RtlModuleList,
                           const intel::OptimizerConfig &Config)
    : Optimizer(M, RtlModuleList, Config) {}

void OptimizerLTO::Optimize(raw_ostream &LogStream) {
  TargetMachine *TM = Config.GetTargetMachine();
  assert(TM && "Uninitialized TargetMachine!");
  PipelineTuningOptions PTO;
  PTO.LoopUnrolling = true;
  PTO.LoopInterleaving = false;
  PTO.LoopVectorization = false;
  PTO.SLPVectorization = false;
  PTO.MergeFunctions = false;
  PTO.CallGraphProfile = true;

  std::optional<PGOOptions> PGOOpt;
  PassInstrumentationCallbacks PIC;
  bool DebugPassManager = getDebugPM() != DebugLogging::None;
  PrintPassOptions PrintPassOpts;
  PrintPassOpts.Verbose = getDebugPM() == DebugLogging::Verbose;
  PrintPassOpts.SkipAnalyses = getDebugPM() == DebugLogging::Quiet;
  StandardInstrumentations SI(m_M.getContext(), DebugPassManager,
                              getVerifyEachPass(), PrintPassOpts);
  SI.registerCallbacks(PIC);
  PassBuilder PB(TM, PTO, PGOOpt, &PIC);

  LoopAnalysisManager LAM;
  FunctionAnalysisManager FAM;
  CGSCCAnalysisManager CGAM;
  ModuleAnalysisManager MAM;

  // Register the AA manager first so that our version is the one used.
  FAM.registerPass([&] {
    AAManager AAM = PB.buildDefaultAAPipeline();
    if (Config.EnableOCLAA())
      AAM.registerFunctionAnalysis<SYCLAliasAnalysis>();
    return AAM;
  });

  // Register the target library analysis directly and give it a customized
  // preset TLI.
  Triple TargetTriple(m_M.getTargetTriple());
  TLII.reset(new TargetLibraryInfoImpl(TargetTriple));
  // Disable LLVM transformations of printf to ensure it is resolved to
  // __opencl_printf.
  TLII->setUnavailable(LibFunc_printf);
  FAM.registerPass([&] { return TargetLibraryAnalysis(*TLII); });

  // Register module analysis with custom parameters.
  MAM.registerPass([&] { return BuiltinLibInfoAnalysis(m_RtlModules); });

  // Register all the basic analyses with the managers.
  PB.registerModuleAnalyses(MAM);
  PB.registerCGSCCAnalyses(CGAM);
  PB.registerFunctionAnalyses(FAM);
  PB.registerLoopAnalyses(LAM);
  PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);

  registerPipelineStartCallback(PB);
  registerOptimizerEarlyCallback(PB);
  registerVectorizerStartCallback(PB);
  registerOptimizerLastCallback(PB);

  ModulePassManager MPM;
  auto OptLevel = BackendUtils::getOptLevel(Config.GetDisableOpt(), m_M);
  if (OptLevel == OptimizationLevel::O0)
    MPM = PB.buildO0DefaultPipeline(OptimizationLevel::O0);
  else
    MPM = PB.buildPerModuleDefaultPipeline(OptLevel);

  // Set custom DiagnosticHandler callback.
  setDiagnosticHandler(LogStream);

  MPM.run(m_M, MAM);
}

void OptimizerLTO::registerPipelineStartCallback(PassBuilder &PB) {
  PB.registerPipelineStartEPCallback(
      [this](ModulePassManager &MPM, OptimizationLevel Level) {
        if (m_IsSYCL && !CompilationUtils::generatedFromSPIRV(m_M)) {
          MPM.addPass(SPIRVLowerConstExprPass());
        }

        if (m_IsSYCL && !m_IsFpgaEmulator)
          // OCL CPU backend support SYCL assert now. We need to remove the
          // duplicated functions definition from assert fallback.
          MPM.addPass(RemoveDeviceLibAssertFallbackPass());

        MPM.addPass(KernelTargetExtTypeLowerPass());
        MPM.addPass(SPIRVToOCL20Pass());
        MPM.addPass(NameAnonGlobalPass());
        MPM.addPass(SpecializeConstantPass());

#ifndef NDEBUG
        MPM.addPass(VerifierPass());
#endif // #ifndef NDEBUG

        MPM.addPass(SYCLEqualizerPass(getBuiltinAliases()));
        MPM.addPass(ExternalizeGlobalVariablesPass());

        if (Config.GetCoverage())
          MPM.addPass(GCOVProfilerPass());

        Triple TargetTriple(m_M.getTargetTriple());
        if (TargetTriple.isArch64Bit()) {
          if (TargetTriple.isOSLinux())
            MPM.addPass(CoerceTypesPass());
          else if (TargetTriple.isOSWindows())
            MPM.addPass(CoerceWin64TypesPass());
        }

        if (m_IsFpgaEmulator)
          MPM.addPass(RemoveAtExitPass());

        MPM.addPass(SetPreferVectorWidthPass(ISA));

        if (m_IsSYCL && Config.GetRelaxedMath())
          MPM.addPass(createModuleToFunctionPassAdaptor(AddFastMathPass()));

        if (Level != OptimizationLevel::O0)
          MPM.addPass(InternalizeNonKernelFuncPass());

        // Flatten get_{local, global}_linear_id()
        if (m_HasOcl20)
          MPM.addPass(LinearIdResolverPass());

        MPM.addPass(AddFunctionAttrsPass());

        if (Level != OptimizationLevel::O0) {
          FunctionPassManager FPM;
          FPM.addPass(SimplifyCFGPass());
          if (Level == OptimizationLevel::O1)
            FPM.addPass(PromotePass());
          else
            FPM.addPass(SROAPass(SROAOptions::ModifyCFG));
          FPM.addPass(InstCombinePass());
          FPM.addPass(InstSimplifyPass());
          MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
        }

        // Resolve variable argument of get_global_id, get_local_id and
        // get_group_id.
        MPM.addPass(ResolveVarTIDCallPass());
        MPM.addPass(SGRemapWICallPass(static_cast<SubGroupConstructionMode>(
            Config.GetSubGroupConstructionMode())));

        if (m_IsFpgaEmulator) {
          MPM.addPass(ChannelPipeTransformationPass());
          MPM.addPass(SYCLRewritePipesPass());
          MPM.addPass(PipeIOTransformationPass());
          MPM.addPass(PipeOrderingPass());
          MPM.addPass(AutorunReplicatorPass());
        }

        FunctionPassManager FPM;
        // Static resolution of generic address space pointers
        if (Level != OptimizationLevel::O0 && m_HasOcl20) {
          FPM.addPass(PromotePass());
          FPM.addPass(
              InferAddressSpacesPass(CompilationUtils::ADDRESS_SPACE_GENERIC));
          MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
        }

        FPM.addPass(BuiltinCallToInstPass());
        MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));

        // Adding IPSCCPPass to the beginning to propogate constant. Otherwise
        // the opportunity may disappear when EarlyCSE pass is run first.
        if (Level != OptimizationLevel::O0)
          MPM.addPass(IPSCCPPass());
      });
}

void OptimizerLTO::registerOptimizerEarlyCallback(PassBuilder &PB) {
  PB.registerOptimizerEarlyEPCallback([&](ModulePassManager &MPM,
                                          OptimizationLevel Level,
                                          ThinOrFullLTOPhase) {
    MPM.addPass(DetectRecursionPass());

    if (m_IsFpgaEmulator)
      MPM.addPass(PipeSupportPass());

    if (Level != OptimizationLevel::O0) {
      FunctionPassManager FPM;
      FPM.addPass(ReassociatePass());
      FPM.addPass(UnifyFunctionExitNodesPass());
      if (m_HasOcl20) {
        // Repeat resolution of generic address space pointers after LLVM
        // IR was optimized.
        FPM.addPass(
            InferAddressSpacesPass(CompilationUtils::ADDRESS_SPACE_GENERIC));
        // Cleanup after InferAddressSpaces pass.
        FPM.addPass(SimplifyCFGPass());
        FPM.addPass(SROAPass(SROAOptions::ModifyCFG));
        FPM.addPass(EarlyCSEPass());
        FPM.addPass(PromotePass());
        FPM.addPass(InstCombinePass());
        // No need to run function inlining pass here, because if there are
        // still non-inlined functions, then we don't have to inline new
        // ones.
      }
      if (Config.GetTransposeSize() != 1) {
        FPM.addPass(SimplifyCFGPass(SimplifyCFGOptions()
                                        .bonusInstThreshold(1)
                                        .forwardSwitchCondToPhi(false)
                                        .convertSwitchToLookupTable(false)
                                        .needCanonicalLoops(true)
                                        .sinkCommonInsts(true)));
        FPM.addPass(InstCombinePass());
        FPM.addPass(GVNHoistPass());
        FPM.addPass(DCEPass());
      }
      MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
    }

    if (m_IsSYCL) {
      MPM.addPass(TaskSeqAsyncHandling());
    }

    if (Level != OptimizationLevel::O0)
      MPM.addPass(InferArgumentAliasPass());

    MPM.addPass(DuplicateCalledKernelsPass());

    MPM.addPass(SYCLKernelAnalysisPass(
        Intel::OpenCL::Utils::CPUDetect::GetInstance()->HasSPR(),
        Intel::OpenCL::Utils::CPUDetect::GetInstance()->HasGNR()));

    if (Level != OptimizationLevel::O0) {
      MPM.addPass(createModuleToFunctionPassAdaptor(SimplifyCFGPass()));
      MPM.addPass(WGLoopBoundariesPass());
      FunctionPassManager FPM;
      FPM.addPass(DCEPass());
      FPM.addPass(SimplifyCFGPass());
      FPM.addPass(LoopUnrollPass(
          LoopUnrollOptions(Level.getSpeedupLevel()).setPartial(true)));
      MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
      MPM.addPass(DeduceMaxWGDimPass());
    }

    // Should be called before vectorizer!
    MPM.addPass(InstToFuncCallPass(ISA));
    // Select math builtin based on required accuracy
    MPM.addPass(MathFuncSelectPass());
  });
}

void OptimizerLTO::registerVectorizerStartCallback(PassBuilder &PB) {
  PB.registerVectorizerStartEPCallback(
      [this](FunctionPassManager &FPM, OptimizationLevel Level) {
        if (Config.GetTransposeSize() == 1)
          return;

        FPM.addPass(PromotePass());
        FPM.addPass(LoopSimplifyPass());
        FPM.addPass(createFunctionToLoopPassAdaptor(
            LICMPass(SetLicmMssaOptCap, SetLicmMssaNoAccForPromotionCap,
                     /*AllowSpeculation*/ true),
            /*UseMemorySSA=*/true, /*UseBlockFrequencyInfo=*/true));
      });
}

void OptimizerLTO::registerOptimizerLastCallback(PassBuilder &PB) {
  PB.registerOptimizerLastEPCallback([this](ModulePassManager &MPM,
                                            OptimizationLevel Level,
                                            ThinOrFullLTOPhase) {
    {
      // When forced VF equals 1 or in O0 case, check subgroup semantics AND
      // prepare subgroup_emu_size for sub-group emulation.
      MPM.addPass(ReqdSubGroupSizePass());
      MPM.addPass(SetVectorizationFactorPass(ISA));
    }

    MPM.addPass(ResolveSubGroupWICallPass(/*ResolveSGBarrier*/ false));

    FunctionPassManager FPM;
    if (Level != OptimizationLevel::O0)
      FPM.addPass(OptimizeIDivAndIRemPass());
    FPM.addPass(PreventDivCrashesPass());
    if (Level != OptimizationLevel::O0) {
      // We need InstructionCombining and GVN passes after PreventDivCrashes
      // passes to optimize redundancy introduced by those passes
      FPM.addPass(InstCombinePass());
      FPM.addPass(GVNPass());
      FPM.addPass(VectorCombinePass());
      // In specACCEL/124, InstCombine may generate a cross-barrier bool value
      // used as a condition of a 'br' instruction, which leads to performance
      // degradation. JumpThreading eliminates the cross-barrier value.
      FPM.addPass(JumpThreadingPass());
    }
    MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));

    // OpenCL -g and -profiling flags are mutually exclusive, with precedence
    // given to -g.
    if (Config.GetProfilingFlag())
      MPM.addPass(ProfilingInfoPass());

    if (Level != OptimizationLevel::O0 && Config.GetStreamingAlways())
      MPM.addPass(createModuleToFunctionPassAdaptor(AddNTAttrPass()));
    MPM.addPass(ImplicitGIDPass(/*HandleBarrier*/ false));
    MPM.addPass(SYCLKernelWGLoopCreatorPass());
    MPM.addPass(InvalidateAnalysisPass<KernelIndirectCallAnalysis>());

    // Can't run loop unroll between WGLoopCreator and LoopIdiom for scalar
    // workload, which can benefit from LoopIdiom.
    // TODO wen can consider move this unroll into ScalarOptimizerLate callback.
    if (Level != OptimizationLevel::O0 && Config.GetTransposeSize() != 1) {
      // unroll loops with non-constant trip count
      const int thresholdBase = 16;
      int RTLoopUnrollFactor = Config.GetRTLoopUnrollFactor();
      if (RTLoopUnrollFactor > 1) {
        LoopUnrollOptions UnrollOpts(Level.getSpeedupLevel());
        const unsigned threshold = thresholdBase * RTLoopUnrollFactor;
        // RTLoopUnrollFactor is to customize Count. However, LoopUnrollOptions
        // doesn't allow the customization.
        UnrollOpts.setPartial(false).setRuntime(true).setThreshold(
            threshold); // INTEL
        MPM.addPass(
            createModuleToFunctionPassAdaptor(LoopUnrollPass(UnrollOpts)));
      }
    }

    FunctionPassManager FPM2;
    // Clean up scalar kernel after WGLoop for native subgroups.
    if (Level != OptimizationLevel::O0) {
      FPM2.addPass(DCEPass());
      FPM2.addPass(SimplifyCFGPass());
    }

    FPM2.addPass(UnifyFunctionExitNodesPass());
    MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM2)));

    if (m_IsFpgaEmulator)
      MPM.addPass(InfiniteLoopCreatorPass());

    addBarrierPasses(MPM, Level);

    // After adding loops run loop optimizations.
    if (Level != OptimizationLevel::O0) {
      // Add LoopSimplify pass before CLBuiltinLICM pass as CLBuiltinLICM pass
      // requires loops in Simplified Form.
      FunctionPassManager FPM;
      FPM.addPass(PromotePass());
      FPM.addPass(LoopSimplifyPass());
      LoopPassManager LPM;
      LPM.addPass(LICMPass(SetLicmMssaOptCap, SetLicmMssaNoAccForPromotionCap,
                           /*AllowSpeculation*/ true));
      LPM.addPass(BuiltinLICMPass());
      LPM.addPass(LoopStridedCodeMotionPass());
      FPM.addPass(
          createFunctionToLoopPassAdaptor(std::move(LPM), /*UseMemorySSA=*/true,
                                          /*UseBlockFrequencyInfo=*/true));
      MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
    }

    if (Config.GetRelaxedMath())
      MPM.addPass(RelaxedMathPass());

    // The following three passes (AddTLSGlobals/AddImplicitArgs,
    // ResolveWICall, LocalBuffer) must run before BuiltinImport pass!
    if (m_UseTLSGlobals)
      MPM.addPass(AddTLSGlobalsPass());
    else
      MPM.addPass(AddImplicitArgsPass());
    MPM.addPass(ResolveWICallPass());
    MPM.addPass(LocalBuffersPass());
    MPM.addPass(PrivateToHeapPass());

#ifdef _DEBUG
    MPM.addPass(VerifierPass());
#endif

    MPM.addPass(BuiltinImportPass(CPUPrefix));
    if (Level != OptimizationLevel::O0) {
      // After the globals used in built-ins are imported - we can internalize
      // them with further wiping them out with GlobalDCE pass
      MPM.addPass(InternalizeGlobalVariablesPass());
    }
    // Need to convert shuffle calls to shuffle IR before running inline pass
    // on built-ins
    MPM.addPass(createModuleToFunctionPassAdaptor(BuiltinCallToInstPass()));

#ifdef _DEBUG
    MPM.addPass(VerifierPass());
#endif

    // Ensure that the built-in functions to be processed by
    // PatchCallbackArgsPass are inlined.
    MPM.addPass(AlwaysInlinerPass());
    if (Level != OptimizationLevel::O0) {
      auto InlineParams = getInlineParams();
      InlineParams.DefaultThreshold = 4096;
      MPM.addPass(ModuleInlinerWrapperPass(InlineParams, /* MandatoryFirst */ false));
    }

    // Some built-in functions contain calls to external functions which take
    // arguments that are retrieved from the function's implicit arguments.
    // Currently only applies to OpenCL 2.x
    if (m_HasOcl20)
      MPM.addPass(PatchCallbackArgsPass());

    if (Level != OptimizationLevel::O0) {
      // AddImplicitArgs pass may create dead implicit arguments.
      MPM.addPass(DeadArgumentEliminationPass());
      // Scalarize argument, e.g. local.ids inserted by WGLoopCreator.
      MPM.addPass(
          createModuleToPostOrderCGSCCPassAdaptor(ArgumentPromotionPass()));
      FunctionPassManager FPM;
      FPM.addPass(SROAPass(SROAOptions::ModifyCFG));
      FPM.addPass(LoopSimplifyPass());
      LoopPassManager LPM;
      LPM.addPass(LICMPass(SetLicmMssaOptCap, SetLicmMssaNoAccForPromotionCap,
                           /*AllowSpeculation*/ true));
      LPM.addPass(LoopIdiomRecognizePass());
      LPM.addPass(LoopDeletionPass());
      FPM.addPass(
          createFunctionToLoopPassAdaptor(std::move(LPM), /*UseMemorySSA=*/true,
                                          /*UseBlockFrequencyInfo=*/true));
      FPM.addPass(SimplifyCFGPass());
      MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
    }

    MPM.addPass(PrepareKernelArgsPass());

    if (Level != OptimizationLevel::O0) {
      MPM.addPass(GlobalOptPass());
      // Clean up internal globals. ModuleInlinerWrapperPass doesn't discard
      // internal lib function, e.g. udiv, which is inlined and now unused.
      MPM.addPass(GlobalDCEPass());
      // These passes come after PrepareKernelArgs pass to eliminate the
      // redundancy produced by it.
      FunctionPassManager FPM;
      // Align with the pipeline in PassBuilderPipelines.cpp, forbid modifying
      // CFG since there is no LICM and SimplifyCFG passes after this.
      FPM.addPass(SROAPass(SROAOptions::PreserveCFG));
      FPM.addPass(InstCombinePass());
      FPM.addPass(SimplifyCFGPass());
      FPM.addPass(GVNPass());
      FPM.addPass(DSEPass());
      FPM.addPass(ADCEPass());
      FPM.addPass(EarlyCSEPass());
      FPM.addPass(InstCombinePass());
      MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
    }
  });
}

void OptimizerLTO::addBarrierPasses(ModulePassManager &MPM,
                                    OptimizationLevel Level) {
  if (Level != OptimizationLevel::O0 ) { 
    MPM.addPass(ReplaceScalarWithMaskPass());

    // Resolve subgroup call introduced by ReplaceScalarWithMask pass.
    MPM.addPass(ResolveSubGroupWICallPass(/*ResolveSGBarrier*/ false));
  }

  {
    FunctionPassManager FPM;
    if (Level != OptimizationLevel::O0) {
      FPM.addPass(DCEPass());
      FPM.addPass(SimplifyCFGPass());
      FPM.addPass(PromotePass());
    }
    MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));
  }

  MPM.addPass(GroupBuiltinPass());
  MPM.addPass(BarrierInFunction());
  if (Level != OptimizationLevel::O0)
    MPM.addPass(RemoveDuplicatedBarrierPass());

  if (SYCLEnableSubGroupEmulation) {
    // Begin sub-group emulation
    MPM.addPass(SGBuiltinPass(getVectInfos()));
    MPM.addPass(SGBarrierPropagatePass());
    MPM.addPass(SGBarrierSimplifyPass());
    // Insert ImplicitGIDPass in the middle of subgroup emulation to track GIDs
    // in emulation loops
    MPM.addPass(ImplicitGIDPass(/*HandleBarrier*/ true));

    // Resume sub-group emulation
    MPM.addPass(SGValueWidenPass());
    MPM.addPass(SGLoopConstructPass());
#ifdef _DEBUG
    MPM.addPass(VerifierPass());
#endif
    // End sub-group emulation
  }
  // Resolve subgroup barriers after subgroup emulation passes
  MPM.addPass(ResolveSubGroupWICallPass(/*ResolveSGBarrier*/ true));
  MPM.addPass(SplitBBonBarrier());
  if (Level != OptimizationLevel::O0)
    MPM.addPass(ReduceCrossBarrierValuesPass());
  MPM.addPass(KernelBarrier());
#ifdef _DEBUG
  MPM.addPass(VerifierPass());
#endif
}

} // namespace DeviceBackend
} // namespace OpenCL
} // namespace Intel
