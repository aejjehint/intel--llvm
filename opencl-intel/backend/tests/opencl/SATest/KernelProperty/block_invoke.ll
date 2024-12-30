; Simplified from input IR to OCL CPU from following SYCL kernel:
;
; int bar() { return 0; }
; int main() {
;   queue q;
;   int result = 0;
;   buffer<int, 1> res_buf(&result, range<1>(1));
;   q.submit([&](handler &cgh) {
;     auto res_acc = res_buf.get_access<access::mode::write>(cgh);
;     cgh.single_task(
;         [=](kernel_handler kh) {
;         task_sequence<bar, decltype(properties{invocation_capacity<1>, response_capacity<1>})> task;
;         task.async();
;         res_acc[0] = task.get(); });
;   });
;   q.wait();
; }

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-G1"
target triple = "spir64-unknown-unknown"

%"class.sycl::_V1::range" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }
%class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_ = type { %"class.sycl::_V1::accessor" }
%"class.sycl::_V1::accessor" = type { %"class.sycl::_V1::detail::AccessorImplDevice", %union.anon }
%"class.sycl::_V1::detail::AccessorImplDevice" = type { %"class.sycl::_V1::range", %"class.sycl::_V1::range", %"class.sycl::_V1::range" }
%union.anon = type { ptr addrspace(1) }
%"class.sycl::_V1::kernel_handler" = type { ptr addrspace(4) }
%class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_ = type { ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4) }
%"struct.std::integer_sequence" = type { i8 }
%class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_ = type { ptr addrspace(4), ptr addrspace(4) }
%"class.sycl::_V1::ext::intel::experimental::task_sequence" = type { i32, target("spirv.TaskSequenceINTEL") }

; Function Attrs: nounwind
define spir_func i32 @_Z3barv() #0 {
entry:
  ret i32 0
}

