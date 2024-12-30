// Copyright (C) 2024 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

include "GENERIC/ll_generation/definition.td"

// __ocl_reduce_fadd implementation
// Example output:
//
// define half @_Z17__ocl_reduce_faddDv2_Dh(<2 x half> %vec) {
//   %call = call reassoc half @llvm.vector.reduce.fadd.v2f16(half zeroinitializer, <2 x half> %vec)
//   return half %call
// }

let EmitMangledName = true,
    FuncAttrs = ["memory(none)", "willreturn", "nounwind"] in {
  foreach vf = [1, 2, 3, 4, 8, 16] in {
    foreach type = ["f16", "f32", "f64"]  in {
      defvar scalar_type = !cast<FloatType>(type);
      defvar vec_type = !cast<VectorType>("v" # vf # type);
      let EmitMangledName = false in
      def llvm_vector_reduce_fadd_ # vec_type : LLDeclare<"llvm.vector.reduce.fadd." # vec_type, [scalar_type, vec_type], scalar_type>;

      defvar ret_type = scalar_type;
      defvar vec_mangle = MangleVectorType<vec_type, /*is_signed*/false>.ret;
      defm __ocl_reduce_fadd_ # vec_type : LLDefine<"__ocl_reduce_fadd", [Value<vec_type, "vec">], ret_type, [{
        %call = call reassoc {RetType} @{INTRINSIC_NAME}({RetType} zeroinitializer, {Args[0]})
        ret {RetType} %call
      }], [Macro<"INTRINSIC_NAME", "llvm.vector.reduce.fadd." # vec_type>], vec_mangle>;
    }
  }
}
