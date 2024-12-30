; RUN: opt -passes=sycl-kernel-coerce-types %s -S -o - | FileCheck %s

; Check that coerced function's use in metadata is replaced with new function.

; CHECK: define i16 @_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EE(i16 %row, ptr %coefficients)
; CHECK: = !DITemplateValueParameter(name: "window_function", type: !{{.*}}, value: ptr @_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EE)

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

%"struct.std::array" = type { [9 x float] }

define i16 @_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EE(i16 %row, ptr byval(%"struct.std::array") align 4 %coefficients) !dbg !4 {
entry:
  ret i16 0
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

define void @_ZN14line_buffer_2d12LineBuffer2dIttLs3ELs4096ELs2EE6FilterIL_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EEEJS5_EEEN10fpga_tools10DataBundleItLi2EEES8_bbRbS9_DpT0_() {
entry:
  call void @llvm.dbg.declare(metadata ptr null, metadata !7, metadata !DIExpression(DW_OP_constu, 4, DW_OP_swap, DW_OP_xderef)), !dbg !19
  ret void
}

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}
!llvm.dbg.cu = !{!1}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !2, producer: "clang based Intel(R) oneAPI DPC++/C++ Compiler 2024.2.0 (2024.x.0.YYYYMMDD)", isOptimized: false, flags: "-g -O0", runtimeVersion: 0, emissionKind: FullDebug, enums: !3, globals: !3, imports: !3)
!2 = !DIFile(filename: "main.cpp", directory: "/")
!3 = !{}
!4 = distinct !DISubprogram(name: "ConvolutionFunction", linkageName: "_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EE", scope: null, file: !5, line: 116, type: !6, scopeLine: 119, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1, templateParams: !3, retainedNodes: !3)
!5 = !DIFile(filename: "convolution_kernel.hpp", directory: "/")
!6 = distinct !DISubroutineType(types: !3)
!7 = !DILocalVariable(name: "this", arg: 1, scope: !8, type: !18, flags: DIFlagArtificial | DIFlagObjectPointer)
!8 = distinct !DISubprogram(name: "Filter<ConvolutionFunction, std::array<float, 9UL> >", linkageName: "_ZN14line_buffer_2d12LineBuffer2dIttLs3ELs4096ELs2EE6FilterIL_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EEEJS5_EEEN10fpga_tools10DataBundleItLi2EEES8_bbRbS9_DpT0_", scope: !10, file: !9, line: 146, type: !12, scopeLine: 149, flags: DIFlagPrivate | DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1, templateParams: !3, declaration: !13, retainedNodes: !3)
!9 = !DIFile(filename: "linebuffer2d.hpp", directory: "/")
!10 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "LineBuffer2d<unsigned short, unsigned short, (short)3, (short)4096, (short)2>", scope: !11, file: !9, line: 29, size: 526240, flags: DIFlagTypePassByReference, elements: !3, templateParams: !3, identifier: "_ZTSN14line_buffer_2d12LineBuffer2dIttLs3ELs4096ELs2EEE")
!11 = !DINamespace(name: "line_buffer_2d", scope: null)
!12 = distinct !DISubroutineType(types: !3)
!13 = !DISubprogram(name: "Filter<ConvolutionFunction, std::array<float, 9UL> >", linkageName: "_ZN14line_buffer_2d12LineBuffer2dIttLs3ELs4096ELs2EE6FilterIL_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EEEJS5_EEEN10fpga_tools10DataBundleItLi2EEES8_bbRbS9_DpT0_", scope: !10, file: !9, line: 146, type: !12, scopeLine: 146, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0, templateParams: !14)
!14 = !{!15}
!15 = !DITemplateValueParameter(name: "window_function", type: !16, value: ptr @_Z19ConvolutionFunctionssssPtSt5arrayIfLm9EE)
!16 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !17, dwarfAddressSpace: 0)
!17 = distinct !DISubroutineType(types: !3)
!18 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !10, size: 64)
!19 = !DILocation(line: 0, scope: !8)
