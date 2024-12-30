; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S | FileCheck %s
; RUN: opt -passes=sycl-kernel-wgloop-creator %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check that function use in global variable is replaced when the function is
; patched with local.ids.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

; CHECK: @"_Z3foo3myS$SIMDTable" = addrspace(1) global [2 x ptr] [ptr @_ZGVeM16vv__Z3foo3myS, ptr @_ZGVeN16vv__Z3foo3myS]

@"_Z3foo3myS$SIMDTable" = addrspace(1) global [2 x ptr] [ptr @_ZGVeM16vv__Z3foo3myS, ptr @_ZGVeN16vv__Z3foo3myS]

; Function Attrs: convergent noinline memory(readwrite)
define internal fastcc void @__asan_store8() unnamed_addr #0 {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0) #2
  store i64 %0, ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), align 8
  ret void
}

; Function Attrs: convergent memory(write, inaccessiblemem: none)
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd() local_unnamed_addr #1 !kernel_arg_addr_space !2 !kernel_arg_access_qual !2 !kernel_arg_type !2 !kernel_arg_base_type !2 !kernel_arg_type_qual !2 !kernel_arg_target_ext_type !2 !no_barrier_path !3 !kernel_has_sub_groups !4 !kernel_has_global_sync !4 !kernel_execution_length !5 !vectorized_kernel !6 !max_wg_dimensions !7 !vectorized_width !7 !spirv.ParameterDecorations !2 {
entry:
  tail call fastcc void @__asan_store8() #6
  ret void
}

; Function Attrs: convergent memory(none)
declare i64 @_Z13get_global_idj(i32) local_unnamed_addr #2

; CHECK: define internal void @_ZGVeM16vv__Z3foo3myS(
; CHECK-SAME: ptr noalias %local.ids

; Function Attrs: convergent memory(readwrite)
define internal void @_ZGVeM16vv__Z3foo3myS(<16 x ptr addrspace(4)> nocapture readnone %agg.result, <16 x ptr> nocapture readnone %myA, <16 x i64> %mask) #3 {
entry:
  %0 = icmp ne <16 x i64> %mask, zeroinitializer
  %1 = bitcast <16 x i1> %0 to i16
  %2 = icmp eq i16 %1, 0
  br i1 %2, label %return, label %VPlannedBB4

VPlannedBB4:                                      ; preds = %entry
  %maskext = sext <16 x i1> %0 to <16 x i32>
  tail call fastcc void @_ZGVeM16___asan_store8(<16 x i32> %maskext) #7
  br label %return

return:                                           ; preds = %VPlannedBB4, %entry
  ret void
}

; CHECK: define internal void @_ZGVeN16vv__Z3foo3myS(
; CHECK-SAME: ptr noalias %local.ids

; Function Attrs: convergent memory(readwrite)
define internal void @_ZGVeN16vv__Z3foo3myS(<16 x ptr addrspace(4)> nocapture readnone %agg.result, <16 x ptr> nocapture readnone %myA) #3 {
entry:
  tail call fastcc void @_ZGVeN16___asan_store8() #7
  ret void
}

; Function Attrs: convergent noinline memory(readwrite)
define internal fastcc void @_ZGVeM16___asan_store8(<16 x i32> %mask) unnamed_addr #0 {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0) #2
  %1 = icmp ne <16 x i32> %mask, zeroinitializer
  %2 = bitcast <16 x i1> %1 to i16
  %3 = icmp eq i16 %2, 0
  br i1 %3, label %return, label %VPlannedBB4

VPlannedBB4:                                      ; preds = %entry
  %4 = trunc i64 %0 to i32
  %broadcast.splatinsert = insertelement <16 x i32> poison, i32 %4, i64 0
  %broadcast.splat = shufflevector <16 x i32> %broadcast.splatinsert, <16 x i32> poison, <16 x i32> zeroinitializer
  %5 = add nuw <16 x i32> %broadcast.splat, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %6 = sext <16 x i32> %5 to <16 x i64>
  tail call void @llvm.masked.scatter.v16i64.v16p1(<16 x i64> %6, <16 x ptr addrspace(1)> <ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1))>, i32 8, <16 x i1> %1)
  br label %return

return:                                           ; preds = %VPlannedBB4, %entry
  ret void
}

; Function Attrs: convergent noinline memory(readwrite)
define internal fastcc void @_ZGVeN16___asan_store8() unnamed_addr #0 {
entry:
  %0 = tail call i64 @_Z13get_global_idj(i32 0) #2
  %1 = shl i64 %0, 32
  %sext = add i64 %1, 64424509440
  %extracted.priv = ashr exact i64 %sext, 32
  store i64 %extracted.priv, ptr addrspace(1) inttoptr (i64 584 to ptr addrspace(1)), align 8
  ret void
}

; Function Attrs: convergent memory(readwrite)
define void @_ZGVeN16__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd() local_unnamed_addr #4 !kernel_arg_addr_space !2 !kernel_arg_access_qual !2 !kernel_arg_type !2 !kernel_arg_base_type !2 !kernel_arg_type_qual !2 !kernel_arg_target_ext_type !2 !no_barrier_path !3 !kernel_has_sub_groups !4 !kernel_has_global_sync !4 !kernel_execution_length !5 !max_wg_dimensions !7 !vectorized_width !8 !spirv.ParameterDecorations !2 !vectorization_dimension !9 !scalar_kernel !1 !can_unite_workgroups !3 {
entry:
  tail call fastcc void @_ZGVeN16___asan_store8() #7
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(write)
declare void @llvm.masked.scatter.v16i64.v16p1(<16 x i64>, <16 x ptr addrspace(1)>, i32 immarg, <16 x i1>) #5

attributes #0 = { convergent noinline memory(readwrite) }
attributes #1 = { convergent memory(write, inaccessiblemem: none) "vector-variants"="_ZGVeN16__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd" }
attributes #2 = { convergent memory(none) }
attributes #3 = { convergent memory(readwrite) "vector_function_ptrs"="_Z3foo3myS$SIMDTable(_ZGVeM16vv__Z3foo3myS,_ZGVeN16vv__Z3foo3myS)" "widened-size"="16" }
attributes #4 = { convergent memory(readwrite) }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(write) }
attributes #6 = { convergent noinline "vector-variants"="_ZGVeM16___asan_store8,_ZGVeN16___asan_store8" }
attributes #7 = { convergent noinline nounwind }

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

!0 = !{i32 0, i32 0}
!1 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd}
!2 = !{}
!3 = !{i1 true}
!4 = !{i1 false}
!5 = !{i32 2}
!6 = !{ptr @_ZGVeN16__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd}
!7 = !{i32 1}
!8 = !{i32 16}
!9 = !{i32 0}

; DEBUGIFY-COUNT-27: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_E9SimpleAdd
; DEBUGIFY: WARNING: Missing line 36
; DEBUGIFY-NOT: WARNING
