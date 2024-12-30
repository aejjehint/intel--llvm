; RUN: opt -passes=sycl-kernel-barrier %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-barrier %s -S | FileCheck %s

; Check barrier_buffer_size of vectorized kernel is not divided by
; vectorized_width. The vectorizer kernel has indirect call to virtual function
; that isn't vectorized.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }

@_ZTV10MultiplyOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !0
@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) nocapture writeonly align 8 %_arg_DeviceStorage, i32 %_arg_TestCase) #0 !no_barrier_path !8 !vectorized_width !9 !spirv.ParameterDecorations !10 {
entry:
  call void @dummy_barrier.()
  %cmp.i = icmp ugt i32 %_arg_TestCase, 1
  br i1 %cmp.i, label %_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit, label %if.end.i

if.end.i:                                         ; preds = %entry
  %cmp.not.i.i = icmp eq i32 %_arg_TestCase, 0
  %. = select i1 %cmp.not.i.i, ptr addrspace(1) getelementptr inbounds (%structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2), ptr addrspace(1) getelementptr inbounds (%structtype, ptr addrspace(1) @_ZTV10MultiplyOp, i64 0, i32 0, i64 2)
  store ptr addrspace(1) %., ptr addrspace(1) %_arg_DeviceStorage, align 8
  br label %_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit

_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit: ; preds = %if.end.i, %entry
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

; Function Attrs: convergent nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage, ptr addrspace(1) nocapture writeonly align 4 %_arg_DataAcc, ptr noalias nocapture readonly byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc3, ptr addrspace(3) noalias align 4 %_arg_LocalAcc) #1 !no_barrier_path !8 !vectorized_width !9 !spirv.ParameterDecorations !13 !vectorized_kernel !18 {
entry:
  call void @dummy_barrier.()
  %0 = load i64, ptr %_arg_DataAcc3, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %0
  %1 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %2 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  call void @_Z18work_group_barrierj(i32 1)
  %3 = tail call addrspace(4) i32 %2(ptr addrspace(4) %1) #5
  br label %Split.Barrier.BB2

Split.Barrier.BB2:                                ; preds = %Split.Barrier.BB1
  call void @dummy_barrier.()
  %4 = tail call i64 @_Z13get_global_idj(i32 0) #2
  %arrayidx.i = getelementptr inbounds i32, ptr addrspace(1) %add.ptr.i, i64 %4
  store i32 %3, ptr addrspace(1) %arrayidx.i, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB2
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

; Function Attrs: convergent nounwind willreturn memory(none)
declare i64 @_Z13get_global_idj(i32) #2

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) #3

; Function Attrs: convergent nounwind
define internal i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) nocapture readonly %LocalData) #3 !spirv.ParameterDecorations !19 {
entry:
  call void @dummy_barrier.()
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #6
  %0 = load i32, ptr addrspace(4) %LocalData, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB1
  call void @_Z18work_group_barrierj(i32 1)
  ret i32 %0
}

; Function Attrs: convergent nounwind
define internal i32 @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) nocapture readonly %LocalData) #3 !spirv.ParameterDecorations !19 {
entry:
  call void @dummy_barrier.()
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #6
  %0 = load i32, ptr addrspace(4) %LocalData, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB1
  call void @_Z18work_group_barrierj(i32 1)
  ret i32 %0
}

; CHECK: define void @_ZGVeN4uuuu__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; CHECK-SAME: !barrier_buffer_size [[SIZE:![0-9]+]] !private_memory_size [[SIZE]]
; CHECK: [[SIZE]] = !{i64 128}

; Function Attrs: convergent
define void @_ZGVeN4uuuu__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage, ptr addrspace(1) nocapture writeonly align 4 %_arg_DataAcc, ptr noalias nocapture readonly byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc3, ptr addrspace(3) noalias align 4 %_arg_LocalAcc) #4 !no_barrier_path !8 !vectorized_width !22 !spirv.ParameterDecorations !13 !scalar_kernel !23 {
entry:
  call void @dummy_barrier.()
  %0 = tail call i64 @_Z13get_global_idj(i32 0) #2
  %1 = load i64, ptr %_arg_DataAcc3, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %1
  %2 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %3 = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %4 = load ptr addrspace(4), ptr addrspace(4) %3, align 8
  br label %Split.Barrier.BB10

Split.Barrier.BB10:                               ; preds = %entry
  call void @_Z18work_group_barrierj(i32 1)
  %5 = tail call addrspace(4) i32 %4(ptr addrspace(4) %2) #5
  br label %Split.Barrier.BB14

