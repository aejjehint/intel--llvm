; RUN: llvm-as %p/../Inputs/fpga-pipes.rtl -o %t.rtl.bc
; RUN: not opt -sycl-kernel-builtin-lib=%t.rtl.bc -passes=sycl-kernel-rewrite-pipes -S %s -disable-output 2>&1 | FileCheck --check-prefix=CHECK-ERROR %s

; Checks that error is thrown when:
;   StreamingBeat struct is instantiated with use_Empty = false
;   and StreamingBeat data type bit size (64) is greater than BitsPerSymbol (16) property of the pipe.

; Make sure this works with unoptimized IR as well.

; CHECK-ERROR: error: The data type carried by D2HPipeID exceeds the bits per symbol. You can either enable the sideband signal 'use empty' or increase the bits per symbol.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype = type { i32, i32, i32, i32, i32, i8, i8, i16 }
%class._ZTSZ4mainEUlvE_ = type { i8 }
%"struct.sycl::_V1::ext::intel::experimental::StreamingBeat" = type { i64, i8, i8, i32 }
%"class.sycl::_V1::ext::oneapi::experimental::properties" = type { %class._ZTSZ4mainEUlvE_ }

declare ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4), ptr, ptr, i32, ptr)
declare ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4))
declare noundef i32 @__write_pipe_2_bl_fpga(ptr addrspace(1), ptr addrspace(4) nocapture noundef readonly, i32 noundef, i32 noundef)

; BitsPerSymbol = 16 (the fifth constant field of the struct initializer)
@_ZN4sycl3_V13ext5intel12experimental4pipeI9D2HPipeIDNS3_13StreamingBeatIlLb1ELb1EEELi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE = linkonce_odr addrspace(1) constant %structtype { i32 16, i32 8, i32 1, i32 0, i32 16, i8 1, i8 0, i16 1 }, align 4
@anon.0 = private unnamed_addr constant [7 x i8] c"{data}\00", align 1
@anon.1 = private unnamed_addr constant [15 x i8] c"{sideband:sop}\00", align 1
@anon.2 = private unnamed_addr constant [15 x i8] c"{sideband:eop}\00", align 1

; Constructor of a StreamingBeat struct, whose use_Empty = false and data type is i64
define internal void @StreamingBeatConstructor(ptr addrspace(4) align 8 %this, i64 %_data, i1 zeroext %_sop, i1 zeroext %_eop) {
entry:
  %this.addr = alloca ptr addrspace(4), align 8
  %this.addr.ascast = addrspacecast ptr %this.addr to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr addrspace(4) %this.addr.ascast, align 8
  %this2 = load ptr addrspace(4), ptr addrspace(4) %this.addr.ascast, align 8
  %data = getelementptr inbounds %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", ptr addrspace(4) %this2, i64 0, i32 0, !spirv.Decorations !15534
  %0 = call ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %data, ptr nonnull @anon.0, ptr undef, i32 undef, ptr undef)
  store i64 %_data, ptr addrspace(4) %0, align 8
  %sop = getelementptr inbounds %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", ptr addrspace(4) %this2, i64 0, i32 1, !spirv.Decorations !15538
  %1 = call ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %sop, ptr nonnull @anon.1, ptr undef, i32 undef, ptr undef)
  %frombool3 = zext i1 %_sop to i8
  store i8 %frombool3, ptr addrspace(4) %1, align 8
  %eop = getelementptr inbounds %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", ptr addrspace(4) %this2, i64 0, i32 2, !spirv.Decorations !15542
  %2 = call ptr addrspace(4) @llvm.ptr.annotation.p4.p0(ptr addrspace(4) %eop, ptr nonnull @anon.2, ptr undef, i32 undef, ptr undef)
  %frombool5 = zext i1 %_eop to i8
  store i8 %frombool5, ptr addrspace(4) %2, align 1
  ret void
}

; Create pipe
define internal void @CreatePipeAndWritePipe(ptr addrspace(4) align 8 dereferenceable(16) %Data, i8 %0) {
entry:
  %call = call ptr addrspace(1) @_Z39__spirv_CreatePipeFromPipeStorage_writePU3AS410structtype(ptr addrspace(4) addrspacecast (ptr addrspace(1) @_ZN4sycl3_V13ext5intel12experimental4pipeI9D2HPipeIDNS3_13StreamingBeatIlLb1ELb1EEELi1ENS1_6oneapi12experimental10propertiesISt5tupleIJNS9_14property_valueINS3_19bits_per_symbol_keyEJSt17integral_constantIiLi16EEEEEEEEEvE9m_StorageE to ptr addrspace(4)))
  call void @WritePipeWrapper(ptr addrspace(1) %call, ptr addrspace(4) %Data, i32 -1, i32 0, i32 0, i32 0)
  ret void
}

; Write pipe
define internal void @WritePipeWrapper(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 %0, i32 %1, i32 %2, i32 %3) {
entry:
  %4 = call i32 @__write_pipe_2_bl_fpga(ptr addrspace(1) %Pipe, ptr addrspace(4) %Data, i32 16, i32 8)
  ret void
}

define internal void @Wrapper(ptr addrspace(4) align 8 dereferenceable(16) %Data) {
entry:
  %agg.tmp = alloca %"class.sycl::_V1::ext::oneapi::experimental::properties", align 1
  %0 = load i8, ptr %agg.tmp, align 1
  call void @CreatePipeAndWritePipe(ptr addrspace(4) %Data, i8 %0)
  ret void
}

define internal void @AnotherWrapper(ptr addrspace(4) align 1 %this) {
entry:
  %ref.tmp = alloca %"struct.sycl::_V1::ext::intel::experimental::StreamingBeat", align 8
  %ref.tmp.ascast = addrspacecast ptr %ref.tmp to ptr addrspace(4)
  call void @StreamingBeatConstructor(ptr addrspace(4) align 8 %ref.tmp.ascast, i64 1, i1 zeroext true, i1 zeroext true)
  call void @Wrapper(ptr addrspace(4) align 8 dereferenceable(16) %ref.tmp.ascast)
  ret void
}

; Kernel
define void @Kernel() #0 !kernel_arg_addr_space !398 !kernel_arg_access_qual !398 !kernel_arg_type !398 !kernel_arg_base_type !398 !kernel_arg_type_qual !398 !kernel_arg_target_ext_type !398 !max_global_work_dim !15494 !spirv.ParameterDecorations !398 {
entry:
  %__SYCLKernel = alloca %class._ZTSZ4mainEUlvE_, align 1
  %__SYCLKernel.ascast = addrspacecast ptr %__SYCLKernel to ptr addrspace(4)
  call void @AnotherWrapper(ptr addrspace(4) align 1 %__SYCLKernel.ascast)
  ret void
}

!sycl.kernels = !{!15488}

!398 = !{}
!15488 = !{ptr @Kernel}
!15494 = !{i32 0}
!15534 = !{!15535}
!15535 = !{i32 5635, !"{data}"}
!15538 = !{!15539}
!15539 = !{i32 5635, !"{sideband:sop}"}
!15542 = !{!15543}
!15543 = !{i32 5635, !"{sideband:eop}"}
