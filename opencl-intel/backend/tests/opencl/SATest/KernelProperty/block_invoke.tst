; RUN: SATest -BUILD -build-iterations=1 -dump-kernel-property -config=%s.cfg 2>&1 | FileCheck %s

; This test checks that kernel property isBlock is true when kernel
; is block_invoke.

; CHECK-DAG: Test program was successfully built.
; CHECK-DAG: isBlock: 1
