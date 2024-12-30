; RUN: opt -passes='print<sycl-kernel-indirect-call-analysis>' %s -disable-output 2>&1 | FileCheck %s

; Check indirect call and virtual functions are found.

; CHECK:      Indirect calls:
; CHECK-NEXT:   FunctionType: i32 (ptr addrspace(4), ptr addrspace(4), ptr)
; CHECK-NEXT:     Indirect call:   %call = call addrspace(4) i32 %2(ptr addrspace(4) %0, ptr addrspace(4) %1, ptr byval(%"class.sycl::_V1::nd_item") %agg.tmp)
; CHECK-NEXT: Indirectly called functions:
; CHECK-NEXT:   _ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE
; CHECK-NEXT:   _ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { [3 x ptr addrspace(4)] }
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }
%"class.sycl::_V1::nd_item" = type { i8 }

@_ZTV10MultiplyOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !0
@_ZTV5SumOp = linkonce_odr addrspace(1) constant %structtype { [3 x ptr addrspace(4)] [ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE to ptr addrspace(4))] }, align 8, !spirv.Decorations !4

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlvE_(ptr addrspace(1) align 8 %_arg_DeviceStorage, i32 %_arg_TestCase) #0 !kernel_arg_addr_space !8 !kernel_arg_access_qual !9 !kernel_arg_type !10 !kernel_arg_base_type !10 !kernel_arg_type_qual !11 !kernel_arg_target_ext_type !11 {
entry:
  %cmp.i = icmp ugt i32 %_arg_TestCase, 1
  %0 = bitcast ptr addrspace(1) @_ZTV10MultiplyOp to ptr addrspace(1)
  %1 = getelementptr inbounds i8, ptr addrspace(1) %0, i64 16
  %2 = bitcast ptr addrspace(1) @_ZTV5SumOp to ptr addrspace(1)
  %3 = getelementptr inbounds i8, ptr addrspace(1) %2, i64 16
  br i1 %cmp.i, label %_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit, label %if.end.i

if.end.i:                                         ; preds = %entry
  %cmp.not.i.i = icmp eq i32 %_arg_TestCase, 0
  br i1 %cmp.not.i.i, label %if.end.i.i, label %if.end.i.i.i

if.end.i.i.i:                                     ; preds = %if.end.i
  store ptr addrspace(1) %1, ptr addrspace(1) %_arg_DeviceStorage, align 8
  br label %_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit

if.end.i.i:                                       ; preds = %if.end.i
  store ptr addrspace(1) %3, ptr addrspace(1) %_arg_DeviceStorage, align 8
  br label %_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit

_ZN13obj_storage_tIJ5SumOp10MultiplyOpEE9constructI6BaseOpJEEEPT_jDpT0_.exit: ; preds = %if.end.i.i, %if.end.i.i.i, %entry
  ret void
}

; Function Attrs: nounwind
define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE0_clES2_EUlT_E_(ptr addrspace(1) align 8 %_arg_DeviceStorage, ptr addrspace(1) align 4 %_arg_DataAcc, ptr byval(%"class.sycl::_V1::id") align 8 %_arg_DataAcc3, ptr addrspace(3) align 4 %_arg_LocalAcc) #0 !kernel_arg_addr_space !12 !kernel_arg_access_qual !13 !kernel_arg_type !14 !kernel_arg_base_type !14 !kernel_arg_type_qual !15 !kernel_arg_target_ext_type !15 {
entry:
  %agg.tmp = alloca %"class.sycl::_V1::nd_item", align 1
  %0 = addrspacecast ptr addrspace(1) %_arg_DeviceStorage to ptr addrspace(4)
  %1 = addrspacecast ptr addrspace(3) %_arg_LocalAcc to ptr addrspace(4)
  %vtable.i = load ptr addrspace(4), ptr addrspace(1) %_arg_DeviceStorage, align 8
  %2 = load ptr addrspace(4), ptr addrspace(4) %vtable.i, align 8
  %call = call addrspace(4) i32 %2(ptr addrspace(4) %0, ptr addrspace(4) %1, ptr byval(%"class.sycl::_V1::nd_item") %agg.tmp)
  ret void
}

; Function Attrs: nounwind
define i32 @_ZN5SumOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(4) %LocalData, ptr byval(%"class.sycl::_V1::nd_item") align 1 %It) #0 {
entry:
  ret i32 0
}

; Function Attrs: nounwind
define i32 @_ZN10MultiplyOp5applyEPiN4sycl3_V17nd_itemILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(4) %LocalData, ptr byval(%"class.sycl::_V1::nd_item") align 1 %It) #0 {
entry:
  ret i32 0
}

attributes #0 = { nounwind }

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
!8 = !{i32 1, i32 0}
!9 = !{!"none", !"none"}
!10 = !{!"char**", !"int"}
!11 = !{!"", !""}
!12 = !{i32 1, i32 1, i32 0, i32 3}
!13 = !{!"none", !"none", !"none", !"none"}
!14 = !{!"int (*)(char*,char*,class.sycl::_V1::nd_item*)**", !"int*", !"class.sycl::_V1::id", !"char*"}
!15 = !{!"", !"", !"", !""}
