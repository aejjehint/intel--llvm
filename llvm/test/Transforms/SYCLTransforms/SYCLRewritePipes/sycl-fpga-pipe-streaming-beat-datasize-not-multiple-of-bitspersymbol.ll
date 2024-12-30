; RUN: llvm-as %p/../Inputs/fpga-pipes.rtl -o %t.rtl.bc
; RUN: not opt -sycl-kernel-builtin-lib=%t.rtl.bc -passes=sycl-kernel-rewrite-pipes -S %s -disable-output 2>&1 | FileCheck --check-prefix=CHECK-ERROR %s

; CHECK-ERROR: error: The width of the data type carried by InPipeBeatID must be a multiple of bits per symbol.

; ModuleID = 'main'
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { i32, i32, i32, i32, i32, i8, i8, i16 }
%class._ZTSZ4mainEUlvE_ = type { i8 }
%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat" = type { i8, i8, i8 }
%"class.sycl::_V1::ext::oneapi::experimental::properties" = type { %class._ZTSZ4mainEUlvE_ }

@_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE = linkonce_odr addrspace(1) constant %structtype { i32 3, i32 1, i32 0, i32 0, i32 16, i8 1, i8 0, i16 1 }, align 4, !spirv.Decorations !15513
@.str = internal unnamed_addr addrspace(1) constant [15 x i8] c"{sideband:sop}\00", !spirv.Decorations !15518
@.str.1 = internal unnamed_addr addrspace(1) constant [41 x i8] c"./sycl/ext/intel/prototype/pipes_ext.hpp\00", !spirv.Decorations !15518
@.str.2 = internal unnamed_addr addrspace(1) constant [15 x i8] c"{sideband:eop}\00", !spirv.Decorations !15518
@anon.c3e2a6b339a4656ed44219b2ed2b7c88.0 = private unnamed_addr constant [15 x i8] c"{sideband:sop}\00", align 1
@anon.c3e2a6b339a4656ed44219b2ed2b7c88.1 = private unnamed_addr constant [15 x i8] c"{sideband:eop}\00", align 1

; Function Attrs: convergent nounwind
define void @_ZTSZ4mainEUlvE_() #0 !kernel_arg_addr_space !408 !kernel_arg_access_qual !408 !kernel_arg_type !408 !kernel_arg_base_type !408 !kernel_arg_type_qual !408 !kernel_arg_target_ext_type !408 !max_global_work_dim !15532 !spirv.ParameterDecorations !408 {
entry:
  %__SYCLKernel = alloca %class._ZTSZ4mainEUlvE_, align 1, !spirv.Decorations !15533
  %__SYCLKernel.ascast = addrspacecast ptr %__SYCLKernel to ptr addrspace(4)
  call void @_ZZ4mainENKUlvE_clEv(ptr addrspace(4) align 1 %__SYCLKernel.ascast) #12
  ret void
}

