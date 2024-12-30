; RUN: opt -passes=sycl-kernel-coerce-types -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-coerce-types -S %s -o - | FileCheck %s

; Check argument of indirect called function is also coerced.

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
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) align 8 %_arg_DeviceStorage) #0 !kernel_arg_addr_space !6 !kernel_arg_access_qual !7 !kernel_arg_type !8 !kernel_arg_base_type !8 !kernel_arg_type_qual !9 !kernel_arg_target_ext_type !9 {
entry:
  %storage.i.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  %0 = getelementptr inbounds %structtype, ptr addrspace(1) @_ZTV5SumOp, i64 0, i32 0, i64 2
  %1 = bitcast ptr addrspace(1) %storage.i.i to ptr addrspace(1)
  store ptr addrspace(1) %0, ptr addrspace(1) %1, align 8
  ret void
}

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(3) align 4 %_arg_LocalAcc, ptr addrspace(1) align 4 %_arg_DataAcc, ptr byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc6, ptr addrspace(1) align 8 %_arg_DeviceStorage) #0 !kernel_arg_addr_space !10 !kernel_arg_access_qual !11 !kernel_arg_type !12 !kernel_arg_base_type !12 !kernel_arg_type_qual !13 !kernel_arg_target_ext_type !13 {
entry:
  %agg.tmp7.i = alloca %"class.sycl::_V1::nd_item", align 1, !spirv.Decorations !14
  %0 = bitcast ptr %_arg_DataAcc6 to ptr
  %1 = load i64, ptr %0, align 8
  %add.ptr.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_DataAcc, i64 %1
  %2 = call i64 @_Z13get_global_idj(i32 0) #1
  %arrayidx.i = getelementptr inbounds i32, ptr addrspace(1) %add.ptr.i, i64 %2
  %3 = load i32, ptr addrspace(1) %arrayidx.i, align 4
  %4 = call i64 @_Z12get_local_idj(i32 0) #1
  %arrayidx.i28 = getelementptr inbounds i32, ptr addrspace(3) %_arg_LocalAcc, i64 %4
  store i32 %3, ptr addrspace(3) %arrayidx.i28, align 4
  %storage.i = getelementptr inbounds %struct.obj_storage_t, ptr addrspace(1) %_arg_DeviceStorage, i64 0, i32 0
  %5 = addrspacecast ptr addrspace(1) %storage.i to ptr addrspace(4)
  %6 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %7 = bitcast ptr addrspace(1) %storage.i to ptr addrspace(1)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %7, align 8
  %8 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8

; CHECK-LABEL: define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_
; CHECK: [[FUNC:%[0-9]+]] = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
; CHECK-NEXT: [[ARG:%[0-9]+]] = load i8, ptr %agg.tmp7.i, align 1
; CHECK-NEXT: call addrspace(4) i32 [[FUNC]](ptr addrspace(4) {{.*}}, ptr addrspace(4) {{.*}}, i8 [[ARG]])

  %call8.i = call addrspace(4) i32 %8(ptr addrspace(4) %5, ptr addrspace(4) %6, ptr byval(%"class.sycl::_V1::nd_item") %agg.tmp7.i), !spirv.Decorations !16
  ret void
}

; Function Attrs: nounwind
define i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(4) %LocalData, ptr byval(%"class.sycl::_V1::nd_item") align 1 %It) #0 !spirv.ParameterDecorations !18 {
entry:

; CHECK-LABEL: define i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(4) %LocalData, i8 %It.coerce.high)
; CHECK: [[ALLOCA:%[0-9]+]] = alloca %"class.sycl::_V1::nd_item", align 1
; CHECK: store i8 %It.coerce.high, ptr [[ALLOCA]], align 1

  ret i32 0
}

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z13get_global_idj(i32) #1

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z12get_local_idj(i32) #1

attributes #0 = { nounwind }
attributes #1 = { nounwind willreturn memory(none) }

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
!10 = !{i32 3, i32 1, i32 0, i32 1}
!11 = !{!"none", !"none", !"none", !"none"}
!12 = !{!"int*", !"int*", !"class.sycl::_V1::id", !"struct obj_storage_t*"}
!13 = !{!"", !"", !"", !""}
!14 = !{!15}
!15 = !{i32 44, i32 1}
!16 = !{!17}
!17 = !{i32 6409, i32 2, i32 2}
!18 = !{!19, !20, !21}
!19 = !{!3}
!20 = !{}
!21 = !{!22, !15}
!22 = !{i32 38, i32 2}

; DEBUGIFY-NOT: WARNING
