//=- ResolveSubGroupWICall.h - Resolve DPC++ kernel subgroup work-item call -=//
//
// Copyright (C) 2021 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SYCLTRANSFORMS_RESOLVE_SUBGROUP_WI_CALL_H
#define LLVM_TRANSFORMS_SYCLTRANSFORMS_RESOLVE_SUBGROUP_WI_CALL_H

#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/PassManager.h"

namespace llvm {

class BuiltinLibInfo;
class RuntimeService;

class ResolveSubGroupWICallPass
    : public PassInfoMixin<ResolveSubGroupWICallPass> {
public:
  ResolveSubGroupWICallPass(bool ResolveSGBarrier = true);

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

  // Glue for old PM.
  bool runImpl(Module &M, BuiltinLibInfo *BLI);

  static bool isRequired() { return true; }

private:
  Value *replaceGetSubGroupSize(Instruction *insertBefore, Value *VF,
                                int32_t VD);
  Value *replaceGetMaxSubGroupSize(Instruction *insertBefore, Value *VF,
                                   int32_t VD);

  Value *replaceGetEnqueuedNumSubGroups(Instruction *insertBefore, Value *VF,
                                        int32_t VD);
  Value *replaceGetNumSubGroups(Instruction *insertBefore, Value *VF,
                                int32_t VD);
  Value *replaceSubGroupBarrier(Instruction *insertBefore, Value *VF,
                                int32_t VD);

  Value *replaceGetSubGroupId(Instruction *insertBefore, Value *VF, int32_t VD);
  
  ConstantInt *createVFConstant(LLVMContext &, const DataLayout &, size_t VF);
  // This pass will run twice, the first time is after vectorizer and before
  // WGLoopCreater / Barrier, all sub-group WI built-ins except sub_group
  // barrier will be resolved. The second time is after sub-group emulation
  // passes, all sub-group barriers and get_sub_group_size introduced by
  // emulation passes will be resolved. The flag is used to control whether
  // sub-group barrier should be resolved. We cannot resolve sub-group barriers
  // at the first time, since sub-group barriers in kernels to be emulated
  // must be visible to emulation passes.
  bool ResolveSGBarrier;

  RuntimeService *RTS = nullptr;

  SmallVector<Instruction *, 8> ExtraInstToRemove;
};
} // namespace llvm

#endif
