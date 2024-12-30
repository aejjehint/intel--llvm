; RUN: opt -S -passes=sycl-kernel-handle-taskseq-async %s | FileCheck %s
; RUN: opt -S -passes=sycl-kernel-handle-taskseq-async %s -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY

; The test checks if sret argument is lowered to return type and
; there are no duplicated kernel in sycl.kernels metadata.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%struct.FunctionPacket = type <{ float, i8, [3 x i8] }>
%"class.sycl::_V1::range" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }

; CHECK-LABEL: define void @_ZTS16TaskSequenceTest
define void @_ZTS16TaskSequenceTest(ptr addrspace(1) nocapture readonly align 4 %_arg_in_acc_struct, ptr nocapture readonly byval(%"class.sycl::_V1::range") align 8 %_arg_in_acc_struct4) !kernel_arg_addr_space !2 !kernel_arg_type !3 !kernel_arg_base_type !3 {
entry:
  %agg.tmp.i.i = alloca %struct.FunctionPacket, align 4
  %agg.tmp13.sroa.0.0.copyload = load i64, ptr %_arg_in_acc_struct4, align 8
  %add.ptr.i = getelementptr inbounds %struct.FunctionPacket, ptr addrspace(1) %_arg_in_acc_struct, i64 %agg.tmp13.sroa.0.0.copyload
  %call.i.i = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPviiii(ptr nonnull @_Z15function1StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEEv14FunctionPacket, i32 -1, i32 -1, i32 0, i32 0)
; CHECK: tail call ptr addrspace(1) @[[CREATE:_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPviiii]](ptr nonnull @[[Function1Struct:_Z15function1StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEEv14FunctionPacket]], i32 -1, i32 -1, i32 0, i32 0)
  %0 = load i64, ptr addrspace(1) %add.ptr.i, align 4
  store i64 %0, ptr %agg.tmp.i.i, align 4
  call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELP14FunctionPacket(ptr addrspace(1) %call.i.i, ptr nonnull %agg.tmp.i.i)
; CHECK: call void @[[ASYNCSTRUCT:_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELP14FunctionPacket]](ptr addrspace(1) %call.i.i, ptr @[[Function1Struct]],  ptr %agg.tmp.i.i)
  %arrayidx.i.1.i = getelementptr inbounds i64, ptr addrspace(1) %add.ptr.i, i64 1
  %1 = load i64, ptr addrspace(1) %arrayidx.i.1.i, align 4
  store i64 %1, ptr %agg.tmp.i.i, align 4
  call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELP14FunctionPacket(ptr addrspace(1) %call.i.i, ptr nonnull %agg.tmp.i.i)
; CHECK: call void @[[ASYNCSTRUCT]](ptr addrspace(1) %call.i.i, ptr @[[Function1Struct]],  ptr %agg.tmp.i.i)
  %arrayidx.i.2.i = getelementptr inbounds i64, ptr addrspace(1) %add.ptr.i, i64 2
  %2 = load i64, ptr addrspace(1) %arrayidx.i.2.i, align 4
  store i64 %2, ptr %agg.tmp.i.i, align 4
  call void @_Z32__spirv_TaskSequenceReleaseINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1) %call.i.i)
  ret void
}

; CHECK-LABEL: define void @_ZTS17TaskSequenceTest1
define void @_ZTS17TaskSequenceTest1() {
entry:
  %ref.tmp.i = alloca %struct.FunctionPacket, align 4
  %ref.tmp.ascast.i = addrspacecast ptr %ref.tmp.i to ptr addrspace(4)
  %call.i7.i = tail call ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPviiii(ptr nonnull @_Z15function2StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEE14FunctionPacketb, i32 -1, i32 -1, i32 0, i32 0)
; CHECK: tail call ptr addrspace(1) @[[CREATE]](ptr nonnull @[[Function2Struct:_Z15function2StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEE14FunctionPacketb]], i32 -1, i32 -1, i32 0, i32 0)
  call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELb(ptr addrspace(1) %call.i7.i, i1 true)
; CHECK: call void @[[ASYNCBOOL:_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELb]](ptr addrspace(1) %call.i7.i, ptr @[[Function2Struct]], i1 true)
  call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELb(ptr addrspace(1) %call.i7.i, i1 true)
; CHECK: call void @[[ASYNCBOOL]](ptr addrspace(1) %call.i7.i, ptr @[[Function2Struct]], i1 true)
  call void @_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(4) sret(%struct.FunctionPacket) %ref.tmp.ascast.i, ptr addrspace(1) %call.i7.i)
; CHECK: call %struct.FunctionPacket @[[GET:_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL]](ptr addrspace(1) %call.i7.i)
  call void @_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(4) sret(%struct.FunctionPacket) %ref.tmp.ascast.i, ptr addrspace(1) %call.i7.i)
; CHECK: call %struct.FunctionPacket @[[GET]](ptr addrspace(1) %call.i7.i)
  call void @_Z32__spirv_TaskSequenceReleaseINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1) %call.i7.i)
  ret void
}

define internal void @_Z15function1StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEEv14FunctionPacket(ptr nocapture readonly byval(%struct.FunctionPacket) align 4 %fp) {
; CHECK-DAG: define internal void @[[Function1Struct]](ptr nocapture readonly byval(%struct.FunctionPacket) align 4 %fp)
entry:
  ret void
}

define internal void @_Z15function2StructIN4sycl3_V13ext5intel4pipeI8my_pipe1fLi12EEEE14FunctionPacketb(ptr addrspace(4) noalias nocapture writeonly sret(%struct.FunctionPacket) align 4 %agg.result, i1 zeroext %shouldRead) {
; CHECK-DAG: define internal %struct.FunctionPacket @[[Function2Struct]](i1 zeroext %shouldRead)
entry:
  ret void
}

declare ptr addrspace(1) @_Z66__spirv_TaskSequenceCreateINTEL_RPU3AS125__spirv_TaskSequenceINTELPviiii(ptr, i32, i32, i32, i32)

declare void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELP14FunctionPacket(ptr addrspace(1), ptr)

declare void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELb(ptr addrspace(1), i1)

declare void @_Z32__spirv_TaskSequenceReleaseINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1))

declare void @_Z28__spirv_TaskSequenceGetINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(4) sret(%struct.FunctionPacket), ptr addrspace(1))
; CHECK-DAG: define internal %struct.FunctionPacket @[[GET]](ptr addrspace(1) %0)

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

; CHECK: !sycl.kernels = !{[[SYCLKernel:![0-9]+]]}
; CHECK: [[SYCLKernel]] = !{ptr @_ZTS16TaskSequenceTest, ptr @_ZTS17TaskSequenceTest1, ptr @[[Function1Struct]]._block_invoke_kernel, ptr @[[Function2Struct]]._block_invoke_kernel}

!0 = !{i32 4, i32 100000}
!1 = !{ptr @_ZTS16TaskSequenceTest, ptr @_ZTS17TaskSequenceTest1}
!2 = !{i32 1, i32 0}
!3 = !{!"char*", !"class.sycl::_V1::range"}

; Generated functions won't contain any debug info, so we only check debug info
; in the original kernel wasn't discarded.
; DEBUGIFY-NOT: WARNING: {{.*}} _ZTS16TaskSequenceTest
; DEBUGIFY-NOT: WARNING: {{.*}} _ZTS17TaskSequenceTest1