; Function Attrs: nounwind
define spir_kernel void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_(ptr addrspace(1) align 4 %_arg_res_acc, ptr byval(%"class.sycl::_V1::range") align 8 %_arg_res_acc1, ptr byval(%"class.sycl::_V1::range") align 8 %_arg_res_acc2, ptr byval(%"class.sycl::_V1::range") align 8 %_arg_res_acc4, ptr addrspace(1) align 1 %_arg__specialization_constants_buffer) #0 !kernel_arg_addr_space !3 !kernel_arg_access_qual !4 !kernel_arg_type !5 !kernel_arg_base_type !5 !kernel_arg_type_qual !6 !max_global_work_dim !7 !spirv.ParameterDecorations !8 {
entry:
  %_arg_res_acc.addr = alloca ptr addrspace(1), align 8, !spirv.Decorations !16
  %_arg_res_acc.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %_arg_res_acc.indirect_addr3 = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %_arg_res_acc.indirect_addr5 = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %_arg__specialization_constants_buffer.addr = alloca ptr addrspace(1), align 8, !spirv.Decorations !16
  %__SYCLKernel = alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_, align 8, !spirv.Decorations !16
  %agg.tmp = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %agg.tmp7 = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %agg.tmp8 = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %KH = alloca %"class.sycl::_V1::kernel_handler", align 8, !spirv.Decorations !16
  %agg.tmp9 = alloca %"class.sycl::_V1::kernel_handler", align 8, !spirv.Decorations !16
  %__SYCLKernel.ascast = addrspacecast ptr %__SYCLKernel to ptr addrspace(4)
  %KH.ascast = addrspacecast ptr %KH to ptr addrspace(4)
  store ptr addrspace(1) %_arg_res_acc, ptr %_arg_res_acc.addr, align 8
  %_arg_res_acc1.ascast = addrspacecast ptr %_arg_res_acc1 to ptr addrspace(4)
  store ptr addrspace(4) %_arg_res_acc1.ascast, ptr %_arg_res_acc.indirect_addr, align 8
  %_arg_res_acc2.ascast = addrspacecast ptr %_arg_res_acc2 to ptr addrspace(4)
  store ptr addrspace(4) %_arg_res_acc2.ascast, ptr %_arg_res_acc.indirect_addr3, align 8
  %_arg_res_acc4.ascast = addrspacecast ptr %_arg_res_acc4 to ptr addrspace(4)
  store ptr addrspace(4) %_arg_res_acc4.ascast, ptr %_arg_res_acc.indirect_addr5, align 8
  store ptr addrspace(1) %_arg__specialization_constants_buffer, ptr %_arg__specialization_constants_buffer.addr, align 8
  %0 = bitcast ptr %__SYCLKernel to ptr
  call void @llvm.lifetime.start.p0(i64 32, ptr %0)
  %res_acc = getelementptr inbounds %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_, ptr %__SYCLKernel, i32 0, i32 0
  %1 = addrspacecast ptr %res_acc to ptr addrspace(4)
  call spir_func void @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEEC2Ev(ptr addrspace(4) align 8 %1) #0
  %res_acc6 = getelementptr inbounds %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_, ptr %__SYCLKernel, i32 0, i32 0
  %2 = addrspacecast ptr %res_acc6 to ptr addrspace(4)
  %3 = load ptr addrspace(1), ptr %_arg_res_acc.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %_arg_res_acc1, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp7, ptr align 8 %_arg_res_acc2, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp8, ptr align 8 %_arg_res_acc4, i64 8, i1 false)
  call spir_func void @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEE(ptr addrspace(4) align 8 %2, ptr addrspace(1) %3, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp7, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp8) #0
  %4 = bitcast ptr %KH to ptr
  call void @llvm.lifetime.start.p0(i64 8, ptr %4)
  call spir_func void @_ZN4sycl3_V114kernel_handlerC2Ev(ptr addrspace(4) align 8 %KH.ascast) #0
  %5 = load ptr addrspace(1), ptr %_arg__specialization_constants_buffer.addr, align 8
  %6 = addrspacecast ptr addrspace(1) %5 to ptr addrspace(4)
  call spir_func void @_ZN4sycl3_V114kernel_handler38__init_specialization_constants_bufferEPc(ptr addrspace(4) align 8 %KH.ascast, ptr addrspace(4) %6) #0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp9, ptr align 8 %KH, i64 8, i1 false)
  call spir_func void @_ZZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_ENKUlNS0_14kernel_handlerEE_clES4_(ptr addrspace(4) align 8 %__SYCLKernel.ascast, ptr byval(%"class.sycl::_V1::kernel_handler") align 8 %agg.tmp9) #0
  %7 = bitcast ptr %KH to ptr
  call void @llvm.lifetime.end.p0(i64 8, ptr %7)
  %8 = bitcast ptr %__SYCLKernel to ptr
  call void @llvm.lifetime.end.p0(i64 32, ptr %8)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEEC2Ev(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %agg.tmp = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %agg.tmp2 = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %agg.tmp3 = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %agg.tmp.ascast = addrspacecast ptr %agg.tmp to ptr addrspace(4)
  %agg.tmp2.ascast = addrspacecast ptr %agg.tmp2 to ptr addrspace(4)
  %agg.tmp3.ascast = addrspacecast ptr %agg.tmp3 to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %impl = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %this1, i32 0, i32 0
  %0 = bitcast ptr %agg.tmp to ptr
  %1 = bitcast ptr addrspace(2) null to ptr addrspace(2)
  call void @llvm.memcpy.p0.p2.i64(ptr %0, ptr addrspace(2) %1, i64 8, i1 false)
  call spir_func void @_ZN4sycl3_V12idILi1EEC2Ev(ptr addrspace(4) align 8 %agg.tmp.ascast) #0
  call spir_func void @_ZN4sycl3_V16detail14InitializedValILi1ENS0_5rangeEE3getILi0EEENS3_ILi1EEEv(ptr addrspace(4) noalias sret(%"class.sycl::_V1::range") align 8 %agg.tmp2.ascast) #0
  call spir_func void @_ZN4sycl3_V16detail14InitializedValILi1ENS0_5rangeEE3getILi0EEENS3_ILi1EEEv(ptr addrspace(4) noalias sret(%"class.sycl::_V1::range") align 8 %agg.tmp3.ascast) #0
  call spir_func void @_ZN4sycl3_V16detail18AccessorImplDeviceILi1EEC2ENS0_2idILi1EEENS0_5rangeILi1EEES7_(ptr addrspace(4) align 8 %impl, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp2, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp3) #0
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p2.i64(ptr noalias nocapture writeonly, ptr addrspace(2) noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V12idILi1EEC2Ev(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  call spir_func void @_ZN4sycl3_V16detail5arrayILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %this1, i64 0) #0
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail5arrayILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %this, i64 %dim0) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dim0.addr = alloca i64, align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i64 %dim0, ptr %dim0.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %common_array = getelementptr inbounds %"class.sycl::_V1::detail::array", ptr addrspace(4) %0, i32 0, i32 0
  %1 = load i64, ptr %dim0.addr, align 8
  %2 = bitcast ptr addrspace(4) %common_array to ptr addrspace(4)
  store i64 %1, ptr addrspace(4) %2, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail14InitializedValILi1ENS0_5rangeEE3getILi0EEENS3_ILi1EEEv(ptr addrspace(4) noalias sret(%"class.sycl::_V1::range") align 8 %agg.result) #0 !spirv.ParameterDecorations !20 {
entry:
  call spir_func void @_ZN4sycl3_V15rangeILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %agg.result, i64 0) #0
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V15rangeILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %this, i64 %dim0) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dim0.addr = alloca i64, align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i64 %dim0, ptr %dim0.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = load i64, ptr %dim0.addr, align 8
  call spir_func void @_ZN4sycl3_V16detail5arrayILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %this1, i64 %0) #0
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail18AccessorImplDeviceILi1EEC2ENS0_2idILi1EEENS0_5rangeILi1EEES7_(ptr addrspace(4) align 8 %this, ptr byval(%"class.sycl::_V1::range") align 8 %Offset, ptr byval(%"class.sycl::_V1::range") align 8 %AccessRange, ptr byval(%"class.sycl::_V1::range") align 8 %MemoryRange) #0 !spirv.ParameterDecorations !24 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %Offset.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %AccessRange.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %MemoryRange.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %Offset.ascast = addrspacecast ptr %Offset to ptr addrspace(4)
  store ptr addrspace(4) %Offset.ascast, ptr %Offset.indirect_addr, align 8
  %AccessRange.ascast = addrspacecast ptr %AccessRange to ptr addrspace(4)
  store ptr addrspace(4) %AccessRange.ascast, ptr %AccessRange.indirect_addr, align 8
  %MemoryRange.ascast = addrspacecast ptr %MemoryRange to ptr addrspace(4)
  store ptr addrspace(4) %MemoryRange.ascast, ptr %MemoryRange.indirect_addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %Offset2 = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %this1, i32 0, i32 0
  call void @llvm.memcpy.p4.p0.i64(ptr addrspace(4) align 8 %Offset2, ptr align 8 %Offset, i64 8, i1 false)
  %AccessRange3 = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %this1, i32 0, i32 1
  call void @llvm.memcpy.p4.p0.i64(ptr addrspace(4) align 8 %AccessRange3, ptr align 8 %AccessRange, i64 8, i1 false)
  %MemRange = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %this1, i32 0, i32 2
  call void @llvm.memcpy.p4.p0.i64(ptr addrspace(4) align 8 %MemRange, ptr align 8 %MemoryRange, i64 8, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p4.p0.i64(ptr addrspace(4) noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEE(ptr addrspace(4) align 8 %this, ptr addrspace(1) %Ptr, ptr byval(%"class.sycl::_V1::range") align 8 %AccessRange, ptr byval(%"class.sycl::_V1::range") align 8 %MemRange, ptr byval(%"class.sycl::_V1::range") align 8 %Offset) #0 !spirv.ParameterDecorations !25 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %Ptr.addr = alloca ptr addrspace(1), align 8, !spirv.Decorations !16
  %AccessRange.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %MemRange.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %Offset.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %ref.tmp = alloca %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, align 8, !spirv.Decorations !16
  %ref.tmp.ascast = addrspacecast ptr %ref.tmp to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store ptr addrspace(1) %Ptr, ptr %Ptr.addr, align 8
  %AccessRange.ascast = addrspacecast ptr %AccessRange to ptr addrspace(4)
  store ptr addrspace(4) %AccessRange.ascast, ptr %AccessRange.indirect_addr, align 8
  %MemRange.ascast = addrspacecast ptr %MemRange to ptr addrspace(4)
  store ptr addrspace(4) %MemRange.ascast, ptr %MemRange.indirect_addr, align 8
  %Offset.ascast = addrspacecast ptr %Offset to ptr addrspace(4)
  store ptr addrspace(4) %Offset.ascast, ptr %Offset.indirect_addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = load ptr addrspace(1), ptr %Ptr.addr, align 8
  %1 = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %this1, i32 0, i32 1
  %2 = bitcast ptr addrspace(4) %1 to ptr addrspace(4)
  store ptr addrspace(1) %0, ptr addrspace(4) %2, align 8
  %3 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.start.p0(i64 32, ptr %3)
  %4 = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr %ref.tmp, i32 0, i32 0
  %5 = bitcast ptr %4 to ptr
  store ptr addrspace(4) %this1, ptr %5, align 8
  %Offset2 = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr %ref.tmp, i32 0, i32 1
  %6 = bitcast ptr %Offset2 to ptr
  store ptr addrspace(4) %Offset.ascast, ptr %6, align 8
  %AccessRange3 = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr %ref.tmp, i32 0, i32 2
  %7 = bitcast ptr %AccessRange3 to ptr
  store ptr addrspace(4) %AccessRange.ascast, ptr %7, align 8
  %MemRange4 = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr %ref.tmp, i32 0, i32 3
  %8 = bitcast ptr %MemRange4 to ptr
  store ptr addrspace(4) %MemRange.ascast, ptr %8, align 8
  call spir_func void @_ZN4sycl3_V16detail4loopILm1EZNS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESG_NS0_2idILi1EEEEUlmE_EEvOT0_(ptr addrspace(4) align 8 dereferenceable(32) %ref.tmp.ascast) #0
  %9 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.end.p0(i64 32, ptr %9)
  %call = call spir_func i64 @_ZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEv(ptr addrspace(4) align 8 %this1) #0
  %10 = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %this1, i32 0, i32 1
  %11 = bitcast ptr addrspace(4) %10 to ptr addrspace(4)
  %12 = load ptr addrspace(1), ptr addrspace(4) %11, align 8
  %add.ptr = getelementptr inbounds i32, ptr addrspace(1) %12, i64 %call
  %13 = bitcast ptr addrspace(4) %10 to ptr addrspace(4)
  store ptr addrspace(1) %add.ptr, ptr addrspace(4) %13, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail4loopILm1EZNS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESG_NS0_2idILi1EEEEUlmE_EEvOT0_(ptr addrspace(4) align 8 dereferenceable(32) %f) #0 !spirv.ParameterDecorations !26 {
entry:
  %f.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %agg.tmp = alloca %"struct.std::integer_sequence", align 1, !spirv.Decorations !14
  store ptr addrspace(4) %f, ptr %f.addr, align 8
  %0 = load ptr addrspace(4), ptr %f.addr, align 8
  call spir_func void @_ZN4sycl3_V16detail9loop_implIJLm0EEZNS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESG_NS0_2idILi1EEEEUlmE_EEvSt16integer_sequenceImJXspT_EEEOT0_(ptr byval(%"struct.std::integer_sequence") align 1 %agg.tmp, ptr addrspace(4) align 8 dereferenceable(32) %0) #0
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail9loop_implIJLm0EEZNS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESG_NS0_2idILi1EEEEUlmE_EEvSt16integer_sequenceImJXspT_EEEOT0_(ptr byval(%"struct.std::integer_sequence") align 1 %0, ptr addrspace(4) align 8 dereferenceable(32) %f) #0 !spirv.ParameterDecorations !29 {
entry:
  %.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %f.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %ref.tmp = alloca %"struct.std::integer_sequence", align 1, !spirv.Decorations !14
  %ref.tmp.ascast = addrspacecast ptr %ref.tmp to ptr addrspace(4)
  %1 = addrspacecast ptr %0 to ptr addrspace(4)
  store ptr addrspace(4) %1, ptr %.indirect_addr, align 8
  store ptr addrspace(4) %f, ptr %f.addr, align 8
  %2 = load ptr addrspace(4), ptr %f.addr, align 8
  %3 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.start.p0(i64 1, ptr %3)
  %call = call spir_func i64 @_ZNKSt17integral_constantImLm0EEcvmEv(ptr addrspace(4) align 1 %ref.tmp.ascast) #0
  call spir_func void @_ZZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEENKUlmE_clEm(ptr addrspace(4) align 8 %2, i64 %call) #0
  %4 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.end.p0(i64 1, ptr %4)
  ret void
}

; Function Attrs: nounwind
define spir_func i64 @_ZNKSt17integral_constantImLm0EEcvmEv(ptr addrspace(4) align 1 %this) #0 !spirv.ParameterDecorations !31 {
entry:
  %retval = alloca i64, align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  ret i64 0
}

