; Check that v32 and v64 builtins are used.

; RUN: SATest -BUILD --config=%s.cfg -tsize=32 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK32
; RUN: SATest -BUILD --config=%s.cfg -tsize=64 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK64

; CHECK32: call <32 x i32> @_Z3absDv32_j(<32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z8abs_diffDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z7add_satDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z4haddDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z5rhaddDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z5clampDv32_jS_S_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z3clzDv32_j(<32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z6mad_hiDv32_jS_S_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z7mad_satDv32_jS_S_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z3maxDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z3minDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z6mul_hiDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z6rotateDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z7sub_satDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z8popcountDv32_j(<32 x i32> noundef {{.*}})
; CHECK32: call <32 x i32> @_Z3ctzDv32_j(<32 x i32> noundef {{.*}})
; CHECK32: call <32 x i64> @_Z8upsampleDv32_jS_(<32 x i32> noundef {{.*}}, <32 x i32> noundef {{.*}})

; CHECK64: call <64 x i32> @_Z3absDv64_j(<64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z8abs_diffDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z7add_satDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z4haddDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z5rhaddDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z5clampDv64_jS_S_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z3clzDv64_j(<64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z6mad_hiDv64_jS_S_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z7mad_satDv64_jS_S_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z3maxDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z3minDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z6mul_hiDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z6rotateDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z7sub_satDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z8popcountDv64_j(<64 x i32> noundef {{.*}})
; CHECK64: call <64 x i32> @_Z3ctzDv64_j(<64 x i32> noundef {{.*}})
; CHECK64: call <64 x i64> @_Z8upsampleDv64_jS_(<64 x i32> noundef {{.*}}, <64 x i32> noundef {{.*}})

; CHECK: Test program was successfully built.
