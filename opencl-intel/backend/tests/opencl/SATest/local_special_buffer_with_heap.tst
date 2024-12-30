; Checks that local/special buffer will use heap memory as expected when the kernel requires a large local and barrier buffer.

; RUN: SATest --VAL --config=%s.cfg -noref -llvm-option='-debug-only=sycl-kernel-prepare-args,sycl-kernel-barrier' 2>&1 | FileCheck %s

; CHECK-DAG: LOCAL BUFFER HEAP_MEMORY_POINTER == NULL : [CMP]{{.*}}: 0
; CHECK-DAG: LOCAL ARG BUFFER HEAP_MEMORY_POINTER == NULL : [CMP]{{.*}}: 0
; CHECK-DAG: SPECIAL BUFFER HEAP_MEMORY_POINTER == NULL : [CMP]{{.*}}: 0
; CHECK-DAG: Test Passed.
