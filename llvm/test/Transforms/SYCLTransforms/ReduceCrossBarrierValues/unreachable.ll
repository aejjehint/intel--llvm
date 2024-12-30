; RUN: opt -S -passes=sycl-kernel-reduce-cross-barrier-values %s | FileCheck %s

; Checks that reduce-cross-barrier-values pass won't crash when a basic block is
; unreachable.

; CHECK: define void @test_freeze(

define void @test_freeze(ptr %dst) {
entry:
  ret void

Split.Barrier:
  call void @dummy_barrier.()
  br i1 true, label %if.then, label %if.end

if.then:
  br label %if.end

if.end:
  %v = phi i32 [ 0, %Split.Barrier ], [%add, %if.then]
  %add = add i32 %v, 1
  br label %Split.Barrier
}

declare void @dummy_barrier.()
