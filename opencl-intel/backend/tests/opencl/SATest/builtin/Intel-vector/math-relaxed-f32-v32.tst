; Check that v32 builtins are used.

; RUN: SATest -BUILD --config=%S/math-relaxed-f32.tst.cfg -tsize=32 -cpuarch=skx -llvm-option=-print-after=sycl-kernel-relaxed-math -dump-llvm-file %t.ll 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK-RM
; RUN: FileCheck %s --input-file=%t.ll -check-prefix=CHECK-SVML

; RUN: SATest -BUILD --config=%S/math-relaxed-f32.tst.cfg -tsize=32 -cpuarch=core-avx2 -llvm-option=-print-after=sycl-kernel-relaxed-math 2>&1 | FileCheck %s -check-prefixes=CHECK,CHECK-RM

; CHECK-RM: call{{.*}} <32 x float> @_Z6cos_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z6exp_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z7exp2_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z8exp10_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z6log_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z7log2_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z6pow_rmDv32_fS_(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z6sin_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z6tan_rmDv32_f(<32 x float> {{.*}})
; CHECK-RM: call{{.*}} <32 x float> @_Z9sincos_rmDv32_fPf(<32 x float> {{.*}}, {{.*}})
; CHECK-RM: call{{.*}} float @_Z6cos_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z6exp_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z7exp2_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z8exp10_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z6log_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z7log2_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z6pow_rmff(float {{.*}}, float {{.*}})
; CHECK-RM: call{{.*}} float @_Z6sin_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z6tan_rmf(float {{.*}})
; CHECK-RM: call{{.*}} float @_Z9sincos_rmfPf(float {{.*}}, {{.*}})

; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_cosf32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_expf32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_exp2f32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_exp10f32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_logf32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_log2f32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_powf32_rm(<32 x float> {{.*}}, <32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_sinf32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_tanf32_rm(<32 x float> {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 <32 x float> @__ocl_svml_{{[xz]}}0_sincosf32_rm(<32 x float> {{.*}}, {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_cosf1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_expf1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_exp2f1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_exp10f1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_logf1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_log2f1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_powf1_rm(float {{.*}}, float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_sinf1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_tanf1_rm(float {{.*}})
; CHECK-SVML: call{{.*}} intel_ocl_bicc_avx512 float @__ocl_svml_{{[xz]}}0_sincosf1_rm(float {{.*}}, {{.*}})

; CHECK: Test program was successfully built
