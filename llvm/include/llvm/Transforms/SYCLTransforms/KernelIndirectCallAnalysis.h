//=== KernelIndirectCallAnalysis.h - Indirect call analysis -----*- C++ -*-===//
//
// Copyright (C) 2024 Intel Corporation
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
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SYCLTRANSFORMS_KERNEL_INDIRECT_CALL_ANALYSIS
#define LLVM_TRANSFORMS_SYCLTRANSFORMS_KERNEL_INDIRECT_CALL_ANALYSIS

#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/PassManager.h"

namespace llvm {
class CallBase;
class FunctionType;

/// IndirectCallInfo collects indirect calls and virtual functions.
/// For now, the mapping from indirect call to potential called functions isn't
/// accurate. The inaccurary won't cause stability issue in passes that uses
/// this info.
class IndirectCallInfo {
public:
  IndirectCallInfo(Module &M);

  /// Handle invalidation events in the new pass manager.
  bool invalidate(Module &M, const PreservedAnalyses &PA,
                  ModuleAnalysisManager::Invalidator &Inv);

  bool isIndirectlyCalledFunction(Function *F) const {
    return IndirectlyCalledFuncs.contains(F);
  }

  SmallPtrSetImpl<Function *> &getIndirectlyCalledFuncs() {
    return IndirectlyCalledFuncs;
  }

  SmallVector<CallBase *, 4> getIndirectCalls(Function *F);

  bool hasIndirectCallInFunc(const Function *F);

  void replaceIndirectCall(CallBase *CI, CallBase *NewCI);

  void replaceIndirectlyCalledFunc(Function *F, Function *NewF);

  void print(raw_ostream &OS, const Module *M) const;

private:
  SmallPtrSet<Function *, 8> IndirectlyCalledFuncs;
  DenseMap<FunctionType *, SetVector<CallBase *>> MapToIndirectCalls;
};

/// The purpose of this pass is to cache IndirectCallInfo which is used
/// by multiple passes.
class KernelIndirectCallAnalysis
    : public AnalysisInfoMixin<KernelIndirectCallAnalysis> {
  friend AnalysisInfoMixin<KernelIndirectCallAnalysis>;
  static AnalysisKey Key;

public:
  using Result = IndirectCallInfo;

  Result run(Module &M, ModuleAnalysisManager &AM);
};

class KernelIndirectCallAnalysisPrinter
    : public PassInfoMixin<KernelIndirectCallAnalysis> {
  raw_ostream &OS;

public:
  explicit KernelIndirectCallAnalysisPrinter(raw_ostream &OS) : OS(OS) {}
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};

} // namespace llvm

#endif // LLVM_TRANSFORMS_SYCLTRANSFORMS_KERNEL_INDIRECT_CALL_ANALYSIS
