; RUN: opt -passes=sycl-kernel-private-to-heap %s -enable-debugify -disable-output 2>&1 | FileCheck %s -check-prefix=DEBUGIFY
; RUN: opt -passes=sycl-kernel-private-to-heap %s -S -o - | FileCheck %s

; Check basic block isn't split before call instruction when there is no
; large-size alloca in a function.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define void @_ZTSN4sycl3_V16kernelE(ptr addrspace(3) %pLocalMemBase, ptr %pWorkDim, ptr %pWGId, [4 x i64] %BaseGlbId, ptr %pSpecialBuf, ptr %RuntimeHandle, ptr %pPrivateHeapMem) !no_barrier_path !1 !private_memory_size !2 {
; CHECK: define void @_ZTSN4sycl3_V16kernelE(
; CHECK-NEXT: call void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_(

  call void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_(ptr addrspace(3) null, ptr null, ptr null, [4 x i64] zeroinitializer, ptr null, ptr null, ptr %pPrivateHeapMem)
  ret void
}

define weak_odr void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_(ptr addrspace(3) %pLocalMemBase, ptr %pWorkDim, ptr %pWGId, [4 x i64] %BaseGlbId, ptr %pSpecialBuf, ptr %RuntimeHandle, ptr %pPrivateHeapMem) {
; CHECK: define weak_odr void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_(
; CHECK-NEXT: call void @_ZN7__spirv14initGlobalSizeILi1EN4sycl3_V15rangeILi1EEEEET0_v(
  call void @_ZN7__spirv14initGlobalSizeILi1EN4sycl3_V15rangeILi1EEEEET0_v(ptr addrspace(4) null, ptr addrspace(3) null, ptr null, ptr null, [4 x i64] zeroinitializer, ptr null, ptr %pPrivateHeapMem)
  ret void
}

define weak_odr void @_ZN7__spirv14initGlobalSizeILi1EN4sycl3_V15rangeILi1EEEEET0_v(ptr addrspace(4) %agg.result, ptr addrspace(3) %pLocalMemBase, ptr %pWorkDim, ptr %pWGId, [4 x i64] %BaseGlbId, ptr %pSpecialBuf, ptr %pPrivateHeapMem) {
; CHECK: define weak_odr void @_ZN7__spirv14initGlobalSizeILi1EN4sycl3_V15rangeILi1EEEEET0_v(
; CHECK-NEXT: call void @_ZN7__spirv21InitSizesSTGlobalSizeILi1EN4sycl3_V15rangeILi1EEEE8initSizeEv(

  call void @_ZN7__spirv21InitSizesSTGlobalSizeILi1EN4sycl3_V15rangeILi1EEEE8initSizeEv()
  ret void
}

declare void @_ZN7__spirv21InitSizesSTGlobalSizeILi1EN4sycl3_V15rangeILi1EEEE8initSizeEv()

!sycl.kernels = !{!0}

!0 = !{ptr @_ZTSN4sycl3_V16kernelE}
!1 = !{i1 true}
!2 = !{i64 1114176}

; DEBUGIFY-NOT: Warning
