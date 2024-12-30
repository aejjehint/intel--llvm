; RUN: opt -S -passes=sycl-kernel-handle-taskseq-async %s | FileCheck %s
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

declare i32 @_Z4multii()

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

declare i32 @_Z7newmultii()

define i32 @_Z15sum_of_productsiPiS_() #1 {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %call.i14 = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr @_Z4multii, i32 0, i32 0, i32 0, i32 0)
  %call.i17 = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr @_Z7newmultii, i32 0, i32 0, i32 0, i32 0)
  br label %for.body
}

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_() {
entry:
  %call.i.i = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr @_Z15sum_of_productsiPiS_, i32 0, i32 0, i32 0, i32 0)
  ret void
}

; Function Attrs: nounwind
declare ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr, i32, i32, i32, i32) local_unnamed_addr #1

; Function Attrs: nounwind
declare i32 @_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1)) local_unnamed_addr #2

; uselistorder directives
uselistorder ptr @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii, { 2, 1, 0 }

; CHECK: define internal ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr %0, i32 %1, i32 %2, i32 %3, i32 %4) local_unnamed_addr #0 {
; CHECK-NEXT:  %6 = ptrtoint ptr %0 to i64
; CHECK-NEXT:  %7 = icmp eq i64 %6, ptrtoint (ptr @_Z7newmultii to i64)
; CHECK-NEXT:  %8 = select i1 %7, i64 4, i64 4
; CHECK-NEXT:  %9 = icmp eq i64 %6, ptrtoint (ptr @_Z4multii to i64)
; CHECK-NEXT:  %10 = select i1 %9, i64 4, i64 %8
; CHECK-NEXT:  %11 = call ptr @__create_task_sequence(i64 %10, i32 %1, i32 %2, i32 %3, i32 %4)
; CHECK-NEXT:  %12 = addrspacecast ptr %11 to ptr addrspace(1)
; CHECK-NEXT:  ret ptr addrspace(1) %12

; CHECK: define internal i32 @_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1) %0) local_unnamed_addr #1 {
; CHECK-NEXT:  %2 = addrspacecast ptr addrspace(1) %0 to ptr addrspace(4)
; CHECK-NEXT:  %3 = call ptr addrspace(4) @__get(ptr addrspace(4) %2)
; CHECK-NEXT:  %4 = addrspacecast ptr addrspace(4) %3 to ptr
; CHECK-NEXT:  %5 = load i32, ptr %4, align

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #1 = { "prefer-vector-width"="512" }
attributes #2 = { nounwind "prefer-vector-width"="512" }
