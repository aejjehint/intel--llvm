//===- SYCLEqualizer.cpp - DPC++ kernel equalizer --------------------===//
//
// Copyright (C) 2021 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/SYCLTransforms/SYCLEqualizer.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/IteratedDominanceFrontier.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/SYCLTransforms/BuiltinLibInfoAnalysis.h"
#include "llvm/Transforms/SYCLTransforms/Utils/CompilationUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/LoopUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/MetadataAPI.h"
#include "llvm/Transforms/SYCLTransforms/Utils/NameMangleAPI.h"

using namespace llvm;
using namespace llvm::CompilationUtils;
using namespace SYCLKernelMetadataAPI;

#define DEBUG_TYPE "sycl-kernel-equalizer"

static cl::opt<bool>
    RemoveFPGAReg("sycl-remove-fpga-reg", cl::init(false), cl::Hidden,
                  cl::desc("Remove __builtin_fpga_reg built-in calls."));

static cl::opt<bool>
    DemangleFPGAPipes("sycl-demangle-fpga-pipes", cl::init(false), cl::Hidden,
                      cl::desc("Remove custom mangling from pipe built-ins"));

static const SmallVector<StringRef, 6> AllWorkGroupSortBuiltinBasicNames = {
    "__devicelib_default_work_group_joint_sort_ascending_",
    "__devicelib_default_work_group_joint_sort_descending_",
    "__devicelib_default_work_group_private_sort_close_ascending_",
    "__devicelib_default_work_group_private_sort_close_descending_",
    "__devicelib_default_work_group_private_sort_spread_ascending_",
    "__devicelib_default_work_group_private_sort_spread_descending_"};

static const SmallVector<StringRef, 2> AllSubGroupSortBuiltinBasicNames = {
    "__devicelib_default_sub_group_private_sort_ascending_",
    "__devicelib_default_sub_group_private_sort_descending_"};

namespace {

/// Base class for all functors, which supports immutability query.
class AbstractFunctor {
protected:
  bool IsChanged;

public:
  AbstractFunctor() : IsChanged(false) {}

  virtual ~AbstractFunctor() {}

  bool isChanged() const { return IsChanged; }
};

class FunctionFunctor : public AbstractFunctor {
public:
  virtual void operator()(Function &) = 0;
};

class BlockFunctor : public AbstractFunctor {
public:
  virtual void operator()(BasicBlock &) = 0;
};

// Basic block functors, to be applied on each block in the module.
class MaterializeBlockFunctor : public BlockFunctor {
public:
  MaterializeBlockFunctor(ArrayRef<Module *> BuiltinModules,
                          SmallPtrSetImpl<Function *> &FuncDeclToRemove)
      : BuiltinModules(BuiltinModules), FuncDeclToRemove(FuncDeclToRemove) {}

  void operator()(BasicBlock &BB) override {
    SmallVector<Instruction *, 4> InstToRemove;

    for (auto &I : BB) {
      if (CallInst *CI = dyn_cast<CallInst>(&I)) {
        IsChanged |= changeCallingConv(CI);

        if (RemoveFPGAReg)
          IsChanged |= removeFPGARegInst(CI, InstToRemove, FuncDeclToRemove);

        if (DemangleFPGAPipes)
          IsChanged |=
              demangleFPGAPipeBICall(CI, InstToRemove, FuncDeclToRemove);

        IsChanged |= handleSortBuiltins(CI, InstToRemove, FuncDeclToRemove);
      }
    }

    // Remove unused instructions.
    for (auto *I : InstToRemove)
      I->eraseFromParent();
  }

private:
  bool changeCallingConv(CallInst *CI) {
    if ((CallingConv::SPIR_FUNC == CI->getCallingConv()) ||
        (CallingConv::SPIR_KERNEL == CI->getCallingConv())) {
      CI->setCallingConv(CallingConv::C);
      return true;
    }

    return false;
  }

