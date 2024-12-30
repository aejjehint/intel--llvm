; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -o - | FileCheck %s
; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check local.ids is patched to indirectly called function 'foo' that has
; get_local_id call and doesn't have barrier call.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }

@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @foo to ptr addrspace(4))] }, align 8, !spirv.Decorations !0

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) align 8 %_arg_DeviceStorage) !no_barrier_path !6 !kernel_has_sub_groups !7 !max_wg_dimensions !8 !recommended_vector_length !9 {
entry:
  store ptr addrspace(1) getelementptr inbounds (%structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2), ptr addrspace(1) %_arg_DeviceStorage, align 8
  ret void
}

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage, ptr addrspace(1) align 8 %_arg_DataAcc) !no_barrier_path !6 !kernel_has_sub_groups !7 !max_wg_dimensions !9 !recommended_vector_length !9 {
entry:
  %0 = addrspacecast ptr addrspace(1) %_arg_DataAcc to ptr addrspace(4)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %1 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8

; CHECK: call addrspace(4) void %{{[0-9]+}}(ptr addrspace(4) %{{[0-9]+}}, ptr %local.ids)

  tail call addrspace(4) void %1(ptr addrspace(4) %0)
  ret void
}

; Function Attrs: convergent mustprogress nofree nounwind willreturn memory(none)
declare i64 @_Z12get_local_idj(i32) local_unnamed_addr #0

; CHECK: define internal void @foo(ptr addrspace(4) %GlobalData, ptr noalias %local.ids)

define internal void @foo(ptr addrspace(4) %GlobalData) {
entry:
  %0 = tail call i64 @_Z12get_local_idj(i32 0)
  store i64 %0, ptr addrspace(4) %GlobalData, align 8
  ret void
}

attributes #0 = { convergent mustprogress nofree nounwind willreturn memory(none) }

!spirv.Source = !{!4}
!sycl.kernels = !{!5}

!0 = !{!1, !2, !3}
!1 = !{i32 22}
!2 = !{i32 41, !"_ZTV5SumOp", i32 2}
!3 = !{i32 44, i32 8}
!4 = !{i32 4, i32 100000}
!5 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_, ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}
!6 = !{i1 true}
!7 = !{i1 false}
!8 = !{i32 0}
!9 = !{i32 1}

; DEBUGIFY-COUNT-2: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_
; DEBUGIFY-COUNT-11: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; DEBUGIFY-NOT: WARNING
