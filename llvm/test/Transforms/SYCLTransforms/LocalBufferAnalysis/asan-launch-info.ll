; RUN: opt -passes='print<sycl-kernel-local-buffer-analysis>' %s -disable-output 2>&1 | FileCheck %s

; Check offset of local variable __AsanLaunchInfo is fixed to zero

; CHECK: LocalBufferInfo
; CHECK:   Local variables used in kernel
; CHECK:     kernel1
; CHECK-DAG:   test1
; CHECK-DAG:   __AsanLaunchInfo
; CHECK:     kernel2
; CHECK-DAG:   test2
; CHECK-DAG:   __AsanLaunchInfo
; CHECK:   Kernel local buffer size
; CHECK-DAG: kernel1 : 12
; CHECK-DAG: kernel2 : 12
; CHECK:   Offset of local variable in containing kernel's local buffer
; CHECK-DAG:   __AsanLaunchInfo : 0
; CHECK-DAG:   test1 : 8
; CHECK-DAG:   test2 : 8

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@__AsanLaunchInfo = external addrspace(3) global ptr addrspace(1)
@test1 = internal addrspace(3) global i32 undef, align 4
@test2 = internal addrspace(3) global i32 undef, align 4

define void @kernel1() {
entry:
  call void @__asan_store8()
  %0 = load i32, ptr addrspace(3) @test1, align 4
  ret void
}

define void @__asan_store8() {
entry:
  %call = call i64 @_ZN12_GLOBAL__N_111MemToShadowEmj()
  ret void
}

define i64 @_ZN12_GLOBAL__N_111MemToShadowEmj() {
entry:
  %0 = load ptr addrspace(1), ptr addrspace(3) @__AsanLaunchInfo, align 8
  ret i64 0
}

define void @kernel2() {
entry:
  call void @__asan_store8()
  %0 = load i32, ptr addrspace(3) @test2, align 4
  ret void
}

!sycl.kernels = !{!0}

!0 = !{ptr @kernel1, ptr @kernel2}
