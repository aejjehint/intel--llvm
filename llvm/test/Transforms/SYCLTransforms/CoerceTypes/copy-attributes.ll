; RUN: opt -passes=sycl-kernel-coerce-types -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-coerce-types -S %s -o - | FileCheck %s

; Check param attributes of the old call are preserved at correct params in the
; new call, while byval attribute is dropped.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%"class.sycl::_V1::range" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [2 x i64] }

define internal void @_ZN4sycl3_V16detail7Builder11createGroupILi2EEENS0_5groupIXT_EEERKNS0_5rangeIXT_EEES9_S9_RKNS0_2idIXT_EEE(ptr addrspace(4) %agg.result, ptr addrspace(4) %0) {
entry:
; CHECK: call void @_ZN4sycl3_V15groupILi2EEC2ERKNS0_5rangeILi2EEES6_S4_RKNS0_2idILi2EEE(ptr addrspace(4) align 8 %agg.result, ptr addrspace(4) align 8 dereferenceable(16) %{{[0-9]+}}, ptr addrspace(4) align 8 dereferenceable(16) %{{[0-9]+}}, i64 %{{[0-9]+}}, i64 %{{[0-9]+}}, ptr addrspace(4) align 8 dereferenceable(16) %{{[0-9]+}})

  call void @_ZN4sycl3_V15groupILi2EEC2ERKNS0_5rangeILi2EEES6_S4_RKNS0_2idILi2EEE(ptr addrspace(4) align 8 %agg.result, ptr addrspace(4) align 8 dereferenceable(16) %0, ptr addrspace(4) align 8 dereferenceable(16) %0, ptr null, ptr addrspace(4) align 8 dereferenceable(16) %0)
  ret void
}

declare void @_ZN4sycl3_V15groupILi2EEC2ERKNS0_5rangeILi2EEES6_S4_RKNS0_2idILi2EEE(ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr byval(%"class.sycl::_V1::range"), ptr addrspace(4))

; DEBUGIFY-NOT: WARNING
