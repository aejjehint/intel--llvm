//===- KernelIndirectCallAnalysis.cpp - Indirect call analysis -------===//
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

#include "llvm/Transforms/SYCLTransforms/KernelIndirectCallAnalysis.h"
#include "llvm/Analysis/IndirectCallVisitor.h"

#define DEBUG_TYPE "sycl-kernel-indirect-call-analysis"

using namespace llvm;

IndirectCallInfo::IndirectCallInfo(Module &M) {
  for (auto &F : M) {
    if (!F.isDeclaration())
      for (auto *Call : findIndirectCalls(F))
        MapToIndirectCalls[Call->getFunctionType()].insert(Call);
    if (F.hasFnAttribute("referenced-indirectly") ||
        F.hasFnAttribute("indirectly-callable") ||
        F.hasAddressTaken(/*User*/ nullptr, /*IgnoreCallbackUses*/ false,
                          /*IgnoreAssumeLikeCalls*/ true,
                          /*IngoreLLVMUsed*/ true,
                          /*IgnoreARCAttachedCall*/ false,
                          /*IgnoreCastedDirectCall*/ true))
      IndirectlyCalledFuncs.insert(&F);
  }

  // __intel_indirect_call calls and mapping from functions with
  // "vector_function_ptrs" attribute to __intel_indirect_call calls are not
  // collected yet. We may need to collect them in the future. Currently
  // patchNotInlinedTIDUserFunc has special handling of the calls.
}

SmallVector<CallBase *, 4> IndirectCallInfo::getIndirectCalls(Function *F) {
  SmallVector<CallBase *, 4> Calls{};
  if (auto It = MapToIndirectCalls.find(F->getFunctionType());
      It != MapToIndirectCalls.end()) {
    for (auto *CB : It->second) {
      // In-memory attribute should match.
      bool InMemoryAttrMatch =
          (CB->hasStructRetAttr() == F->hasStructRetAttr()) &&
          llvm::all_of(F->args(), [&](auto &Arg) {
            unsigned ArgNo = Arg.getArgNo();
            return CB->isPassPointeeByValueArgument(ArgNo) ==
                       Arg.hasPassPointeeByValueCopyAttr() &&
                   CB->getParamByRefType(ArgNo) == F->getParamByRefType(ArgNo);
          });
      if (InMemoryAttrMatch)
        Calls.push_back(CB);
    }
  }
  return Calls;
}

bool IndirectCallInfo::hasIndirectCallInFunc(const Function *F) {
  for (const auto &[_, Calls] : MapToIndirectCalls)
    for (const auto *Call : Calls)
      if (Call->getFunction() == F)
        return true;

  return false;
}

void IndirectCallInfo::replaceIndirectCall(CallBase *CI, CallBase *NewCI) {
  auto *FuncType = CI->getFunctionType();
  [[maybe_unused]] bool Res = MapToIndirectCalls[FuncType].remove(CI);
  assert(Res && "Failed to erase old CI from MapToIndirectCalls");
  if (MapToIndirectCalls[FuncType].empty())
    MapToIndirectCalls.erase(FuncType);
  MapToIndirectCalls[NewCI->getFunctionType()].insert(NewCI);
}

void IndirectCallInfo::replaceIndirectlyCalledFunc(Function *F,
                                                   Function *NewF) {
  [[maybe_unused]] bool Res = IndirectlyCalledFuncs.erase(F);
  assert(Res && "Failed to erase old indirectly called function");
  IndirectlyCalledFuncs.insert(NewF);
}

void IndirectCallInfo::print(raw_ostream &OS, const Module *) const {
  OS << "Indirect calls:\n";
  for (const auto &[FuncType, Calls] : MapToIndirectCalls) {
    OS.indent(2) << "FunctionType: " << *FuncType << "\n";
    for (auto *CI : Calls)
      OS.indent(4) << "Indirect call: " << *CI << "\n";
  }
  OS << "Indirectly called functions:\n";
  for (auto *F : IndirectlyCalledFuncs)
    OS.indent(2) << F->getName() << "\n";
}

bool IndirectCallInfo::invalidate(Module &, const PreservedAnalyses &PA,
                                  ModuleAnalysisManager::Invalidator &) {
  // Check whether the analysis has been explicitly invalidated. Otherwise, it's
  // stateless and remains preserved.
  auto PAC = PA.getChecker<KernelIndirectCallAnalysis>();
  return !PAC.preservedWhenStateless();
}

AnalysisKey KernelIndirectCallAnalysis::Key;

IndirectCallInfo KernelIndirectCallAnalysis::run(Module &M,
                                                 ModuleAnalysisManager &) {
  IndirectCallInfo BLInfo(M);
  return BLInfo;
}

PreservedAnalyses
KernelIndirectCallAnalysisPrinter::run(Module &M, ModuleAnalysisManager &MAM) {
  MAM.getResult<KernelIndirectCallAnalysis>(M).print(OS, &M);
  return PreservedAnalyses::all();
}
