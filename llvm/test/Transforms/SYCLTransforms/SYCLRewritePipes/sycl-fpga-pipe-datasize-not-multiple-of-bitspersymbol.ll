; RUN: llvm-as %p/../Inputs/fpga-pipes.rtl -o %t.rtl.bc
; RUN: not opt -sycl-kernel-builtin-lib=%t.rtl.bc -passes=sycl-kernel-rewrite-pipes -S %s -disable-output 2>&1 | FileCheck --check-prefix=CHECK-ERROR %s

; CHECK-ERROR: error: The width of the data type carried by InPipeID must be a multiple of bits per symbol.
; ModuleID = 'main'
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { i32, i32, i32, i32, i32, i8, i8, i16 }
%class._ZTSZ4mainEUlvE_ = type { i8 }
%"class.sycl::_V1::ext::oneapi::experimental::properties" = type { %class._ZTSZ4mainEUlvE_ }

@_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE = linkonce_odr addrspace(1) constant %structtype { i32 1, i32 1, i32 0, i32 0, i32 16, i8 1, i8 0, i16 1 }, align 4, !spirv.Decorations !15487

; Function Attrs: convergent nounwind
define void @_ZTSZ4mainEUlvE_() #0  !kernel_arg_addr_space !408 !kernel_arg_access_qual !408 !kernel_arg_type !408 !kernel_arg_base_type !408 !kernel_arg_type_qual !408 !kernel_arg_target_ext_type !408 !max_global_work_dim !15505 !spirv.ParameterDecorations !408 {
entry:
  %__SYCLKernel = alloca %class._ZTSZ4mainEUlvE_, align 1, !spirv.Decorations !15506
  %__SYCLKernel.ascast = addrspacecast ptr %__SYCLKernel to ptr addrspace(4)
  call void @_ZZ4mainENKUlvE_clEv(ptr addrspace(4) align 1 %__SYCLKernel.ascast) #11
  ret void
}

; Function Attrs: nounwind
define internal void @_ZZ4mainENKUlvE_clEv(ptr addrspace(4) align 1 %this) #5 {
entry:
  %call = call signext i8 @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readEv() #11
  ret void
}

; Function Attrs: nounwind
define internal signext i8 @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readEv() #5 {
entry:
  %agg.tmp = alloca %"class.sycl::_V1::ext::oneapi::experimental::properties", align 1
  %agg.tmp.ascast = addrspacecast ptr %agg.tmp to ptr addrspace(4)
  call void @_ZN4sycl3_V13ext6oneapi12experimental10propertiesISt5tupleIJEEEC2IJEEEDpT_(ptr addrspace(4) align 1 %agg.tmp.ascast) #11
  %0 = load i8, ptr %agg.tmp, align 1
  %1 = call i8 @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINS8_IS9_IJEEEEEEcT_(i8 %0)
  ret i8 %1
}

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext6oneapi12experimental10propertiesISt5tupleIJEEEC2IJEEEDpT_(ptr addrspace(4) align 1 %this) #5 {
entry:
  %Storage = getelementptr inbounds %"class.sycl::_V1::ext::oneapi::experimental::properties", ptr addrspace(4) %this, i64 0, i32 0
  call void @_ZN4sycl3_V13ext6oneapi12experimental6detail17ExtractPropertiesISt5tupleIJEEE7ExtractIJEEES7_S6_IJDpT_EE(ptr addrspace(4) %Storage, i8 undef)
  ret void
}

; Function Attrs: nounwind
declare void @___ZN4sycl3_V13ext6oneapi12experimental6detail17ExtractPropertiesISt5tupleIJEEE7ExtractIJEEES7_S6_IJDpT_EE_before.CoerceTypes(ptr addrspace(4) noalias sret(%class._ZTSZ4mainEUlvE_) align 1 %agg.result, ptr byval(%class._ZTSZ4mainEUlvE_) align 1 %0) #5

; Function Attrs: nounwind
declare signext i8 @___ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINS8_IS9_IJEEEEEEcT__before.CoerceTypes(ptr byval(%"class.sycl::_V1::ext::oneapi::experimental::properties") align 1 %0) #5

; Function Attrs: nounwind
declare ptr addrspace(1) @_Z38__spirv_CreatePipeFromPipeStorage_readPU3AS427__spirv_ConstantPipeStorage(ptr addrspace(4) %0) #5

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE33__latency_control_bl_read_wrapperIcEEv8ocl_pipePT_iiii(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 %0, i32 %1, i32 %2, i32 %3) #5 !kernel_arg_target_ext_type !15569 {
entry:
  %4 = call i32 @__read_pipe_2_bl_fpga(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 1, i32 1) #11
  ret void
}

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z12get_group_idj(i32 %0) #6

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z20get_global_linear_idv() #6

