; RUN: opt -passes=sycl-kernel-barrier %s -S -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-barrier %s -S | FileCheck %s

; IR is generated from sycl/test-e2e/VirtualFunctions/misc/group-barrier.cpp
; Check that
; 1. Indirect call return value is handled in fixCallInstruction.
; 2. Special buffer value of call instruction isn't handled for indirect call.

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

; CHECK-LABEL: define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; CHECK: tail call addrspace(4) i32 %{{[0-9]+}}(ptr addrspace(4) %{{[0-9]+}}, ptr addrspace(4) %{{[0-9]+}}, i8 undef)
; CHECK-NEXT: br label %Split.Barrier.BB2

  %4 = tail call addrspace(4) i32 %3(ptr addrspace(4) %0, ptr addrspace(4) %2, i8 undef) #1
  br label %Split.Barrier.BB2

; CHECK: SyncBB3:
; CHECK: [[ASC:%[0-9]+]] = addrspacecast ptr addrspace(4) %0 to ptr
; CHECK-NEXT: [[CMP1:%[0-9]+]] = icmp eq ptr [[ASC]], @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; CHECK-NEXT: br i1 [[CMP1]], label %[[THEN1:[0-9]+]], label %[[END1:[0-9]+]]
; CHECK: [[THEN1]]:
; CHECK-NEXT:   %SBIndex = load i64, ptr %pCurrSBIndex, align 8
; CHECK-NEXT:   %SB_LocalId_Offset = add nuw i64 %SBIndex, 4
; CHECK-NEXT:   %pSB_LocalId = getelementptr inbounds i8, ptr %pSB, i64 %SB_LocalId_Offset
; CHECK-NEXT:   %loadedValue = load i32, ptr %pSB_LocalId, align 4
; CHECK-NEXT:   br label %[[END1]]
; CHECK: [[END1]]:
; CHECK-NEXT:   [[PHI1:%loadedValue[0-9]+]] = phi i32 [ %loadedValue, %14 ], [ undef, %SyncBB3 ]
; CHECK-NEXT:   [[CMP2:%[0-9]+]] = icmp eq ptr %12, @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; CHECK-NEXT:   br i1 [[CMP2]], label %[[THEN2:[0-9]+]], label %[[END2:[0-9]+]]
; CHECK: [[THEN2]]:
; CHECK-NEXT:   [[INDEX1:%SBIndex[0-9]+]] = load i64, ptr %pCurrSBIndex, align 8
; CHECK-NEXT:   [[OFFSET1:%SB_LocalId_Offset[0-9]+]] = add nuw i64 [[INDEX1]], 8
; CHECK-NEXT:   [[GEP1:%pSB_LocalId[0-9]+]] = getelementptr inbounds i8, ptr %pSB, i64 [[OFFSET1]]
; CHECK-NEXT:   [[LOAD1:%loadedValue[0-9]+]] = load i32, ptr [[GEP1]], align 4
; CHECK-NEXT:   br label %[[END2]]
; CHECK: [[END2]]:
; CHECK-NEXT:   [[PHI2:%loadedValue[0-9]+]] = phi i32 [ [[LOAD1]], %17 ], [ [[PHI1]], %15 ]
; CHECK-NEXT:   [[INDEX2:%SBIndex[0-9]+]] = load i64, ptr %pCurrSBIndex, align 8
; CHECK-NEXT:   [[OFFSET2:%SB_LocalId_Offset[0-9]+]] = add nuw i64 [[INDEX2]], 0
; CHECK-NEXT:   [[GEP2:%pSB_LocalId[0-9]+]] = getelementptr inbounds i8, ptr %pSB, i64 [[OFFSET2]]
; CHECK-NEXT:   store i32 [[PHI2]], ptr [[GEP2]], align 4

Split.Barrier.BB2:                                ; preds = %Split.Barrier.BB1
  call void @dummy_barrier.()
  store i32 %4, ptr addrspace(1) %add.ptr.i, align 4
  br label %Split.Barrier.BB

Split.Barrier.BB:                                 ; preds = %Split.Barrier.BB2
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) #2

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

!spirv.Source = !{!6}
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

; DEBUGIFY-COUNT-7: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_
; DEBUGIFY-COUNT-13: WARNING: Instruction with empty DebugLoc in function _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; DEBUGIFY-COUNT-7: WARNING: Instruction with empty DebugLoc in function _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; DEBUGIFY-COUNT-7: WARNING: Instruction with empty DebugLoc in function _ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; DEBUGIFY: WARNING: Missing line 11
; DEBUGIFY: WARNING: Missing line 12
; DEBUGIFY: WARNING: Missing line 13
; DEBUGIFY: WARNING: Missing line 14
; DEBUGIFY: WARNING: Missing line 15
; DEBUGIFY: WARNING: Missing line 16
; DEBUGIFY-NOT: WARNING
