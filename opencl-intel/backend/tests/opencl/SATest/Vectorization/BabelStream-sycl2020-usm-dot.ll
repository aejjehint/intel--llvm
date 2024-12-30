target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-G1"
target triple = "spir64-unknown-unknown"

%class.__generated_ = type { i64, %"class.sycl::_V1::range", %class.__generated_.0 }
%"class.sycl::_V1::range" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }
%class.__generated_.0 = type { ptr addrspace(1), ptr addrspace(1) }

; Function Attrs: nounwind
define spir_kernel void @_ZTSZZN4sycl3_V16detail16NDRangeReductionILNS1_9reduction8strategyE1EE3runINS1_9auto_nameELi1ENS0_3ext6oneapi12experimental10propertiesISt5tupleIJEEEEZNS1_22reduction_parallel_forIS7_LS4_0ELi1ESE_JNS1_14reduction_implIdSt4plusIdELi0ELm1ELb0EPdEEZZN10SYCLStreamIdE3dotEvENKUlRNS0_7handlerEE_clESO_EUlNS0_2idILi1EEERT_E_EEEvSO_NS0_5rangeIXT1_EEET2_DpT3_EUlSS_DpRT0_E_SK_EEvSO_RSt10shared_ptrINS1_10queue_implEENS0_8nd_rangeIXT0_EEERT1_RT3_RSX_ENKUlSS_E_clINS0_8accessorIiLi1ELNS0_6access4modeE1026ELNS1I_6targetE2014ELNS1I_11placeholderE0ENS9_22accessor_property_listIJEEEEEEEDaSS_EUlNS0_7nd_itemILi1EEEE_(ptr byval(%class.__generated_) align 8 %0, i64 %1, i64 %2, i1 zeroext %3, ptr addrspace(1) align 8 %4, ptr addrspace(1) align 8 %5, ptr byval(%"class.sycl::_V1::range") align 8 %6, ptr addrspace(1) align 4 %7, ptr byval(%"class.sycl::_V1::range") align 8 %8, ptr addrspace(3) align 4 %9, i64 %10) #0 !kernel_arg_addr_space !6 !kernel_arg_access_qual !7 !kernel_arg_type !8 !kernel_arg_type_qual !9 !kernel_arg_base_type !8 !spirv.ParameterDecorations !10 {
  %12 = bitcast ptr %0 to ptr
  %13 = load i64, ptr %12, align 8
  %14 = bitcast ptr %0 to ptr
  %15 = getelementptr inbounds i64, ptr %14, i64 1
  %16 = load i64, ptr %15, align 8
  %17 = bitcast ptr %0 to ptr
  %18 = getelementptr inbounds i8, ptr %17, i64 16
  %19 = bitcast ptr %18 to ptr
  %20 = load ptr addrspace(4), ptr %19, align 8
  %21 = bitcast ptr %0 to ptr
  %22 = getelementptr inbounds i8, ptr %21, i64 24
  %23 = bitcast ptr %22 to ptr
  %24 = load ptr addrspace(4), ptr %23, align 8
  %25 = bitcast ptr %6 to ptr
  %26 = load i64, ptr %25, align 8
  %27 = getelementptr inbounds double, ptr addrspace(1) %5, i64 %26
  %28 = bitcast ptr %8 to ptr
  %29 = load i64, ptr %28, align 8
  %30 = getelementptr inbounds i32, ptr addrspace(1) %7, i64 %29
  %31 = call spir_func i64 @_Z14get_num_groupsj(i32 0) #2
  %32 = call spir_func i64 @_Z12get_group_idj(i32 0) #2
  %33 = add i64 %31, -1
  %34 = icmp eq i64 %32, %33
  %35 = mul i64 %32, %13
  br i1 %34, label %.preheader1, label %41

.preheader1:                                      ; preds = %11
  br label %36