  bool demangleFPGAPipeBICall(CallInst *CI,
                              SmallVectorImpl<Instruction *> &InstToRemove,
                              SmallPtrSetImpl<Function *> &FuncDeclToRemove) {
    auto *F = CI->getCalledFunction();
    if (!F)
      return false;

    StringRef FName = F->getName();
    bool PipeBI = StringSwitch<bool>(FName)
                      .Case("__read_pipe_2", true)
                      .Case("__write_pipe_2", true)
                      .Case("__read_pipe_2_bl", true)
                      .Case("__write_pipe_2_bl", true)
                      .Case("__read_pipe_2_AS0", true)
                      .Case("__read_pipe_2_AS1", true)
                      .Case("__read_pipe_2_AS3", true)
                      .Case("__read_pipe_2_bl_AS0", true)
                      .Case("__read_pipe_2_bl_AS1", true)
                      .Case("__read_pipe_2_bl_AS3", true)
                      .Case("__write_pipe_2_AS0", true)
                      .Case("__write_pipe_2_AS1", true)
                      .Case("__write_pipe_2_AS2", true)
                      .Case("__write_pipe_2_AS3", true)
                      .Case("__write_pipe_2_bl_AS0", true)
                      .Case("__write_pipe_2_bl_AS1", true)
                      .Case("__write_pipe_2_bl_AS2", true)
                      .Case("__write_pipe_2_bl_AS3", true)
                      .Default(false);

    if (!PipeBI)
      return false;

    Module *PipesModule = nullptr;
    for (auto *M : BuiltinModules) {
      if (StructType::getTypeByName(M->getContext(), "struct.__pipe_t")) {
        PipesModule = M;
        break;
      }
    }
    assert(PipesModule && "Module containing pipe built-ins not found");

    assert(CI->arg_size() == 4 && "Unexpected number of arguments");
    SmallVector<Value *, 4> NewArgs;
    NewArgs.push_back(CI->getArgOperand(0));

    IRBuilder<> Builder(CI);

    if (FName.contains("_AS")) {
      FName = FName.drop_back(4);
      auto *Int8Ty = IntegerType::getInt8Ty(PipesModule->getContext());
      // We need to do a cast from global/local/private address spaces to
      // generic due to in backend we have pipe built-ins only with generic
      // address space.
      auto *I8PTy = PointerType::get(Int8Ty, ADDRESS_SPACE_GENERIC);
      auto *ResArg = Builder.CreatePointerBitCastOrAddrSpaceCast(
          CI->getArgOperand(1), I8PTy);
      NewArgs.push_back(ResArg);
    } else {
      // Copy packet argument as-is.
      NewArgs.push_back(CI->getArgOperand(1));
    }

    // Copy rest arguments.
    for (size_t I = 2; I < CI->arg_size(); ++I)
      NewArgs.push_back(CI->getArgOperand(I));

    // Add _fpga suffix to pipe built-ins.
    PipeKind Kind = getPipeKind(FName.str());
    Kind.FPGA = true;
    auto NewFName = getPipeName(Kind);

    Module *M = CI->getModule();
    Function *NewF = M->getFunction(NewFName);
    if (!NewF) {
      if (Kind.Blocking) {
        // Blocking built-ins are not declared in RTL, they are resolved in
        // PipeSupport instead.
        PipeKind NonBlockingKind = Kind;
        NonBlockingKind.Blocking = false;

        // Blocking built-ins differ from non-blocking only by name, so we
        // import a non-blocking function to get a declaration ...
        NewF = importFunctionDecl(
            M, PipesModule->getFunction(getPipeName(NonBlockingKind)),
            /*DuplicateIfExists*/ true);
        NewF->setName(getPipeName(Kind));
      } else {
        NewF = importFunctionDecl(M, PipesModule->getFunction(NewFName));
      }
    }

    for (size_t Idx = 0; Idx < NewArgs.size(); ++Idx) {
      if (auto *PTy = dyn_cast<PointerType>(NewArgs[Idx]->getType())) {
        auto *FArgTy = NewF->getArg(Idx)->getType();
        if (PTy->getAddressSpace() != FArgTy->getPointerAddressSpace())
          NewArgs[Idx] = Builder.CreateAddrSpaceCast(NewArgs[Idx], FArgTy);
      }
    }

    // With materialization of fpga pipe built-in calls, we import new
    // declarations for them, leaving old declarations unused. Add these unused
    // declarations with avoiding of duplications to the list of functions to
    // remove.
    FuncDeclToRemove.insert(F);

    auto *NewCI = Builder.CreateCall(NewF, NewArgs);
    NewCI->setCallingConv(CI->getCallingConv());
    NewCI->setAttributes(CI->getAttributes());
    if (CI->isTailCall())
      NewCI->setTailCall();

    // Replace old call instruction with updated one.
    InstToRemove.push_back(CI);
    if (CI->getType()->isVoidTy()) {
      // SYCL blocking pipe built-ins unlike OpenCL have no return type, so
      // instead of replacing uses of the old instruction - just create a new
      // one.
      assert(Kind.Blocking && "Only blocking pipes can have void return type!");
      return true;
    }
    CI->replaceAllUsesWith(NewCI);

    return true;
  }

