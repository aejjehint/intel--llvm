; RUN: opt -passes=sycl-kernel-prevent-div-crashes,instcombine -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-prevent-div-crashes,instcombine -S %s -o - | FileCheck %s

; CHECK: @sample_test
define void @sample_test(<2 x i32> %x, ptr addrspace(1) nocapture %res) nounwind !kernel_arg_base_type !0 !arg_type_null_val !1 {
entry:
  %div = sdiv <2 x i32> %x, <i32 -1, i32 6>
  store <2 x i32> %div, ptr addrspace(1) %res
  ret void
}

; CHECK: 		[[IS_DIVIDEND_MIN_INT:%[a-zA-Z0-9]+]] = icmp eq <2 x i32> %x, splat (i32 -2147483648)
; CHECK-NEXT: 	[[NEW_DIVISOR:%[a-zA-Z0-9]+]] = select <2 x i1> [[IS_DIVIDEND_MIN_INT]], <2 x i32> <i32 1, i32 6>, <2 x i32> <i32 -1, i32 6>
; CHECK-NEXT: 	sdiv <2 x i32> %x, [[NEW_DIVISOR]]

; DEBUGIFY-NOT: WARNING

!0 = !{!"int2", !"int2*"}
!1 = !{<2 x i32> zeroinitializer, ptr addrspace(1) null}
