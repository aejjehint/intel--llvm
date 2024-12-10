// AC Types tests (-qactypes)
// RUN: env INTELFPGAOCLSDKROOT=%S/Inputs/intel/actypes \
// RUN: %clangxx -target x86_64-unknown-linux-gnu -qactypes -### %s 2>&1 \
// RUN: | FileCheck -check-prefixes=CHECK-ACTYPES,CHECK-ACTYPES-LIN %s
// RUN: env INTELFPGAOCLSDKROOT=%S/Inputs/intel/actypes \
// RUN: %clangxx -target x86_64-unknown-linux-gnu -fsycl -fintelfpga -### %s 2>&1 \
// RUN: | FileCheck -check-prefixes=CHECK-ACTYPES,CHECK-ACTYPES-LIN %s
// RUN: env INTELFPGAOCLSDKROOT=%S/Inputs/intel/actypes \
// RUN: %clang_cl -Qactypes -### %s 2>&1 \
// RUN: | FileCheck -check-prefixes=CHECK-ACTYPES,CHECK-ACTYPES-WIN %s
// RUN: env INTELFPGAOCLSDKROOT=%S/Inputs/intel/actypes \
// RUN: %clang_cl -fsycl -fintelfpga -### %s 2>&1 \
// RUN: | FileCheck -check-prefixes=CHECK-ACTYPES,CHECK-ACTYPES-WIN %s
// CHECK-ACTYPES-WIN: "--dependent-lib=dspba_mpir" "--dependent-lib=dspba_mpfr" "--dependent-lib=ac_types_fixed_point_math_x86" "--dependent-lib=ac_types_vpfp_library"
// CHECK-ACTYPES: "-internal-isystem" "{{.*}}actypes{{/|\\\\}}include"
// CHECK-ACTYPES-LIN: ld{{.*}} "-L{{.*}}actypes{{/|\\\\}}host{{/|\\\\}}linux64{{/|\\\\}}lib" {{.*}} "-ldspba_mpir" "-ldspba_mpfr" "-lac_types_fixed_point_math_x86" "-lac_types_vpfp_library"
// CHECK-ACTYPES-WIN: link{{.*}} "-libpath:{{.*}}actypes{{/|\\\\}}host{{/|\\\\}}windows64{{/|\\\\}}lib"

// RUN: %clangxx -fsycl -fintelfpga -qno-actypes -### %s 2>&1 \
// RUN:   | FileCheck -check-prefixes=CHECK_NOACTYPES_LIN %s
// RUN: %clang_cl -fsycl -fintelfpga -Qactypes- -### %s 2>&1 \
// RUN:   | FileCheck -check-prefixes=CHECK_NOACTYPES_WIN %s
// CHECK_NOACTYPES_WIN-NOT: "--dependent-lib=dspba_mpir"
// CHECK_NOACTYPES_LIN-NOT: "-ldspba_mpir"

