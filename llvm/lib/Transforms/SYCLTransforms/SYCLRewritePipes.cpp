//==- SYCLRewritePipes.cpp - Rewrite SYCL pipe structs to OpenCL structs ==//
//
// Copyright (C) 2022 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.
//
// ===--------------------------------------------------------------------===//

#include "llvm/Transforms/SYCLTransforms/SYCLRewritePipes.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/Value.h"
#include "llvm/Support/Casting.h"
#include "llvm/Transforms/SYCLTransforms/BuiltinLibInfoAnalysis.h"
#include "llvm/Transforms/SYCLTransforms/Utils/CompilationUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/DiagnosticInfo.h"
#include "llvm/Transforms/SYCLTransforms/Utils/MetadataAPI.h"
#include "llvm/Transforms/SYCLTransforms/Utils/RuntimeService.h"
#include "llvm/Transforms/SYCLTransforms/Utils/SYCLChannelPipeUtils.h"

using namespace llvm;
using namespace SYCLChannelPipeUtils;
using namespace CompilationUtils;

#define DEBUG_TYPE "sycl-kernel-rewrite-pipes"

const StringRef CreatePipeFromPipeStorageWriteName =
    "_Z39__spirv_CreatePipeFromPipeStorage_write";
const StringRef CreatePipeFromPipeStorageReadName =
    "_Z38__spirv_CreatePipeFromPipeStorage_read";
const StringRef CreatePipeFromPipeStorageWriteTargetName =
    "_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS427"
    "__spirv_ConstantPipeStorage";
const StringRef CreatePipeFromPipeStorageReadTargetName =
    "_Z38__spirv_CreatePipeFromPipeStorage_readPU3AS427"
    "__spirv_ConstantPipeStorage";

static void
collectCreatePipeFuncs(Module &M,
                       SmallVectorImpl<Function *> &CreatePipeFuncs) {
  for (auto &F : M) {
    StringRef Name = F.getName();
    if (Name.starts_with(CreatePipeFromPipeStorageWriteName) ||
        Name.starts_with(CreatePipeFromPipeStorageReadName))
      CreatePipeFuncs.push_back(&F);
  }
}

static void
fixCreatePipeFuncName(Module &M, SmallVectorImpl<Function *> &CreatePipeFuncs) {
  Function *CreateWritePipeFunc =
      M.getFunction(CreatePipeFromPipeStorageWriteTargetName);
  Function *CreateReadPipeFunc =
      M.getFunction(CreatePipeFromPipeStorageReadTargetName);
  for (auto *F : make_early_inc_range(CreatePipeFuncs)) {
    // Name is correct, no need to fix.
    if (F == CreateWritePipeFunc || F == CreateReadPipeFunc)
      continue;

    if (F->getName().starts_with(CreatePipeFromPipeStorageWriteName)) {
      if (!CreateWritePipeFunc) {
        F->setName(CreatePipeFromPipeStorageWriteTargetName);
        CreateWritePipeFunc = F;
      } else {
        F->replaceAllUsesWith(CreateWritePipeFunc);
        F->eraseFromParent();
      }
    } else if (F->getName().starts_with(CreatePipeFromPipeStorageReadName)) {
      if (!CreateReadPipeFunc) {
        F->setName(CreatePipeFromPipeStorageReadTargetName);
        CreateReadPipeFunc = F;
      } else {
        F->replaceAllUsesWith(CreateReadPipeFunc);
        F->eraseFromParent();
      }
    }
  }

  CreatePipeFuncs.clear();
  if (CreateWritePipeFunc)
    CreatePipeFuncs.push_back(CreateWritePipeFunc);
  if (CreateReadPipeFunc)
    CreatePipeFuncs.push_back(CreateReadPipeFunc);
}

