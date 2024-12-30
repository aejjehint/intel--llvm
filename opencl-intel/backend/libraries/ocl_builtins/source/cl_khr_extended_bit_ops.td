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

defvar bitfield_scalar_types = [v1i8, v1u8, v1i16, v1u16, v1i32, v1u32, v1i64, v1u64];
defvar bitfield_all_types = ExpandTypesByVFAndFlatten<bitfield_scalar_types, [1, 2, 3, 4, 8, 16, 32, 64]>.Tout;
defvar bitfield_vector_types = ExpandTypesByVFAndFlatten<bitfield_scalar_types, [2, 3, 4, 8, 16, 32, 64]>.Tout;
defvar bitfield_widen_types = ExpandTypesByVFAndFlatten<bitfield_scalar_types, [4, 8, 16, 32, 64]>.Tout;

// https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_Ext.html#cl_khr_extended_bit_ops
//
// Prototypes
let Types = bitfield_all_types,
    Attrs = [CONSTFUNC, OVERLOADABLE], NeedForwardDecl = true in {
  def bitfield_insert: OclBuiltin<"bitfield_insert",  (outs gentype:$ret), (ins gentype:$base, gentype:$insert, uint:$offset, uint:$count), [], [], 0, 0>;
  def bitfield_extract_signed: OclBuiltin<"bitfield_extract_signed",  (outs igentype:$ret), (ins gentype:$base, uint:$offset, uint:$count), [], [], 0, 0>;
  def bitfield_extract_unsigned: OclBuiltin<"bitfield_extract_unsigned",  (outs ugentype:$ret), (ins gentype:$base, uint:$offset, uint:$count), [], [], 0, 0>;
  def bit_reverse: OclBuiltin<"bit_reverse",  (outs gentype:$ret), (ins gentype:$base), [], [], 0, 0>;
}

let Types = bitfield_widen_types,
    Attrs = [CONSTFUNC, OVERLOADABLE], NeedForwardDecl = true in {
  def bitfield_insert_v1widen  : OclBuiltin<"bitfield_insert_v1widen",  (outs gentype:$ret), (ins gentype:$base, gentype:$insert, u32gentype:$offset, u32gentype:$count), [], [], 0, 0>;
  def bitfield_extract_signed_v1widen: OclBuiltin<"bitfield_extract_signed_v1widen",  (outs igentype:$ret), (ins gentype:$base, u32gentype:$offset, u32gentype:$count), [], [], 0, 0>;
  def bitfield_extract_unsigned_v1widen: OclBuiltin<"bitfield_extract_unsigned_v1widen",  (outs ugentype:$ret), (ins gentype:$base, u32gentype:$offset, u32gentype:$count), [], [], 0, 0>;
  def bit_reverse_v1widen: OclBuiltin<"bit_reverse_v1widen",  (outs gentype:$ret), (ins gentype:$base), [], [], 0, 0>;
  def bitfield_insert_v1widen_mask  : OclBuiltin<"bitfield_insert_v1widen",  (outs gentype:$ret), (ins gentype:$base, gentype:$insert, u32gentype:$offset, u32gentype:$count, gentype:$mask), [], [], 0, 0>;
  def bitfield_extract_signed_v1widen_mask: OclBuiltin<"bitfield_extract_signed_v1widen",  (outs igentype:$ret), (ins gentype:$base, u32gentype:$offset, u32gentype:$count, gentype:$mask), [], [], 0, 0>;
  def bitfield_extract_unsigned_v1widen_mask: OclBuiltin<"bitfield_extract_unsigned_v1widen",  (outs ugentype:$ret), (ins gentype:$base, u32gentype:$offset, u32gentype:$count, gentype:$mask), [], [], 0, 0>;
  def bit_reverse_v1widen_mask: OclBuiltin<"bit_reverse_v1widen",  (outs gentype:$ret), (ins gentype:$base, gentype:$mask), [], [], 0, 0>;
}

// Implementations
defvar bitfield_insert_util_code = [{
  $Arg0ugentype baseU = __builtin_astype(base, $Arg0ugentype);
  $Arg0ugentype insertU = __builtin_astype(insert, $Arg0ugentype);
  $Arg0ugentype selectLeft = ~($Arg0ugentype)(0);
  $Arg0ugentype selectRight = ((($Arg0ugentype)(1) << count) - ($Arg0ugentype)(1)) << offset;
#if $VecLength == 1
  $Arg0ugentype mask = select(selectLeft, selectRight, convert_$Arg0ugentype(count < sizeof($Arg0BaseType) * 8));
#else
  $Arg0ugentype mask = select(selectLeft, selectRight, convert_$Arg0ugentype(count < (uint$VecLength)(sizeof($Arg0BaseType) * 8)));
#endif
  $Arg0ugentype result = ((insertU << offset) & mask) | (baseU & ~mask);
  return __builtin_astype(result, $ReturnType);
}];

defvar bitfield_insert_mask_code = [{
  $Arg0gentype base_mask = select(($Arg0gentype)(0), $Arg0VarName, ($Arg0igentype)0 != convert_$Arg0igentype($Arg4VarName));
  $Arg0gentype insert_mask = select(($Arg0gentype)(0), $Arg1VarName, ($Arg0igentype)0 != convert_$Arg0igentype($Arg4VarName));
  return bitfield_insert_v1widen(base_mask, insert_mask, offset, count);
}];

