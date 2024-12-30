; RUN: opt -passes=sycl-kernel-wg-loop-bound %s -S -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-wg-loop-bound %s -S -debug 2>&1 | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

declare void @foo(i64)
declare i64 @_Z13get_global_idj(i32) local_unnamed_addr

; No early exit boundary is generated for ule comparison with non-const operand.
; CHECK-LABEL: WGLoopBoundaries constant_kernel
; CHECK: found 0 early exit boundaries
define void @constant_kernel(ptr addrspace(1) noalias %out, i32 %lb, i32 %ub) local_unnamed_addr !no_barrier_path !1 {
entry:
  %gid  = tail call i64 @_Z13get_global_idj(i32 0)
  %conv = trunc i64 %gid to i32
  %new_lb = sub i32 %conv, %lb
  %cmp = icmp ule i32 %new_lb, %ub
  br i1 %cmp, label %if.end, label %if.then

if.then:
  %sext = shl i64 %gid, 32
  call void @foo(i64 %sext)
  br label %if.end

if.end:
  ret void
}

; CHECK-LABEL: WGLoopBoundaries constant_kernel1
; CHECK: found 0 early exit boundaries
define void @constant_kernel1(ptr addrspace(1) noalias %out) local_unnamed_addr !no_barrier_path !1 {
entry:
  %gid  = tail call i64 @_Z13get_global_idj(i32 0)
  %conv = trunc i64 %gid to i32
  %new_lb = sub i32 %conv, 4
  %cmp = icmp ule i32 %new_lb, 9
  br i1 %cmp, label %if.end, label %if.then

if.then:
  %sext = shl i64 %gid, 32
  call void @foo(i64 %sext)
  br label %if.end

if.end:
  ret void
}

; CHECK-LABEL: WGLoopBoundaries constant_kernel2
; CHECK: found 2 early exit boundaries
; CHECK-NEXT: Dim=0, Contains=T, IsGID=T, IsSigned=F, IsUpperBound=T
; CHECK-NEXT: Dim=0, Contains=T, IsGID=T, IsSigned=F, IsUpperBound=F
define void @constant_kernel2(ptr addrspace(1) noalias %out) local_unnamed_addr !no_barrier_path !1 {
entry:
  %gid  = tail call i64 @_Z13get_global_idj(i32 0)
  %conv = trunc i64 %gid to i32
  %new_lb = sub i32 %conv, 4
  %cmp = icmp ule i32 %new_lb, 9
  br i1 %cmp, label %if.then , label %if.end

if.then:
  %sext = shl i64 %gid, 32
  call void @foo(i64 %sext)
  br label %if.end

if.end:
  ret void
}

; CHECK-LABEL: WGLoopBoundaries constant_kernel3
; CHECK: found 0 early exit boundaries
define void @constant_kernel3(ptr addrspace(1) noalias %out) local_unnamed_addr !no_barrier_path !1 {
entry:
  %gid  = tail call i64 @_Z13get_global_idj(i32 0)
  %conv = trunc i64 %gid to i32
  %new_lb = sub i32 %conv, 4
  %cmp = icmp ule i32 9, %new_lb
  br i1 %cmp, label %if.then , label %if.end

if.then:
  %sext = shl i64 %gid, 32
  call void @foo(i64 %sext)
  br label %if.end

if.end:
  ret void
}

; CHECK-LABEL: WGLoopBoundaries constant_kernel4
; CHECK: found 2 early exit boundaries
; CHECK-NEXT: Dim=0, Contains=F, IsGID=T, IsSigned=F, IsUpperBound=T
; CHECK-NEXT: Dim=0, Contains=T, IsGID=T, IsSigned=F, IsUpperBound=F
define void @constant_kernel4(ptr addrspace(1) noalias %out) local_unnamed_addr !no_barrier_path !1 {
entry:
  %gid  = tail call i64 @_Z13get_global_idj(i32 0)
  %conv = trunc i64 %gid to i32
  %new_lb = sub i32 %conv, 4
  %cmp = icmp ule i32 9, %new_lb
  br i1 %cmp, label %if.end , label %if.then

if.then:
  %sext = shl i64 %gid, 32
  call void @foo(i64 %sext)
  br label %if.end

if.end:
  ret void
}

; CHECK-NOT: define [7 x i64] @WG.boundaries.constant_kernel(ptr addrspace(1) noalias %{{.*}}, i32 %{{.*}}, i32 %{{.*}})
; CHECK-NOT: define [7 x i64] @WG.boundaries.constant_kernel1(ptr addrspace(1) noalias %{{.*}})
; CHECK: define [7 x i64] @WG.boundaries.constant_kernel2(ptr addrspace(1) noalias %{{.*}})
; CHECK-NOT: define [7 x i64] @WG.boundaries.constant_kernel3(ptr addrspace(1) noalias %{{.*}})
; CHECK: define [7 x i64] @WG.boundaries.constant_kernel4(ptr addrspace(1) noalias %{{.*}})

!sycl.kernels = !{!0}

!0 = !{ptr @constant_kernel, ptr @constant_kernel1, ptr @constant_kernel2, ptr @constant_kernel3, ptr @constant_kernel4}
!1 = !{i1 true}

; DEBUGIFY-COUNT-12: WARNING: Instruction with empty DebugLoc in function constant_kernel
; DEBUGIFY-COUNT-55: WARNING: Instruction with empty DebugLoc in function WG.boundaries.constant_kernel
; DEBUGIFY-COUNT-2: WARNING: Missing line
