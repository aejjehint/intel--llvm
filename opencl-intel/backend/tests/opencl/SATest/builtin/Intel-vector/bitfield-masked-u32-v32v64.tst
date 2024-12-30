; Check that v32 and v64 builtins are used.

; RUN: SATest -BUILD --config=%s.cfg -tsize=32 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefix=CHECK32
; RUN: SATest -BUILD --config=%s.cfg -tsize=64 -cpuarch="skx" -llvm-option=-print-after=vplan-vec 2>&1 | FileCheck %s -check-prefix=CHECK64

; IR Dump After vplan-vec
; CHECK32: call <32 x i32> @_Z23bitfield_insert_v1widenDv32_jS_S_S_S_({{.*}}) 
; CHECK32: call <32 x i32> @_Z31bitfield_extract_signed_v1widenDv32_jS_S_S_({{.*}})
; CHECK32: call <32 x i32> @_Z33bitfield_extract_unsigned_v1widenDv32_jS_S_S_({{.*}})
; CHECK32: call <32 x i32> @_Z19bit_reverse_v1widenDv32_jS_({{.*}})

; IR Dump After vplan-vec
; CHECK64: call <64 x i32> @_Z23bitfield_insert_v1widenDv64_jS_S_S_S_({{.*}})
; CHECK64: call <64 x i32> @_Z31bitfield_extract_signed_v1widenDv64_jS_S_S_({{.*}})
; CHECK64: call <64 x i32> @_Z33bitfield_extract_unsigned_v1widenDv64_jS_S_S_({{.*}})
; CHECK64: call <64 x i32> @_Z19bit_reverse_v1widenDv64_jS_({{.*}})
