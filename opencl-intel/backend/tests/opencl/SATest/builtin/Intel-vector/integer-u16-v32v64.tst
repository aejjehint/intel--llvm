; Check that v32 and v64 builtins are used.

; RUN: SATest -BUILD --config=%s.cfg -tsize=32 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK32
; RUN: SATest -BUILD --config=%s.cfg -tsize=64 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK64

; CHECK32: call zeroext <32 x i16> @_Z3absDv32_t(<32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z8abs_diffDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z7add_satDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z4haddDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z5rhaddDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z5clampDv32_tS_S_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z3clzDv32_t(<32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z6mad_hiDv32_tS_S_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z7mad_satDv32_tS_S_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z3maxDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z3minDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z6mul_hiDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z6rotateDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z7sub_satDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z8popcountDv32_t(<32 x i16> noundef zeroext {{.*}})
; CHECK32: call zeroext <32 x i16> @_Z3ctzDv32_t(<32 x i16> noundef zeroext {{.*}})
; CHECK32: call <32 x i32> @_Z8upsampleDv32_tS_(<32 x i16> noundef zeroext {{.*}}, <32 x i16> noundef zeroext {{.*}})

; CHECK64: call zeroext <64 x i16> @_Z3absDv64_t(<64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z8abs_diffDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z7add_satDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z4haddDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z5rhaddDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z5clampDv64_tS_S_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z3clzDv64_t(<64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z6mad_hiDv64_tS_S_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z7mad_satDv64_tS_S_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z3maxDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z3minDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z6mul_hiDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z6rotateDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z7sub_satDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z8popcountDv64_t(<64 x i16> noundef zeroext {{.*}})
; CHECK64: call zeroext <64 x i16> @_Z3ctzDv64_t(<64 x i16> noundef zeroext {{.*}})
; CHECK64: call <64 x i32> @_Z8upsampleDv64_tS_(<64 x i16> noundef zeroext {{.*}}, <64 x i16> noundef zeroext {{.*}})

; CHECK: Test program was successfully built.
