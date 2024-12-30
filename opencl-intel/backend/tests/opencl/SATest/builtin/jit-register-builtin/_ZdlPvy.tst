; RUN: SATest -BUILD --config=%s.cfg --dump-llvm-file - 2>&1 | FileCheck %s

; Check symbol _ZdlPvy is resolved.

; CHECK: _ZdlPvy

; CHECK: Test program was successfully built.
