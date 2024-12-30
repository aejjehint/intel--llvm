target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"

%structtype.1 = type { [1 x ptr addrspace(4)] }

@_ZTV10NodeKernel = linkonce_odr addrspace(1) constant %structtype.1 { [1 x ptr addrspace(4)] [ptr addrspace(4) addrspacecast (ptr @_ZN10NodeKernelD0Ev to ptr addrspace(4))] }, align 8

define linkonce_odr spir_func void @_ZN10NodeKernelD0Ev(ptr addrspace(4) align 8 %this) noinline optnone {
entry:
  call spir_func void @_ZdlPvy(ptr addrspace(4) %this, i64 16)
  ret void
}

define spir_func void @_ZdlPvy(ptr addrspace(4) %ptr, i64 %size) {
entry:
  call spir_func void @__kmpc_free(i32 0, ptr addrspace(4) %ptr, ptr addrspace(4) null)
  ret void
}

define spir_func void @__kmpc_free(i32 %gtid, ptr addrspace(4) %ptr, ptr addrspace(4) %al) {
  ret void
}
