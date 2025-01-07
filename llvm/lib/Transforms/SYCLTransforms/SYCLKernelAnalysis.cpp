//==--- SYCLKernelAnalysis.cpp - Analyze SYCL kernel properties - C++ -*--==//
//
// Copyright (C) 2020 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //

#include "llvm/Transforms/SYCLTransforms/SYCLKernelAnalysis.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/SYCLTransforms/BuiltinLibInfoAnalysis.h"
#include "llvm/Transforms/SYCLTransforms/KernelIndirectCallAnalysis.h"
#include "llvm/Transforms/SYCLTransforms/Utils/BarrierUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/CompilationUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/DiagnosticInfo.h"
#include "llvm/Transforms/SYCLTransforms/Utils/LoopUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/MetadataAPI.h"
#include <cmath>

#define DEBUG_TYPE "sycl-kernel-analysis"

using namespace llvm;
using namespace CompilationUtils;

static cl::opt<bool> SYCLKernelAnalysisAssumeIsAMX(
    "sycl-kernel-analysis-assume-isamx", cl::init(false), cl::Hidden,
    cl::desc("make assumption for sycl kernel analysis's isamx"));

static cl::opt<bool> SYCLKernelAnalysisAssumeIsAMXFP16(
    "sycl-kernel-analysis-assume-isamxfp16", cl::init(false), cl::Hidden,
    cl::desc("make assumption for sycl kernel analysis's isamxfp16"));

DiagnosticKind FPGAMemoryScopeErrorDiagInfo::Kind =
    static_cast<DiagnosticKind>(getNextAvailablePluginDiagnosticKind());

void SYCLKernelAnalysisPass::fillSyncUsersFuncs(IndirectCallInfo *ICI) {
  // Get all synchronize built-ins declared in module
  FuncSet SyncFunctions = getAllSyncBuiltinsDecls(*M);

  LoopUtils::fillFuncUsersSet(SyncFunctions, UnsupportedFuncs);

  // Inaccurate analysis of which functions are callee of indirect call may
  // falsely mark a kernel as having barrier path. But this shouldn't cause
  // stability issue.
  FuncSet IndirectUserFuncs;
  for (auto *F : UnsupportedFuncs)
    for (auto *Call : ICI->getIndirectCalls(F))
      IndirectUserFuncs.insert(Call->getFunction());
  UnsupportedFuncs.insert(IndirectUserFuncs.begin(), IndirectUserFuncs.end());
  LoopUtils::fillFuncUsersSet(IndirectUserFuncs, UnsupportedFuncs);
}

void SYCLKernelAnalysisPass::fillRootGroupBarrierCallerFuncs() {
  BarrierUtils Utils;
  Utils.init(this->M);
  FuncSet RootGroupBarrierDirectCallerFuncs;
  for (auto *Inst : Utils.getDeviceBarrierCallInsts()) {
    assert(Inst && Inst->getFunction() &&
           "nullptr is not expected for Inst or its owning function!");
    if (Inst && Inst->getFunction()) {
      RootGroupBarrierDirectCallerFuncs.insert(Inst->getFunction());
    }
  }
  LoopUtils::fillFuncUsersSet(RootGroupBarrierDirectCallerFuncs,
                              RootGroupBarrierCallerFuncs);
  RootGroupBarrierCallerFuncs.insert(RootGroupBarrierDirectCallerFuncs.begin(),
                                     RootGroupBarrierDirectCallerFuncs.end());
}

void SYCLKernelAnalysisPass::fillKernelCallers() {
  for (Function *Kernel : Kernels) {
    if (!Kernel)
      continue;
    FuncSet KernelRootSet;
    FuncSet KernelUsers;
    KernelRootSet.insert(Kernel);
    LoopUtils::fillFuncUsersSet(KernelRootSet, KernelUsers);
    // The kernel has user functions meaning it is called by another kernel.
    // Since there is no barrier in it's start it will be executed
    // multiple time (because of the WG loop of the calling kernel).
    if (KernelUsers.size())
      UnsupportedFuncs.insert(Kernel);
  }

  // Also can not use explicit loops on kernel callers since the barrier
  // pass need to handle them in order to process the called kernels.
  FuncSet KernelSet(Kernels.begin(), Kernels.end());
  LoopUtils::fillFuncUsersSet(KernelSet, UnsupportedFuncs);
}