; Function Attrs: nounwind
define spir_func void @_ZZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEENKUlmE_clEm(ptr addrspace(4) align 8 %this, i64 %I) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %I.addr = alloca i64, align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i64 %I, ptr %I.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr addrspace(4) %this1, i32 0, i32 0
  %1 = load ptr addrspace(4), ptr addrspace(4) %0, align 8
  %Offset = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr addrspace(4) %this1, i32 0, i32 1
  %2 = load ptr addrspace(4), ptr addrspace(4) %Offset, align 8
  %3 = load i64, ptr %I.addr, align 8
  %conv = trunc i64 %3 to i32
  %call = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %2, i32 %conv) #0
  %4 = load i64, ptr addrspace(4) %call, align 8
  %call2 = call spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE9getOffsetEv(ptr addrspace(4) align 8 %1) #0
  %5 = load i64, ptr %I.addr, align 8
  %conv3 = trunc i64 %5 to i32
  %call4 = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %call2, i32 %conv3) #0
  store i64 %4, ptr addrspace(4) %call4, align 8
  %AccessRange = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr addrspace(4) %this1, i32 0, i32 2
  %6 = load ptr addrspace(4), ptr addrspace(4) %AccessRange, align 8
  %7 = load i64, ptr %I.addr, align 8
  %conv5 = trunc i64 %7 to i32
  %call6 = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %6, i32 %conv5) #0
  %8 = load i64, ptr addrspace(4) %call6, align 8
  %call7 = call spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getAccessRangeEv(ptr addrspace(4) align 8 %1) #0
  %9 = load i64, ptr %I.addr, align 8
  %conv8 = trunc i64 %9 to i32
  %call9 = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %call7, i32 %conv8) #0
  store i64 %8, ptr addrspace(4) %call9, align 8
  %MemRange = getelementptr inbounds %class._ZTSZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE6__initEPU3AS5iNS0_5rangeILi1EEESE_NS0_2idILi1EEEEUlmE_, ptr addrspace(4) %this1, i32 0, i32 3
  %10 = load ptr addrspace(4), ptr addrspace(4) %MemRange, align 8
  %11 = load i64, ptr %I.addr, align 8
  %conv10 = trunc i64 %11 to i32
  %call11 = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %10, i32 %conv10) #0
  %12 = load i64, ptr addrspace(4) %call11, align 8
  %call12 = call spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getMemoryRangeEv(ptr addrspace(4) align 8 %1) #0
  %13 = load i64, ptr %I.addr, align 8
  %conv13 = trunc i64 %13 to i32
  %call14 = call spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %call12, i32 %conv13) #0
  store i64 %12, ptr addrspace(4) %call14, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func ptr addrspace(4) @_ZN4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %this, i32 %dimension) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr.i = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dimension.addr.i = alloca i32, align 4, !spirv.Decorations !9
  %retval = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dimension.addr = alloca i32, align 4, !spirv.Decorations !9
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i32 %dimension, ptr %dimension.addr, align 4
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = load i32, ptr %dimension.addr, align 4
  store ptr addrspace(4) %this1, ptr %this.addr.i, align 8
  store i32 %0, ptr %dimension.addr.i, align 4
  %this1.i = load ptr addrspace(4), ptr %this.addr.i, align 8
  %1 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %common_array = getelementptr inbounds %"class.sycl::_V1::detail::array", ptr addrspace(4) %1, i32 0, i32 0
  %2 = load i32, ptr %dimension.addr, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [1 x i64], ptr addrspace(4) %common_array, i64 0, i64 %idxprom
  ret ptr addrspace(4) %arrayidx
}

