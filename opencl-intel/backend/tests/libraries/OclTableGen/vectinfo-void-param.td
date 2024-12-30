// RUN: %ocltblgen %s --gen-vectorization-info | FileCheck %s

include "GENERIC/opencl-builtin.td"

let Attrs = [OVERLOADABLE] in {
  def scalar: OclBuiltin<"foo", (outs gentype:$ret), (ins void), [v1i32]>;
  def vector: OclBuiltin<"foo_vec", (outs gentype:$ret), (ins gentype:$vec_mask), [v1i32, v4i32, v8i32, v16i32]>;
}

def : VectInfo<[v1i32], scalar, vector, vector, vector>;
// Checks that masked VectInfos are generated properly for void-paramter function.
// CHECK-DAG: {"_Z3foov","","_ZGVbM16__Z3foov(_Z7foo_vecDv16_i)"},
// CHECK-DAG: {"_Z3foov","","_ZGVbM4__Z3foov(_Z7foo_vecDv4_i)"},
// CHECK-DAG: {"_Z3foov","","_ZGVbM8__Z3foov(_Z7foo_vecDv8_i)"},
