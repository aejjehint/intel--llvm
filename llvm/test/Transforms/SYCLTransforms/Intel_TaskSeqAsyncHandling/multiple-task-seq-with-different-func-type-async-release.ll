; RUN: opt -S -passes=sycl-kernel-handle-taskseq-async %s | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

declare i32 @_Z4multii(i32, i32)

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

define i32 @_Z15sum_of_productsiPiS_() {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %call.i = tail call ptr addrspace(1) null(ptr @_Z4multii, i32 0, i32 0, i32 0, i32 0)
  tail call void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELii(ptr addrspace(1) %call.i, i32 0, i32 0)
  br label %for.body
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELii(ptr addrspace(1), i32, i32)

; Function Attrs: nounwind
declare void @_Z32__spirv_TaskSequenceReleaseINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1)) local_unnamed_addr #2

; CHECK: define internal void @_Z32__spirv_TaskSequenceReleaseINTELPU3AS125__spirv_TaskSequenceINTEL(ptr addrspace(1) %0) local_unnamed_addr #1 {
; CHECK-NEXT:  %2 = addrspacecast ptr addrspace(1) %0 to ptr addrspace(4)
; CHECK-NEXT:  call void @__release_task_sequence(ptr addrspace(4) %2)
; CHECK-NEXT:  ret void
; CHECK-NEXT: }


; CHECK: define internal void @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELii(ptr addrspace(1) %0, ptr %1, i32 %2, i32 %3) {
; CHECK-NEXT:  %5 = addrspacecast ptr %1 to ptr addrspace(4)
; CHECK-NEXT:  %block.invoke = call ptr addrspace(4) @_Z30__spirv_TaskSequenceAsyncINTELPU3AS125__spirv_TaskSequenceINTELii.block_invoke_mapper(ptr addrspace(4) %5)
; CHECK-NEXT:  %literal = alloca { i32, i32, ptr, i32, i32, ptr }, align 8
; CHECK-NEXT:  %literal.size = getelementptr inbounds { i32, i32, ptr, i32, i32, ptr }, ptr %literal, i32 0, i32 0
; CHECK-NEXT:  store i32 32, ptr %literal.size, align 4
; CHECK-NEXT:  %literal.align = getelementptr inbounds { i32, i32, ptr, i32, i32, ptr }, ptr %literal, i32 0, i32 1
; CHECK-NEXT:  store i32 8, ptr %literal.align, align 4
; CHECK-NEXT:  %literal.invoke = getelementptr inbounds { i32, i32, ptr, i32, i32, ptr }, ptr %literal, i32 0, i32 2
; CHECK-NEXT:  %6 = addrspacecast ptr addrspace(4) %block.invoke to ptr
; CHECK-NEXT:  store ptr %6, ptr %literal.invoke, align 8
; CHECK-NEXT:  %literal.argument.0 = getelementptr { i32, i32, ptr, i32, i32, ptr }, ptr %literal, i32 0, i32 3
; CHECK-NEXT:  store i32 %2, ptr %literal.argument.0, align 4
; CHECK-NEXT:  %literal.argument.1 = getelementptr { i32, i32, ptr, i32, i32, ptr }, ptr %literal, i32 0, i32 4
; CHECK-NEXT:  store i32 %3, ptr %literal.argument.1, align 4
; CHECK-NEXT:  %7 = addrspacecast ptr addrspace(1) %0 to ptr addrspace(4)
; CHECK-NEXT:  %8 = addrspacecast ptr %literal to ptr addrspace(4)
; CHECK-NEXT:  call void @__async(ptr addrspace(4) %7, ptr addrspace(4) %block.invoke, ptr addrspace(4) %8)
; CHECK-NEXT:  ret void


attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind }
