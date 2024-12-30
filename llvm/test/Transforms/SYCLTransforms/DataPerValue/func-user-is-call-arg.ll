; RUN: opt -disable-output 2>&1 -passes='print<sycl-kernel-data-per-value-analysis>' -S < %s | FileCheck %s

; Check the pass doesn't crash when a function's user is CallInst argument.

; CHECK:      Group-B.2 Values
; CHECK-NEXT: +_ZTS14ConcurrentLoop
; CHECK-NEXT:         -call.i4.i

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define internal double @_Z6task_bIN4sycl3_V13ext5intel12experimental4pipeI1pdLi0ENS2_6oneapi12experimental10propertiesISt5tupleIJEEEEvEEEddi(double %b, i32 %precision) {
entry:
  call void @dummy_barrier.()
  br label %exit

exit:                                             ; preds = %entry
  tail call void @_Z18work_group_barrierj(i32 1)
  ret double 0.000000e+00
}

define void @_ZTS14ConcurrentLoop() !no_barrier_path !2 {
entry:
  call void @dummy_barrier.()
  %call.i4.i = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPdiiii(ptr nonnull @_Z6task_bIN4sycl3_V13ext5intel12experimental4pipeI1pdLi0ENS2_6oneapi12experimental10propertiesISt5tupleIJEEEEvEEEddi)
  br label %Split.Barrier.BB36

Split.Barrier.BB36:                               ; preds = %entry
  call void @dummy_barrier.()
  tail call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELdi(ptr addrspace(1) %call.i4.i, ptr nonnull @_Z6task_bIN4sycl3_V13ext5intel12experimental4pipeI1pdLi0ENS2_6oneapi12experimental10propertiesISt5tupleIJEEEEvEEEddi, double 0.000000e+00, i32 20)
  ret void
}

declare ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPdiiii(ptr)

declare void @_Z18work_group_barrierj(i32)

declare void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELdi(ptr addrspace(1), ptr, double, i32)

declare void @dummy_barrier.()

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

!0 = !{i32 4, i32 100000}
!1 = !{ptr @_ZTS14ConcurrentLoop}
!2 = !{i1 false}
