; RUN: SATest -VAL --force_ref -config=%s.cfg | FileCheck %s
; RUN: SATest -VAL --force_ref -config=%s.sat.cfg | FileCheck %s
; RUN: SATest -VAL --force_ref -config=%s.rte.cfg | FileCheck %s
; RUN: SATest -VAL --force_ref -config=%s.sat_rte.cfg | FileCheck %s
; CHECK: Test Passed.
