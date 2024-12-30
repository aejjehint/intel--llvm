; RUN: opt -passes='print<sycl-kernel-indirect-call-analysis>' %s -disable-output 2>&1 | FileCheck %s

; Check indirectly called functions are correctly indentified.

; CHECK: Indirect calls:
; CHECK:   FunctionType: i32 (ptr addrspace(4))
; CHECK:     Indirect call:   %1 = call i32 %0(ptr addrspace(4) null)
; CHECK: Indirectly called functions:
; CHECK:   func1
; CHECK:   func2
; CHECK:   func3
; CHECK:   func4
; CHECK-NOT: func5

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define i32 @func1(ptr addrspace(4) %0) #0 {
entry:
  ret i32 0
}

declare i32 @func2(ptr addrspace(4) %0)

define i32 @func3(ptr addrspace(4) %0) {
entry:
  ret i32 0
}

define i32 @func4(ptr addrspace(4) %0) #1 {
entry:
  ret i32 0
}

define i32 @func5(ptr addrspace(4) %0) {
entry:
  ret i32 0
}

define void @test() {
newFuncRoot:
  %0 = call ptr @get_fptr(i1 true)

; CHECK call i32 %{{[0-9]+}}(ptr addrspace(4) null)

  %1 = call i32 %0(ptr addrspace(4) null)
  ret void
}

define ptr @get_fptr(i1 %0) {
entry:
  %1 = select i1 %0, ptr @func2, ptr @func3
  ret ptr %1
}

attributes #0 = { "referenced-indirectly" }
attributes #1 = { "indirectly-callable"="_ZTSv" }
