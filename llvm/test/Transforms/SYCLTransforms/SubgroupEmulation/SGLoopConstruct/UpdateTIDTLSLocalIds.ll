; RUN: opt -passes='sycl-kernel-sg-emu-loop-construct' -S %s | FileCheck %s

; get_global_id and get_local_id were already resolved with get_base_global_id + @__LocalIds
; when handling the first kernel which doesn't need subgroup emulation.
; Check TID0 is added by %sg.lid, which is required for the second kernel.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@__LocalIds = internal thread_local global [3 x i64] undef, align 16

define void @_ZTSZN10root_group5testsL22CATCH2_INTERNAL_TEST_2EvE21RootGroupNoSyncProp1D() {
scalar_kernel_entry:
  call void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_()
  ret void
}

define void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_() {
entry:
  call void @_ZN7__spirv22initGlobalInvocationIdILi1EN4sycl3_V12idILi1EEEEET0_v()
  call void @_ZN7__spirv21initLocalInvocationIdILi1EN4sycl3_V12idILi1EEEEET0_v()
  ret void
}

define void @_ZN7__spirv22initGlobalInvocationIdILi1EN4sycl3_V12idILi1EEEEET0_v() {
entry:
  call void @_ZN7__spirv29InitSizesSTGlobalInvocationIdILi1EN4sycl3_V12idILi1EEEE8initSizeEv()
  ret void
}

define void @_ZN7__spirv29InitSizesSTGlobalInvocationIdILi1EN4sycl3_V12idILi1EEEE8initSizeEv() {
entry:
  %call = call i64 @_ZN7__spirv21getGlobalInvocationIdILi0EEEmv()
  ret void
}

define i64 @_ZN7__spirv21getGlobalInvocationIdILi0EEEmv() {
entry:
  %call = call i64 @_Z28__spirv_GlobalInvocationId_xv()
  ret i64 0
}

define internal i64 @_Z28__spirv_GlobalInvocationId_xv() {
entry:
; CHECK-LABEL: define internal i64 @_Z28__spirv_GlobalInvocationId_xv(i32 %sg.lid)
; CHECK: %lid2 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 2), align 8
; CHECK: store i64 %lid2, ptr %lid2.addr, align 8
; CHECK: %lid1 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 1), align 8
; CHECK: store i64 %lid1, ptr %lid1.addr, align 8
; CHECK: %lid0 = load i64, ptr @__LocalIds, align 8
; CHECK: %0 = zext i32 %sg.lid to i64
; CHECK: %1 = add i64 %0, %lid0
; CHECK: store i64 %1, ptr %lid0.addr, align 8
; CHECK: %base.gid2 = call i64 @get_base_global_id.(i32 2)
; CHECK: %gid2 = add i64 %lid2, %base.gid2
; CHECK: store i64 %gid2, ptr %gid2.addr, align 8
; CHECK: %base.gid1 = call i64 @get_base_global_id.(i32 1)
; CHECK: %gid1 = add i64 %lid1, %base.gid1
; CHECK: store i64 %gid1, ptr %gid1.addr, align 8
; CHECK: %base.gid0 = call i64 @get_base_global_id.(i32 0)
; CHECK: %gid0 = add i64 %1, %base.gid0
; CHECK: store i64 %gid0, ptr %gid0.addr, align 8

  %lid1.addr = alloca i64, i32 0, align 8
  %lid0.addr = alloca i64, i32 0, align 8
  %gid2.addr = alloca i64, i32 0, align 8
  %gid1.addr = alloca i64, i32 0, align 8
  %gid0.addr = alloca i64, i32 0, align 8
  %lid2.addr = alloca i64, i32 0, align 8
  %lid2 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 2), align 8
  store i64 %lid2, ptr %lid2.addr, align 8
  %lid1 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 1), align 8
  store i64 %lid1, ptr %lid1.addr, align 8
  %lid0 = load i64, ptr @__LocalIds, align 8
  store i64 %lid0, ptr %lid0.addr, align 8
  %base.gid2 = call i64 @get_base_global_id.(i32 2)
  %gid2 = add i64 %lid2, %base.gid2
  store i64 %gid2, ptr %gid2.addr, align 8
  %base.gid1 = call i64 @get_base_global_id.(i32 1)
  %gid1 = add i64 %lid1, %base.gid1
  store i64 %gid1, ptr %gid1.addr, align 8
  %base.gid0 = call i64 @get_base_global_id.(i32 0)
  %gid0 = add i64 %lid0, %base.gid0
  store i64 %gid0, ptr %gid0.addr, align 8
  ret i64 0
}

