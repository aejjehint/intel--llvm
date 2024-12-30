; Check that v32 and v64 builtins are used.

; RUN: SATest -BUILD --config=%s.cfg -tsize=32 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK32
; RUN: SATest -BUILD --config=%s.cfg -tsize=64 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK64

; CHECK32: call <32 x i64> @_Z3absDv32_m(<32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z8abs_diffDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z7add_satDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z4haddDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z5rhaddDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z5clampDv32_mS_S_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z3clzDv32_m(<32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z6mad_hiDv32_mS_S_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z7mad_satDv32_mS_S_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z3maxDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z3minDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z6mul_hiDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z6rotateDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z7sub_satDv32_mS_(<32 x i64> noundef {{.*}}, <32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z8popcountDv32_m(<32 x i64> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z3ctzDv32_m(<32 x i64> noundef {{.*}})

; CHECK64: call <64 x i64> @_Z3absDv64_m(<64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z8abs_diffDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z7add_satDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z4haddDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z5rhaddDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z5clampDv64_mS_S_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z3clzDv64_m(<64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z6mad_hiDv64_mS_S_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z7mad_satDv64_mS_S_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z3maxDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z3minDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z6mul_hiDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z6rotateDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z7sub_satDv64_mS_(<64 x i64> noundef {{.*}}, <64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z8popcountDv64_m(<64 x i64> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z3ctzDv64_m(<64 x i64> noundef {{.*}})

; CHECK: Test program was successfully built.