defvar bitfield_extract_signed_util_code = [{
#if $VecLength == 1
  if (count == 0)
    return 0;
#endif
  $Arg0ugentype baseU = __builtin_astype(base, $Arg0ugentype);
#if $VecLength == 1
  $Arg0ugentype result = baseU << (sizeof($Arg0BaseType) * 8 - offset - count);
  $Arg0ugentype s = -(result >> (sizeof($Arg0BaseType) * 8 - 1));
  result = (s ^ result) >> (sizeof($Arg0BaseType) * 8 - count) ^ s;
#else
  $Arg0ugentype result = baseU << ((uint$VecLength)(sizeof($Arg0BaseType) * 8) - offset - count);
  $Arg0ugentype s = -(result >> ((uint$VecLength)(sizeof($Arg0BaseType) * 8 - 1)));
  result = (s ^ result) >> ((uint$VecLength)(sizeof($Arg0BaseType) * 8) - count) ^ s;
#endif
  result = select(result, ($Arg0ugentype)(0), convert_$Arg0ugentype(count == (uint$VecLength)(0)));
  return __builtin_astype(result, $ReturnType);
}];

defvar bitfield_extract_signed_mask_code = [{
  $Arg0gentype base_mask = select(($Arg0gentype)(0), $Arg0VarName, ($Arg0igentype)0 != convert_$Arg0igentype($Arg3VarName));
  return bitfield_extract_signed_v1widen(base_mask, offset, count);
}];

defvar bitfield_extract_unsigned_util_code = [{
#if $VecLength == 1
  if (count == 0)
    return 0;
#endif
  $Arg0ugentype baseU = __builtin_astype(base, $Arg0ugentype);
#if $VecLength == 1
  $Arg0ugentype result = baseU << (sizeof($Arg0BaseType) * 8 - offset - count);
  result = result >> (sizeof($Arg0BaseType) * 8 - count);
#else
  $Arg0ugentype result = baseU << ((uint$VecLength)(sizeof($Arg0BaseType) * 8) - offset - count);
  result = result >> ((uint$VecLength)(sizeof($Arg0BaseType) * 8) - count);
#endif
  result = select(result, ($Arg0ugentype)(0), convert_$Arg0ugentype(count == (uint$VecLength)(0)));
  return __builtin_astype(result, $ReturnType);
}];

defvar bitfield_extract_unsigned_mask_code = [{
  $Arg0gentype base_mask = select(($Arg0gentype)(0), $Arg0VarName, ($Arg0igentype)0 != convert_$Arg0igentype($Arg3VarName));
  return bitfield_extract_unsigned_v1widen(base_mask, offset, count);
}];

defvar bit_reverse_util_code = [{
  $Arg0gentype result = ($Arg0gentype)(0);
  $Arg0gentype baseU = base;
  const size_t count = sizeof($Arg0BaseType) * 8;
  for (size_t i = 0; i < count; i++) {
    result <<= 1;
    result |= (baseU & ($Arg0gentype)(1));
    baseU >>= 1;
  }
  return result;
}];

defvar bit_reverse_mask_code = [{
  $Arg0gentype base_mask = select(($Arg0gentype)(0), $Arg0VarName, ($Arg0igentype)0 != convert_$Arg0igentype($Arg1VarName));
  return bit_reverse_v1widen(base_mask);
}];

def : OclBuiltinImpl<bitfield_insert, bitfield_insert.Types, false, bitfield_insert_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_signed, bitfield_extract_signed.Types, false, bitfield_extract_signed_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_unsigned, bitfield_extract_unsigned.Types, false, bitfield_extract_unsigned_util_code>, SHARED;
def : OclBuiltinImpl<bit_reverse, bit_reverse.Types, false, bit_reverse_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_insert_v1widen, bitfield_insert_v1widen.Types, false, bitfield_insert_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_signed_v1widen, bitfield_extract_signed_v1widen.Types, false, bitfield_extract_signed_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_unsigned_v1widen, bitfield_extract_unsigned_v1widen.Types, false, bitfield_extract_unsigned_util_code>, SHARED;
def : OclBuiltinImpl<bit_reverse_v1widen, bit_reverse_v1widen.Types, false, bit_reverse_util_code>, SHARED;
def : OclBuiltinImpl<bitfield_insert_v1widen_mask, bitfield_insert_v1widen_mask.Types, false, bitfield_insert_mask_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_signed_v1widen_mask, bitfield_extract_signed_v1widen_mask.Types, false, bitfield_extract_signed_mask_code>, SHARED;
def : OclBuiltinImpl<bitfield_extract_unsigned_v1widen_mask, bitfield_extract_unsigned_v1widen_mask.Types, false, bitfield_extract_unsigned_mask_code>, SHARED;
def : OclBuiltinImpl<bit_reverse_v1widen_mask, bit_reverse_v1widen_mask.Types, false, bit_reverse_mask_code>, SHARED;

// VectInfos
let Types = bitfield_scalar_types in {
  foreach bi = [bitfield_insert, bitfield_extract_signed, bitfield_extract_unsigned, bit_reverse] in {
    defvar v1widen = !cast<OclBuiltin>(bi # "_v1widen");
    defvar v1widen_mask = !cast<OclBuiltin>(bi # "_v1widen_mask");
    def : VectInfo<[], bi, v1widen, v1widen, v1widen, v1widen, v1widen>;
    let HandleAlias = false in
    def : VectInfo<[], bi, v1widen_mask, v1widen_mask, v1widen_mask, v1widen_mask, v1widen_mask>;
  }
}