; Function Attrs: nounwind
define internal void @_ZZ4mainENKUlvE_clEv(ptr addrspace(4) align 1 %this) #5 {
entry:
  %agg.tmp.ensured = alloca %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", align 1, !spirv.Decorations !15533
  %agg.tmp.ensured.ascast = addrspacecast ptr %agg.tmp.ensured to ptr addrspace(4)
  call void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readEv(ptr addrspace(4) noalias sret(%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat") align 1 %agg.tmp.ensured.ascast) #12
  call void @_ZN4sycl3_V13ext5intel12experimental13StreamingBeatIcLb1ELb0EED2Ev(ptr addrspace(4) align 1 %agg.tmp.ensured.ascast) #12
  ret void
}

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readEv(ptr addrspace(4) noalias sret(%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat") align 1 %agg.result) #5 {
entry:
  %agg.tmp = alloca %"class.sycl::_V1::ext::oneapi::experimental::properties", align 1, !spirv.Decorations !15533
  %agg.tmp.ascast = addrspacecast ptr %agg.tmp to ptr addrspace(4)
  call void @_ZN4sycl3_V13ext6oneapi12experimental10propertiesISt5tupleIJEEEC2IJEEEDpT_(ptr addrspace(4) align 1 %agg.tmp.ascast) #12
  %0 = load i8, ptr %agg.tmp, align 1
  call void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINSA_ISB_IJEEEEEES7_T_(ptr addrspace(4) %agg.result, i8 %0)
  ret void
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
declare void @___ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINSA_ISB_IJEEEEEES7_T__before.CoerceTypes(ptr addrspace(4) noalias sret(%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat") align 1 %agg.result, ptr byval(%"class.sycl::_V1::ext::oneapi::experimental::properties") align 1 %0) #5

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental13StreamingBeatIcLb1ELb0EEC2Ev(ptr addrspace(4) align 1 %this) #5 {
entry:
  %sop = getelementptr inbounds %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", ptr addrspace(4) %this, i64 0, i32 1, !spirv.Decorations !15592
  %0 = call ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %sop, ptr nonnull @anon.c3e2a6b339a4656ed44219b2ed2b7c88.0, ptr undef, i32 undef, ptr undef)
  store i8 0, ptr addrspace(4) %0, align 1
  %eop = getelementptr inbounds %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", ptr addrspace(4) %this, i64 0, i32 2, !spirv.Decorations !15595
  %1 = call ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %eop, ptr nonnull @anon.c3e2a6b339a4656ed44219b2ed2b7c88.1, ptr undef, i32 undef, ptr undef)
  store i8 0, ptr addrspace(4) %1, align 1
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %0, ptr %1, ptr %2, i32 %3, ptr %4) #6

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental13StreamingBeatIcLb1ELb0EED2Ev(ptr addrspace(4) align 1 %this) #5 {
entry:
  ret void
}

; Function Attrs: nounwind
declare ptr addrspace(1) @_Z38__spirv_CreatePipeFromPipeStorage_readPU3AS427__spirv_ConstantPipeStorage(ptr addrspace(4) %0) #5

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE33__latency_control_bl_read_wrapperIS7_EEv8ocl_pipePT_iiii(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 %0, i32 %1, i32 %2, i32 %3) #5 !kernel_arg_target_ext_type !15618 {
entry:
  %4 = call i32 @__read_pipe_2_bl_fpga(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 3, i32 1) #12
  ret void
}

; Function Attrs: convergent norecurse nounwind
declare noundef i32 @__read_pipe_2_bl_fpga(ptr addrspace(1) %0, ptr addrspace(4) nocapture noundef writeonly %1, i32 noundef %2, i32 noundef %3) #8

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext6oneapi12experimental6detail17ExtractPropertiesISt5tupleIJEEE7ExtractIJEEES7_S6_IJDpT_EE(ptr addrspace(4) noalias sret(%class._ZTSZ4mainEUlvE_) align 1 %agg.result, i8 %0) #5 !spirv.ParameterDecorations !15630 {
entry:
  ret void
}

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readINSA_ISB_IJEEEEEES7_T_(ptr addrspace(4) noalias sret(%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat") align 1 %agg.result, i8 %0) #5 !spirv.ParameterDecorations !15630 {
entry:
  %call = call ptr addrspace(1) @_Z38__spirv_CreatePipeFromPipeStorage_readPU3AS427__spirv_ConstantPipeStorage(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE to ptr addrspace(4))) #12
  call void @_ZN4sycl3_V13ext5intel12experimental13StreamingBeatIcLb1ELb0EEC2Ev(ptr addrspace(4) align 1 %agg.result) #12
  call void @_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE33__latency_control_bl_read_wrapperIS7_EEv8ocl_pipePT_iiii(ptr addrspace(1) %call, ptr addrspace(4) %agg.result, i32 -1, i32 0, i32 0, i32 0) #12
  br i1 true, label %nrvo.skipdtor, label %nrvo.unused

nrvo.unused:                                      ; preds = %entry
  br label %nrvo.skipdtor

nrvo.skipdtor:                                    ; preds = %nrvo.unused, %entry
  ret void
}

