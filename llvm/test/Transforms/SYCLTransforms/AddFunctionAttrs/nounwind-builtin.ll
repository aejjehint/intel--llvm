; RUN: opt -passes=sycl-kernel-add-function-attrs -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-add-function-attrs -S < %s | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

; Check nounwind attribute isn't removed from builtin that doesn't raise an exception.

define void @foo() {
entry:
; CHECK: call void @__devicelib_exit()
; CHECK-NOT: #
; CHECK: call i32 @_Z16get_sub_group_idv() [[ATTR:#[0-9]+]]

  call void @__devicelib_exit() #0
  %0 = call i32 @_Z16get_sub_group_idv() #0
  ret void
}

declare void @__devicelib_exit() #0

declare i32 @_Z16get_sub_group_idv() #0

; CHECK: attributes [[ATTR]] = { nounwind }

attributes #0 = { nounwind }

; DEBUGIFY-NOT: WARNING
