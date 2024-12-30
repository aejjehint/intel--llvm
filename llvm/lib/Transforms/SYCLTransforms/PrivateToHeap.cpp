//== PrivateToHeap.cpp -- Map private buffer allocation to stack or heap ===//
//
// Copyright (C) 2024 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/SYCLTransforms/PrivateToHeap.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/SYCLTransforms/Utils/CompilationUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/ImplicitArgsUtils.h"
#include "llvm/Transforms/SYCLTransforms/Utils/TypeAlignment.h"
#include <algorithm>
#include <numeric>

using namespace llvm;

#define DEBUG_TYPE "sycl-kernel-private-to-heap"

static void
updatePrivateMemoryAllocation(Function *Func, Value *HeapMem, Value *HeapMemTLS,
                              const SmallVectorImpl<AllocaInst *> &AllocaInsts,
                              const SmallVectorImpl<CallInst *> &CallInsts,
                              IRBuilder<> &Builder, bool AllAllocaInEntry) {
  LLVMContext &C = Func->getContext();
  IntegerType *I8Ty = Type::getInt8Ty(C);
  const DataLayout DL = Func->getParent()->getDataLayout();
  IntegerType *SizetTy = IntegerType::get(C, DL.getPointerSizeInBits());

  Value *HeapCurrentOffset = ConstantInt::get(SizetTy, 0);
  Value *HeapMemOffsetStorage = nullptr;
  // If there's any dynamic alloca in non-entry block, we have to store/load
  // offset into/from a storage.
  if (!AllAllocaInEntry) {
    // Create an alloca to store the offset to the heap memory
    HeapMemOffsetStorage =
        Builder.CreateAlloca(SizetTy, nullptr, "HeapMemOffsetStorage");
    Builder.CreateStore(HeapCurrentOffset, HeapMemOffsetStorage);
  }

  // Compare HeapMem with Null
  Value *HeapMemNullCmp = Builder.CreateCmp(
      CmpInst::ICMP_EQ, HeapMem, Constant::getNullValue(HeapMem->getType()));

  // Update the allocation instruction
  for (auto *AllocaItem : make_early_inc_range(AllocaInsts)) {
    Builder.SetInsertPoint(AllocaItem);
    uint64_t AlignValue = AllocaItem->getAlign().value();
    std::optional<TypeSize> AllocaSize = AllocaItem->getAllocationSize(DL);
    Value *BufferSize = nullptr;
    if (!AllocaSize) {
      // Handle dynamic size buffer
      uint64_t TSize = DL.getTypeAllocSize(AllocaItem->getAllocatedType());
      Value *TSizeValue = ConstantInt::get(SizetTy, TSize);
      Value *Asize = Builder.CreateMul(TSizeValue, AllocaItem->getArraySize());
      BufferSize = CompilationUtils::updateValueWithAlignment(
          Asize, TypeAlignment::MAX_ALIGNMENT, Builder);
    } else {
      assert(AllocaItem->getParent() == &Func->getEntryBlock() &&
             "Large alloca should be hoisted into entry block");
      uint64_t ASize = AllocaItem->getAllocationSize(DL).value();
      uint64_t ASizeWithAlign = (ASize + TypeAlignment::MAX_ALIGNMENT - 1) &
                                (~(TypeAlignment::MAX_ALIGNMENT - 1));
      BufferSize = ConstantInt::get(SizetTy, ASizeWithAlign);
    }
    // Replace private mem allocation with heap
    if (HeapMemOffsetStorage)
      HeapCurrentOffset = Builder.CreateLoad(SizetTy, HeapMemOffsetStorage);
    Value *PrivateBuffer = CompilationUtils::allocaArrayForLocalPrivateBuffer(
        Builder, std::make_pair(HeapMem, HeapMemNullCmp), DL, BufferSize,
        AlignValue, HeapCurrentOffset);

    LLVM_DEBUG(CompilationUtils::insertPrintf(
        "PRIVATE BUFFER HEAP_MEMORY_POINTER == NULL : ", Builder,
        {HeapMemNullCmp}, {"CMP"}));

    // Update offset
    HeapCurrentOffset = Builder.CreateAdd(HeapCurrentOffset, BufferSize);
    if (HeapMemOffsetStorage) // store back if necessary
      Builder.CreateStore(HeapCurrentOffset, HeapMemOffsetStorage);

    AllocaItem->replaceAllUsesWith(PrivateBuffer);
    AllocaItem->eraseFromParent();
  }

  if (CallInsts.empty())
    return;

  Value *NewHeapMem = nullptr;
  // If all allocas are in the entry, we can generate GEP and SELECT sequence in
  // the entry and reuse them for all call sites. The dominance is guaranteed
  // because we already assured all call instructions are not in entry.
  if (AllAllocaInEntry) {
    // Create GEP and SELECT in the entry block
    Builder.SetInsertPoint(&Func->getEntryBlock().back());
    // HeapCurrentOffset is the final offset considering all the allocas to
    // handle.
    Value *HeapMemGep = Builder.CreateGEP(I8Ty, HeapMem, HeapCurrentOffset);
    NewHeapMem = Builder.CreateSelect(
        HeapMemNullCmp, Constant::getNullValue(HeapMem->getType()), HeapMemGep);

    // Store HeapMem + HeapOffset in TLS Global variable
    if (HeapMemTLS)
      Builder.CreateStore(NewHeapMem, HeapMemTLS);
  }

  for (auto *CI : CallInsts) {
    if (HeapMemOffsetStorage) {
      // There's some dynamic alloca in non-entry block, we have to load offset
      // from the storage before each call site, and then create the GEP and
      // SELECT sequence.
      assert(!AllAllocaInEntry &&
             "There should be allocas in non-entry in this case");
      Builder.SetInsertPoint(CI);
      HeapCurrentOffset = Builder.CreateLoad(SizetTy, HeapMemOffsetStorage);
      auto *HeapMemGep = Builder.CreateGEP(I8Ty, HeapMem, HeapCurrentOffset);
      NewHeapMem = Builder.CreateSelect(
          HeapMemNullCmp, Constant::getNullValue(HeapMem->getType()),
          HeapMemGep);
    }

    assert(NewHeapMem && "NewHeapMem is not created.");
    if (HeapMemTLS) {
      // If we didn't update TLS GV in the entry, we have to do it before each
      // CI.
      if (!AllAllocaInEntry)
        Builder.CreateStore(NewHeapMem, HeapMemTLS);
      // The callee may modify the HeapMemTLS content, recover it after the call
      Builder.SetInsertPoint(CI->getNextNode());
      Builder.CreateStore(NewHeapMem, HeapMemTLS);
    } else {
      // Replace the use of pPrivateHeapMem in CallInst
      CI->replaceUsesOfWith(HeapMem, NewHeapMem);
    }
  }
}

