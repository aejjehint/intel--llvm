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

let Types = ExpandTypesByVFAndFlatten<[v1f16, v1f32, v1f64], [1, 2, 3, 4, 8, 16]>.Tout,
    IsDeclOnly = 1, NeedForwardDecl = 1, Attrs = [OVERLOADABLE] in {
  def : OclBuiltin<"__ocl_reduce_fadd", (outs sgentype:$ret), (ins gentype:$vec)>;
}