; Function Attrs: nounwind
define spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE9getOffsetEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %retval = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %impl = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %0, i32 0, i32 0
  %Offset = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %impl, i32 0, i32 0
  %1 = bitcast ptr addrspace(4) %Offset to ptr addrspace(4)
  ret ptr addrspace(4) %1
}

; Function Attrs: nounwind
define spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getAccessRangeEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %retval = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %impl = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %0, i32 0, i32 0
  %AccessRange = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %impl, i32 0, i32 1
  %1 = bitcast ptr addrspace(4) %AccessRange to ptr addrspace(4)
  ret ptr addrspace(4) %1
}

; Function Attrs: nounwind
define spir_func ptr addrspace(4) @_ZN4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getMemoryRangeEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %retval = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %impl = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %0, i32 0, i32 0
  %MemRange = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %impl, i32 0, i32 2
  %1 = bitcast ptr addrspace(4) %MemRange to ptr addrspace(4)
  ret ptr addrspace(4) %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: nounwind
define spir_func i64 @_ZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %retval = alloca i64, align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %TotalOffset = alloca i64, align 8, !spirv.Decorations !16
  %ref.tmp = alloca %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, align 8, !spirv.Decorations !16
  %cleanup.dest.slot = alloca i32, align 4, !spirv.Decorations !9
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  %TotalOffset.ascast = addrspacecast ptr %TotalOffset to ptr addrspace(4)
  %ref.tmp.ascast = addrspacecast ptr %ref.tmp to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr %TotalOffset to ptr
  call void @llvm.lifetime.start.p0(i64 8, ptr %0)
  store i64 0, ptr %TotalOffset, align 8
  %1 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.start.p0(i64 16, ptr %1)
  %2 = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr %ref.tmp, i32 0, i32 0
  %3 = bitcast ptr %2 to ptr
  store ptr addrspace(4) %this1, ptr %3, align 8
  %TotalOffset2 = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr %ref.tmp, i32 0, i32 1
  %4 = bitcast ptr %TotalOffset2 to ptr
  store ptr addrspace(4) %TotalOffset.ascast, ptr %4, align 8
  call spir_func void @_ZN4sycl3_V16detail4loopILm1EZNKS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_EEvOT0_(ptr addrspace(4) align 8 dereferenceable(16) %ref.tmp.ascast) #0
  %5 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.end.p0(i64 16, ptr %5)
  %6 = load i64, ptr %TotalOffset, align 8
  %7 = bitcast ptr %TotalOffset to ptr
  call void @llvm.lifetime.end.p0(i64 8, ptr %7)
  ret i64 %6
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail4loopILm1EZNKS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_EEvOT0_(ptr addrspace(4) align 8 dereferenceable(16) %f) #0 !spirv.ParameterDecorations !32 {
entry:
  %f.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %agg.tmp = alloca %"struct.std::integer_sequence", align 1, !spirv.Decorations !14
  store ptr addrspace(4) %f, ptr %f.addr, align 8
  %0 = load ptr addrspace(4), ptr %f.addr, align 8
  call spir_func void @_ZN4sycl3_V16detail9loop_implIJLm0EEZNKS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_EEvSt16integer_sequenceImJXspT_EEEOT0_(ptr byval(%"struct.std::integer_sequence") align 1 %agg.tmp, ptr addrspace(4) align 8 dereferenceable(16) %0) #0
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V16detail9loop_implIJLm0EEZNKS0_8accessorIiLi1ELNS0_6access4modeE1025ELNS4_6targetE2014ELNS4_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_EEvSt16integer_sequenceImJXspT_EEEOT0_(ptr byval(%"struct.std::integer_sequence") align 1 %0, ptr addrspace(4) align 8 dereferenceable(16) %f) #0 !spirv.ParameterDecorations !35 {
entry:
  %.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %f.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %ref.tmp = alloca %"struct.std::integer_sequence", align 1, !spirv.Decorations !14
  %ref.tmp.ascast = addrspacecast ptr %ref.tmp to ptr addrspace(4)
  %1 = addrspacecast ptr %0 to ptr addrspace(4)
  store ptr addrspace(4) %1, ptr %.indirect_addr, align 8
  store ptr addrspace(4) %f, ptr %f.addr, align 8
  %2 = load ptr addrspace(4), ptr %f.addr, align 8
  %3 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.start.p0(i64 1, ptr %3)
  %call = call spir_func i64 @_ZNKSt17integral_constantImLm0EEcvmEv(ptr addrspace(4) align 1 %ref.tmp.ascast) #0
  call spir_func void @_ZZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvENKUlmE_clEm(ptr addrspace(4) align 8 %2, i64 %call) #0
  %4 = bitcast ptr %ref.tmp to ptr
  call void @llvm.lifetime.end.p0(i64 1, ptr %4)
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvENKUlmE_clEm(ptr addrspace(4) align 8 %this, i64 %I) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %I.addr = alloca i64, align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i64 %I, ptr %I.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr addrspace(4) %this1, i32 0, i32 0
  %1 = load ptr addrspace(4), ptr addrspace(4) %0, align 8
  %TotalOffset = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr addrspace(4) %this1, i32 0, i32 1
  %2 = load ptr addrspace(4), ptr addrspace(4) %TotalOffset, align 8
  %3 = bitcast ptr addrspace(4) %2 to ptr addrspace(4)
  %4 = load i64, ptr addrspace(4) %3, align 8
  %5 = bitcast ptr addrspace(4) %1 to ptr addrspace(4)
  %impl = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %5, i32 0, i32 0
  %MemRange = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %impl, i32 0, i32 2
  %6 = load i64, ptr %I.addr, align 8
  %conv = trunc i64 %6 to i32
  %call = call spir_func i64 @_ZNK4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %MemRange, i32 %conv) #0
  %mul = mul i64 %4, %call
  %TotalOffset2 = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr addrspace(4) %this1, i32 0, i32 1
  %7 = load ptr addrspace(4), ptr addrspace(4) %TotalOffset2, align 8
  %8 = bitcast ptr addrspace(4) %7 to ptr addrspace(4)
  store i64 %mul, ptr addrspace(4) %8, align 8
  %9 = bitcast ptr addrspace(4) %1 to ptr addrspace(4)
  %impl3 = getelementptr inbounds %"class.sycl::_V1::accessor", ptr addrspace(4) %9, i32 0, i32 0
  %Offset = getelementptr inbounds %"class.sycl::_V1::detail::AccessorImplDevice", ptr addrspace(4) %impl3, i32 0, i32 0
  %10 = load i64, ptr %I.addr, align 8
  %conv4 = trunc i64 %10 to i32
  %call5 = call spir_func i64 @_ZNK4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %Offset, i32 %conv4) #0
  %TotalOffset6 = getelementptr inbounds %class._ZTSZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEE14getTotalOffsetEvEUlmE_, ptr addrspace(4) %this1, i32 0, i32 1
  %11 = load ptr addrspace(4), ptr addrspace(4) %TotalOffset6, align 8
  %12 = bitcast ptr addrspace(4) %11 to ptr addrspace(4)
  %13 = load i64, ptr addrspace(4) %12, align 8
  %add = add i64 %13, %call5
  %14 = bitcast ptr addrspace(4) %11 to ptr addrspace(4)
  store i64 %add, ptr addrspace(4) %14, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func i64 @_ZNK4sycl3_V16detail5arrayILi1EEixEi(ptr addrspace(4) align 8 %this, i32 %dimension) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr.i = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dimension.addr.i = alloca i32, align 4, !spirv.Decorations !9
  %retval = alloca i64, align 8, !spirv.Decorations !16
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %dimension.addr = alloca i32, align 4, !spirv.Decorations !9
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store i32 %dimension, ptr %dimension.addr, align 4
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = load i32, ptr %dimension.addr, align 4
  store ptr addrspace(4) %this1, ptr %this.addr.i, align 8
  store i32 %0, ptr %dimension.addr.i, align 4
  %this1.i = load ptr addrspace(4), ptr %this.addr.i, align 8
  %1 = bitcast ptr addrspace(4) %this1 to ptr addrspace(4)
  %common_array = getelementptr inbounds %"class.sycl::_V1::detail::array", ptr addrspace(4) %1, i32 0, i32 0
  %2 = load i32, ptr %dimension.addr, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [1 x i64], ptr addrspace(4) %common_array, i64 0, i64 %idxprom
  %3 = load i64, ptr addrspace(4) %arrayidx, align 8
  ret i64 %3
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V114kernel_handlerC2Ev(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %MSpecializationConstantsBuffer = getelementptr inbounds %"class.sycl::_V1::kernel_handler", ptr addrspace(4) %this1, i32 0, i32 0
  store ptr addrspace(4) null, ptr addrspace(4) %MSpecializationConstantsBuffer, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V114kernel_handler38__init_specialization_constants_bufferEPc(ptr addrspace(4) align 8 %this, ptr addrspace(4) %SpecializationConstantsBuffer) #0 !spirv.ParameterDecorations !18 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %SpecializationConstantsBuffer.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  store ptr addrspace(4) %SpecializationConstantsBuffer, ptr %SpecializationConstantsBuffer.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = load ptr addrspace(4), ptr %SpecializationConstantsBuffer.addr, align 8
  %MSpecializationConstantsBuffer = getelementptr inbounds %"class.sycl::_V1::kernel_handler", ptr addrspace(4) %this1, i32 0, i32 0
  store ptr addrspace(4) %0, ptr addrspace(4) %MSpecializationConstantsBuffer, align 8
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_ENKUlNS0_14kernel_handlerEE_clES4_(ptr addrspace(4) align 8 %this, ptr byval(%"class.sycl::_V1::kernel_handler") align 8 %kh) #0 !spirv.ParameterDecorations !36 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %kh.indirect_addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %task = alloca %"class.sycl::_V1::ext::intel::experimental::task_sequence", align 8, !spirv.Decorations !16
  %agg.tmp = alloca %"class.sycl::_V1::range", align 8, !spirv.Decorations !16
  %task.ascast = addrspacecast ptr %task to ptr addrspace(4)
  %agg.tmp.ascast = addrspacecast ptr %agg.tmp to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %kh.ascast = addrspacecast ptr %kh to ptr addrspace(4)
  store ptr addrspace(4) %kh.ascast, ptr %kh.indirect_addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %0 = bitcast ptr %task to ptr
  call void @llvm.lifetime.start.p0(i64 16, ptr %0)
  call spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEEC2Ev(ptr addrspace(4) align 8 %task.ascast) #0
  call spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEE5asyncEv(ptr addrspace(4) align 8 %task.ascast) #0
  %call = call spir_func i32 @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEE3getEv(ptr addrspace(4) align 8 %task.ascast) #0
  %res_acc = getelementptr inbounds %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_14kernel_handlerEE_, ptr addrspace(4) %this1, i32 0, i32 0
  call spir_func void @_ZN4sycl3_V12idILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8 %agg.tmp.ascast, i64 0) #0
  %call2 = call spir_func ptr addrspace(4) @_ZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEEixILi1EvEERiNS0_2idILi1EEE(ptr addrspace(4) align 8 %res_acc, ptr byval(%"class.sycl::_V1::range") align 8 %agg.tmp) #0
  store i32 %call, ptr addrspace(4) %call2, align 4
  call spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEED2Ev(ptr addrspace(4) align 8 %task.ascast) #0
  %1 = bitcast ptr %task to ptr
  call void @llvm.lifetime.end.p0(i64 16, ptr %1)
  ret void
}

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEEC2Ev(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %outstanding = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 0
  store i32 0, ptr addrspace(4) %outstanding, align 8
  %call = call spir_func target("spirv.TaskSequenceINTEL") @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr @_Z3barv, i32 -1, i32 -1, i32 1, i32 1) #0
  %taskSequence = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 1
  store target("spirv.TaskSequenceINTEL") %call, ptr addrspace(4) %taskSequence, align 8
  ret void
}

