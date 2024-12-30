; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S | FileCheck %s
; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check __intel_indirect_call call inst is patched with %local.ids argument.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@"_Z3foo3myS$SIMDTable" = addrspace(1) global [2 x ptr] [ptr @_ZGVeM4v__Z3foo3myS, ptr @_ZGVeN4v__Z3foo3myS]

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd(ptr addrspace(1) %__asan_launch) !no_barrier_path !1 !vectorized_kernel !2 {
entry:
; CHECK-LABEL: void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd(
; CHECK: entryvector_func:
; CHECK: [[FUNC_PTR:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr inttoptr (i64 ptrtoint (ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)) to i64) to ptr) to ptr addrspace(4)), i64 8), align 8
; CHECK: [[FUNC_PTR_ASC:%[0-9]+]] = bitcast ptr addrspace(4) [[FUNC_PTR]] to ptr addrspace(4)
; CHECK: call addrspace(4) void [[FUNC_PTR_ASC]](<4 x ptr> {{.*}}, ptr %local.idsvector_func)
; CHECK: scalar_kernel_entry:
; CHECK: [[ASC:%[0-9]+]] = addrspacecast ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)
; CHECK: [[PTR2INT:%[0-9]+]] = ptrtoint ptr addrspace(4) [[ASC]] to i64
; CHECK: [[INT2PTR:%[0-9]+]] = inttoptr i64 [[PTR2INT]] to ptr
; CHECK: [[ASC2:%[0-9]+]] = addrspacecast ptr [[INT2PTR]] to ptr addrspace(4)
; CHECK: call void @__intel_indirect_call(ptr addrspace(4) [[ASC2]], ptr null, ptr noalias %local.ids)
; CHECK: call void @__intel_indirect_call(ptr addrspace(4) addrspacecast (ptr inttoptr (i64 ptrtoint (ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)) to i64) to ptr) to ptr addrspace(4)), ptr {{.*}}, ptr noalias %local.ids)
; CHECK: dim_0_exit:

  %0 = addrspacecast ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)
  %1 = ptrtoint ptr addrspace(4) %0 to i64
  %2 = inttoptr i64 %1 to ptr
  %3 = addrspacecast ptr %2 to ptr addrspace(4)
  call void @__intel_indirect_call(ptr addrspace(4) %3, ptr null)
  call void @__intel_indirect_call(ptr addrspace(4) addrspacecast (ptr inttoptr (i64 ptrtoint (ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)) to i64) to ptr) to ptr addrspace(4)), ptr null)

  ret void
}

declare i64 @_Z13get_global_idj(i32)

declare void @__intel_indirect_call(ptr addrspace(4), ptr)

define fastcc void @_ZGVeN4v___asan_store8_as0() {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0)
  ret void
}

define void @_ZGVeN4u__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd(ptr addrspace(1) %__asan_launch) !no_barrier_path !1 !vectorized_width !3 {
entry:
  %0 = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr inttoptr (i64 ptrtoint (ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)) to i64) to ptr) to ptr addrspace(4)), i64 8), align 8
  call addrspace(4) void %0(<4 x ptr> zeroinitializer)
  ret void
}

define void @_ZGVeM4v__Z3foo3myS(<4 x ptr> %a, <4 x i64> %mask) #0 {
  ret void
}

define void @_ZGVeN4v__Z3foo3myS(<4 x ptr> %a) #0 {
entry:
  call fastcc void @_ZGVeN4v___asan_store8_as0()
  ret void
}

attributes #0 = { "vector_function_ptrs"="_Z3foo3myS$SIMDTable(_ZGVeM4v__Z3foo3myS,_ZGVeN4v__Z3foo3myS)" }

!sycl.kernels = !{!0}

!0 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd}
!1 = !{i1 true}
!2 = !{ptr @_ZGVeN4u__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd}
!3 = !{i32 4}

; DEBUGIFY-NOT: WARNING
; DEBUGIFY-COUNT-61: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd
; DEBUGIFY: WARNING: Missing line 12
; DEBUGIFY-NOT: WARNING
