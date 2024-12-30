//===-- CoerceWin64Types.h - Coerce types to ensure win64 ABI compliance --===//
//
// Copyright (C) 2021 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SYCLTRANSFORMS_COERCE_WIN64_TYPES_H
#define LLVM_TRANSFORMS_SYCLTRANSFORMS_COERCE_WIN64_TYPES_H

#include "llvm/IR/PassManager.h"
#include "llvm/Transforms/SYCLTransforms/CoerceTypes.h"

namespace llvm {

class CoerceTypesWin64Impl : public CoerceTypesImpl {
protected:
  bool runOnFunction(Function *F) override;
};

class CoerceWin64TypesPass : public PassInfoMixin<CoerceWin64TypesPass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
};
} // namespace llvm

#endif