static void
collectSYCLPipeStorageGlobals(SmallVectorImpl<Function *> &CreatePipeFuncs,
                              SmallVectorImpl<GlobalVariable *> &StorageVars) {
  for (auto *F : CreatePipeFuncs) {
    for (auto *U : F->users()) {
      if (!isa<CallInst>(U))
        continue;
      auto *CI = cast<CallInst>(U);
      assert(CI->arg_size() == 1 &&
             "Expect __spirv_CreatePipeFromPipeStorage to have 1 argument");
      // Get PipeStorage GV, it might be hidden by several pointer casts.
      // Strip them.
      auto *PipeStorageArg = CI->getArgOperand(0);
      assert(PipeStorageArg && "Failed to obtain an argument");
      auto *PipeStorageGV =
          cast<GlobalVariable>(PipeStorageArg->stripPointerCasts());
      LLVM_DEBUG(dbgs() << "Found SYCL pipe storage: " << *PipeStorageGV
                        << "\n");
      StorageVars.emplace_back(PipeStorageGV);
    }
  }
}

static void
rewritePipeStorageVars(Module &M,
                       SmallVectorImpl<GlobalVariable *> &StorageVars,
                       RuntimeService &RTS) {
  if (StorageVars.empty())
    return;

  const StringRef OCLPipeRWTypeName = "opencl.pipe_rw_t";
  auto *OCLPipeRWType =
      StructType::getTypeByName(M.getContext(), OCLPipeRWTypeName);
  if (!OCLPipeRWType)
    StructType::create(M.getContext(), OCLPipeRWTypeName);
  auto *OCLPipeRWPtrType = llvm::PointerType::get(
      M.getContext(), AddressSpace::ADDRESS_SPACE_GLOBAL);

  Function *GlobalCtor = nullptr;

  for (auto *StorageVar : StorageVars) {
    // For each SYCL program scope pipe storage we create an opaque pointer that
    // is going to point to an implementation defined memory.
    auto *OCLPipeGV = new GlobalVariable(
        M, OCLPipeRWPtrType, /*isConstant*/ false, GlobalValue::ExternalLinkage,
        /*Initializer*/ nullptr, StorageVar->getName() + ".syclpipe",
        /*InsertBefore*/ nullptr, GlobalValue::ThreadLocalMode::NotThreadLocal,
        AddressSpace::ADDRESS_SPACE_GLOBAL);
    OCLPipeGV->setInitializer(ConstantPointerNull::get(OCLPipeRWPtrType));
    OCLPipeGV->setAlignment(M.getDataLayout().getPreferredAlign(OCLPipeGV));

    // Pipe parameters are hidden inside of the {i32, i32, i32} struct, so we
    // deconstruct it and set it as a metadata so other passes can check it as
    // with FPGA OpenCL pipes.
    ChannelPipeMD PipeMD;
    getSYCLPipeMetadata(StorageVar, PipeMD);
    setPipeMetadata(OCLPipeGV, PipeMD);

    // Program scope Pipe object has to be initialized at runtime after a
    // program is loaded into memory. We use a global ctor function to do that.
    if (!GlobalCtor)
      GlobalCtor = createPipeGlobalCtor(M);

    // Emit a code that adds necessary initialization to the global ctor.
    Function *PipeInitFunc = importFunctionDecl(
        &M, RTS.findFunctionInBuiltinModules(PipeMD.Protocol < 0
                                                 ? "__pipe_init_fpga"
                                                 : "__pipe_init_ext_fpga"));
    initializeGlobalPipeScalar(OCLPipeGV, PipeMD, GlobalCtor, PipeInitFunc);

    // Finally we replace all usages of {i32, i32, i32} struct with our new
    // %opencl.pipe_rw_t global. It is expected that all usages are the calls to
    // __spirv_CreatePipeFromPipeStorage.
    //
    // This is not always the case, especially when IR is optimized, but we are
    // not going to handle all cases.
    //
    // If you see any of the following asserts firing, then the time to replace
    // this hack with a proper solution has finally come.
#ifndef NDEBUG
    std::function<bool(Value *, int)> ReplaceChecker = [&](Value *Value,
                                                           int Depth) {
      if (Depth == 0) {
        return false;
      }
      if (auto *CI = dyn_cast<CallInst>(Value)) {
        Function *F = CI->getCalledFunction();
        assert(F && "Indirect call is not expected");
        assert(F->getName().find(CreatePipeFromPipeStorageWriteName) !=
                   StringRef::npos ||
               F->getName().find(CreatePipeFromPipeStorageReadName) !=
                   StringRef::npos);
        return true;
      }
      for (auto *U : Value->users()) {
        if (!ReplaceChecker(U, Depth - 1)) {
          return false;
        }
      }
      return true;
    };
    assert(ReplaceChecker(StorageVar, 5) &&
           "The usage of pipe storage is not expected");
#endif

    Constant *Bitcast =
        ConstantExpr::getBitCast(OCLPipeGV, StorageVar->getType());
    LLVM_DEBUG(dbgs() << "Replacing pipe storage pointer (" << *StorageVar
                      << ") with read-write pipe (" << *Bitcast << "\n");
    StorageVar->replaceAllUsesWith(Bitcast);
  }
}