  bool removeFPGARegInst(CallInst *CI,
                         SmallVectorImpl<Instruction *> &InstToRemove,
                         SmallPtrSetImpl<Function *> &FuncDeclToRemove) {
    auto *F = CI->getCalledFunction();
    if (!F)
      return false;

    StringRef FName = F->getName();
    if (!FName.starts_with("llvm.fpga.reg"))
      return false;

    if (!FName.starts_with("llvm.fpga.reg.struct."))
      CI->replaceAllUsesWith(CI->getArgOperand(0));
    else {
      Value *Dst = CI->getArgOperand(0);
      Value *Src = CI->getArgOperand(1);
      Dst->replaceAllUsesWith(Src);
    }

    FuncDeclToRemove.insert(F);
    InstToRemove.push_back(CI);
    return true;
  }

  bool handleSortBuiltins(CallInst *CI,
                          SmallVectorImpl<Instruction *> &InstToRemove,
                          SmallPtrSetImpl<Function *> &FuncDeclToRemove) {
    Function *Func = CI->getCalledFunction();
    if (!Func)
      return false;
    StringRef FuncName = Func->getName();
    if (!isWorkGroupSort(FuncName) && !isSubGroupSort(FuncName))
      return false;

    // sort builtin always need be mangled
    std::string MangledFuncName = mangleSortBuiltinName(CI, FuncName);

    SmallVector<Type *> FuncArgTys;
    SmallVector<Value *> FuncArgValues;
    IRBuilder<> Builder(CI);
    // Get builtin params type
    // If pointer params is not generic, cast pointer to generic
    reflection::FunctionDescriptor SortFD =
        NameMangleAPI::demangle(MangledFuncName);
    unsigned Idx = 0;
    for (auto &Arg : CI->args()) {
      auto *PType = dyn_cast<PointerType>(Arg->getType());
      if (PType && PType->getPointerAddressSpace() !=
                       CompilationUtils::ADDRESS_SPACE_GENERIC) {
        // Get type and value for create or get new builtin function
        PointerType *NewType = PointerType::get(
            PType->getContext(), CompilationUtils::ADDRESS_SPACE_GENERIC);
        Value *NewOp =
            Builder.CreateAddrSpaceCast(Arg, NewType, Twine("cast.data"));
        FuncArgValues.push_back(NewOp);
        FuncArgTys.push_back(NewType);
        // Get params reflection type for remangle builtin
        reflection::PointerType *OldParam =
            dyn_cast<reflection::PointerType>(SortFD.Parameters[Idx].get());
        reflection::RefParamType NewParam = new reflection::PointerType(
            OldParam->getPointee(), {reflection::ATTR_GENERIC});
        SortFD.Parameters[Idx] = NewParam;
      } else {
        // No need to cast, just push_back
        reflection::ParamType *Param = SortFD.Parameters[Idx].get();
        FuncArgValues.push_back(Arg);
        FuncArgTys.push_back(Arg->getType());
        SortFD.Parameters[Idx] = Param;
      }
      ++Idx;
    }

    std::string NewFuncName = NameMangleAPI::mangle(SortFD);
    Type *Result = CI->getType();
    // get or create new functon
    Function *NewFunc = CI->getModule()->getFunction(NewFuncName);
    if (!NewFunc) {
      FunctionType *FuncTy = FunctionType::get(
          /*Result=*/Result,
          /*Params=*/FuncArgTys,
          /*isVarArg=*/false);
      assert(FuncTy && "Failed to create new function type");
      NewFunc = Function::Create(
          /*Type=*/FuncTy,
          /*Linkage=*/GlobalValue::ExternalLinkage,
          /*Name=*/NewFuncName, CI->getModule());
      assert(NewFunc && "Failed to create new function declaration");
      NewFunc->setCallingConv(CallingConv::C);
    }
    CallInst *NewCI = Builder.CreateCall(NewFunc, FuncArgValues, "");
    CI->replaceAllUsesWith(NewCI);
    FuncDeclToRemove.insert(Func);
    InstToRemove.push_back(CI);
    return true;
  }

