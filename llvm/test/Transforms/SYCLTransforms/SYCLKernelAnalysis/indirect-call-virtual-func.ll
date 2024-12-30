; RUN: opt -passes=sycl-kernel-analysis -sycl-kernel-analysis-assume-isamx=true %s -S -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-analysis -sycl-kernel-analysis-assume-isamx=true %s -S -debug -disable-output 2>&1| FileCheck %s

; Check kernel _ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_'s
; no_barrier_path metadata is false because it indirectly calls a function that
; contains a barrier.

; CHECK: Kernel <_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_>:
; CHECK-NEXT:   NoBarrierPath=0
; CHECK-NEXT:   KernelHasSubgroups=0
; CHECK-NEXT:   KernelHasGlobalSync=0
; CHECK-NEXT:   KernelExecutionLength=3
; CHECK-NEXT: Kernel <_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_>:
; CHECK-NEXT:   NoBarrierPath=0
; CHECK-NEXT:   KernelHasSubgroups=0
; CHECK-NEXT:   KernelHasGlobalSync=0
; CHECK-NEXT:   KernelExecutionLength=15

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }
%struct.obj_storage_t = type { %"struct.aligned_storage<SumOp>::type" }
%"struct.aligned_storage<SumOp>::type" = type { [8 x i8] }
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }

@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !0

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) nocapture writeonly align 8 %_arg_DeviceStorage) local_unnamed_addr #0 !kernel_arg_addr_space !6 !kernel_arg_access_qual !7 !kernel_arg_type !8 !kernel_arg_base_type !8 !kernel_arg_type_qual !9 !kernel_arg_target_ext_type !9 !spirv.ParameterDecorations !10 {
entry:
  %storage.i.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  store ptr addrspace(1) getelementptr inbounds (%structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2), ptr addrspace(1) %storage.i.i, align 8
  ret void
}

; Function Attrs: convergent nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(3) noalias align 4 %_arg_LocalAcc, ptr addrspace(1) nocapture align 4 %_arg_DataAcc, ptr noalias nocapture readonly byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc6, ptr addrspace(1) align 8 %_arg_DeviceStorage) local_unnamed_addr #1 !kernel_arg_addr_space !12 !kernel_arg_access_qual !13 !kernel_arg_type !14 !kernel_arg_base_type !14 !kernel_arg_type_qual !15 !kernel_arg_target_ext_type !15 !spirv.ParameterDecorations !16 {
entry:
  %0 = load i64, ptr %_arg_DataAcc6, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %0
  %1 = tail call i64 @_Z13get_global_idj(i32 0) #5
  %arrayidx.i = getelementptr inbounds i32, ptr addrspace(1) %add.ptr.i, i64 %1
  %2 = load i32, ptr addrspace(1) %arrayidx.i, align 4
  %3 = tail call i64 @_Z12get_local_idj(i32 0) #5
  %arrayidx.i28 = getelementptr inbounds i32, ptr addrspace(3) %_arg_LocalAcc, i64 %3
  store i32 %2, ptr addrspace(3) %arrayidx.i28, align 4
  %storage.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  %4 = addrspacecast ptr addrspace(1) %storage.i to ptr addrspace(4)
  %5 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %storage.i, align 8
  %6 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  %7 = tail call addrspace(4) i32 %6(ptr addrspace(4) %4, ptr addrspace(4) %5, i8 undef) #6
  ret void
}

; Function Attrs: convergent mustprogress nofree nounwind willreturn memory(none)
declare i64 @_Z13get_global_idj(i32) local_unnamed_addr #3

; Function Attrs: convergent mustprogress nofree nounwind willreturn memory(none)
declare i64 @_Z12get_local_idj(i32) local_unnamed_addr #3

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) local_unnamed_addr #4

; Function Attrs: convergent nounwind
define internal i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) nocapture readnone align 8 %this, ptr addrspace(4) nocapture %LocalData, i8 %It.coerce.high) #4 !spirv.ParameterDecorations !21 {
entry:
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #4
  ret i32 0
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "kernel-call-once" "kernel-convergent-call" }
attributes #1 = { convergent nounwind }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #3 = { convergent mustprogress nofree nounwind willreturn memory(none) }
attributes #4 = { convergent nounwind "kernel-call-once" "kernel-convergent-call" }
attributes #5 = { convergent nounwind willreturn memory(none) }
attributes #6 = { nounwind }

!spirv.Source = !{!4, !4}
!sycl.kernels = !{!5}

!0 = !{!1, !2, !3}
!1 = !{i32 22}
!2 = !{i32 41, !"_ZTV5SumOp", i32 2}
!3 = !{i32 44, i32 8}
!4 = !{i32 4, i32 100000}
!5 = !{ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_, ptr @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_}
!6 = !{i32 1}
!7 = !{!"none"}
!8 = !{!"struct obj_storage_t*"}
!9 = !{!""}
!10 = !{!11}
!11 = !{!3}
!12 = !{i32 3, i32 1, i32 0, i32 1}
!13 = !{!"none", !"none", !"none", !"none"}
!14 = !{!"int*", !"int*", !"class.sycl::_V1::id", !"struct obj_storage_t*"}
!15 = !{!"", !"", !"", !""}
!16 = !{!17, !17, !19, !11}
!17 = !{!18}
!18 = !{i32 44, i32 4}
!19 = !{!20, !3}
!20 = !{i32 38, i32 2}
!21 = !{!11, !22, !23}
!22 = !{}
!23 = !{!20, !24}
!24 = !{i32 44, i32 1}

; DEBUGIFY-NOT: WARNING
