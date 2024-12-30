; RUN: opt -passes=sycl-kernel-private-to-heap -S %s -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-private-to-heap -sycl-kernel-max-private-mem-size=0 -S %s -o - | FileCheck %s -check-prefix=CHECK-0
; RUN: opt -passes=sycl-kernel-private-to-heap -sycl-kernel-max-private-mem-size=2 -S %s -o - | FileCheck %s -check-prefix=CHECK-2
; RUN: opt -passes=sycl-kernel-private-to-heap -sycl-kernel-max-private-mem-size=8192 -S %s -o - | FileCheck %s -check-prefix=CHECK-8192
; RUN: opt -passes=sycl-kernel-private-to-heap -sycl-kernel-max-private-mem-size=49154 -S %s -o - | FileCheck %s -check-prefix=CHECK-49154

; Check alloca instructions are moved to heap gradually when threshold increases.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_ = type { i8 }

define void @_ZTSN4sycl3_V16kernelE(ptr addrspace(3) noalias %pLocalMemBase, ptr noalias %pWorkDim, ptr noalias %pWGId, [4 x i64] %BaseGlbId, ptr noalias %pSpecialBuf, ptr noalias %RuntimeHandle, ptr noalias %pPrivateHeapMem) #0 !no_barrier_path !2 !private_memory_size !3 {
entry:
; CHECK-LABEL: @_ZTSN4sycl3_V16kernelE
; CHECK-0-NOT: alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_,
; CHECK-0: icmp eq ptr %pPrivateHeapMem, null
; CHECK-2: alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_,
; CHECK-8192: alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_,
; CHECK-49154-NOT: alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_,

  %__SYCLKernel = alloca %class._ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUlNS0_7nd_itemILi1EEEE_, align 1
  %__SYCLKernel.ascast = addrspacecast ptr %__SYCLKernel to ptr addrspace(4)
  call void @_ZZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_ENKUlNS0_7nd_itemILi1EEEE_clES5_(ptr addrspace(4) align 1 %__SYCLKernel.ascast, ptr addrspace(3) noalias %pLocalMemBase, ptr noalias %pWorkDim, ptr noalias %pWGId, [4 x i64] %BaseGlbId, ptr noalias %pSpecialBuf, ptr noalias %RuntimeHandle, ptr noalias %pPrivateHeapMem) #1
  ret void
}

define hidden void @_ZZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_ENKUlNS0_7nd_itemILi1EEEE_clES5_(ptr addrspace(4) align 1 %this, ptr addrspace(3) noalias %pLocalMemBase, ptr noalias %pWorkDim, ptr noalias %pWGId, [4 x i64] %BaseGlbId, ptr noalias %pSpecialBuf, ptr noalias %RuntimeHandle, ptr noalias %pPrivateHeapMem) #1 {
entry:
; CHECK-LABEL: @_ZZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_ENKUlNS0_7nd_itemILi1EEEE_clES5_
; CHECK-0-NOT: alloca [1024 x i8]
; CHECK-2-NOT: alloca [1024 x i8]
; CHECK-8192-COUNT-7: alloca [1024 x i8]
; CHECK-8192-NOT: alloca [1024 x i8]
; CHECK-49154-NOT: alloca [1024 x i8]

  %a1b1c1 = alloca [1024 x i8], align 1
  %a2b1c1 = alloca [1024 x i8], align 1
  %a3b1c1 = alloca [1024 x i8], align 1
  %a4b1c1 = alloca [1024 x i8], align 1
  %a5b1c1 = alloca [1024 x i8], align 1
  %a6b1c1 = alloca [1024 x i8], align 1
  %a7b1c1 = alloca [1024 x i8], align 1
  %a8b1c1 = alloca [1024 x i8], align 1
  %a9b1c1 = alloca [1024 x i8], align 1
  %a10b1c1 = alloca [1024 x i8], align 1
  %a11b1c1 = alloca [1024 x i8], align 1
  %a12b1c1 = alloca [1024 x i8], align 1
  %a13b1c1 = alloca [1024 x i8], align 1
  %a14b1c1 = alloca [1024 x i8], align 1
  %a15b1c1 = alloca [1024 x i8], align 1
  %a16b1c1 = alloca [1024 x i8], align 1
  %a1b2c1 = alloca [1024 x i8], align 1
  %a2b2c1 = alloca [1024 x i8], align 1
  %a3b2c1 = alloca [1024 x i8], align 1
  %a4b2c1 = alloca [1024 x i8], align 1
  %a5b2c1 = alloca [1024 x i8], align 1
  %a6b2c1 = alloca [1024 x i8], align 1
  %a7b2c1 = alloca [1024 x i8], align 1
  %a8b2c1 = alloca [1024 x i8], align 1
  %a9b2c1 = alloca [1024 x i8], align 1
  %a10b2c1 = alloca [1024 x i8], align 1
  %a11b2c1 = alloca [1024 x i8], align 1
  %a12b2c1 = alloca [1024 x i8], align 1
  %a13b2c1 = alloca [1024 x i8], align 1
  %a14b2c1 = alloca [1024 x i8], align 1
  %a15b2c1 = alloca [1024 x i8], align 1
  %a16b2c1 = alloca [1024 x i8], align 1
  %a1b3c1 = alloca [1024 x i8], align 1
  %a2b3c1 = alloca [1024 x i8], align 1
  %a3b3c1 = alloca [1024 x i8], align 1
  %a4b3c1 = alloca [1024 x i8], align 1
  %a5b3c1 = alloca [1024 x i8], align 1
  %a6b3c1 = alloca [1024 x i8], align 1
  %a7b3c1 = alloca [1024 x i8], align 1
  %a8b3c1 = alloca [1024 x i8], align 1
  %a9b3c1 = alloca [1024 x i8], align 1
  %a10b3c1 = alloca [1024 x i8], align 1
  %a11b3c1 = alloca [1024 x i8], align 1
  %a12b3c1 = alloca [1024 x i8], align 1
  %a13b3c1 = alloca [1024 x i8], align 1
  %a14b3c1 = alloca [1024 x i8], align 1
  %a15b3c1 = alloca [1024 x i8], align 1
  %a16b3c1 = alloca [1024 x i8], align 1

  ret void
}

attributes #0 = { convergent noinline nounwind optnone }
attributes #1 = { noinline nounwind optnone }

!spirv.Source = !{!0}
!sycl.kernels = !{!1}

!0 = !{i32 4, i32 100000}
!1 = !{ptr @_ZTSN4sycl3_V16kernelE}
!2 = !{i1 true}
!3 = !{i64 1114176}

; DEBUGIFY-NOT: WARNING