// If a kernel's private memory size exceeds the threshold, save the kernel to
// WorkList.
static void getKernelsToHandle(Module &M, size_t MaxPrivateMemSize,
                               SmallVectorImpl<Function *> &WorkList) {
  for (auto *Kernel : CompilationUtils::getKernels(M)) {
    auto KIMD = SYCLKernelMetadataAPI::KernelInternalMetadataAPI(Kernel);
    if (KIMD.NoBarrierPath.hasValue() && KIMD.NoBarrierPath.get() == true &&
        KIMD.PrivateMemorySize.hasValue() &&
        KIMD.PrivateMemorySize.get() > MaxPrivateMemSize) {
      WorkList.push_back(Kernel);
    }
  }
}

// An extreme case is that there are many small-size allocas used in a function
// but the total size still exceeds the threshold. Therefore, we need to sort
// alloca instruction by its size and record large-size alloca.
static MapVector<Function *, SmallVector<AllocaInst *>>
getAllocasToHandle(const DataLayout &DL, size_t MaxPrivateMemSize,
                   CallGraphNode *N) {
  // Collect all allocas of the kernel and functions called by the kernel.
  SmallVector<std::pair<AllocaInst *, uint64_t>> AllocaInstToSize;
  for (auto It = df_begin(N), E = df_end(N); It != E; ++It) {
    Function *F = It->getFunction();
    if (!F || F->isDeclaration())
      continue;
    for (auto &I : instructions(F)) {
      if (auto *AI = dyn_cast<AllocaInst>(&I)) {
        std::optional<TypeSize> AllocaSize = AI->getAllocationSize(DL);
        assert((!AllocaSize || !AllocaSize->isScalable()) &&
               "unexpected scalable vector");
        AllocaInstToSize.emplace_back(
            AI, AllocaSize ? AllocaSize.value() : CompilationUtils::VLAMaxSize);
      }
    }
  }

  // Sort allocas and exclude smaller-size allocas.
  SmallVector<size_t> Indices(AllocaInstToSize.size());
  std::iota(Indices.begin(), Indices.end(), 0);
  std::stable_sort(Indices.begin(), Indices.end(), [&](auto &A, auto &B) {
    return AllocaInstToSize[A].second > AllocaInstToSize[B].second;
  });

  auto Begin = Indices.rbegin();
  auto End = Indices.rend();
  uint64_t SizeSum = 0;
  for (; Begin != End; ++Begin) {
    uint64_t NewSum = SizeSum + AllocaInstToSize[*Begin].second;
    if (NewSum >= MaxPrivateMemSize)
      break;
    SizeSum = NewSum;
  }
  if (Begin == End) {
    // Above loop under-estimates private memory size.
    // Conservatively mark all allocas as to be handled.
    Begin = Indices.rbegin();
  }
  Indices.resize(std::distance(Begin, End));
  std::sort(Indices.begin(), Indices.end());

  // Save large-size alloca insts to map.
  MapVector<Function *, SmallVector<AllocaInst *>> FuncToAllocaInsts;
  for (auto Idx : Indices) {
    AllocaInst *AI = AllocaInstToSize[Idx].first;
    FuncToAllocaInsts[AI->getFunction()].push_back(AI);
  }

  return FuncToAllocaInsts;
}

