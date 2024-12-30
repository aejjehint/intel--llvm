; RUN: opt -passes=sycl-kernel-barrier %s -S | FileCheck %s

; Check value %start's user in phi is replaced with load value from incoming block.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

@__LocalIds = external global [3 x i64]

; Function Attrs: convergent nounwind
define void @_ZTSZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_EUlNS8_7nd_itemILi3EEEE_(ptr addrspace(3) nocapture align 4 %_arg_workstack_acc_ct1) #0 !dbg !7 !no_barrier_path !13 !kernel_has_sub_groups !13 !max_wg_dimensions !14 !recommended_vector_length !14 {
entry:
  call void @dummy_barrier.()
  br label %while.body.i

while.body.i:                                     ; preds = %Split.Barrier.BB54, %entry
  %wr31.sroa.0.0.copyload.i = load i32, ptr addrspace(3) %_arg_workstack_acc_ct1, align 4
  br label %Split.Barrier.BB54

Split.Barrier.BB54:                               ; preds = %while.body.i
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #0
  tail call fastcc void @_Z14sort_thresholdPjS_jjS_jRKN4sycl3_V17nd_itemILi3EEE(i32 %wr31.sroa.0.0.copyload.i) #0, !dbg !15
  call void @dummy_barrier.()
  br label %while.body.i
}

; Function Attrs: convergent nounwind
define fastcc void @_Z14sort_thresholdPjS_jjS_jRKN4sycl3_V17nd_itemILi3EEE(i32 %start) #0 !dbg !30 {
entry:
  call void @dummy_barrier.()
  call void @llvm.dbg.value(metadata i32 %start, metadata !32, metadata !DIExpression()), !dbg !35
  br i1 false, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  tail call void @_Z18work_group_barrierj12memory_scope(i32 3, i32 1) #0
  %add.1 = add i32 %start, 128
  br label %if.end51.sink.split

if.else:                                          ; preds = %entry
; CHECK-LABEL: if.else:
; CHECK:      [[INDEX:%SBIndex.*]] = load i64, ptr %pCurrSBIndex, align 8, !dbg
; CHECK-NEXT: [[OFFSET:%SB_LocalId_Offset.*]] = add nuw i64 [[INDEX]], 4, !dbg
; CHECK-NEXT: [[PSB:%pSB_LocalId.*]] = getelementptr inbounds i8, ptr %pSB, i64 [[OFFSET]], !dbg
; CHECK-NEXT: store ptr [[PSB]], ptr %start.addr, align 8, !dbg
; CHECK-NEXT: [[LOAD:%[0-9]+]] = load ptr, ptr %start.addr, align 8, !dbg
; CHECK-NEXT: [[LOADVALUE:%loadedValue.*]] = load i32, ptr [[LOAD]], align 4, !dbg
; CHECK-NEXT: br label %if.end51.sink.split

  br label %if.end51.sink.split

if.end51.sink.split:                              ; preds = %if.else, %if.then
; CHECK-LABEL: if.end51.sink.split:
; CHECK: %add.1.sink = phi i32 [ %add.1, %SyncBB1 ], [ [[LOADVALUE]], %if.else ]

  %add.1.sink = phi i32 [ %add.1, %if.then ], [ %start, %if.else ]
  br label %if.end51

if.end51:                                         ; preds = %if.end51.sink.split
  call void @_Z18work_group_barrierj(i32 1)
  ret void
}

; Function Attrs: convergent nounwind
declare void @_Z18work_group_barrierj12memory_scope(i32, i32) #0

declare void @dummy_barrier.()

