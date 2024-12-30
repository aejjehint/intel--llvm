; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S | FileCheck %s
; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; An indirectly called function _ZGVeM16vv__Z3foo3myS contains TID call.
; Check all indirect calls are patched with %local.ids argument.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%struct.myS = type { i64, i64, i64, i64 }

@"_Z3foo3myS$SIMDTable" = weak addrspace(1) global [2 x ptr] [ptr @_ZGVeM16vv__Z3foo3myS, ptr @_ZGVeN16vv__Z3foo3myS]
@"_Z3bari$SIMDTable" = weak addrspace(1) global [2 x ptr] [ptr @_ZGVeM16v__Z3bari, ptr @_ZGVeN16v__Z3bari]

define void @_ZTS9SimpleAdd(ptr addrspace(1) %__asan_launch) !no_barrier_path !1 !vectorized_kernel !2 {
entry:
; CHECK-LABEL: define dso_local void @_ZTS9SimpleAdd(
; CHECK: entryvector_func:
; CHECK: call void @_ZGVeN16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(<16 x ptr addrspace(4)> {{.*}}, <16 x ptr> nonnull %.vec.base.addrvector_func, ptr noalias %local.idsvector_func)
; CHECK: scalar_kernel_entry:
; CHECK: call void @_Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(
; CHECK-SAME: ptr noalias %local.ids)

  call void @_Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(ptr addrspace(4) null, ptr null)
  ret void
}

declare i32 @__intel_indirect_call_1(ptr addrspace(4), i32)

define void @__asan_load8_as4() {
entry:
  br label %if.end

while.end.i:                                      ; No predecessors!
  %0 = tail call i64 @_Z13get_global_idj(i32 0)
  br label %if.end

if.end:                                           ; preds = %while.end.i, %entry
  ret void
}

declare i64 @_Z13get_global_idj(i32)

define void @_Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(ptr addrspace(4) %agg, ptr %0) {
entry:
  tail call void @__intel_indirect_call_0(ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)), ptr addrspace(4) %agg, ptr nonnull %0)
  %1 = tail call i32 @__intel_indirect_call_1(ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4)), i32 9)
  call void @__asan_load8_as4()
  ret void
}

declare void @__intel_indirect_call_0(ptr addrspace(4), ptr addrspace(4), ptr)

define dso_local void @_ZGVeN16uuuuuuuuu__ZTS9SimpleAdd(ptr addrspace(1) %__asan_launch) !no_barrier_path !1 !vectorized_width !3 {
entry:
  %.vec.base.addr = getelementptr %struct.myS, ptr null, <16 x i64> <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7, i64 8, i64 9, i64 10, i64 11, i64 12, i64 13, i64 14, i64 15>
  call void @_ZGVeN16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(<16 x ptr addrspace(4)> zeroinitializer, <16 x ptr> nonnull %.vec.base.addr)
  ret void
}

define void @_ZGVeN16vv___asan_load8_as4() {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0)
  ret void
}

define void @_ZGVeM16vv___asan_store8_as0() {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0)
  ret void
}

define i32 @_Z3bari(i32 %a) #0 {
entry:
  ret i32 %a
}

define <16 x i32> @_ZGVeM16v__Z3bari(<16 x i32> %a, <16 x i32> %mask) #0 {
entry:
  ret <16 x i32> zeroinitializer
}

define <16 x i32> @_ZGVeN16v__Z3bari(<16 x i32> %a) #0 {
entry:
  ret <16 x i32> %a
}

define void @_Z3foo3myS(ptr addrspace(4) %agg, ptr %A) #1 {
entry:
  ret void
}

define void @_ZGVeM16vv__Z3foo3myS(<16 x ptr addrspace(4)> %agg, <16 x ptr> %A, <16 x i64> %mask) #1 {
entry:
  br label %VPlannedBB45

pred.call.if:                                     ; No predecessors!
  call void @_ZGVeM16vv___asan_store8_as0()
  br label %VPlannedBB45

VPlannedBB45:                                     ; preds = %pred.call.if, %entry
  ret void
}

define void @_ZGVeN16vv__Z3foo3myS(<16 x ptr addrspace(4)> %agg, <16 x ptr> %A) #1 {
entry:
  ret void
}