36:                                               ; preds = %39, %.preheader1
  %37 = phi i64 [ %40, %39 ], [ 1, %.preheader1 ]
  %38 = phi i1 [ false, %39 ], [ true, %.preheader1 ]
  br i1 %38, label %39, label %.loopexit2

39:                                               ; preds = %36
  %40 = mul i64 %37, %16
  br label %36

41:                                               ; preds = %11
  %42 = add i64 %35, %13
  br label %43

.loopexit2:                                       ; preds = %36
  br label %43

43:                                               ; preds = %.loopexit2, %41
  %44 = phi i64 [ %42, %41 ], [ %37, %.loopexit2 ]
  %45 = call spir_func i64 @_Z12get_local_idj(i32 0) #2
  %46 = icmp ult i64 %45, 2147483648
  call void @llvm.assume(i1 %46)
  %47 = add i64 %35, %45
  %48 = call spir_func i64 @_Z14get_local_sizej(i32 0) #2
  %49 = icmp ult i64 %48, 2147483648
  call void @llvm.assume(i1 %49)
  br label %50

50:                                               ; preds = %60, %43
  %51 = phi double [ 0.000000e+00, %43 ], [ %67, %60 ]
  %52 = phi i64 [ %47, %43 ], [ %68, %60 ]
  %53 = icmp ult i64 %52, %44
  br i1 %53, label %60, label %54

54:                                               ; preds = %50
  %55 = icmp eq i64 %45, 0
  %56 = icmp ult i64 %32, 2147483648
  %57 = icmp eq i64 %2, 1
  %58 = mul i64 %32, %1
  %59 = getelementptr double, ptr addrspace(1) %27, i64 %58
  br label %69

60:                                               ; preds = %50
  %61 = icmp ult i64 %52, 2147483648
  call void @llvm.assume(i1 %61)
  %62 = getelementptr inbounds double, ptr addrspace(4) %20, i64 %52
  %63 = load double, ptr addrspace(4) %62, align 8
  %64 = getelementptr inbounds double, ptr addrspace(4) %24, i64 %52
  %65 = load double, ptr addrspace(4) %64, align 8
  %66 = fmul reassoc nsz arcp contract double %63, %65
  %67 = fadd reassoc nsz arcp contract double %51, %66
  %68 = add nuw nsw i64 %52, %48
  br label %50

69:                                               ; preds = %88, %54
  %70 = phi double [ %89, %88 ], [ %51, %54 ]
  %71 = phi i64 [ %90, %88 ], [ 0, %54 ]
  %72 = icmp ult i64 %71, %1
  br i1 %72, label %75, label %73

73:                                               ; preds = %69
  %74 = icmp eq i64 %2, 1
  br i1 %74, label %107, label %91

75:                                               ; preds = %69
  %76 = call spir_func double @_Z21work_group_reduce_addd(double %70) #3
  br i1 %55, label %77, label %88

77:                                               ; preds = %75
  br i1 %57, label %78, label %86

78:                                               ; preds = %77
  br i1 %3, label %79, label %83

79:                                               ; preds = %78
  %80 = getelementptr inbounds double, ptr addrspace(1) %4, i64 %71
  %81 = load double, ptr addrspace(1) %80, align 8
  %82 = fadd reassoc nsz arcp contract double %76, %81
  br label %83

83:                                               ; preds = %79, %78
  %84 = phi double [ %76, %78 ], [ %82, %79 ]
  %85 = getelementptr inbounds double, ptr addrspace(1) %4, i64 %71
  store double %84, ptr addrspace(1) %85, align 8
  br label %88

86:                                               ; preds = %77
  call void @llvm.assume(i1 %56)
  %87 = getelementptr double, ptr addrspace(1) %59, i64 %71
  store double %76, ptr addrspace(1) %87, align 8
  br label %88

88:                                               ; preds = %86, %83, %75
  %89 = phi double [ %84, %83 ], [ %76, %86 ], [ %76, %75 ]
  %90 = add nuw i64 %71, 1
  br label %69

