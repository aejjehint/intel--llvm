target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"

$_ZN4BaseD0Ev = comdat any

@"_ZN4BaseD0Ev$SIMDTable" = weak local_unnamed_addr addrspace(1) global [1 x ptr] [ptr @_ZN4BaseD0Ev], align 8

declare dso_local spir_func void @_ZdlPvy(ptr addrspace(4) noundef, i64 noundef)

define linkonce_odr dso_local spir_func void @_ZN4BaseD0Ev(ptr addrspace(4) align 8 %this) {
entry:
  tail call spir_func void @_ZdlPvy(ptr addrspace(4) noundef %this, i64 noundef 8) #5
  ret void
}
