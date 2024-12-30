; RUN: opt -passes=sycl-kernel-add-implicit-args,sycl-kernel-prepare-args -S %s -enable-debugify -disable-output 2>&1 | FileCheck  -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-add-implicit-args,sycl-kernel-prepare-args -S %s | FileCheck %s

; Checks that kernel_arg_properties metadata is added to the wrapper.

; CHECK: define void @test
; CHECK-SAME: !kernel_arg_properties [[MD:![0-9]+]]
; CHECK: [[MD]] = !{[[MD1:![0-9]+]], [[MD2:![0-9]+]], [[MD3:![0-9]+]], [[MD4:![0-9]+]], [[MD5:![0-9]+]]}
; CHECK-NEXT: [[MD1]] = !{i32 9, i64 8, i64 0, i1 true}
; CHECK-NEXT: [[MD2]] = !{i32 10, i64 8, i64 8, i1 true}
; CHECK-NEXT: [[MD3]] = !{i32 8, i64 8, i64 16, i1 false}
; CHECK-NEXT: [[MD4]] = !{i32 0, i64 4, i64 24, i1 false}
; CHECK-NEXT: [[MD5]] = !{i32 4, i64 262148, i64 32, i1 false}

define void @test(i32 addrspace(1)* %a, i32 addrspace(2)* %b, i32 addrspace(3)* %c, i32 %d, <4 x float> %e) #0 {
  ret void
}

!sycl.kernels = !{!0}

!0 = !{ ptr @test }

; DEBUGIFY-COUNT-47: WARNING: Instruction with empty DebugLoc in function test
; DEBUGIFY-NOT: WARNING