91:                                               ; preds = %73
  br i1 %55, label %92, label %102

92:                                               ; preds = %91
  %93 = addrspacecast ptr addrspace(1) %30 to ptr addrspace(4)
  %94 = bitcast ptr addrspace(4) %93 to ptr addrspace(4)
  %95 = call spir_func ptr addrspace(1) @__to_global(ptr addrspace(4) %94) #0
  %96 = bitcast ptr addrspace(1) %95 to ptr addrspace(1)
  %97 = call spir_func i32 @_Z10atomic_addPU3AS1Vii(ptr addrspace(1) %96, i32 1) #0
  %98 = add nsw i32 %97, 1
  %99 = trunc i64 %2 to i32
  %100 = icmp eq i32 %98, %99
  %101 = select i1 %100, i32 1, i32 0
  store i32 %101, ptr addrspace(3) %9, align 4
  br label %102

102:                                              ; preds = %92, %91
  call spir_func void @_Z7barrierj(i32 1) #3
  %103 = load i32, ptr addrspace(3) %9, align 4
  %104 = icmp eq i32 %103, 0
  br i1 %104, label %107, label %105

105:                                              ; preds = %102
  %106 = getelementptr inbounds double, ptr addrspace(1) %4, i64 0
  store double 0.000000e+00, ptr addrspace(1) %106, align 8
  br label %107

107:                                              ; preds = %105, %102, %73
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #1

; Function Attrs: nounwind willreturn memory(none)
declare spir_func i64 @_Z14get_num_groupsj(i32) #2

; Function Attrs: nounwind willreturn memory(none)
declare spir_func i64 @_Z12get_group_idj(i32) #2

; Function Attrs: nounwind willreturn memory(none)
declare spir_func i64 @_Z12get_local_idj(i32) #2

; Function Attrs: nounwind willreturn memory(none)
declare spir_func i64 @_Z14get_local_sizej(i32) #2

; Function Attrs: convergent nounwind
declare spir_func double @_Z21work_group_reduce_addd(double) #3

; Function Attrs: nounwind
declare spir_func ptr addrspace(1) @__to_global(ptr addrspace(4)) #0

; Function Attrs: nounwind
declare spir_func i32 @_Z10atomic_addPU3AS1Vii(ptr addrspace(1), i32) #0

; Function Attrs: convergent nounwind
declare spir_func void @_Z7barrierj(i32) #3

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #2 = { nounwind willreturn memory(none) }
attributes #3 = { convergent nounwind }

!spirv.MemoryModel = !{!0}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!1}
!opencl.spir.version = !{!2}
!opencl.used.extensions = !{!3}
!opencl.used.optional.core.features = !{!4}
!spirv.Generator = !{!5}

!0 = !{i32 2, i32 2}
!1 = !{i32 4, i32 100000}
!2 = !{i32 1, i32 2}
!3 = !{!"cl_khr_subgroups"}
!4 = !{!"cl_doubles"}
!5 = !{i16 6, i16 14}
!6 = !{i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 0, i32 1, i32 0, i32 3, i32 0}
!7 = !{!"none", !"none", !"none", !"none", !"none", !"none", !"none", !"none", !"none", !"none", !"none"}
!8 = !{!"class.__generated_", !"long", !"long", !"bool", !"double*", !"double*", !"class.sycl::_V1::range", !"int*", !"class.sycl::_V1::range", !"int*", !"long"}
!9 = !{!"", !"", !"", !"", !"", !"", !"", !"", !"", !"", !""}
!10 = !{!11, !14, !14, !15, !17, !17, !11, !18, !11, !18, !14}
!11 = !{!12, !13}
!12 = !{i32 38, i32 2}
!13 = !{i32 44, i32 8}
!14 = !{}
!15 = !{!16}
!16 = !{i32 38, i32 0}
!17 = !{!13}
!18 = !{!19}
!19 = !{i32 44, i32 4}
