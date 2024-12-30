; RUN: opt -passes=sycl-kernel-add-function-attrs -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-add-function-attrs -S < %s | FileCheck %s

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

; Function Attrs: nounwind
declare spir_func void @__devicelib_exit() #0

; Function Attrs: nounwind
define void @foo() #0 {
entry:
  call spir_func void @__devicelib_exit() #0
  ret void
}

; CHECK-NOT: nounwind

attributes #0 = { nounwind }

; DEBUGIFY-NOT: WARNING
