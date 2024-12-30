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

// https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_Ext.html#cl_khr_integer_dot_product

let Types = [v4i8],
    Attrs = [CONSTFUNC, OVERLOADABLE],
    NeedForwardDecl = 1 in {
def dot_ss         : OclBuiltin<"dot",         (outs v1i32:$ret), (ins gentype:$a, gentype:$b), [], [], 0, 0>;
def dot_su         : OclBuiltin<"dot",         (outs v1i32:$ret), (ins gentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_us         : OclBuiltin<"dot",         (outs v1i32:$ret), (ins ugentype:$a, gentype:$b), [], [], 0, 0>;
def dot_uu         : OclBuiltin<"dot",         (outs v1u32:$ret), (ins ugentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_acc_sat_ss : OclBuiltin<"dot_acc_sat", (outs v1i32:$ret), (ins gentype:$a, gentype:$b, v1i32:$acc), [], [], 0, 0>;
def dot_acc_sat_su : OclBuiltin<"dot_acc_sat", (outs v1i32:$ret), (ins gentype:$a, ugentype:$b, v1i32:$acc), [], [], 0, 0>;
def dot_acc_sat_us : OclBuiltin<"dot_acc_sat", (outs v1i32:$ret), (ins ugentype:$a, gentype:$b, v1i32:$acc), [], [], 0, 0>;
def dot_acc_sat_uu : OclBuiltin<"dot_acc_sat", (outs v1u32:$ret), (ins ugentype:$a, ugentype:$b, v1u32:$acc), [], [], 0, 0>;
}

let Types = [v1i32],
    Attrs = [CONSTFUNC, OVERLOADABLE],
    NeedForwardDecl = 1 in {
def dot_4x8packed_ss_int          : OclBuiltin<"dot_4x8packed_ss_int",          (outs gentype:$ret), (ins ugentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_4x8packed_su_int          : OclBuiltin<"dot_4x8packed_su_int",          (outs gentype:$ret), (ins ugentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_4x8packed_us_int          : OclBuiltin<"dot_4x8packed_us_int",          (outs gentype:$ret), (ins ugentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_4x8packed_uu_uint         : OclBuiltin<"dot_4x8packed_uu_uint",         (outs ugentype:$ret), (ins ugentype:$a, ugentype:$b), [], [], 0, 0>;
def dot_acc_sat_4x8packed_ss_int  : OclBuiltin<"dot_acc_sat_4x8packed_ss_int",  (outs gentype:$ret), (ins ugentype:$a, ugentype:$b, gentype:$acc), [], [], 0, 0>;
def dot_acc_sat_4x8packed_su_int  : OclBuiltin<"dot_acc_sat_4x8packed_su_int",  (outs gentype:$ret), (ins ugentype:$a, ugentype:$b, gentype:$acc), [], [], 0, 0>;
def dot_acc_sat_4x8packed_us_int  : OclBuiltin<"dot_acc_sat_4x8packed_us_int",  (outs gentype:$ret), (ins ugentype:$a, ugentype:$b, gentype:$acc), [], [], 0, 0>;
def dot_acc_sat_4x8packed_uu_uint : OclBuiltin<"dot_acc_sat_4x8packed_uu_uint", (outs ugentype:$ret), (ins ugentype:$a, ugentype:$b, ugentype:$acc), [], [], 0, 0>;
}

/*****************************************************************\
 * dot:                                                          *
 *   v1i32 dot (gentype a, gentype b)                            *
 *   Returns the dot product of the two vectors a and b          *
\*****************************************************************/
defvar dot_integer = [{
  $ReturnType$VecLength arg0 = convert_$ReturnType$VecLength($Arg0VarName);
  $ReturnType$VecLength arg1 = convert_$ReturnType$VecLength($Arg1VarName);
  arg0 = arg0 * arg1;
  arg0 = as_$ReturnType$VecLength(_mm_hadd_epi32((__m128i)arg0, (__m128i)arg0));
  return arg0.x + arg0.y;
}];

foreach bi = [dot_ss, dot_su, dot_us, dot_uu] in {
  def : OclBuiltinImpl<bi, bi.Types, false, dot_integer>, SHARED;
}

/*****************************************************************\
 * dot_acc_sat:                                                  *
 *   v1i32 dot_acc_sat (gentype a, gentype b, v1i32 acc)         *
 *   Returns the saturating addition of dot(a, b) and acc        *
\*****************************************************************/
defvar dot_acc_sat_integer = [{
  return add_sat(dot($Arg0VarName, $Arg1VarName), $Arg2VarName);
}];

foreach bi = [dot_acc_sat_ss, dot_acc_sat_su, dot_acc_sat_us, dot_acc_sat_uu] in {
  def : OclBuiltinImpl<bi, bi.Types, false, dot_acc_sat_integer>, SHARED;
}

/*****************************************************************************\
 * dot_4x8packed_ss_int:                                                     *
 * dot_4x8packed_su_int:                                                     *
 * dot_4x8packed_us_int:                                                     *
 * dot_4x8packed_uu_uint:                                                    *
 *   v1i32 dot_4x8packed_* (ugentype a, ugentype b)                          *
 *   Returns dot for 4x8 bit input vectors packed into a 32-bit word         *
\*****************************************************************************/
defvar dot_4x8packed_integer = [{
  $TYPE0 arg0 = as_$TYPE0($Arg0VarName);
  $TYPE1 arg1 = as_$TYPE1($Arg1VarName);
  return dot(arg0, arg1);
}];

foreach arg0 = [ "s", "u" ] in {
  defvar type0 = !cond(!eq(arg0, "s") : "char4", true: "uchar4");
  foreach arg1 = [ "s", "u" ] in {
    defvar type1 = !cond(!eq(arg1, "s") : "char4", true: "uchar4");
    defvar type_result = !cond(!and(!eq(arg0, "u"), !eq(arg1, "u")) : "uint", true: "int");
    defvar builtin = !cast<OclBuiltin>("dot_4x8packed_"#arg0#arg1#"_"#type_result);
    def : OclBuiltinImpl<builtin, [v1i32], false, dot_4x8packed_integer, [["$TYPE0", type0], ["$TYPE1", type1]]>, SHARED;
  }
}

/*****************************************************************************\
 * dot_acc_sat_4x8packed_ss_int:                                             *
 * dot_acc_sat_4x8packed_su_int:                                             *
 * dot_acc_sat_4x8packed_us_int:                                             *
 * dot_acc_sat_4x8packed_uu_uint:                                            *
 *   v1i32 dot_acc_sat_4x8packed_* (ugentype a, ugentype b, gentype acc)     *
 *   Returns dot_acc_set for 4x8 bit input vectors packed into a 32-bit word *
\*****************************************************************************/
defvar dot_acc_sat_4x8packed_integer = [{
  $TYPE0 arg0 = as_$TYPE0($Arg0VarName);
  $TYPE1 arg1 = as_$TYPE1($Arg1VarName);
  return dot_acc_sat(arg0, arg1, $Arg2VarName);
}];

foreach arg0 = [ "s", "u" ] in {
  defvar type0 = !cond(!eq(arg0, "s") : "char4", true: "uchar4");
  foreach arg1 = [ "s", "u" ] in {
    defvar type1 = !cond(!eq(arg1, "s") : "char4", true: "uchar4");
    defvar type_result = !cond(!and(!eq(arg0, "u"), !eq(arg1, "u")) : "uint", true: "int");
    defvar builtin = !cast<OclBuiltin>("dot_acc_sat_4x8packed_"#arg0#arg1#"_"#type_result);
    def : OclBuiltinImpl<builtin, [v1i32], false, dot_acc_sat_4x8packed_integer, [["$TYPE0", type0], ["$TYPE1", type1]]>, SHARED;
  }
}