  // Analyze sort builtin's suffix, to get mangled name
  std::string mangleSortBuiltinName(CallInst *CI, StringRef FuncName) {
    std::string BasicFuncName = FuncName.data();

    // Consume the basic name to get builtin's suffix
    // The suffix means params type
    // e.g.
    // "__devicelib_default_work_group_private_sort_close_ascending_p1i32_u32_p1i8"
    // Consume the basic name
    // "__devicelib_default_work_group_private_sort_close_ascending_"
    // get "p1i32_u32_p1i8"
    for (auto &Str : AllWorkGroupSortBuiltinBasicNames) {
      if (FuncName.consume_front(Str))
        break;
    }
    for (auto &Str : AllSubGroupSortBuiltinBasicNames) {
      if (FuncName.consume_front(Str))
        break;
    }

    // Use the suffix to generate the FunctionDescriptor's param types
    reflection::FunctionDescriptor NewFD;
    NewFD.Name = BasicFuncName;
    for (StringRef ArgStr : llvm::split(FuncName, "_")) {
      unsigned Idx = 0;
      StringRef ArgTypeStr;
      if (ArgStr.starts_with("p")) {
        // Pointer type
        assert(CI->getArgOperand(Idx)->getType()->isPointerTy() &&
               "Function args type do not match its name");
        ArgTypeStr = ArgStr.substr(2, ArgStr.size());
        // Get paramType for mangle
        reflection::TypePrimitiveEnum PointeeType =
            llvm::CompilationUtils::getPrimitiveTypeOfString(ArgTypeStr);
        reflection::RefParamType ParamTy(
            new reflection::PrimitiveType(PointeeType));
        reflection::PointerType *PType = new reflection::PointerType(
            ParamTy,
            {reflection::TypeAttributeEnum(
                CI->getArgOperand(Idx)->getType()->getPointerAddressSpace())});

        NewFD.Parameters.push_back(PType);
      } else {
        // Not pointer type, which is the size of sort and its type is uint
        ArgTypeStr = ArgStr;
        reflection::TypePrimitiveEnum PrimitiveType =
            llvm::CompilationUtils::getPrimitiveTypeOfString(ArgTypeStr);
        reflection::PrimitiveType *NumType =
            new reflection::PrimitiveType(PrimitiveType);
        NewFD.Parameters.push_back(NumType);
      }
      ++Idx;
    }
    return NameMangleAPI::mangle(NewFD);
  }

private:
  ArrayRef<Module *> BuiltinModules;
  SmallPtrSetImpl<Function *> &FuncDeclToRemove;
};

// Function functor, to be applied for every function in the module.
// Delegates call to basic-block functors.
class MaterializeFunctionFunctor : public FunctionFunctor {
public:
  MaterializeFunctionFunctor(ArrayRef<Module *> BuiltinModules,
                             SmallPtrSetImpl<Function *> &FuncDeclToRemove)
      : BuiltinModules(BuiltinModules), FuncDeclToRemove(FuncDeclToRemove) {}