void SYCLKernelAnalysisPass::fillSubgroupCallingFuncs(CallGraph &CG) {
  using namespace CompilationUtils;
  for (auto &F : *M) {
    if (F.isDeclaration())
      continue;
    if (hasFunctionCallInCGNodeIf(CG[&F], [&](const Function *CalledFunc) {
          return CalledFunc && CalledFunc->isDeclaration() &&
                 (isSubGroupBuiltin(CalledFunc->getName()) ||
                  isSubGroupBarrier(CalledFunc->getName()));
        })) {
      SubgroupCallingFuncs.insert(&F);
      F.addFnAttr(KernelAttribute::HasSubGroups);
    }
  }
}

static bool hasAtomicBuiltinCall(CallGraph &CG, const RuntimeService &RTS,
                                 Function *F) {
  auto *Node = CG[F];
  for (auto It = df_begin(Node), E = df_end(Node); It != E; ++It) {
    for (const auto &Pair : **It) {
      if (!Pair.first)
        continue;
      CallInst *CI = cast<CallInst>(*Pair.first);
      Function *CalledFunc = Pair.second->getFunction();
      if (!CalledFunc || !RTS.isAtomicBuiltin(CalledFunc->getName()))
        continue;
      Value *Arg0 = CI->getOperand(0);

      // handle atomic_work_item_fence(cl_mem_fence_flags flags,
      // memory_order order, memory_scope scope) builtin.
      if (isAtomicWorkItemFenceBuiltin(CalledFunc->getName())) {
        // FPGA emulator only.
        // DiagnosticHandler can check device type and emit error messge
        // for FPGA emulator.
        if (auto *MemoryScope = dyn_cast<ConstantInt>(CI->getOperand(2))) {
          uint64_t MemoryScopeAttr = MemoryScope->getZExtValue();
          // The memory scope options must be aligned with define in
          // clang/lib/Headers/opencl-c-base.h
          static const uint64_t memory_scope_work_item = 0;
          static const uint64_t memory_scope_work_group = 1;
          static const uint64_t memory_scope_device = 2;
          static const uint64_t memory_scope_sub_group = 4;
          if (MemoryScopeAttr != memory_scope_work_item &&
              MemoryScopeAttr != memory_scope_work_group &&
              MemoryScopeAttr != memory_scope_sub_group &&
              MemoryScopeAttr != memory_scope_device) {
            F->getContext().diagnose(FPGAMemoryScopeErrorDiagInfo(
                "Use unsupported memory scope in function " + F->getName() +
                " for FPGA emulator "
                "platform!"));
          }
        }
        // !!! MUST be aligned with define in clang/lib/Headers/opencl-c-base.h
        // #define CLK_GLOBAL_MEM_FENCE   0x2
        static const uint64_t CLK_GLOBAL_MEM_FENCE = 2;
        if (auto *C = dyn_cast<ConstantInt>(Arg0)) {
          return C->getZExtValue() & CLK_GLOBAL_MEM_FENCE;
        } else {
          // 0th argument is not constant.
          // Assume the worst case - has CLK_GLOBAL_MEM_FENCE flag set.
          return true;
        }
      }

      // After switching GenericAddressStaticResolutionPass to
      // InferAddressSpacesPass, it's legal for a pointer to remain as
      // unresolved and live in generic address space until CodeGen. So if a
      // pointer is in generic address space, we just ignore it and assume
      // that it won't access global address space. This assumption won't
      // affect the correctness of the program, as the global synchronization
      // information is only used to calculate the workgroup size (see
      // Kernel.cpp and search 'HasGlobalSyncOperation' keyword) for
      // performance tunning.

      // [OpenCL 2.0] The following condition covers pipe built-ins as well
      // because the first arguments is a pipe which is a __global opaque
      // pointer.
      if (cast<PointerType>(Arg0->getType())->getAddressSpace() ==
          ADDRESS_SPACE_GLOBAL)
        return true;
    }
  }
  return false;
}

static size_t getExecutionEstimation(unsigned Depth) {
  return (size_t)pow(10.f, (int)Depth);
}

