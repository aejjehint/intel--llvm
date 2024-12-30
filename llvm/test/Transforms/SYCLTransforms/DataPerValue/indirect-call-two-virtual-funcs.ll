; RUN: opt -passes='print<sycl-kernel-data-per-value-analysis>' %s -disable-output 2>&1 | FileCheck %s

; _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE and
; _ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE are virtual functions that
; have the same base.
; They're called in _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_.
; Check the three functions are in the same equivalence set.

; CHECK: Function Equivalence Classes:
; CHECK-DAG: [_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_]: _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_
; CHECK-DAG: [_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_]: _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_ _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE _ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }

@_ZTV10MultiplyOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !0
@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) nocapture writeonly align 8 %_arg_DeviceStorage, i32 %_arg_TestCase) #0 !no_barrier_path !8 !spirv.ParameterDecorations !9 {
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

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage, ptr addrspace(1) nocapture writeonly align 4 %_arg_DataAcc, ptr noalias nocapture readonly byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc3, ptr addrspace(3) noalias align 4 %_arg_LocalAcc) #1 !no_barrier_path !8 !spirv.ParameterDecorations !12 {
entry:
  call void @dummy_barrier.()
  %0 = addrspacecast ptr addrspace(1) %_arg_DeviceStorage to ptr addrspace(4)
  %1 = load i64, ptr %_arg_DataAcc3, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %1
  %2 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %3 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  call void @_Z18work_group_barrierj(i32 1)
  %4 = tail call addrspace(4) i32 %3(ptr addrspace(4) %0, ptr addrspace(4) %2, i8 undef) #1
  br label %Split.Barrier.BB2

Split.Barrier.BB2:                                ; preds = %Split.Barrier.BB1
  call void @dummy_barrier.()
  store i32 %4, ptr addrspace(1) %add.ptr.i, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB2
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) local_unnamed_addr #2

; Function Attrs: convergent nounwind
define internal i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) nocapture readnone align 8 %this, ptr addrspace(4) nocapture readonly %LocalData, i8 %It.coerce.high) #2 !spirv.ParameterDecorations !17 {
entry:
  call void @dummy_barrier.()
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #2
  %0 = load i32, ptr addrspace(4) %LocalData, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB1
  call void @_Z18work_group_barrierj(i32 1)
  ret i32 %0
}

; Function Attrs: convergent nounwind
define internal i32 @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) nocapture readnone align 8 %this, ptr addrspace(4) nocapture readonly %LocalData, i8 %It.coerce.high) #2 !spirv.ParameterDecorations !17 {
entry:
  call void @dummy_barrier.()
  br label %Split.Barrier.BB1

Split.Barrier.BB1:                                ; preds = %entry
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #2
  %0 = load i32, ptr addrspace(4) %LocalData, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB1
  call void @_Z18work_group_barrierj(i32 1)
  ret i32 %0
}

declare void @dummy_barrier.()

; Function Attrs: convergent
declare void @_Z18work_group_barrierj(i32) #3

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "kernel-call-once" "kernel-convergent-call" }
attributes #1 = { nounwind }
attributes #2 = { convergent nounwind "kernel-call-once" "kernel-convergent-call" }
attributes #3 = { convergent }

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
!9 = !{!10, !11}
!10 = !{!3}
!11 = !{}
!12 = !{!10, !13, !15, !13}
!13 = !{!14}
!14 = !{i32 44, i32 4}
!15 = !{!16, !3}
!16 = !{i32 38, i32 2}
!17 = !{!10, !11, !18}
!18 = !{!16, !19}
!19 = !{i32 44, i32 1}
