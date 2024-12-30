; RUN: opt -passes=sycl-kernel-deduce-max-dim -sycl-kernel-builtin-lib=%S/builtin-lib.rtl -S %s | FileCheck %s
; RUN: opt -passes=sycl-kernel-deduce-max-dim -sycl-kernel-builtin-lib=%S/builtin-lib.rtl -S %s -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY

; Kernel @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_ doens't contain
; tid call, but its indirectly called function @foo has tid call.
; Check max_wg_dimensions of the kernel is 1 instead of 0.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }

@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @foo to ptr addrspace(4))] }, align 8, !spirv.Decorations !0

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) nocapture writeonly align 8 %_arg_DeviceStorage, i32 %_arg_TestCase) #0 !kernel_has_sub_groups !6 {
entry:
  %cmp.not.i = icmp eq i32 %_arg_TestCase, 0
  br i1 %cmp.not.i, label %_ZN13obj_storage_tIJ5SumOpEE15constructHelperI6BaseOpS0_JEJEEEPT_iiDpT2_.exit.i, label %_ZN13obj_storage_tIJ5SumOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit

_ZN13obj_storage_tIJ5SumOpEE15constructHelperI6BaseOpS0_JEJEEEPT_iiDpT2_.exit.i: ; preds = %entry
  store ptr addrspace(1) getelementptr inbounds (%structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2), ptr addrspace(1) %_arg_DeviceStorage, align 8
  br label %_ZN13obj_storage_tIJ5SumOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit

_ZN13obj_storage_tIJ5SumOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit: ; preds = %_ZN13obj_storage_tIJ5SumOpEE15constructHelperI6BaseOpS0_JEJEEEPT_iiDpT2_.exit.i, %entry
  ret void
}

; CHECK: define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(
; CHECK-SAME: !max_wg_dimensions [[MD:![0-9]+]]
; CHECK: [[MD]] = !{i32 1}

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage) #1 !kernel_has_sub_groups !6 {
entry:
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %0 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  %1 = tail call addrspace(4) i32 %0() #1
  ret void
}

define internal i32 @foo() {
entry:
  %0 = tail call i64 @_Z12get_local_idj(i32 0) #1
  ret i32 0
}

declare i64 @_Z12get_local_idj(i32)

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "kernel-call-once" "kernel-convergent-call" }
attributes #1 = { nounwind }

!spirv.Source = !{!4}
!sycl.kernels = !{!5}

!0 = !{!1, !2, !3}
!1 = !{i32 22}
!2 = !{i32 41, !"_ZTV5SumOp", i32 2}
!3 = !{i32 44, i32 8}
!4 = !{i32 4, i32 100000}
!5 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_, ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}
!6 = !{i1 false}

; DEBUGIFY-NOT: WARNING
