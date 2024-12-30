; Check that v32 builtins are used.

; Disable the test in debug build since CHECK-SVML will be complicated.
; UNSUPPORTED: debug-build

; RUN: SATest -BUILD --config=%S/math-masked-f32.tst.cfg -tsize=32 -cpuarch="skx" -llvm-option=-print-after=vplan-vec -dump-llvm-file %t.ll 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK-VPLAN
; RUN: FileCheck %s --input-file=%t.ll -check-prefix=CHECK-SVML

; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4acosDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5acoshDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6acospiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4asinDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5asinhDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6asinpiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4atanDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5atan2Dv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5atanhDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6atanpiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z7atan2piDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4cbrtDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4ceilDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z8copysignDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4coshDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5cospiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4erfcDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3erfDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3expDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4exp2Dv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5exp10Dv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5expm1Dv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fabsDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fdimDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5floorDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3fmaDv32_fS_S_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fmaxDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fmaxDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fminDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fminDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4fmodDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5hypotDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x i32> @_Z5ilogbDv32_fDv32_i(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5ldexpDv32_fDv32_iS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6lgammaDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3logDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4log2Dv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5log10Dv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5log1pDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4logbDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3madDv32_fS_S_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6maxmagDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6minmagDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z9nextafterDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3powDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4pownDv32_fDv32_iS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4powrDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z9remainderDv32_fS_S_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5rootnDv32_fDv32_iS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5roundDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5rsqrtDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4sinhDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5sinpiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4sqrtDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z3tanDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z4tanhDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5tanpiDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z6tgammaDv32_fS_(<32 x float> {{.*}}mask
; CHECK-VPLAN: call{{.*}} <32 x float> @_Z5truncDv32_fS_(<32 x float> {{.*}}mask

; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_acosf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_acoshf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_acospif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_asinf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_asinhf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_asinpif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_atanf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_atan2f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_atanhf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_atanpif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_atan2pif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_cbrtf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_coshf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_cospif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_erfcf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_erff32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_expf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_exp2f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_exp10f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_expm1f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_fmodf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_hypotf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_ldexpf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_lgammaf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_logf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_log2f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_log10f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_log1pf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_logbf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_nextafterf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_powf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_pownf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_powrf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_remainderf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_rootnf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_roundf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_rsqrtf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_rsqrtf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_sinhf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_sinpif32(<32 x float>
; CHECK-SVML: call{{.*}} <32 x float> @llvm.sqrt.v32f32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_tanf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_tanhf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_tanpif32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_tgammaf32(<32 x float>
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_truncf32(<32 x float>

; CHECK: Test program was successfully built