Split.Barrier.BB14:                               ; preds = %Split.Barrier.BB10
  call void @dummy_barrier.()
  %6 = insertelement <4 x i32> poison, i32 %5, i64 0
  br label %Split.Barrier.BB9

Split.Barrier.BB9:                                ; preds = %Split.Barrier.BB14
  call void @_Z18work_group_barrierj(i32 1)
  %7 = tail call addrspace(4) i32 %4(ptr addrspace(4) %2) #5
  br label %Split.Barrier.BB13

Split.Barrier.BB13:                               ; preds = %Split.Barrier.BB9
  call void @dummy_barrier.()
  %8 = insertelement <4 x i32> %6, i32 %7, i64 1
  br label %Split.Barrier.BB8

Split.Barrier.BB8:                                ; preds = %Split.Barrier.BB13
  call void @_Z18work_group_barrierj(i32 1)
  %9 = tail call addrspace(4) i32 %4(ptr addrspace(4) %2) #5
  br label %Split.Barrier.BB12

Split.Barrier.BB12:                               ; preds = %Split.Barrier.BB8
  call void @dummy_barrier.()
  %10 = insertelement <4 x i32> %8, i32 %9, i64 2
  br label %Split.Barrier.BB7

Split.Barrier.BB7:                                ; preds = %Split.Barrier.BB12
  call void @_Z18work_group_barrierj(i32 1)
  %11 = tail call addrspace(4) i32 %4(ptr addrspace(4) %2) #5
  br label %Split.Barrier.BB11

Split.Barrier.BB11:                               ; preds = %Split.Barrier.BB7
  call void @dummy_barrier.()
  %12 = insertelement <4 x i32> %10, i32 %11, i64 3
  %scalar.gep = getelementptr inbounds i32, ptr addrspace(1) %add.ptr.i, i64 %0
  store <4 x i32> %12, ptr addrspace(1) %scalar.gep, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB11
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

declare void @dummy_barrier.()

; Function Attrs: convergent
declare void @_Z18work_group_barrierj(i32) #4

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "kernel-call-once" "kernel-convergent-call" }
attributes #1 = { convergent nounwind "vector-variants"="_ZGVeN4uuuu__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_" }
attributes #2 = { convergent nounwind willreturn memory(none) }
attributes #3 = { convergent nounwind "kernel-call-once" "kernel-convergent-call" }
attributes #4 = { convergent }
attributes #5 = { nounwind }
attributes #6 = { convergent nounwind "kernel-call-once" "kernel-convergent-call" "kernel-uniform-call" }

!spirv.Source = !{!6, !6}
!sycl.kernels = !{!7}

!0 = !{!1, !2, !3}
!1 = !{i32 22}
!2 = !{i32 41, !"_ZTV10MultiplyOp", i32 2}
!3 = !{i32 44, i32 8}
!4 = !{!1, !5, !3}
!5 = !{i32 41, !"_ZTV5SumOp", i32 2}
!6 = !{i32 4, i32 100000}
!7 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_, ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}
!8 = !{i1 false}
!9 = !{i32 1}
!10 = !{!11, !12}
!11 = !{!3}
!12 = !{}
!13 = !{!11, !14, !16, !14}
!14 = !{!15}
!15 = !{i32 44, i32 4}
!16 = !{!17, !3}
!17 = !{i32 38, i32 2}
!18 = !{ptr @_ZGVeN4uuuu__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}
!19 = !{!11, !12, !20}
!20 = !{!17, !21}
!21 = !{i32 44, i32 1}
!22 = !{i32 4}
!23 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}

; DEBUGIFY-COUNT-7:  WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_
; DEBUGIFY-COUNT-13: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; DEBUGIFY-COUNT-7:  WARNING: Instruction with empty DebugLoc in function _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; DEBUGIFY-COUNT-7:  WARNING: Instruction with empty DebugLoc in function _ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; DEBUGIFY-COUNT-12: WARNING: Instruction with empty DebugLoc in function _ZGVeN4uuuu__ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; DEBUGIFY: WARNING: Missing line 11
; DEBUGIFY: WARNING: Missing line 12
; DEBUGIFY: WARNING: Missing line 13
; DEBUGIFY: WARNING: Missing line 14
; DEBUGIFY: WARNING: Missing line 15
; DEBUGIFY: WARNING: Missing line 43
; DEBUGIFY: WARNING: Missing line 44
; DEBUGIFY: WARNING: Missing line 45
; DEBUGIFY-NOT: WARNING
