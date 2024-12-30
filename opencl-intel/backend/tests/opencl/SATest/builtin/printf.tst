; RUN: SATest --VAL --config=%s.cfg -dump-llvm-file %t.ll > %t 2>&1
; RUN: FileCheck %s --input-file=%t --check-prefix=CHECK-VAL && FileCheck %s --input-file=%t.ll --check-prefix=CHECK-LLVM

; Check that printf outputs correctly.

; CHECK-VAL: 1.000000,2.000000,3.000000,4.000000
; CHECK-VAL-NEXT: 1.00,2.00,3.00,4.00
; CHECK-VAL-NEXT: a
; CHECK-VAL-SAME: bar
; CHECK-VAL-NEXT: foo
; CHECK-VAL-NEXT: c
; CHECK-VAL-SAME: bar
; CHECK-VAL: Test Passed.

; Check that printf is not simplified and that it is resolved to __opencl_printf.

; CHECK-LLVM: target triple = "x86_64-pc-linux"
; CHECK-LLVM-NOT: declare noundef i32 @puts(ptr nocapture noundef readonly)
; CHECK-LLVM-NOT: declare noundef i32 @putchar(i32 noundef)
; CHECK-LLVM: declare i32 @__opencl_printf(ptr addrspace(2), ptr, ptr, ptr)
; CHECK-LLVM-NOT: declare noundef i32 @puts(ptr nocapture noundef readonly)
; CHECK-LLVM-NOT: declare noundef i32 @putchar(i32 noundef)
; CHECK-LLVM: void @test(
; CHECK-LLVM: %translated_opencl_printf_call = call i32 @__opencl_printf(ptr addrspace(2) @.str, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call2 = call i32 @__opencl_printf(ptr addrspace(2) @.str.1, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call4 = call i32 @__opencl_printf(ptr addrspace(2) @.str.2, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call6 = call i32 @__opencl_printf(ptr addrspace(2) @.str.2, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call8 = call i32 @__opencl_printf(ptr addrspace(2) @.str.5, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call10 = call i32 @__opencl_printf(ptr addrspace(2) @.str.6, ptr nonnull %{{[0-9]+}}
; CHECK-LLVM: %translated_opencl_printf_call12 = call i32 @__opencl_printf(ptr addrspace(2) @.str.7, ptr nonnull %{{[0-9]+}}