using StreamingBeatStructInfoTy =
    std::pair</*sizeof(_dataT) in bits*/ unsigned, /*use_Empty*/ bool>;
using StreamingBeatStructInfoMapTy =
    SmallDenseMap<Value *, StreamingBeatStructInfoTy>;

// Collect the "sizeof(_dataT) in bits" and "use_Empty" info for all
// StreamingBeat struct memory defining instructions. For example:
// clang-format off
//   define void @kernel() {
//     %alloca = alloca %"struct.StreamingBeat"
//     %alloca.ascast = addrspacecast ptr %alloca to ptr addrspace(4)
//     call void @foo(ptr addrspace(4) %alloca.ascast)
//   }
//   define void @foo(ptr addrspace(4) %x) {
//     %data = getelementptr %"struct.StreamingBeat", ptraddrspace(4)  %x, ..., !spirv.Decorations !{!{i32 ..., !"{data}"}}
//     ... = call ptr @llvm.ptr.annotation.*(ptr %data, ...)
//     %use_empty = getelementptr %"struct.StreamingBeat", ptr addrspace(4) %x, ..., !spirv.Decorations !{!{i32 ..., !"{sideband:empty}"}}
//     ... = call ptr @llvm.ptr.annotation.*(ptr %use_empty, ...)
//   }
// clang-format on
//
// We can analyze the @llvm.ptr.annotation calls in @foo, to get the data size
// and use_empty info for @foo's argument %x. We further traverse the CallGraph
// to figure out that %alloca.ascast is the memory definition for this
// StreamingBeat struct.
//
// Finally, we store the (%alloca.ascast) --> {data_size, use_empty} relation in
// the map.
static void collectStreamingBeatStructInfo(
    Module &M, StreamingBeatStructInfoMapTy &StreamingBeatStructInfoMap,
    function_ref<MemorySSA &(Function &F)> GetMemorySSA) {
  for (auto &F : M) {
    // Find @llvm.ptr.annotation intrinsic
    if (!F.isIntrinsic() || F.getIntrinsicID() != Intrinsic::ptr_annotation)
      continue;
    // Match pattern:
    // clang-format off
    // %data = getelementptr %"struct.StreamingBeat", ptr %p, ..., !spirv.Decorations !{!{i32 ..., !"{data}"}}
    // ... = call ptr @llvm.ptr.annotation.*(ptr %data, ...)
    // clang-format on
    for (auto *U : F.users()) {
      auto *CI = dyn_cast<CallInst>(U);
      if (!CI)
        continue;
      auto *GEP = dyn_cast<GetElementPtrInst>(CI->getArgOperand(0));
      if (!GEP)
        continue;
      // Check struct name
      auto *StructTy = dyn_cast<StructType>(GEP->getSourceElementType());
      // TODO: Check the name which contains "StreamingBeat". We can check
      // the full name including namespace later once StreamingBeat becomes
      // offical feature. Currently it's an experimental feature.
      if (!StructTy || !StructTy->getName().contains("StreamingBeat"))
        continue;
      if (auto Annotation = getUserAnnotationStr(GEP)) {
        Value *StructPtr = GEP->getOperand(0);
        SmallPtrSet<Instruction *, 4> InstDefs;
        findMemoryDefsOverCallGraph(StructPtr, InstDefs, GetMemorySSA);
        auto &DL = M.getDataLayout();
        unsigned DataBitSize =
            DL.getTypeSizeInBits(StructTy->getElementType(0));

        for (auto *I : InstDefs) {
          // StreamingBeat struct is instantiated with `use_Empty = true` if and
          // only if there exists a field annotated with "{sideband:empty}".
          if (*Annotation == "{sideband:empty}") {
            // we should set use_empty=true no matter whether `I` is in the map
            // or not.
            StreamingBeatStructInfoMap[I] = {DataBitSize, true};
          } else if (!StreamingBeatStructInfoMap.contains(I)) {
            // only set use_empty=false when `I` is not in the map.
            // Otherwise, we may overwrite the previous "use_empty=true" setting
            // in the "if" branch
            StreamingBeatStructInfoMap[I] = {DataBitSize, false};
          }
        }
      }
    }
  }
}

static void
checkPipeBitsPerSymbol(Module &M,
                       StreamingBeatStructInfoMapTy &StreamingBeatStructInfoMap,
                       function_ref<MemorySSA &(Function &F)> GetMemorySSA) {
  // Collect FPGA pipe read/write call insts.
  SmallVector<CallInst *, 4> FPGAPipeReadWriteCIs;
  for (auto &F : M) {
    if (!F.isDeclaration())
      continue;

    PipeKind Kind = getPipeKind(F.getName());
    if (!Kind || !Kind.FPGA || Kind.Op != PipeKind::OpKind::ReadWrite)
      continue;

    for (auto *U : F.users())
      if (auto *CI = dyn_cast<CallInst>(U))
        FPGAPipeReadWriteCIs.push_back(CI);
  }

  for (auto *CI : FPGAPipeReadWriteCIs) {
    auto *Pipe = CI->getArgOperand(0);
    auto *Data = CI->getArgOperand(1);

    SmallPtrSet<Instruction *, 4> PipeDefs;
    SmallPtrSet<Instruction *, 4> DataDefs;
    findMemoryDefsOverCallGraph(Pipe, PipeDefs, GetMemorySSA);
    findMemoryDefsOverCallGraph(Data, DataDefs, GetMemorySSA);

    for (auto *DataDef : DataDefs) {
      auto It = StreamingBeatStructInfoMap.find(DataDef);
      for (auto *PipeDef : PipeDefs) {
        auto *CreatePipeStorageCall = cast<CallInst>(PipeDef);
        assert(
            CreatePipeStorageCall->getCalledFunction()->getName().starts_with(
                CreatePipeFromPipeStorageReadName) ||
            CreatePipeStorageCall->getCalledFunction()->getName().starts_with(
                CreatePipeFromPipeStorageWriteName));
        auto *StorageGV = cast<GlobalVariable>(
            CreatePipeStorageCall->getArgOperand(0)->stripPointerCasts());
        auto *Initializer = cast<ConstantStruct>(StorageGV->getInitializer());

        std::string PipeClassID =
            tryParseSYCLPipeReadableName(StorageGV->getName());
        // This means the pipe is not a
        // sycl::_V1::ext::intel::experimental::pipe. We will not hadle it.
        if (PipeClassID.empty())
          continue;

        unsigned BitsPerSymbol =
            cast<ConstantInt>(
                Initializer->getOperand(
                    SYCLInterface::ConstantPipeStorageStructField::
                        BitsPerSymbol))
                ->getZExtValue();

        unsigned DataBitSize = 0;
        if (It != StreamingBeatStructInfoMap.end()) {
          DataBitSize = It->second.first;
          // Checks whether read/write pipe data is a StreamingBeat struct whose
          // use_Empty = false.
          bool StreamingBeatUseEmpty = It->second.second;
          if (DataBitSize > BitsPerSymbol && !StreamingBeatUseEmpty) {

            std::string ErrMsg =
                "The data type carried by " + PipeClassID +
                " exceeds the bits per symbol. You can either enable the "
                "sideband signal 'use empty' or increase the bits per "
                "symbol.";
            M.getContext().diagnose(OptimizationErrorDiagInfo(ErrMsg));
          }
        } else {
          DataBitSize =
              cast<ConstantInt>(
                  Initializer->getOperand(
                      SYCLInterface::ConstantPipeStorageStructField::Size))
                  ->getZExtValue() *
              8;
        }
        // Width of data type must be multiple of bits_per_symbol
        if (DataBitSize % BitsPerSymbol != 0) {
          std::string ErrMsg = "The width of the data type carried by " +
                               PipeClassID +
                               " must be a multiple of bits per symbol.";
          M.getContext().diagnose(OptimizationErrorDiagInfo(ErrMsg));
        }
      }
    }
  }
}

