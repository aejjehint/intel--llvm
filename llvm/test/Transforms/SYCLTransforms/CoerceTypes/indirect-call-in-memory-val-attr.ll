; RUN: opt -passes=sycl-kernel-coerce-types -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-coerce-types -S %s -o - | FileCheck %s

; Check the indirect call isn't modified as it won't call __devicelib_crealf
; which is coerced.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%structtype.1 = type { float, float }

define linkonce_odr float @_Z3bazIfET_PS0_(ptr addrspace(4) %0) #0 {
entry:
  ret float 0.000000e+00
}

define void @__omp_offloading_804_246ea00__Z4main_l18(i64 %_Z3bazIfET_PS0_, ptr addrspace(1) %.inst) {
newFuncRoot:
  %.ascast = addrspacecast ptr addrspace(1) null to ptr addrspace(4)
  %0 = call ptr addrspace(4) @__kmpc_target_translate_fptr(i64 %_Z3bazIfET_PS0_)
  %1 = addrspacecast ptr addrspace(4) %0 to ptr

; CHECK call float %{{[0-9]+}}(ptr addrspace(4) %.ascast)

  %2 = call float %1(ptr addrspace(4) %.ascast)
  ret void
}

define internal ptr addrspace(4) @__kmpc_target_translate_fptr(i64 %fn_ptr) #1 {
entry:
  ret ptr addrspace(4) null
}

; CHECK: declare float @__devicelib_crealf(<2 x float>)

declare float @__devicelib_crealf(ptr addrspace(4) byval(%structtype.1))

attributes #0 = { "referenced-indirectly" }
attributes #1 = { nounwind }

; DEBUGIFY-NOT: WARNING
