; RUN: opt -passes='sycl-kernel-add-implicit-args,sycl-kernel-prepare-args' -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes='sycl-kernel-add-implicit-args,sycl-kernel-prepare-args' -S %s | FileCheck %s

; Checks that the attributes of the old kernel is copied to the wrapper.

; CHECK: define void @test
; CHECK-SAME: #[[ATTR:[0-9]+]]

; CHECK-DAG: attributes #[[ATTR]] = { noinline }

define void @test(i32 %a) #0 {
  ret void
}

attributes #0 = { noinline }

!sycl.kernels = !{!0}
!0 = !{ptr @test}

; DEBUGIFY-NOT: WARNING
; DEBUGIFY-COUNT-30: WARNING: Instruction with empty DebugLoc in function test {{.*}}
; DEBUGIFY-NOT: WARNING
