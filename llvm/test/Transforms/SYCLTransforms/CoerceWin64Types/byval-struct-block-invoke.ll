; RUN: opt -passes=sycl-kernel-coerce-win64-types -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-coerce-win64-types -S %s -o - | FileCheck %s

; Check byval arguments in __block_arg_struct_block_invoke are coerced.
; Check the function's use in global variable is replaced.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-win32-msvc-elf"

%struct.two_ints = type { i16, i64 }
%struct.two_structs = type { %struct.two_ints, %struct.two_ints }

; CHECK: @__block_literal_global =
; CHECK-SAME: ptr addrspace(4) addrspacecast (ptr @__block_arg_struct_block_invoke to ptr addrspace(4))

@__block_literal_global = addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 16, i32 8, ptr addrspace(4) addrspacecast (ptr @__block_arg_struct_block_invoke to ptr addrspace(4)) }

define dso_local void @block_arg_struct() {
entry:
; CHECK-LABEL: define dso_local void @block_arg_struct(
; CHECK: %0 = alloca %struct.two_structs, align 8
; CHECK: %1 = alloca %struct.two_ints, align 8
; CHECK: call i32 @__block_arg_struct_block_invoke(ptr addrspace(4) noundef addrspacecast (ptr addrspace(1) @__block_literal_global to ptr addrspace(4)), ptr %1, ptr %0)

  %i = alloca %struct.two_ints, align 8
  %s = alloca %struct.two_structs, align 8
  %call7 = call i32 @__block_arg_struct_block_invoke(ptr addrspace(4) noundef addrspacecast (ptr addrspace(1) @__block_literal_global to ptr addrspace(4)), ptr noundef byval(%struct.two_ints) align 8 %i, ptr noundef byval(%struct.two_structs) align 8 %s)
  ret void
}

define internal i32 @__block_arg_struct_block_invoke(ptr addrspace(4) noundef %.block_descriptor, ptr byval(%struct.two_ints) %ti, ptr byval(%struct.two_structs) %ts) {
entry:
; CHECK-LABEL: define internal i32 @__block_arg_struct_block_invoke(ptr addrspace(4) noundef %.block_descriptor, ptr %ti, ptr %ts)
; CHECK: %x = getelementptr inbounds nuw %struct.two_ints, ptr %ti, i32 0, i32 0
; CHECK: %a = getelementptr inbounds nuw %struct.two_structs, ptr %ts, i32 0, i32 0

  %x = getelementptr inbounds nuw %struct.two_ints, ptr %ti, i32 0, i32 0
  %a = getelementptr inbounds nuw %struct.two_structs, ptr %ts, i32 0, i32 0
  ret i32 0
}

!sycl.kernels = !{!0}
!0 = !{ptr @block_arg_struct}

; DEBUGIFY-NOT: WARNING
