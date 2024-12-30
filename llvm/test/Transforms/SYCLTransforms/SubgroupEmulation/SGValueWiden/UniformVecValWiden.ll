; RUN: opt -passes=sycl-kernel-sg-emu-value-widen -S %s -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-sg-emu-value-widen -S %s | FileCheck %s

; Checks that shufflevector is properly generated to extract a sub-vector from a uniform sub-group call result.

; CHECK: [[CALL:%.*]] = call <16 x i32> @_Z19sub_group_broadcastDv16_jjDv8_j(
; CHECK: [[UNI:%.*]] = shufflevector <16 x i32> [[CALL]], <16 x i32> undef, <2 x i32> <i32 0, i32 1>
; CHECK: store <2 x i32> [[UNI]], ptr

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define void @test(ptr %mem) !kernel_has_sub_groups !1 !sg_emu_size !2 {
sg.barrier.bb:
  %call.i.i = call <2 x i32> @_Z19sub_group_broadcastDv2_jj(<2 x i32> zeroinitializer, i32 0)
  br label %sg.dummy.bb

sg.dummy.bb:                                    ; preds = %sg.barrier.bb
  call void @dummy_sg_barrier()
  store <2 x i32> %call.i.i, ptr %mem
  ret void
}

declare <2 x i32> @_Z19sub_group_broadcastDv2_jj(<2 x i32>, i32) #0

declare void @dummy_sg_barrier()

attributes #0 = { "vector-variants"="_ZGVbM8vu__Z19sub_group_broadcastDv2_jj(_Z19sub_group_broadcastDv16_jjDv8_j),_ZGVbM8vv__Z19sub_group_broadcastDv2_jj(_Z19sub_group_broadcastDv16_jDv8_jS0_)" }

!sycl.kernels = !{!0}

!0 = !{ptr @test}
!1 = !{i1 true}
!2 = !{i32 8}

; DEBUGIFY-NOT: WARNING