attributes #0 = { convergent nounwind "prefer-vector-width"="512" }
attributes #1 = { alwaysinline convergent nounwind "prefer-vector-width"="512" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { noinline nounwind optnone "prefer-vector-width"="512" }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nounwind "prefer-vector-width"="512" }
attributes #6 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #7 = { nounwind willreturn memory(none) "prefer-vector-width"="512" }
attributes #8 = { convergent norecurse nounwind "denormal-fp-math"="dynamic,dynamic" "min-legal-vector-width"="0" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "stackrealign" "target-cpu"="skx" "target-features"="+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+evex512,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves" }
attributes #9 = { convergent memory(none) }
attributes #10 = { memory(none) }
attributes #11 = { alwaysinline convergent nounwind }
attributes #12 = { nounwind }

!llvm.module.flags = !{!15519, !15520}
!llvm.dbg.cu = !{!2}
!spirv.MemoryModel = !{!15521}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!15522}
!opencl.spir.version = !{!15523}
!opencl.ocl.version = !{!15524}
!opencl.used.extensions = !{!408}
!opencl.used.optional.core.features = !{!408}
!spirv.Generator = !{!15525}
!sycl.kernels = !{!15526}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "m_Storage", linkageName: "_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE", scope: !2,  line: 395, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2024.2.0 (2024.x.0.YYYYMMDD)", isOptimized: false, flags: " --driver-mode=g++ --intel -I . -fintelfpga test2.cpp -g -O2 -fveclib=SVML -faltmathlib=SVML -fheinous-gnu-extensions -dumpdir a-", runtimeVersion: 0, emissionKind: FullDebug)
!3 = !DIFile(filename: "test.cpp", directory: "/")
!408 = !{}
!15513 = !{!15514, !15515, !15516, !15517}
!15514 = !{i32 22}
!15515 = !{i32 41, !"_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE", i32 2}
!15516 = !{i32 44, i32 4}
!15517 = !{i32 6147, i32 2, !"_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE"}
!15518 = !{!15514}
!15519 = !{i32 7, !"Dwarf Version", i32 4}
!15520 = !{i32 2, !"Debug Info Version", i32 3}
!15521 = !{i32 2, i32 2}
!15522 = !{i32 4, i32 100000}
!15523 = !{i32 1, i32 2}
!15524 = !{i32 1, i32 0}
!15525 = !{i16 6, i16 14}
!15526 = !{ptr @_ZTSZ4mainEUlvE_}
!15532 = !{i32 0}
!15533 = !{!15534}
!15534 = !{i32 44, i32 1}
!15558 = distinct !DISubprogram(name: "read", linkageName: "_ZN4sycl3_V13ext5intel12experimental4pipeI12InPipeBeatIDNS3_13StreamingBeatIcLb1ELb0EEELi0ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE4readEv", line: 323, scopeLine: 323, flags: DIFlagPrivate | DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, templateParams: !408)
!15559 = !{!15560}
!15560 = !{!15561, !15562, !15534}
!15561 = !{i32 38, i32 4}
!15562 = !{i32 38, i32 3}
!15563 = !DILocation(line: 323, column: 38, scope: !15558)
!15564 = !DILocation(line: 323, column: 33, scope: !15558)
!15565 = !DILocation(line: 323, column: 26, scope: !15558)
!15592 = !{!15593}
!15593 = !{i32 5635, !"{sideband:sop}"}
!15595 = !{!15596}
!15596 = !{i32 5635, !"{sideband:eop}"}
!15618 = !{!"spirv.Pipe_0", !"", !"", !"", !"", !""}
!15630 = !{!15560, !15631}
!15631 = !{!15632, !15534}
!15632 = !{i32 38, i32 2}