; Function Attrs: nounwind willreturn memory(none)
declare i64 @_Z14get_local_sizej(i32 %0) #6

; Function Attrs: convergent norecurse nounwind
declare noundef i32 @__read_pipe_2_bl_fpga(ptr addrspace(1) %0, ptr addrspace(4) nocapture noundef writeonly %1, i32 noundef %2, i32 noundef %3) #7

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext6oneapi12experimental6detail17ExtractPropertiesISt5tupleIJEEE7ExtractIJEEES7_S6_IJDpT_EE(ptr addrspace(4) noalias sret(%class._ZTSZ4mainEUlvE_) align 1 %agg.result, i8 %0) #5 {
entry:
  ret void
}

; Function Attrs: nounwind
define internal signext i8 @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINS8_IS9_IJEEEEEEcT_(i8 %0) #5  {
entry:
  %TempData = alloca i8, align 1
  %TempData.ascast = addrspacecast ptr %TempData to ptr addrspace(4)
  %call = call ptr addrspace(1) @_Z38__spirv_CreatePipeFromPipeStorage_readPU3AS427__spirv_ConstantPipeStorage(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE to ptr addrspace(4))) #11
  call void @_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE33__latency_control_bl_read_wrapperIcEEv8ocl_pipePT_iiii(ptr addrspace(1) %call, ptr addrspace(4) %TempData.ascast, i32 -1, i32 0, i32 0, i32 0) #11
  %1 = load i8, ptr %TempData, align 1
  ret i8 %1
}

; Function Attrs: convergent memory(none)
declare i64 @_Z13get_global_idj(i32 %0) #8

; Function Attrs: memory(none)
declare i64 @_Z17get_global_offsetj(i32 %0) #9

; Function Attrs: memory(none)
declare i64 @_Z15get_global_sizej(i32 %0) #9


attributes #0 = { convergent nounwind "prefer-vector-width"="512" }
attributes #1 = { alwaysinline convergent nounwind "prefer-vector-width"="512" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { noinline nounwind optnone "prefer-vector-width"="512" }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nounwind "prefer-vector-width"="512" }
attributes #6 = { nounwind willreturn memory(none) "prefer-vector-width"="512" }
attributes #7 = { convergent norecurse nounwind "denormal-fp-math"="dynamic,dynamic" "min-legal-vector-width"="0" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "stackrealign" "target-cpu"="skx" "target-features"="+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+evex512,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves" }
attributes #8 = { convergent memory(none) }
attributes #9 = { memory(none) }
attributes #10 = { alwaysinline convergent nounwind }
attributes #11 = { nounwind }

!llvm.module.flags = !{!15492, !15493}
!llvm.dbg.cu = !{!2}
!spirv.MemoryModel = !{!15494}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!15495}
!opencl.spir.version = !{!15496}
!opencl.ocl.version = !{!15497}
!opencl.used.extensions = !{!408}
!opencl.used.optional.core.features = !{!408}
!spirv.Generator = !{!15498}
!sycl.kernels = !{!15499}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "m_Storage", linkageName: "_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE", scope: !2, line: 395, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2024.2.0 (2024.x.0.YYYYMMDD)", isOptimized: false, flags: " --driver-mode=g++ --intel -I . -fintelfpga test.cpp -g -O2 -fveclib=SVML -faltmathlib=SVML -fheinous-gnu-extensions -dumpdir a-", runtimeVersion: 0, emissionKind: FullDebug )
!3 = !DIFile(filename: "test.cpp", directory: "/")
!408 = !{}
!15487 = !{!15488, !15489, !15490, !15491}
!15488 = !{i32 22}
!15489 = !{i32 41, !"_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE", i32 2}
!15490 = !{i32 44, i32 4}
!15491 = !{i32 6147, i32 2, !"_ZN4sycl3_V13ext5intel12experimental4pipeI8InPipeIDcLi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE"}
!15492 = !{i32 7, !"Dwarf Version", i32 4}
!15493 = !{i32 2, !"Debug Info Version", i32 3}
!15494 = !{i32 2, i32 2}
!15495 = !{i32 4, i32 100000}
!15496 = !{i32 1, i32 2}
!15497 = !{i32 1, i32 0}
!15498 = !{i16 6, i16 14}
!15499 = !{ptr @_ZTSZ4mainEUlvE_}
!15505 = !{i32 0}
!15506 = !{!15507}
!15507 = !{i32 44, i32 1}
!15569 = !{!"spirv.Pipe_0", !"", !"", !"", !"", !""}