define void @_ZGVeM16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(<16 x ptr addrspace(4)> %agg, <16 x i64> %mask) {
entry:
; CHECK-LABEL: define void @_ZGVeM16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(
; CHECK-SAME: <16 x i64> %mask, ptr noalias %local.ids)
; CHECK: [[LOAD0:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4))
; CHECK: [[CAST0:%[0-9]+]] = bitcast ptr addrspace(4) [[LOAD0]] to ptr addrspace(4)
; CHECK: call addrspace(4) void [[CAST0]](<16 x ptr addrspace(4)> %agg, <16 x ptr> %.vec.base.addr, <16 x i64> %maskext, ptr %local.ids)
; CHECK: [[LOAD1:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4))
; CHECK: [[CAST1:%[0-9]+]] = bitcast ptr addrspace(4) [[LOAD1]] to ptr addrspace(4)
; CHECK: = call addrspace(4) <16 x i32> [[CAST1]](<16 x i32> splat (i32 9), <16 x i32> %maskext48, ptr %local.ids)

  %.vec.base.addr = getelementptr %struct.myS, ptr null, <16 x i64> <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7, i64 8, i64 9, i64 10, i64 11, i64 12, i64 13, i64 14, i64 15>
  %maskext = sext <16 x i1> zeroinitializer to <16 x i64>
  %0 = load ptr addrspace(4), ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)), align 8
  call addrspace(4) void %0(<16 x ptr addrspace(4)> %agg, <16 x ptr> %.vec.base.addr, <16 x i64> %maskext)
  %maskext48 = sext <16 x i1> zeroinitializer to <16 x i32>
  %1 = load ptr addrspace(4), ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4)), align 8
  %2 = call addrspace(4) <16 x i32> %1(<16 x i32> splat (i32 9), <16 x i32> %maskext48)
  ret void
}

; CHECK-LABEL: define void @_Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(
; CHECK-SAME: ptr noalias %local.ids)
; CHECK: call void @__intel_indirect_call_0(ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)), ptr addrspace(4) %agg, ptr nonnull %0, ptr noalias %local.ids)
; CHECK: call i32 @__intel_indirect_call_1(ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4)), i32 9, ptr noalias %local.ids)

define void @_ZGVeN16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(<16 x ptr addrspace(4)> %agg, <16 x ptr> %A) {
entry:
; CHECK-LABEL: define void @_ZGVeN16vv__Z3quxIRF3mySS0_ERFiiEES0_S0_OT_OT0_(
; CHECK-SAME: ptr noalias %local.ids)
; CHECK: [[LOAD0:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)), i64 8)
; CHECK: [[CAST0:%[0-9]+]] = bitcast ptr addrspace(4) [[LOAD0]] to ptr addrspace(4)
; CHECK: call addrspace(4) void [[CAST0]](<16 x ptr addrspace(4)> %agg, <16 x ptr> %.vec.base.addr, ptr %local.ids)
; CHECK: [[LOAD1:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4)), i64 8)
; CHECK: [[CAST1:%[0-9]+]] = bitcast ptr addrspace(4) [[LOAD1]] to ptr addrspace(4)
; CHECK: = call addrspace(4) <16 x i32> [[CAST1]](<16 x i32> splat (i32 9), ptr %local.ids)

  %.vec.base.addr = getelementptr %struct.myS, ptr null, <16 x i64> <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7, i64 8, i64 9, i64 10, i64 11, i64 12, i64 13, i64 14, i64 15>
  %0 = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3foo3myS$SIMDTable" to ptr addrspace(4)), i64 8), align 8
  call addrspace(4) void %0(<16 x ptr addrspace(4)> %agg, <16 x ptr> %.vec.base.addr)
  %1 = load ptr addrspace(4), ptr addrspace(4) getelementptr (i8, ptr addrspace(4) addrspacecast (ptr addrspace(1) @"_Z3bari$SIMDTable" to ptr addrspace(4)), i64 8), align 8
  %2 = call addrspace(4) <16 x i32> %1(<16 x i32> splat (i32 9))
  call void @_ZGVeN16vv___asan_load8_as4()
  ret void
}

attributes #0 = { "vector_function_ptrs"="_Z3bari$SIMDTable(_ZGVeM16v__Z3bari,_ZGVeN16v__Z3bari)" }
attributes #1 = { "vector_function_ptrs"="_Z3foo3myS$SIMDTable(_ZGVeM16vv__Z3foo3myS,_ZGVeN16vv__Z3foo3myS)" }

!sycl.kernels = !{!0}

!0 = !{ptr @_ZTS9SimpleAdd}
!1 = !{i1 true}
!2 = !{ptr @_ZGVeN16uuuuuuuuu__ZTS9SimpleAdd}
!3 = !{i32 16}

; DEBUGIFY-NOT: WARNING
; DEBUGIFY-COUNT-61: WARNING: Instruction with empty DebugLoc in function _ZTS9SimpleAdd --
; DEBUGIFY: WARNING: Missing line 13
; DEBUGIFY-NOT: WARNING