; Function Attrs: convergent
declare void @_Z18work_group_barrierj(i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { convergent nounwind "kernel-call-once" "kernel-convergent-call" }
attributes #1 = { convergent }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0, !1}
!llvm.dbg.cu = !{!2}
!spirv.Source = !{!5}
!sycl.kernels = !{!6}

!0 = !{i32 7, !"Dwarf Version", i32 4}
!1 = !{i32 2, !"Debug Info Version", i32 3}
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2025.1.0 (2025.x.0.YYYYMMDD)", isOptimized: false, flags: " quicksort.dp.cpp -O2 -g", runtimeVersion: 0, emissionKind: FullDebug, enums: !4, imports: !4)
!3 = !DIFile(filename: "quicksort.dp.cpp", directory: "")
!4 = !{}
!5 = !{i32 4, i32 100000}
!6 = !{ptr @_ZTSZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_EUlNS8_7nd_itemILi3EEEE_}
!7 = distinct !DISubprogram(name: "_ZTSZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_EUlNS8_7nd_itemILi3EEEE_", scope: null, file: !3, line: 353, type: !8, flags: DIFlagArtificial | DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized | DISPFlagMainSubprogram, unit: !2, templateParams: !4, retainedNodes: !4)
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !11, size: 64, dwarfAddressSpace: 3)
!11 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "workstack_record", file: !12, line: 342, size: 96, flags: DIFlagTypePassByValue, elements: !4, identifier: "_ZTS16workstack_record")
!12 = !DIFile(filename: "QuicksortKernels.dp.hpp", directory: "")
!13 = !{i1 false}
!14 = !{i32 1}
!15 = !DILocation(line: 600, column: 25, scope: !16, inlinedAt: !22)
!16 = distinct !DILexicalBlock(scope: !17, file: !12, line: 594, column: 1522)
!17 = distinct !DILexicalBlock(scope: !18, file: !12, line: 594, column: 1590)
!18 = distinct !DILexicalBlock(scope: !19, file: !12, line: 425, column: 3119)
!19 = distinct !DISubprogram(name: "lqsort_kernel", linkageName: "_Z13lqsort_kernelPjS_P11work_recordRKN4sycl3_V17nd_itemILi3EEEP16workstack_recordRiS_S_S_RS_SB_RjSC_S_S_", scope: null, file: !12, line: 376, type: !20, scopeLine: 380, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, templateParams: !4, retainedNodes: !4)
!20 = !DISubroutineType(types: !21)
!21 = !{null}
!22 = distinct !DILocation(line: 354, column: 29, scope: !23, inlinedAt: !26)
!23 = distinct !DISubprogram(name: "operator()", linkageName: "_ZZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_ENKUlNS8_7nd_itemILi3EEEE_clESD_", scope: !24, file: !3, line: 353, type: !20, scopeLine: 353, flags: DIFlagPrivate | DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, templateParams: !4, declaration: !25, retainedNodes: !4)
!24 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "_ZTSZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_EUlNS8_7nd_itemILi3EEEE_", file: !3, line: 353, size: 3008, flags: DIFlagTypePassByValue, elements: !4, identifier: "_ZTSZZ6lqsortIjEvPT_S1_RSt6vectorI11work_recordSaIS3_EEENKUlRN4sycl3_V17handlerEE_clESA_EUlNS8_7nd_itemILi3EEEE_")
!25 = !DISubprogram(name: "operator()", scope: !24, file: !3, line: 353, type: !20, scopeLine: 353, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized, templateParams: !4)
!26 = distinct !DILocation(line: 1665, column: 5, scope: !27)
!27 = distinct !DILexicalBlock(scope: !29, file: !28, line: 1663, column: 1832)
!28 = !DIFile(filename: "handler.hpp", directory: "")
!29 = !DILexicalBlockFile(scope: !7, file: !28, discriminator: 0)
!30 = distinct !DISubprogram(name: "sort_threshold", linkageName: "_Z14sort_thresholdPjS_jjS_jRKN4sycl3_V17nd_itemILi3EEE", scope: null, file: !12, line: 93, type: !20, scopeLine: 96, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, templateParams: !4, retainedNodes: !31)
!31 = !{!32}
!32 = !DILocalVariable(name: "start", arg: 3, scope: !30, file: !12, line: 94, type: !33)
!33 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint", file: !3, baseType: !34)
!34 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!35 = !DILocation(line: 0, scope: !30)
