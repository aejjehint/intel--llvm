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

// --- Geometric Functions ---
// https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_C.html#geometric-functions
//
// Prototypes
defvar geometric_vf3_f16_types = ExpandTypesByVFAndFlatten<[v1f16], [3]>.Tout;
defvar geometric_vf4_f16_types = ExpandTypesByVFAndFlatten<[v1f16], [4]>.Tout;
defvar geometric_all_f16_types = ExpandTypesByVFAndFlatten<[v1f16], [1, 2, 3, 4]>.Tout;
let Attrs = [CONSTFUNC, OVERLOADABLE] in {
  let Types = geometric_vf3_f16_types # geometric_vf4_f16_types in
  def cross_f16 : OclBuiltin<"cross", (outs gentype:$ret), (ins gentype:$p0, gentype:$p1)>;

  let Types = geometric_all_f16_types in {
    def dot_f16 : OclBuiltin<"dot", (outs sgentype:$ret), (ins gentype:$p0, gentype:$p1)>;
    def distance_f16 : OclBuiltin<"distance", (outs sgentype:$ret), (ins gentype:$p0, gentype:$p1)>;
    def length_f16 : OclBuiltin<"length", (outs sgentype:$ret), (ins gentype:$p)>;
    def normalize_f16 : OclBuiltin<"normalize", (outs gentype:$ret), (ins gentype:$p)>;
  }
}

// Implementations
def : OclBuiltinImpl<cross_f16, geometric_vf3_f16_types, false, [{
  // input: (a0, a1, a2), (b0, b1, b2)
  $ReturnType _t0 = __builtin_shufflevector($Arg0VarName, $Arg0VarName, 1, 2, 0); // (a1, a2, a0)
  $ReturnType _t1 = __builtin_shufflevector($Arg1VarName, $Arg1VarName, 1, 2, 0); // (b1, b2, b0)
  _t0 = $Arg1VarName * _t0; // (a1b0, a2b1, a0b2)
  _t1 = $Arg0VarName * _t1; // (a0b1, a1b2, a2b0)
  _t1 = _t1 - _t0; // (a0b1 - a1b0, a1b2 - a2b1, a2b0 - a0b2)
  return __builtin_shufflevector(_t1, _t1, 1, 2, 0); // (a1b2 - a2b1, a2b0 - a0b2, a0b1 - a1b0)
}]>, SHARED;
def : OclBuiltinImpl<cross_f16, geometric_vf4_f16_types, false, [{
  $ReturnType _res;
  _res.xyz = cross($Arg0VarName.xyz, $Arg1VarName.xyz);
  _res.w = 0.;
  return _res;
}]>, SHARED;
def : OclBuiltinImpl<dot_f16, dot_f16.Types, false, [{
  return __ocl_reduce_fadd($Arg0VarName * $Arg1VarName);
}]>, SHARED;
def : OclBuiltinImpl<distance_f16, distance_f16.Types, false, [{
  return length($Arg0VarName - $Arg1VarName);
}]>, SHARED;
def : OclBuiltinImpl<length_f16, length_f16.Types, false, [{
#if $VecLength == 1
  return $Arg0VarName;
#else
  $ReturnType _d = dot($Arg0VarName, $Arg0VarName);
  $ReturnType _scale_factor = 0x1.0p15h;
  if (isinf(_d)) {
    $Arg0VarName /= _scale_factor;
    _d = dot($Arg0VarName, $Arg0VarName);
    return sqrt(_d) * _scale_factor;
  } else if (_d < $VecLength * HALF_MIN / HALF_EPSILON) {
    $Arg0VarName *= _scale_factor;
    _d = dot($Arg0VarName, $Arg0VarName);
    return sqrt(_d) / _scale_factor;
  }
  return sqrt(_d);
#endif
}]>, SHARED;
def : OclBuiltinImpl<normalize_f16, normalize_f16.Types, false, [{
  $Arg0sgentype _l = length($Arg0VarName);
  if (any(isnan($Arg0VarName)) || _l == 0)
    return $Arg0VarName;
  return $Arg0VarName / _l;
}]>, SHARED;
