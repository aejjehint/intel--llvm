; Checks that private buffer will use heap memory as expected when the kernel requires a large private buffer.

; RUN: SATest --VAL --config=%s.cfg -llvm-option='-debug-only=sycl-kernel-private-to-heap' 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.debug.cfg -llvm-option='-debug-only=sycl-kernel-private-to-heap' 2>&1 | FileCheck %s

; CHECK-DAG: PRIVATE BUFFER HEAP_MEMORY_POINTER == NULL : [CMP]{{.*}}: 0

; CHECK-DAG: Test Passed.
