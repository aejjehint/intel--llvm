; RUN: opt -passes=sycl-kernel-sg-emu-value-widen -S %s | FileCheck %s
;
; Validate the debug information describing a widened alloca.
;
; CHECK:       define void @main_kernel() {{.*}} {
; CHECK-LABEL: sg.loop.exclude:
; CHECK:         %w.__ocl_dbg_gid0 = alloca <16 x i64>, align 128
; CHECK:         %dbg.__ocl_dbg_gid0 = alloca ptr, align 8
; CHECK-NEXT:      #dbg_declare(ptr %dbg.__ocl_dbg_gid0,
; CHECK-SAME:        [[GID0:![0-9]+]],
; CHECK-SAME:        !DIExpression(DW_OP_deref),
; CHECK-SAME:        !11
; CHECK-SAME:        )
; CHECK:         br label %entry
; CHECK-LABEL: entry:
; CHECK-NOT:       #dbg_declare(ptr undef, {{.*}}, !DIExpression(), {{.*}})
; CHECK:         call void @dummy_sg_barrier()
; CHECK:       }
;
; CHECK: [[GID0]] = !DILocalVariable(name: "__ocl_dbg_gid0", {{.*}})

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define void @main_kernel() !kernel_has_sub_groups !4 !sg_emu_size !5 {
entry:
  %__ocl_dbg_gid0 = alloca i64, align 8
    #dbg_declare(ptr %__ocl_dbg_gid0, !6, !DIExpression(), !11)
  call void @dummy_sg_barrier()
  store i64 0, ptr %__ocl_dbg_gid0, align 8
  ret void
}

declare void @dummy_sg_barrier()

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}
!sycl.kernels = !{!3}

!0 = distinct !DICompileUnit(language: DW_LANG_OpenCL, file: !1, producer: "clang", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "sg_emu_subroutine.cl", directory: "/path/to")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{ptr @main_kernel}
!4 = !{i1 true}
!5 = !{i32 16}
!6 = !DILocalVariable(name: "__ocl_dbg_gid0", scope: !7, line: 1, type: !10, flags: DIFlagArtificial)
!7 = distinct !DISubprogram(name: "main_kernel", scope: !1, file: !1, line: 7, type: !8, scopeLine: 7, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !9)
!8 = !DISubroutineType(cc: DW_CC_LLVM_OpenCLKernel, types: !9)
!9 = !{}
!10 = !DIBasicType(name: "unsigned int", size: 64, encoding: DW_ATE_unsigned)
!11 = !DILocation(line: 7, scope: !7)
