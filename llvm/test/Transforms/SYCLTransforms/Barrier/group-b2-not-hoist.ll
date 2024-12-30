; RUN: opt -passes=sycl-kernel-barrier %s -S -o - | FileCheck %s
; RUN: opt -passes=sycl-kernel-barrier %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check that uniform load instruction, which are clobbered, are not hoisted.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%struct.FDWT53 = type { i32, i32 }

define void @test(ptr addrspace(1) %arg0, ptr addrspace(3) %arg1, ptr addrspace(4) %arg2) {
entry:
; CHECK: br label %[[SYNCBB3:SyncBB[0-9]+]]

  call void @dummy_barrier.()
  %OFFSET0 = getelementptr inbounds %struct.FDWT53, ptr addrspace(1) %arg0, i64 0, i32 1
  store i32 0, ptr addrspace(1) %OFFSET0, align 4
  %0 = load i32, ptr addrspace(1) %OFFSET0, align 4
  %OFFSET1 = getelementptr inbounds %struct.FDWT53, ptr addrspace(3) %arg1, i64 0, i32 1
  store i32 0, ptr addrspace(3) %OFFSET1, align 4
  %1 = load i32, ptr addrspace(3) %OFFSET1, align 4
  %OFFSET2 = getelementptr inbounds %struct.FDWT53, ptr addrspace(4) %arg2, i64 0, i32 1
  store i32 0, ptr addrspace(4) %OFFSET2, align 4
  %2 = load i32, ptr addrspace(4) %OFFSET2, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                              ; preds = %entry
; CHECK: [[SYNCBB3]]:
; CHECK: store i32 {{.*}}, ptr addrspace(1) %OFFSET0, align 4
; CHECK: load i32, ptr addrspace(1) %OFFSET0, align 4
; CHECK: store i32 {{.*}}, ptr addrspace(3) %OFFSET1, align 4
; CHECK: load i32, ptr addrspace(3) %OFFSET1, align 4
; CHECK: store i32 {{.*}}, ptr addrspace(4) %OFFSET2, align 4
; CHECK: load i32, ptr addrspace(4) %OFFSET2, align 4

  call void @_Z18work_group_barrierj12memory_scope()
  %3 = select i1 false, i32 0, i32 %0
  %4 = select i1 false, i32 0, i32 %1
  %5 = select i1 false, i32 0, i32 %2
  call void @_Z18work_group_barrierj12memory_scope()
  call void @_Z18work_group_barrierj()
  ret void
}

declare void @_Z18work_group_barrierj12memory_scope()

declare void @dummy_barrier.()

declare void @_Z18work_group_barrierj()

; DEBUGIFY-COUNT-10: WARNING: Instruction with empty DebugLoc in function test
; DEBUGIFY-NOT: WARNING
