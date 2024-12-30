; RUN: opt -passes=sycl-kernel-barrier %s -S | FileCheck %s
; RUN: opt -passes=sycl-kernel-barrier %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check get_special_buffer. call has noalias attribute. Check function pointer
; %1 is hoisted to entry block as the pointer won't alias with special buffer.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define void @test(ptr addrspace(1) align 4 %_arg_DataAcc, ptr addrspace(4) %vtable.i) !no_barrier_path !1{
entry:
; CHECK: entry:
; CHECK: [[PTR:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
; CHECK: %pSB = call noalias ptr @get_special_buffer.()
; CHECK: br label %FirstBB

  call void @dummy_barrier.()
  %0 = tail call i64 @_Z13get_global_idj(i32 0) #0
  %arrayidx.i = getelementptr i32, ptr addrspace(1) %_arg_DataAcc, i64 %0
  %1 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  call void @_Z18work_group_barrierj()

; CHECK: tail call addrspace(4) i32 [[PTR]]()

  %2 = tail call addrspace(4) i32 %1()
  store i32 0, ptr addrspace(1) %arrayidx.i, align 4
  ret void
}

declare i64 @_Z13get_global_idj(i32)

declare void @dummy_barrier.()

declare void @_Z18work_group_barrierj()

attributes #0 = { memory(none) }

!sycl.kernels = !{!5}

!1 = !{i1 false}
!5 = !{ptr @test}

; DEBUGIFY-COUNT-9: WARNING: Instruction with empty DebugLoc in function test
; DEBUGIFY: WARNING: Missing line 4
; DEBUGIFY-NOT: WARNING
