; RUN: llvm-as %p/../Inputs/fpga-pipes.rtl -o %t.rtl.bc
; RUN: opt -sycl-kernel-builtin-lib=%t.rtl.bc -passes=sycl-kernel-rewrite-pipes -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -sycl-kernel-builtin-lib=%t.rtl.bc -passes=sycl-kernel-rewrite-pipes -S %s -o - | FileCheck %s

; ModuleID = 'main'
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { i32, i32, i32, i32, i32, i8, i8, i16 }
%struct.Adder = type { i32, i32 }
%"class.sycl::_V1::ext::oneapi::experimental::properties" = type { %"class.std::tuple" }
%"class.std::tuple" = type { i8 }

@_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE9m_StorageE = linkonce_odr addrspace(1) constant %structtype { i32 4, i32 4, i32 1, i32 0, i32 8, i8 1, i8 0, i16 2 }, align 4, !spirv.Decorations !15369

; Function Attrs: nounwind
declare ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4)) #5

; CHECK:   call void @__pipe_init_ext_fpga(ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE9m_StorageE.syclpipe.bs, i32 4, i32 1, i32 0, i32 2)
; CHECK: declare void @__pipe_init_ext_fpga(ptr addrspace(1), i32, i32, i32, i32) #1

; Function Attrs: nounwind
define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE5writeINS8_IS9_IJEEEEEEvRKiT_(ptr addrspace(4) align 4 dereferenceable(4) %Data, i8 %0) #5 !spirv.ParameterDecorations !15522 {
entry:
  %call = call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE9m_StorageE to ptr addrspace(4))) #10
  ret void
}

attributes #0 = { convergent nounwind "prefer-vector-width"="512" }
attributes #1 = { alwaysinline convergent nounwind "prefer-vector-width"="512" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { noinline nounwind optnone "prefer-vector-width"="512" }
attributes #4 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nounwind "prefer-vector-width"="512" }
attributes #6 = { nounwind willreturn memory(none) "prefer-vector-width"="512" }
attributes #7 = { convergent norecurse nounwind "denormal-fp-math"="dynamic,dynamic" "min-legal-vector-width"="0" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "stackrealign" "target-cpu"="skx" "target-features"="+adx,+aes,+avx,+avx2,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512vl,+bmi,+bmi2,+clflushopt,+clwb,+cmov,+crc32,+cx16,+cx8,+evex512,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+pku,+popcnt,+prfchw,+rdrnd,+rdseed,+sahf,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsavec,+xsaveopt,+xsaves" }
attributes #8 = { convergent }
attributes #9 = { alwaysinline convergent nounwind }
attributes #10 = { nounwind }

!spirv.MemoryModel = !{!15376}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!15377}
!opencl.spir.version = !{!15378}
!opencl.ocl.version = !{!15379}
!opencl.used.extensions = !{!374}
!opencl.used.optional.core.features = !{!374}
!spirv.Generator = !{!15380}

!374 = !{}
!15507 = !{!15508, !15450}
!15522 = !{!15447, !15507}
!15369 = !{!15370, !15371, !15372, !15373}
!15370 = !{i32 22}
!15371 = !{i32 41, !"_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE9m_StorageE", i32 2}
!15372 = !{i32 44, i32 4}
!15373 = !{i32 6147, i32 2, !"_ZN4sycl3_V13ext5intel12experimental4pipeI12OutputPipeIDiLi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS7_14property_valueINS3_12protocol_keyEJSt17integral_constantINS3_13protocol_nameELSD_2EEEEEEEEEvE9m_StorageE"}
!15376 = !{i32 2, i32 2}
!15377 = !{i32 4, i32 100000}
!15378 = !{i32 1, i32 2}
!15379 = !{i32 1, i32 0}
!15380 = !{i16 6, i16 14}
!15447 = !{!15372, !15448}
!15448 = !{i32 45, i32 4}
!15450 = !{i32 44, i32 1}
!15508 = !{i32 38, i32 2}

; DEBUGIFY: WARNING: Instruction with empty DebugLoc in function __pipe_global_ctor --  ret void
; DEBUGIFY: PASS