  void operator()(Function &F) override {
    CallingConv::ID CConv = F.getCallingConv();
    if (CallingConv::SPIR_FUNC == CConv || CallingConv::SPIR_KERNEL == CConv) {
      F.setCallingConv(CallingConv::C);
      IsChanged = true;
    }
    MaterializeBlockFunctor BBMaterializer(BuiltinModules, FuncDeclToRemove);
    std::for_each(F.begin(), F.end(), BBMaterializer);
    IsChanged |= BBMaterializer.isChanged();
  }

private:
  ArrayRef<Module *> BuiltinModules;
  SmallPtrSetImpl<Function *> &FuncDeclToRemove;
};

} // namespace

// Set block-literal-size attribute for enqueued kernels.
static void setBlockLiteralSizeMetadata(Function &F) {
  SYCLKernelMetadataAPI::KernelInternalMetadataAPI KIMD(&F);
  // Find all enqueue_kernel and kernel query calls.
  for (const auto &EEF : *(F.getParent())) {
    if (!EEF.isDeclaration())
      continue;

    StringRef EEFName = EEF.getName();
    if (!(isEnqueueKernel(EEFName.str()) ||
          EEFName == "__get_kernel_work_group_size_impl" ||
          EEFName == "__get_kernel_preferred_work_group_size_multiple_impl"))
      continue;

    unsigned BlockInvokeIdx = (EEFName.starts_with("__enqueue_kernel_"))
                                  ? (EEFName.contains("_events") ? 6 : 3)
                                  : 0;
    unsigned BlockLiteralIdx = BlockInvokeIdx + 1;

    for (auto *U : EEF.users()) {
      auto *EECall = dyn_cast<CallInst>(U);
      if (!EECall)
        continue;
      Value *BlockInvoke =
          EECall->getArgOperand(BlockInvokeIdx)->stripPointerCasts();
      if (BlockInvoke != &F)
        continue;
      Value *BlockLiteral =
          EECall->getArgOperand(BlockLiteralIdx)->stripPointerCasts();
      int64_t BlockSize = 0;
      if (auto *BlockAlloca = dyn_cast<AllocaInst>(BlockLiteral)) {
        BlockSize = F.getParent()->getDataLayout().getTypeAllocSize(
            BlockAlloca->getAllocatedType());
      } else if (auto *BlockGlobal = dyn_cast<Constant>(BlockLiteral)) {
        auto *BlockGlobalConst = cast<Constant>(BlockGlobal->getOperand(0));
        auto *Size = cast<ConstantInt>(BlockGlobalConst->getOperand(0));
        BlockSize = Size->getZExtValue();
      } else {
        llvm_unreachable("Unexpected instruction");
      }

      KIMD.BlockLiteralSize.set(BlockSize);
      return;
    }
  }
}

// Find kernel and set external linkage.
static auto findKernels(Module &M) {
  assert(!M.getNamedMetadata("sycl.kernels") &&
         "Do not expect sycl.kernels Metadata");

  KernelList::KernelVectorTy Kernels;

  for (auto &F : M) {
    if (F.isDeclaration())
      continue;
    if (F.getCallingConv() != CallingConv::SPIR_KERNEL)
      continue;

    Kernels.push_back(&F);

    // OpenCL/SYCL/SPIR-V kernel could have internal linkage since spec doesn't
    // mandate kernel to have external linkage.
    F.setLinkage(GlobalValue::ExternalLinkage);

    if (F.getName().contains("_block_invoke_") &&
        F.getName().ends_with("_kernel")) {
      // Set block-literal-size attribute for enqueued kernels.
      setBlockLiteralSizeMetadata(F);
    }
  }

  return Kernels;
}

