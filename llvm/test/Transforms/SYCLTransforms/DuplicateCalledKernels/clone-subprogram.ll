; RUN: opt -passes=sycl-kernel-duplicate-called-kernels %s -S | FileCheck %s

; Check when a functions is cloned, its DISubprogram is also cloned.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@__AsanLaunchInfo = addrspace(3) global ptr addrspace(1) null

; Function Attrs: noinline optnone
define void @kernel_1() #0 !dbg !12 {
entry:
  call void @foo(), !dbg !15
  ret void
}

define void @foo() !dbg !19 {
entry:
; CHECK: define void @foo() !dbg [[DBG_FOO:![0-9]+]]
  %call = call i64 @bar(), !dbg !25
  ret void
}

define i64 @bar() !dbg !26 {
entry:
; CHECK: define i64 @bar() !dbg [[DBG_BAR:![0-9]+]]
  call void @__asan_load1_as0()
  call void @qux(), !dbg !27
  ret i64 0
}

define void @qux() !dbg !28 {
entry:
; CHECK: define void @qux() !dbg [[DBG_QUX:![0-9]+]]
  call void @__asan_load8_as4()
  ret void
}

; Function Attrs: noinline optnone
define void @kernel_2() #0 !dbg !32 {
entry:
; CHECK-LABEL: define void @kernel_2
; CHECK-NEXT: entry:
; CHECK-NEXT: call void @foo.clone(), !dbg
  call void @foo(), !dbg !33
  ret void
}

define void @__asan_load1_as0() {
if.end:
  %call = call i64 @_ZN12_GLOBAL__N_111MemToShadowEmj()
  ret void
}

define i64 @_ZN12_GLOBAL__N_111MemToShadowEmj() {
entry:
  %0 = load ptr addrspace(1), ptr addrspace(3) @__AsanLaunchInfo, align 8
  ret i64 0
}

define void @__asan_load8_as4() {
entry:
  %call = call i64 @_ZN12_GLOBAL__N_111MemToShadowEmj()
  ret void
}

; CHECK: define internal i64 @_ZN12_GLOBAL__N_111MemToShadowEmj.clone() {
; CHECK: entry:
; CHECK:   %0 = load ptr addrspace(1), ptr addrspace(3) @__AsanLaunchInfo.clone, align 8
; CHECK:   ret i64 0
; CHECK: }

; CHECK: define internal void @__asan_load8_as4.clone() {
; CHECK: entry:
; CHECK:   %call = call i64 @_ZN12_GLOBAL__N_111MemToShadowEmj.clone()
; CHECK:   ret void
; CHECK: }

; CHECK: define internal void @__asan_load1_as0.clone() {
; CHECK: if.end:
; CHECK:   %call = call i64 @_ZN12_GLOBAL__N_111MemToShadowEmj.clone()
; CHECK:   ret void
; CHECK: }

; CHECK: define internal i64 @bar.clone() !dbg
; CHECKNOT: [[DBG_BAR]]
; CHECK: entry:
; CHECK:   call void @__asan_load1_as0.clone()
; CHECK:   call void @qux.clone(), !dbg
; CHECK:   ret i64 0
; CHECK: }

; CHECK: define internal void @foo.clone() !dbg
; CHECKNOT: [[DBG_FOO]]
; CHECK: entry:
; CHECK:   %call = call i64 @bar.clone(), !dbg
; CHECK:   ret void
; CHECK: }

; CHECK: define internal void @qux.clone() !dbg
; CHECK-NOT: [[DBG_QUX]]
; CHECK: entry:
; CHECK:   call void @__asan_load8_as4.clone()
; CHECK:   ret void
; CHECK: }

attributes #0 = { noinline optnone }

!llvm.dbg.cu = !{!0}
!spirv.Source = !{!3}
!llvm.module.flags = !{!4, !5, !6, !7, !8, !9, !10}
!sycl.kernels = !{!11}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2025.1.0 (2025.x.0.YYYYMMDD)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !2, imports: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "src/array_reduction.cpp", directory: "")
!2 = !{}
!3 = !{i32 4, i32 100000}
!4 = !{i32 7, !"Dwarf Version", i32 4}
!5 = !{i32 2, !"Debug Info Version", i32 3}
!6 = !{i32 1, !"wchar_size", i32 4}
!7 = !{i32 1, !"sycl-device", i32 1}
!8 = !{i32 7, !"uwtable", i32 2}
!9 = !{i32 7, !"frame-pointer", i32 2}
!10 = !{i32 4, !"nosanitize_address", i32 1}
!11 = !{ptr @kernel_1, ptr @kernel_2}
!12 = distinct !DISubprogram(name: "kernel_1", scope: !13, file: !13, line: 1305, type: !14, flags: DIFlagArtificial | DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!13 = !DIFile(filename: "sycl/reduction.hpp", directory: "")
!14 = !DISubroutineType(cc: DW_CC_LLVM_OpenCLKernel, types: !2)
!15 = !DILocation(line: 1491, column: 5, scope: !16)
!16 = distinct !DILexicalBlock(scope: !18, file: !17, line: 1489, column: 53)
!17 = !DIFile(filename: "include/sycl/handler.hpp", directory: "")
!18 = !DILexicalBlockFile(scope: !12, file: !17, discriminator: 0)
!19 = distinct !DISubprogram(name: "operator[]<1, void>", linkageName: "foo", scope: !21, file: !20, line: 1725, type: !24, scopeLine: 1725, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, templateParams: !2)
!20 = !DIFile(filename: "include/sycl/accessor.hpp", directory: "")
!21 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "accessor<int, 1, (sycl::_V1::access::mode)1026, (sycl::_V1::access::target)2014, (sycl::_V1::access::placeholder)0, sycl::_V1::ext::oneapi::accessor_property_list<> >", scope: !22, file: !20, line: 598, size: 256, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !2, templateParams: !2)
!22 = !DINamespace(name: "_V1", scope: !23, exportSymbols: true)
!23 = !DINamespace(name: "sycl", scope: null)
!24 = !DISubroutineType(cc: DW_CC_LLVM_SpirFunction, types: !2)
!25 = !DILocation(line: 1726, column: 32, scope: !19)
!26 = distinct !DISubprogram(name: "getLinearIndex<1>", linkageName: "bar", scope: !21, file: !20, line: 658, type: !24, scopeLine: 658, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, templateParams: !2)
!27 = !DILocation(line: 661, column: 5, scope: !26)
!28 = distinct !DISubprogram(name: "loop_impl<0UL, (lambda at include/sycl/accessor.hpp:661:24)>", linkageName: "qux", scope: !30, file: !29, line: 243, type: !31, scopeLine: 243, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, templateParams: !2)
!29 = !DIFile(filename: "include/sycl/detail/helpers.hpp", directory: "")
!30 = !DINamespace(name: "detail", scope: !22)
!31 = !DISubroutineType(cc: DW_CC_LLVM_SpirFunction, types: !2)
!32 = distinct !DISubprogram(name: "kernel_2", scope: !13, file: !13, line: 1305, type: !14, flags: DIFlagArtificial | DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!33 = !DILocation(line: 1491, column: 5, scope: !34)
!34 = distinct !DILexicalBlock(scope: !35, file: !17, line: 1489, column: 53)
!35 = !DILexicalBlockFile(scope: !32, file: !17, discriminator: 0)