/// Previously this is calculated before Barrier and PrepareKernelArgs Passes.
/// TODO This is a rough calculation. WeightedInstCount probably provides better
/// estimation.
static size_t getExecutionLength(Function *F, LoopInfo &LI) {
  size_t Length = 0;
  for (auto &BB : *F) {
    Length += BB.size() * getExecutionEstimation(LI.getLoopDepth(&BB));
  }
  return Length;
}

bool SYCLKernelAnalysisPass::runImpl(Module &M, CallGraph &CG,
                                     const RuntimeService &RTS,
                                     function_ref<LoopInfo &(Function &)> GetLI,
                                     IndirectCallInfo *ICI) {
  this->M = &M;
  UnsupportedFuncs.clear();
  auto KernelList = CompilationUtils::getKernels(M);
  Kernels.insert(KernelList.begin(), KernelList.end());

  fillKernelCallers();
  fillSyncUsersFuncs(ICI);
  fillRootGroupBarrierCallerFuncs();
  fillSubgroupCallingFuncs(CG);

  for (Function *Kernel : Kernels) {
    assert(Kernel && "nullptr is not expected in KernelList!");
    SYCLKernelMetadataAPI::KernelInternalMetadataAPI KIMD(Kernel);
    
    if (RootGroupBarrierCallerFuncs.count(Kernel))
      KIMD.HasRootGroupBarrier.set(true);
    KIMD.NoBarrierPath.set(!UnsupportedFuncs.contains(Kernel));
    KIMD.KernelHasSubgroups.set(SubgroupCallingFuncs.contains(Kernel));
    KIMD.KernelHasGlobalSync.set(hasAtomicBuiltinCall(CG, RTS, Kernel));
    KIMD.KernelExecutionLength.set(getExecutionLength(Kernel, GetLI(*Kernel)));
  }

  LLVM_DEBUG(print(dbgs(), this->M));

  return (Kernels.size() != 0);
}

void SYCLKernelAnalysisPass::print(raw_ostream &OS, const Module *M) const {
  if (!M)
    return;

  OS << "\nSYCLKernelAnalysisPass\n";

  for (Function *Kernel : Kernels) {
    assert(Kernel && "nullptr is not expected in KernelList!");

    StringRef FuncName = Kernel->getName();

    SYCLKernelMetadataAPI::KernelInternalMetadataAPI KIMD(Kernel);
    OS << "Kernel <" << FuncName << ">:\n";
    OS.indent(2) << "NoBarrierPath=" << KIMD.NoBarrierPath.get() << "\n";
    if (KIMD.HasMatrixCall.hasValue())
      OS.indent(2) << "KernelHasMatrixCall=" << KIMD.HasMatrixCall.get()
                   << "\n";
    OS.indent(2) << "KernelHasSubgroups=" << KIMD.KernelHasSubgroups.get()
                 << "\n";
    OS.indent(2) << "KernelHasGlobalSync=" << KIMD.KernelHasGlobalSync.get()
                 << "\n";
    OS.indent(2) << "KernelExecutionLength=" << KIMD.KernelExecutionLength.get()
                 << "\n";
  }

  OS << "\nFunctions that call subgroup builtins:\n";
  for (Function *F : SubgroupCallingFuncs)
    OS << "  " << F->getName() << '\n';
}

PreservedAnalyses SYCLKernelAnalysisPass::run(Module &M,
                                              ModuleAnalysisManager &AM) {
  IsAMX = SYCLKernelAnalysisAssumeIsAMX || IsAMX;
  IsAMXFP16 = SYCLKernelAnalysisAssumeIsAMXFP16 || IsAMXFP16;
  RuntimeService &RTS =
      AM.getResult<BuiltinLibInfoAnalysis>(M).getRuntimeService();
  IndirectCallInfo *ICI = &AM.getResult<KernelIndirectCallAnalysis>(M);
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto GetLI = [&](Function &F) -> LoopInfo & {
    return FAM.getResult<LoopAnalysis>(F);
  };
  (void)runImpl(M, AM.getResult<CallGraphAnalysis>(M), RTS, GetLI, ICI);
  return PreservedAnalyses::all();
}