; Function Attrs: nounwind
declare spir_func target("spirv.TaskSequenceINTEL") @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPiiiii(ptr, i32, i32, i32, i32) #0

; Function Attrs: nounwind
define spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEE5asyncEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %outstanding = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 0
  %0 = load i32, ptr addrspace(4) %outstanding, align 8
  %inc = add i32 %0, 1
  store i32 %inc, ptr addrspace(4) %outstanding, align 8
  %taskSequence = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 1
  %1 = load target("spirv.TaskSequenceINTEL"), ptr addrspace(4) %taskSequence, align 8
  call spir_func void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTEL(target("spirv.TaskSequenceINTEL") %1) #0
  ret void
}

; Function Attrs: nounwind
declare spir_func void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTEL(target("spirv.TaskSequenceINTEL")) #0

; Function Attrs: nounwind
define spir_func i32 @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEE3getEv(ptr addrspace(4) align 8 %this) #0 !spirv.ParameterDecorations !17 {
entry:
  %retval = alloca i32, align 4, !spirv.Decorations !9
  %this.addr = alloca ptr addrspace(4), align 8, !spirv.Decorations !16
  %retval.ascast = addrspacecast ptr %retval to ptr addrspace(4)
  store ptr addrspace(4) %this, ptr %this.addr, align 8
  %this1 = load ptr addrspace(4), ptr %this.addr, align 8
  %outstanding = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 0
  %0 = load i32, ptr addrspace(4) %outstanding, align 8
  %dec = add i32 %0, -1
  store i32 %dec, ptr addrspace(4) %outstanding, align 8
  %taskSequence = getelementptr inbounds %"class.sycl::_V1::ext::intel::experimental::task_sequence", ptr addrspace(4) %this1, i32 0, i32 1
  %1 = load target("spirv.TaskSequenceINTEL"), ptr addrspace(4) %taskSequence, align 8
  %call = call spir_func i32 null(target("spirv.TaskSequenceINTEL") %1) #0
  ret i32 %call
}