// Rename builtin functions that may alias to other functions.
// e.g. intel_sub_group_broadcast --> sub_group_broadcast
static bool renameAliasingBuiltins(Module &M,
                                   ArrayRef<BuiltinAliasItem> BuiltinAliases) {
  static std::unordered_map<std::string, std::string> TrivialMappings(
      BuiltinAliases.begin(), BuiltinAliases.end());

  // This is only for opt test: opt -passes=sycl-kernel-equalizer ...
  // In the scenario, SYCLEqualizerPass is called without loading the
  // file BulitinAliases.gen.
  // So, these tests need an additional option (-sycl-builtin-alias=) to specify
  // the file path of BulitinAliases.gen.
  if (BuiltinAliases.empty())
    CompilationUtils::initializeBuiltinAliases(TrivialMappings);

  bool Changed = false;
  for (auto &F : M) {
    // Parse function name with StringRef operations directly.
    // We don't use the demangle API intentionally as we don't need to know
    // type infos here.
    StringRef Name = F.getName();
    if (!Name.consume_front("_Z"))
      continue;
    unsigned EncodedLen = 0;
    if (Name.consumeInteger(10, EncodedLen))
      continue;
    StringRef RawName = Name.substr(0, EncodedLen);
    auto It = TrivialMappings.find(RawName.str());
    if (It == TrivialMappings.end())
      continue;

    LLVM_DEBUG(dbgs() << "Renaming function " << F.getName());
    const std::string &Replacement = It->second;
    F.setName(Twine("_Z") + Twine(Replacement.length()) + Twine(Replacement) +
              Name.substr(EncodedLen));
    LLVM_DEBUG(dbgs() << " as " << F.getName() << '\n');
    Changed = true;
  }

  return Changed;
}

// This is a workaround for VPlan.
// sub_group_inverse_ballot(uint4 value) has a uniform argument, and VPlan DA
// (DivergenceAnalysis) assumes the return value to be uniform as well, which
// is not true for sub_group_inverse_ballot semantics.
// So we replace `sub_group_inverse_ballot(value)` with
// `sub_group_ballot_bit_extract(value, get_sub_group_local_id())` as a
// workaround, until VPlan resolves the divergence analysis issue above.
static bool rewriteSGInverseBallot(Module &M) {
  bool Changed = false;
  auto *F = M.getFunction("_Z24sub_group_inverse_ballotDv4_j");
  if (!F)
    return Changed;

  auto *FuncType = F->getFunctionType();
  auto *NewFuncType = FunctionType::get(
      FuncType->getReturnType(),
      {FuncType->getParamType(0), FuncType->getReturnType()}, false);
  auto NewF = M.getOrInsertFunction("_Z28sub_group_ballot_bit_extractDv4_jj",
                                    NewFuncType);
  for (auto *U : make_early_inc_range(F->users())) {
    if (auto *CI = dyn_cast<CallInst>(U)) {
      auto *SGLID =
          CompilationUtils::createGetSubGroupLocalIdCall(CI, "sg.lid");
      IRBuilder<> Builder(CI);
      auto *NewCall = Builder.CreateCall(NewF, {CI->getArgOperand(0), SGLID});
      CI->replaceAllUsesWith(NewCall);
      CI->eraseFromParent();
      Changed = true;
    }
  }

  return Changed;
}

PreservedAnalyses SYCLEqualizerPass::run(Module &M, ModuleAnalysisManager &AM) {
  // Find kernel list in the module.
  auto Kernels = findKernels(M);

  // Set sycl.kernels metadata.
  SYCLKernelMetadataAPI::KernelList KernelList(M);
  KernelList.set(Kernels);

  auto BuiltinModules =
      AM.getResult<BuiltinLibInfoAnalysis>(M).getBuiltinModules();
  SmallPtrSet<Function *, 4> FuncDeclToRemove;
  MaterializeFunctionFunctor FuncMaterializer(BuiltinModules, FuncDeclToRemove);
  // Take care of calling conventions.
  std::for_each(M.begin(), M.end(), FuncMaterializer);
  // Remove unused declarations.
  for (auto *FDecl : FuncDeclToRemove)
    FDecl->eraseFromParent();
  std::ignore = FuncMaterializer.isChanged();

  std::ignore = rewriteSGInverseBallot(M);

  // Module is always changed.
  return PreservedAnalyses::none();
}
