; RUN: opt -passes=sycl-kernel-coerce-win64-types -mtriple x86_64-w64-mingw32 -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-coerce-win64-types -mtriple x86_64-w64-mingw32 -S %s -o - | FileCheck %s

; Check struct type containing a pointer type is coerced into the pointer type.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-win32-msvc-elf"

%"class.sycl::_V1::span" = type { ptr addrspace(4) }
%"class.2" = type { %"class.sycl::_V1::span" }

define void @test() {
entry:
  %agg1 = alloca %"class.sycl::_V1::span", align 8
  %agg2 = alloca %"class.2", align 8

; CHECK: [[LOAD0:%[0-9]+]] = load ptr addrspace(4), ptr %agg1, align 8
; CHECK: [[LOAD1:%[0-9]+]] = load ptr addrspace(4), ptr %agg2, align 8
; CHECK: call void @foo(ptr addrspace(4) [[LOAD0]], ptr addrspace(4) [[LOAD1]])

  call void @foo(ptr byval(%"class.sycl::_V1::span") align 8 %agg1, ptr byval(%"class.2") align 8 %agg2)
  ret void
}

; CHECK: define void @foo(ptr addrspace(4) %a, ptr addrspace(4) %b)

define void @foo(ptr byval(%"class.sycl::_V1::span") align 8 %a, ptr byval(%"class.2") align 8 %b) {
entry:
  ret void
}

; DEBUGIFY-NOT: WARNING
