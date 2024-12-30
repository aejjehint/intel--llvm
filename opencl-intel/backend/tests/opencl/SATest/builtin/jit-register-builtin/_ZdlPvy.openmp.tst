; RUN: SATest -BUILD --config=%s.cfg --dump-llvm-file - 2>&1 | FileCheck %s

; Check build is sucessful when symbol _ZdlPvy is defined in the device code.

; CHECK: _ZdlPvy

; CHECK: Test program was successfully built.
