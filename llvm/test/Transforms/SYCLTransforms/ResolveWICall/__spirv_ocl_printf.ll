; RUN: opt -passes=debugify,sycl-kernel-resolve-wi-call,check-debugify -S %s -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-resolve-wi-call -S %s | FileCheck %s

; Check __spirv_ocl_printf is resolved.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@.str = internal unnamed_addr addrspace(1) constant [9 x i8] c"%s, %s!\0A\00", align 1
@.str.1 = internal unnamed_addr addrspace(1) constant [6 x i8] c"Hello\00", align 1
@.str.2 = internal unnamed_addr addrspace(1) constant [6 x i8] c"world\00", align 1

declare i32 @_Z18__spirv_ocl_printfPU3AS4PcS1_S1_(ptr addrspace(4), ptr addrspace(4), ptr addrspace(4))

define void @test(ptr addrspace(3) noalias %pLocalMemBase, ptr noalias %pWorkDim, ptr noalias %pWGId, [4 x i64] %BaseGlbId, ptr noalias %pSpecialBuf, ptr noalias %RuntimeHandle) #0 {
entry:
; CHECK: %temp_arg_buf = alloca [32 x i8], align 4
; CHECK: [[GEP1:%[0-9]+]] = getelementptr inbounds [32 x i8], ptr %temp_arg_buf, i32 0, i32 0
; CHECK: store i32 32, ptr [[GEP1]], align 4
; CHECK: [[GEP2:%[0-9]+]] = getelementptr inbounds [32 x i8], ptr %temp_arg_buf, i32 0, i32 4
; CHECK: store i32 8, ptr [[GEP2]], align 4
; CHECK: [[GEP3:%[0-9]+]] = getelementptr inbounds [32 x i8], ptr %temp_arg_buf, i32 0, i32 8
; CHECK: store ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str.1 to ptr addrspace(4)), ptr [[GEP3]], align 1
; CHECK: [[GEP4:%[0-9]+]] = getelementptr inbounds [32 x i8], ptr %temp_arg_buf, i32 0, i32 16
; CHECK: store i32 262152, ptr [[GEP4]], align 4
; CHECK: [[GEP5:%[0-9]+]] = getelementptr inbounds [32 x i8], ptr %temp_arg_buf, i32 0, i32 24
; CHECK: store ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str.2 to ptr addrspace(4)), ptr [[GEP5]], align 1
; CHECK: %translated_opencl_printf_call = call i32 @__opencl_printf(ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str to ptr addrspace(4)), ptr %1, ptr %RuntimeInterface, ptr %RuntimeHandle)

  %call = tail call i32 @_Z18__spirv_ocl_printfPU3AS4PcS1_S1_(ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str.1 to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @.str.2 to ptr addrspace(4))) #0
  ret void
}

attributes #0 = { nounwind }

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

!0 = !{i32 4, i32 100000}
!1 = !{ptr @test}

; DEBUGIFY: WARNING: Instruction with empty DebugLoc in function test -- {{.*}} = getelementptr { i64, [3 x i64], [3 x i64], [2 x [3 x i64]], [3 x i64], ptr, ptr, [3 x i64], [2 x [3 x i64]], [3 x i64] }, ptr %pWorkDim, i32 0, i32 5
; DEBUGIFY: WARNING: Instruction with empty DebugLoc in function test -- %RuntimeInterface = load ptr, ptr %0, align 1
; DEBUGIFY: WARNING: Instruction with empty DebugLoc in function test -- %temp_arg_buf = alloca [32 x i8], align 4
; DEBUGIFY-NOT: WARNING
