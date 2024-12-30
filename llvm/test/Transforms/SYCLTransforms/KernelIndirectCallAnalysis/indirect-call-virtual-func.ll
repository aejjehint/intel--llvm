; RUN: opt -passes='print<sycl-kernel-indirect-call-analysis>' %s -disable-output 2>&1 | FileCheck %s

; Check indirect call is found.

; CHECK:      Indirect calls:
; CHECK-NEXT:   FunctionType: i32 (ptr addrspace(4), ptr addrspace(4), ptr)
; CHECK-NEXT:     Indirect call:   %call8.i = call addrspace(4) i32 %9(ptr addrspace(4) %6, ptr addrspace(4) %7, ptr byval(%"class.sycl::_V1::nd_item") %agg.tmp7.i), !spirv.Decorations !18
; CHECK-NEXT: Indirectly called functions:
; CHECK-NEXT:   _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }
%struct.obj_storage_t = type { %"struct.aligned_storage<SumOp>::type" }
%"struct.aligned_storage<SumOp>::type" = type { [8 x i8] }
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }
%"class.sycl::_V1::nd_item" = type { i8 }

@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !0

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) align 8 %_arg_DeviceStorage) #0 !kernel_arg_addr_space !6 !kernel_arg_access_qual !7 !kernel_arg_type !8 !kernel_arg_base_type !8 !kernel_arg_type_qual !9 !kernel_arg_target_ext_type !9 !spirv.ParameterDecorations !10 {
entry:
  %storage.i.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  %0 = getelementptr inbounds %structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2
  %1 = bitcast ptr addrspace(1) %storage.i.i to ptr addrspace(1)
  store ptr addrspace(1) %0, ptr addrspace(1) %1, align 8
  ret void
}

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(3) align 4 %_arg_LocalAcc, ptr addrspace(1) align 4 %_arg_DataAcc, ptr byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc6, ptr addrspace(1) align 8 %_arg_DeviceStorage) #0 !kernel_arg_addr_space !12 !kernel_arg_access_qual !13 !kernel_arg_type !14 !kernel_arg_base_type !14 !kernel_arg_type_qual !15 !kernel_arg_target_ext_type !15 !spirv.ParameterDecorations !16 {
entry:
  %agg.tmp7.i = alloca %"class.sycl::_V1::nd_item", align 1, !spirv.Decorations !21
  %0 = bitcast ptr %_arg_DataAcc6 to ptr
  %1 = load i64, ptr %0, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %1
  %2 = bitcast ptr %agg.tmp7.i to ptr
  call void @llvm.lifetime.start.p0(i64 1, ptr %2)
  %3 = call i64 @_Z13get_global_idj(i32 0) #3
  %arrayidx.i = getelementptr inbounds i32, ptr addrspace(1) %add.ptr.i, i64 %3
  %4 = load i32, ptr addrspace(1) %arrayidx.i, align 4
  %5 = call i64 @_Z12get_local_idj(i32 0) #3
  %arrayidx.i28 = getelementptr inbounds i32, ptr addrspace(3) %_arg_LocalAcc, i64 %5
  store i32 %4, ptr addrspace(3) %arrayidx.i28, align 4
  %storage.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  %6 = addrspacecast ptr addrspace(1) %storage.i to ptr addrspace(4)
  %7 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %8 = bitcast ptr addrspace(1) %storage.i to ptr addrspace(1)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %8, align 8
  %9 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  %call8.i = call addrspace(4) i32 %9(ptr addrspace(4) %6, ptr addrspace(4) %7, ptr byval(%"class.sycl::_V1::nd_item") %agg.tmp7.i), !spirv.Decorations !23
  store i32 %call8.i, ptr addrspace(1) %arrayidx.i, align 4
  %10 = bitcast ptr %agg.tmp7.i to ptr
  call void @llvm.lifetime.end.p0(i64 1, ptr %10)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind
define i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(4) %LocalData, ptr byval(%"class.sycl::_V1::nd_item") align 1 %It) #0 !spirv.ParameterDecorations !25 {
entry:
  %0 = call i64 @_Z12get_local_idj(i32 0) #3
  %cmp.i7 = icmp ult i64 %0, 2147483648
  call void @llvm.assume(i1 %cmp.i7)
  %arrayidx = getelementptr inbounds i32, ptr addrspace(4) %LocalData, i64 %0
  %1 = load i32, ptr addrspace(4) %arrayidx, align 4
  %2 = trunc i64 %0 to i32
  %conv4 = add i32 %1, %2
  store i32 %conv4, ptr addrspace(4) %arrayidx, align 4
  call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #4
  %arrayidx5 = getelementptr inbounds i32, ptr addrspace(4) %LocalData, i64 1
  %3 = load i32, ptr addrspace(4) %arrayidx5, align 4
  ret i32 %3
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #2

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z13get_global_idj(i32) #3

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z12get_local_idj(i32) #3

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) #4

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #3 = { nounwind willreturn memory(none) }
attributes #4 = { convergent nounwind }

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
!21 = !{!22}
!22 = !{i32 44, i32 1}
!23 = !{!24}
!24 = !{i32 6409, i32 2, i32 2}
!25 = !{!11, !26, !27}
!26 = !{}
!27 = !{!20, !22}