define void @_ZN7__spirv21initLocalInvocationIdILi1EN4sycl3_V12idILi1EEEEET0_v() {
entry:
  call void @_ZN7__spirv28InitSizesSTLocalInvocationIdILi1EN4sycl3_V12idILi1EEEE8initSizeEv()
  ret void
}

define void @_ZN7__spirv28InitSizesSTLocalInvocationIdILi1EN4sycl3_V12idILi1EEEE8initSizeEv() {
entry:
  %call = call i64 @_ZN7__spirv20getLocalInvocationIdILi0EEEmv()
  ret void
}

define i64 @_ZN7__spirv20getLocalInvocationIdILi0EEEmv() {
entry:
  %call = call i64 @_Z27__spirv_LocalInvocationId_xv()
  ret i64 0
}

define internal i64 @_Z27__spirv_LocalInvocationId_xv() {
entry:
; CHECK-LABEL: define internal i64 @_Z27__spirv_LocalInvocationId_xv(i32 %sg.lid)
; CHECK: %lid2 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 2), align 8
; CHECK: store i64 %lid2, ptr %lid2.addr, align 8
; CHECK: %lid1 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 1), align 8
; CHECK: store i64 %lid1, ptr %lid1.addr, align 8
; CHECK: %lid0 = load i64, ptr @__LocalIds, align 8
; CHECK: %0 = zext i32 %sg.lid to i64
; CHECK: %1 = add i64 %0, %lid0
; CHECK: store i64 %1, ptr %lid0.addr, align 8

  %lid1.addr = alloca i64, i32 0, align 8
  %lid0.addr = alloca i64, i32 0, align 8
  %lid2.addr = alloca i64, i32 0, align 8
  %lid2 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 2), align 8
  store i64 %lid2, ptr %lid2.addr, align 8
  %lid1 = load i64, ptr getelementptr inbounds ([3 x i64], ptr @__LocalIds, i64 0, i32 1), align 8
  store i64 %lid1, ptr %lid1.addr, align 8
  %lid0 = load i64, ptr @__LocalIds, align 8
  store i64 %lid0, ptr %lid0.addr, align 8
  ret i64 0
}

declare i64 @get_base_global_id.(i32)

declare void @dummy_sg_barrier()

define void @_ZTSZN10root_group5testsL22CATCH2_INTERNAL_TEST_4EvE18RootGroupBarrier1D() !dbg !6 !kernel_has_sub_groups !9 !sg_emu_size !10 {
sg.loop.exclude:
  br label %entry

entry:                                            ; preds = %sg.loop.exclude
  call void @dummy_sg_barrier()
  call void @_ZN4sycl3_V16detail7Builder10getElementILi1EEEKNS0_7nd_itemIXT_EEEPS5_()
  ret void
}

!sycl.kernels = !{!0}
!llvm.module.flags = !{!1, !2}
!llvm.dbg.cu = !{!3}

!0 = !{ptr @_ZTSZN10root_group5testsL22CATCH2_INTERNAL_TEST_2EvE21RootGroupNoSyncProp1D, ptr @_ZTSZN10root_group5testsL22CATCH2_INTERNAL_TEST_4EvE18RootGroupBarrier1D}
!1 = !{i32 7, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !4, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2025.1.0 (2025.x.0.YYYYMMDD)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !5, imports: !5)
!4 = !DIFile(filename: "root_group.cpp", directory: "oneapi_root_group")
!5 = !{}
!6 = distinct !DISubprogram(name: "_ZTSZN10root_group5testsL22CATCH2_INTERNAL_TEST_4EvE18RootGroupBarrier1D", scope: null, file: !4, line: 58, type: !7, flags: DIFlagArtificial | DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagMainSubprogram, unit: !3, templateParams: !5, retainedNodes: !5)
!7 = !DISubroutineType(types: !8)
!8 = !{null}
!9 = !{i1 true}
!10 = !{i32 16}