static SmallVector<CallInst *> collectAndSplitCallInsts(Function *F,
                                                        bool HasTLSGlobals,
                                                        Value *&HeapMem,
                                                        Value *&HeapMemTLS) {
  SmallVector<CallInst *> CallInsts;
  if (HasTLSGlobals) {
    HeapMemTLS = CompilationUtils::getTLSGlobal(
        F->getParent(), ImplicitArgsUtils::IA_PRIVATE_MEM_HEAP);
    assert(HeapMemTLS && "TLS HeapMem is not found.");

    // find all callee functions which would use the TLS GV.
    for (auto &I : instructions(F)) {
      if (auto *CI = dyn_cast<CallInst>(&I)) {
        Function *Callee = CI->getCalledFunction();
        if (ImplicitArgsUtils::needImplicitArgs(Callee))
          CallInsts.push_back(CI);
      }
    }
  } else {
    CompilationUtils::getImplicitArgs(F, nullptr, nullptr, nullptr, nullptr,
                                      nullptr, nullptr, &HeapMem);
    assert(HeapMem && "HeapMem implicit arg is not found.");
    for (auto *U : HeapMem->users())
      if (auto *CI = dyn_cast<CallInst>(U))
        CallInsts.push_back(CI);
  }

  // Split basic block at call inst to make sure no call inst is in the
  // entry.
  for (auto *CI : CallInsts)
    if (CI->getParent() == &F->getEntryBlock())
      CI->getParent()->splitBasicBlock(CI);

  return CallInsts;
}

PreservedAnalyses PrivateToHeapPass::run(Module &M, ModuleAnalysisManager &AM) {
  SmallSetVector<unsigned, 8> ImplicitArgEnums;
  ImplicitArgsUtils::getImplicitArgEnums(ImplicitArgEnums, &M);
  if (!ImplicitArgEnums.contains(ImplicitArgsUtils::IA_PRIVATE_MEM_HEAP))
    return PreservedAnalyses::all();

  // Collect all kernels to handle in the module.
  size_t MaxPrivateMemorySize = ImplicitArgsUtils::getMaxPrivateMemorySize();
  SmallVector<Function *, 4> WorkList;
  getKernelsToHandle(M, MaxPrivateMemorySize, WorkList);
  if (WorkList.empty())
    return PreservedAnalyses::all();

  const DataLayout &DL = M.getDataLayout();
  bool HasTLSGlobals = CompilationUtils::hasTLSGlobals(M);
  CallGraph &CG = AM.getResult<CallGraphAnalysis>(M);

  for (auto *Kernel : WorkList) {
    // Collect all large-size alloca insts in the kernel call graph.
    CallGraphNode *N = CG[Kernel];
    MapVector<Function *, SmallVector<AllocaInst *>> FuncToAllocaInsts =
        getAllocasToHandle(DL, MaxPrivateMemorySize, N);

    // Handle each function and its large-size allocas.
    for (auto &[F, AllocaInsts] : FuncToAllocaInsts) {
      Value *HeapMem = nullptr;
      Value *HeapMemTLS = nullptr;

      // Collect all call instructions to handle.
      SmallVector<CallInst *> CallInsts =
          collectAndSplitCallInsts(F, HasTLSGlobals, HeapMem, HeapMemTLS);

      // Allocas that can be hoisted to the entry.
      SmallVector<AllocaInst *> AllocasToHoist;
      bool AllAllocaInEntry = true;
      for (auto *AI : AllocaInsts) {
        // alloca with a dynamic size cannot be safely hoisted
        std::optional<TypeSize> AllocaSize = AI->getAllocationSize(DL);
        if (!AllocaSize) {
          if (AI->getParent() != &F->getEntryBlock())
            AllAllocaInEntry = false;
        } else {
          // large alloca with a static size can be safely hoisted to the entry
          if (AI->getParent() != &F->getEntryBlock())
            AllocasToHoist.push_back(AI);
        }
      }

      for (auto *AI : AllocasToHoist)
        AI->moveBefore(&F->getEntryBlock().back());

      LLVM_DEBUG(dbgs() << "Allocas to handle in function " << F->getName()
                        << "\n");
      LLVM_DEBUG(for (auto *Item : AllocaInsts) {
        dbgs().indent(2) << *Item << "\n";
      });

      IRBuilder<> Builder(&F->getEntryBlock().front());

      // Create a load from TLS GV if needed.
      if (HeapMemTLS)
        HeapMem =
            Builder.CreateLoad(cast<GlobalVariable>(HeapMemTLS)->getValueType(),
                               HeapMemTLS, "pPrivateHeapMem");

      assert(HeapMem && "HeapMem should have been set");
      updatePrivateMemoryAllocation(F, HeapMem, HeapMemTLS, AllocaInsts,
                                    CallInsts, Builder, AllAllocaInEntry);

#ifndef NDEBUG
      // Verify the function after transformation
      if (verifyFunction(*F, &dbgs())) {
        LLVM_DEBUG(dbgs() << "Function after transformation: " << F->getName()
                          << "\n");
        LLVM_DEBUG(dbgs() << *F << "\n");
        report_fatal_error(
            "Function verification failed after transformation.");
      }
#endif // NDEBUG
    }
  }

  return PreservedAnalyses::none();
}
