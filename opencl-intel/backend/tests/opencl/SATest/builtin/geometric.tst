; RUN: SATest --VAL --config=%s.f32.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.f64.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.f16.cfg 2>&1 | FileCheck %s

; CHECK: Test Passed.