; Function Attrs: nounwind
declare spir_func void @_ZN4sycl3_V12idILi1EEC2ILi1EEENSt9enable_ifIXeqT_Li1EEmE4typeE(ptr addrspace(4) align 8, i64) #0

; Function Attrs: nounwind
declare spir_func ptr addrspace(4) @_ZNK4sycl3_V18accessorIiLi1ELNS0_6access4modeE1025ELNS2_6targetE2014ELNS2_11placeholderE0ENS0_3ext6oneapi22accessor_property_listIJEEEEixILi1EvEERiNS0_2idILi1EEE(ptr addrspace(4) align 8, ptr byval(%"class.sycl::_V1::range") align 8) #0

; Function Attrs: nounwind
declare spir_func void @_ZN4sycl3_V13ext5intel12experimental13task_sequenceIL_Z3barvENS1_6oneapi12experimental10propertiesISt5tupleIJNS6_14property_valueINS3_23invocation_capacity_keyEJSt17integral_constantIjLj1EEEEENS9_INS3_21response_capacity_keyEJSC_EEEEEEEED2Ev(ptr addrspace(4) align 8) #0

attributes #0 = { nounwind }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!spirv.Source = !{!2}

!2 = !{i32 4, i32 100000}
!3 = !{i32 1, i32 0, i32 0, i32 0, i32 1}
!4 = !{!"none", !"none", !"none", !"none", !"none"}
!5 = !{!"char*", !"class.sycl::_V1::range", !"class.sycl::_V1::range", !"class.sycl::_V1::range", !"char*"}
!6 = !{!"", !"", !"", !"", !""}
!7 = !{i32 0}
!8 = !{!9, !11, !11, !11, !14}
!9 = !{!10}
!10 = !{i32 44, i32 4}
!11 = !{!12, !13}
!12 = !{i32 38, i32 2}
!13 = !{i32 44, i32 8}
!14 = !{!15}
!15 = !{i32 44, i32 1}
!16 = !{!13}
!17 = !{!16}
!18 = !{!16, !19}
!19 = !{}
!20 = !{!21}
!21 = !{!22, !23, !13}
!22 = !{i32 38, i32 4}
!23 = !{i32 38, i32 3}
!24 = !{!16, !11, !11, !11}
!25 = !{!16, !19, !11, !11, !11}
!26 = !{!27}
!27 = !{!13, !28}
!28 = !{i32 45, i32 32}
!29 = !{!30, !27}
!30 = !{!12, !15}
!31 = !{!14}
!32 = !{!33}
!33 = !{!13, !34}
!34 = !{i32 45, i32 16}
!35 = !{!30, !33}
!36 = !{!16, !11}
