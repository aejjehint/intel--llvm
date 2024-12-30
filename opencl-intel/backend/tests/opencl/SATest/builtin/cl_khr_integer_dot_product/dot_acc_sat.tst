; dot_acc_sat
; RUN: SATest --VAL --config=%s.v4i8.v4i8.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.v4i8.v4u8.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.v4u8.v4i8.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.v4u8.v4u8.cfg 2>&1 | FileCheck %s

; dot_acc_sat_4x8packed_ss_int, dot_acc_sat_4x8packed_su_int,
; dot_acc_sat_4x8packed_us_int, dot_acc_sat_4x8packed_uu_uint
; RUN: SATest --VAL --config=%s.4x8packed_ss_int.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.4x8packed_su_int.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.4x8packed_us_int.cfg 2>&1 | FileCheck %s
; RUN: SATest --VAL --config=%s.4x8packed_uu_uint.cfg 2>&1 | FileCheck %s

; CHECK: Test Passed.
