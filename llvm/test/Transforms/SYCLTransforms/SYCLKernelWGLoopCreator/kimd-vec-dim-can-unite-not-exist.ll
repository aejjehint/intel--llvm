; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S | FileCheck %s
; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check the pass doesn't crash when kernel metadata vectorization_dimension
; and can_unite_workgroups don't exist.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

; CHECK: define void @_ZTSN11range_api__17test_range_kernelILi3EEE

define void @_ZTSN11range_api__17test_range_kernelILi3EEE(ptr addrspace(1) align 4 %_arg_error_ptr) !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 !kernel_arg_target_ext_type !5 !no_barrier_path !6 !kernel_has_sub_groups !7 !vectorized_kernel !8 !vectorized_width !9 {
for.inc16.i.2:
  ret void
}

define void @_ZGVeN16uu__ZTSN11range_api__17test_range_kernelILi3EEE(ptr addrspace(1) align 4 %_arg_error_ptr) !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 !kernel_arg_target_ext_type !5 !no_barrier_path !6 !kernel_has_sub_groups !7 !vectorized_width !10 !scalar_kernel !1 {
for.inc16.i.2:
  ret void
}

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

!0 = !{i32 4, i32 100000}
!1 = !{ptr @_ZTSN11range_api__17test_range_kernelILi3EEE}
!2 = !{i32 1, i32 0}
!3 = !{!"none", !"none"}
!4 = !{!"int*", !"class.sycl::_V1::id"}
!5 = !{!"", !""}
!6 = !{i1 true}
!7 = !{i1 false}
!8 = !{ptr @_ZGVeN16uu__ZTSN11range_api__17test_range_kernelILi3EEE}
!9 = !{i32 1}
!10 = !{i32 16}

; DEBUGIFY-COUNT-63: WARNING: Instruction with empty DebugLoc
; See CMPLRLLVM-63201
; DEBUGIFY-NEXT: WARNING: Missing line 2
; DEBUGIFY-NOT: WARNING