// clang-format off
// https://www.intel.com/content/www/us/en/docs/oneapi-fpga-add-on/optimization-guide/2023-2/host-pipes-rtl-interfaces.html
//
// FPGA Add-on header provides `StreamingBeat` struct that could be used as pipe data type:
//
//   template <class _dataT, bool uses_packets, bool use_Empty> struct StreamingBeat;
//
// Example use:
//
//   namespace intelexp = sycl::ext::intel::experimental;
//   namespace oneapiexp = sycl::ext::oneapi::experimental;
//
//   #define BITSPERSYMBOL 16
//   #define USE_EMPTY true
//
//   using pipe_properties = decltype(oneapiexp::properties(
//     intelexp::bits_per_symbol<BITSPERSYMBOL>));
//
//   using Packet  = intelexp::StreamingBeat<int32_t, true, USE_EMPTY>;
//   using D2HPipe = intelexp::pipe<class D2HPipeID, Packet, 1, pipe_properties>;
//
// clang-format on
//
// According to the Host Pipes RTL Interfaces document, users must set
// use_Empty for all packet interfaces that carry more than one symbol of data
// that have a variable length packet format.
//
// In other words, if `sizeof(_dataT)` for `StreamingBeat` is greater than the
// `bits_per_symbol` value defined in `pipe_properties`, then `use_Empty` must
// be `true`. Otherwise, the compiler should issue a compilation error.
//
// Another check for all Host Pipes is that the `sizeof(_dataT)` should be a
// multiple of `bits_per_symbol` value.
//
// Implementation:
// Step 1: Find all pointers of StreamingBeat struct, collect sizeof(_dataT) and
//         use_Empty info.
// Step 2: Build StreamingBeat struct pointer <-> pipe relation map according to
//         read/write pipe builtins.
// Step 3: Extract bits_per_symbol info from pipe global constant storage and
//         perform legality check if the carried data is StreamingBeat
//         structure.
// Step 4: Compare carried data size with `bits_per_symbol` value.
//
static void validateSYCLPipeDataSizeLegality(
    Module &M, function_ref<MemorySSA &(Function &F)> GetMemorySSA) {
  StreamingBeatStructInfoMapTy StreamingBeatStructInfoMap;
  collectStreamingBeatStructInfo(M, StreamingBeatStructInfoMap, GetMemorySSA);

  checkPipeBitsPerSymbol(M, StreamingBeatStructInfoMap, GetMemorySSA);
}

PreservedAnalyses SYCLRewritePipesPass::run(Module &M,
                                            ModuleAnalysisManager &AM) {
  auto &BLI = AM.getResult<BuiltinLibInfoAnalysis>(M);
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  auto GetMemorySSA = [&](Function &F) -> MemorySSA & {
    return FAM.getResult<MemorySSAAnalysis>(F).getMSSA();
  };
  SmallVector<Function *, 2> CreatePipeFuncs;
  collectCreatePipeFuncs(M, CreatePipeFuncs);
  if (CreatePipeFuncs.empty())
    return PreservedAnalyses::all();
  ;
  // FIXME: this workaround should be removed when llvm-spirv can translate the
  // name correctly.
  fixCreatePipeFuncName(M, CreatePipeFuncs);

  SmallVector<GlobalVariable *, 2> StorageVars;
  collectSYCLPipeStorageGlobals(CreatePipeFuncs, StorageVars);
  validateSYCLPipeDataSizeLegality(M, GetMemorySSA);
  rewritePipeStorageVars(M, StorageVars, BLI.getRuntimeService());

  return PreservedAnalyses::none();
}
