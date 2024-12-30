; RUN: opt -sycl-kernel-builtin-lib=%p/../Inputs/fpga-pipes.rtl -passes=sycl-kernel-rewrite-pipes -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -sycl-kernel-builtin-lib=%p/../Inputs/fpga-pipes.rtl -passes=sycl-kernel-rewrite-pipes -S %s | FileCheck %s

; This test checks that when sycl::pipe and experimental::pipe are used in the same
; translation unit, the corresponding create pipe function names are unified.

; CHECK-DAG: call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS427__spirv_ConstantPipeStorage(
; CHECK-DAG: call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS427__spirv_ConstantPipeStorage(
; CHECK-DAG: declare ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS427__spirv_ConstantPipeStorage(
; CHECK-NOT: _Z39__spirv_CreatePipeFromPipeStorage_writePU3AS419ConstantPipeStorage
; CHECK-NOT: _Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype

%struct.ConstantPipeStorage = type { i32, i32, i32 }
%structtype = type { i32, i32, i32, i32, i32, i8, i8, i16 }

@_ZN4sycl3_V13ext5intel4pipeI14FinalPipeClass13StreamingDataI9FinalDataLi4EELi0EE9m_StorageE = linkonce_odr addrspace(1) constant %struct.ConstantPipeStorage { i32 136, i32 8, i32 0 }, align 4
@_ZN4sycl3_V13ext5intel12experimental4pipeI12DebugPipeIDAiLi1024ENS1_6oneapi12experimental10propertiesISt5tupleIJEEEEvE9m_StorageE = linkonce_odr addrspace(1) constant %structtype { i32 4, i32 4, i32 1024, i32 0, i32 8, i8 1, i8 0, i16 1 }, align 4

define internal void @_ZN4sycl3_V13ext5intel4pipeI14FinalPipeClass13StreamingDataI9FinalDataLi4EELi0EE5writeERKS7_(ptr addrspace(4) align 8 dereferenceable(136) %_Data) {
entry:
  %call = call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS419ConstantPipeStorage(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel4pipeI14FinalPipeClass13StreamingDataI9FinalDataLi4EELi0EE9m_StorageE to ptr addrspace(4)))
  %0 = call i32 @__write_pipe_2_bl_fpga(ptr addrspace(1) %call, ptr addrspace(4) %_Data, i32 136, i32 8)
  ret void
}

define internal void @_ZN4sycl3_V13ext5intel12experimental4pipeI12DebugPipeIDAiLi1024ENS1_6oneapi12experimental10propertiesISt5tupleIJEEEEvE5writeISB_EEvRKiT_(ptr addrspace(4) align 4 dereferenceable(4) %Data, i8 %0) {
entry:
  %call = call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI12DebugPipeIDAiLi1024ENS1_6oneapi12experimental10propertiesISt5tupleIJEEEEvE9m_StorageE to ptr addrspace(4)))
  ret void
}

declare ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS419ConstantPipeStorage(ptr addrspace(4))

declare ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4))

declare noundef i32 @__write_pipe_2_bl_fpga(ptr addrspace(1), ptr addrspace(4) nocapture noundef readonly, i32 noundef, i32 noundef)

; DEBUGIFY: PASS
