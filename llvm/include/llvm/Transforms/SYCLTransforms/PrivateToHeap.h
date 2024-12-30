//=== PrivateToHeap.h -- Map private buffer allocation to stack or heap ===//
//
// Copyright (C) 2024 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SYCLTRANSFORMS_PRIVATE_TO_HEAP_H
#define LLVM_TRANSFORMS_SYCLTRANSFORMS_PRIVATE_TO_HEAP_H

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/PassManager.h"

namespace llvm {

// This pass will update the private buffer allocation instructions, to
// map them to stack or heap. It will not handle barrier special buffer.
class PrivateToHeapPass : public PassInfoMixin<PrivateToHeapPass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

  static bool isRequired() { return true; }
};

} // namespace llvm

#endif // LLVM_TRANSFORMS_SYCLTRANSFORMS_PRIVATE_TO_HEAP_H
