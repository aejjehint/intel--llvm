// Copyright (c) 2006 Intel Corporation
// Integers Built-In Functions
// AVX2

/*****************************************************************\
 * abs:                                                          *
 *   ugentype abs (gentype x)                                    *
 *   Returns | x |                                               *
\*****************************************************************/
// abs native
OclBuiltinImpl abs_avx2native = OclBuiltinImpl<abs, [v16i16, v8i32] , 0, [{
    return as_u$Arg0Type(_mm256_abs_epi$BitWidth((__m256i)$Arg0VarName));
  }]>;


/*****************************************************************\
 * add_sat:                                                      *
 *   gentype add_sat (gentype x, gentype y)                      *
 *   Returns x + y saturated                                     *
\*****************************************************************/
// add_sat on short16
OclBuiltinImpl add_sat_v16i8v8i16 = OclBuiltinImpl<add_sat, [v16i16], 0, [{
    return as_$ReturnType(_mm256_adds_epi16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;
// add_sat on ushort16
OclBuiltinImpl add_sat_v16u8v8u16 = OclBuiltinImpl<add_sat, [v16u16], 0, [{
    return as_$ReturnType(_mm256_adds_epu16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;


/*****************************************************************\
 * rhadd:                                                        *
 *   gentype rhadd (gentype x, gentype y)                        *
 *   Returns (x + y + 1) >> 1. The intermediate sum does         *
 *     not modulo overflow.                                      *
\*****************************************************************/
// rhadd fix for regression on int16
OclBuiltinImpl rhadd_16i32 = OclBuiltinImpl<rhadd, [v16i32] , 0, [{
    int16 LSB_mask_int16 = (int16)LSB_mask;
    int16 lsbx = $Arg0VarName & LSB_mask_int16;
    int16 lsby = $Arg1VarName & LSB_mask_int16;
    int16 lsb  = lsbx | lsby;
    $Arg0VarName = $Arg0VarName >> 1;
    $Arg1VarName = $Arg1VarName >> 1;
    return $Arg0VarName + $Arg1VarName + lsb;
  }]>;


/*****************************************************************\
 * mad_sat:                                                      *
 *   gentype mad_sat (gentype x , gentype y , gentype z)         *
 *   Returns x * y + z and saturates the result.                 *
\*****************************************************************/
// mad_sat native ushort16
OclBuiltinImpl mad_sat_v16u16 = OclBuiltinImpl<mad_sat, [v16u16] , 0, [{
    $Arg0Type zero = ( $Arg0Type)0;
    uint8 lox = as_uint8(_mm256_unpacklo_epi16((__m256i)$Arg0VarName, (__m256i)zero));
    uint8 loy = as_uint8(_mm256_unpacklo_epi16((__m256i)$Arg1VarName, (__m256i)zero));
    uint8 loz = as_uint8(_mm256_unpacklo_epi16((__m256i)$Arg2VarName, (__m256i)zero));
    uint8 reslo = lox * loy;
    reslo = reslo + loz;
    reslo = min(reslo, (uint8)generic_max_ushort);
    uint8 hix = as_uint8(_mm256_unpackhi_epi16((__m256i)$Arg0VarName, (__m256i)zero));
    uint8 hiy = as_uint8(_mm256_unpackhi_epi16((__m256i)$Arg1VarName, (__m256i)zero));
    uint8 hiz = as_uint8(_mm256_unpackhi_epi16((__m256i)$Arg2VarName, (__m256i)zero));
    uint8 reshi = hix * hiy;
    reshi = reshi + hiz;
    reshi = min(reshi, (uint8)generic_max_ushort);
    $ReturnType res = as_$ReturnType(_mm256_packus_epi32((__m256i)reslo, (__m256i)reshi));
    return res;
  }]>;
// mad_sat native int8
OclBuiltinImpl mad_sat_v8i32 = OclBuiltinImpl<mad_sat, [v8i32] , 0, [{
    $Arg0Type loz = $Arg2VarName & as_$Arg0Type((long4)long_even_mask);
    $Arg0Type reslo = as_$Arg0Type(_mm256_mul_epi32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reslo = reslo + loz;
    reslo = as_$Arg0Type(max(as_long4(reslo), (long)generic_min_int));
    reslo = as_$Arg0Type(min(as_long4(reslo), (long)generic_max_int));
    reslo = reslo & as_$Arg0Type((long4)long_even_mask);
    $Arg0VarName = as_$Arg0Type(as_long4($Arg0VarName) >> 32);
    $Arg1VarName = as_$Arg0Type(as_long4($Arg1VarName) >> 32);
    $Arg0Type hiz = as_$Arg0Type(_mm256_srli_epi64((__m256i)$Arg2VarName, 32));
    $Arg0Type reshi = as_$Arg0Type(_mm256_mul_epi32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reshi = reshi + hiz;
    reshi = as_$Arg0Type(max(as_long4(reshi), (long)generic_min_int));
    reshi = as_$Arg0Type(min(as_long4(reshi), (long)generic_max_int));
    reshi = as_$Arg0Type(as_long4(reshi) << 32);
    return reshi | reslo;
  }]>;
// mad_sat native uint8
OclBuiltinImpl mad_sat_v8u32 = OclBuiltinImpl<mad_sat, [v8u32] , 0, [{
    $Arg0Type loz = $Arg2VarName & as_$Arg0Type((ulong4)long_even_mask);
    $Arg0Type reslo = as_$Arg0Type(_mm256_mul_epu32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reslo = reslo + loz;
    reslo = as_$Arg0Type(min(as_ulong4(reslo), (ulong)generic_max_uint));
    reslo = reslo & as_$Arg0Type((ulong4)long_even_mask);
    $Arg0VarName = as_$Arg0Type(as_ulong4($Arg0VarName) >> 32);
    $Arg1VarName = as_$Arg0Type(as_ulong4($Arg1VarName) >> 32);
    $Arg2VarName = as_$Arg0Type(as_ulong4($Arg2VarName) >> 32);
    $Arg0Type reshi = as_$Arg0Type(_mm256_mul_epu32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reshi = reshi + $Arg2VarName;
    reshi = as_$Arg0Type(min(as_ulong4(reshi), (ulong)generic_max_uint) << 32);
    return reshi | reslo;
  }]>;


/*****************************************************************\
 * mul_hi                                                        *
 *   gentype mul_hi (gentype x , gentype y)                      *
 *   Returns the high half of the product of (x * y)             *
\*****************************************************************/
// mul_hi native short16
OclBuiltinImpl mul_hi_v16i16 = OclBuiltinImpl<mul_hi, [v16i16] , 0, [{
    return as_$ReturnType(_mm256_mulhi_epi16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;
// mul_hi native ushort16
OclBuiltinImpl mul_hi_v16u16 = OclBuiltinImpl<mul_hi, [v16u16] , 0, [{
    return as_$ReturnType(_mm256_mulhi_epu16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;
// mul_hi native int8
OclBuiltinImpl mul_hi_v8i32 = OclBuiltinImpl<mul_hi, [v8i32] , 0, [{
    ulong4 reslo = as_ulong4(_mm256_mul_epi32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reslo = reslo >> (ulong)32;
    $Arg0VarName = as_$Arg0Type(as_ulong4($Arg0VarName) >> (ulong)32);
    $Arg1VarName = as_$Arg1Type(as_ulong4($Arg1VarName) >> (ulong)32);
    ulong4 reshi = as_ulong4(_mm256_mul_epi32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    $ReturnType res = as_$ReturnType(_mm256_blend_epi32((__m256i)reslo, (__m256i)reshi, 0b10101010));
    return res;
  }]>;
// mul_hi native uint8
OclBuiltinImpl mul_hi_v8u32 = OclBuiltinImpl<mul_hi, [v8u32] , 0, [{
    ulong4 reslo = as_ulong4(_mm256_mul_epu32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    reslo = reslo >> (ulong)32;
    $Arg0VarName = as_$Arg0Type(as_ulong4($Arg0VarName) >> (ulong)32);
    $Arg1VarName = as_$Arg1Type(as_ulong4($Arg1VarName) >> (ulong)32);
    ulong4 reshi = as_ulong4(_mm256_mul_epu32((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
    $ReturnType res = as_$ReturnType(_mm256_blend_epi32((__m256i)reslo, (__m256i)reshi, 0b10101010));
    return res;
  }]>;
// mul_hi fix for regression on ulong16
OclBuiltinImpl mul_hi_v2u64 = OclBuiltinImpl<mul_hi, [v4u64] , 0, [{
    __attribute__((aligned(16))) ulong tempX[4];
    __attribute__((aligned(16))) ulong tempY[4];
    ulong destLow;
    ulong destHi;

    // Store to temporary buffer
    _mm256_store_si256((__m256i *)tempX,(__m256i) $Arg0VarName);
    _mm256_store_si256((__m256i *)tempY,(__m256i) $Arg1VarName);
#if defined(__GNUC__)
#pragma GCC ivdep
#elif defined(__clang__)
#pragma clang loop vectorize(enable)
#endif
    for(int i=0; i < 4; ++i)
    {
      multiply_unsigned_64_by_64( tempX[i], tempY[i], &destLow, &destHi );
      tempX[i] = destHi;
    }

    return as_ulong4(_mm256_load_si256((const __m256i *)tempX));
  }]>;


/*****************************************************************\
 * sub_sat:                                                      *
 *   gentype sub_sat (gentype x, gentype y)                      *
 *   Returns x - y saturated                                     *
\*****************************************************************/
// sub_sat on short16
OclBuiltinImpl sub_sat_v16i8v8i16 = OclBuiltinImpl<sub_sat, [v16i16], 0, [{
    return as_$ReturnType(_mm256_subs_epi16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;
// sub_sat on ushort16
OclBuiltinImpl sub_sat_v16u8v8u16 = OclBuiltinImpl<sub_sat, [v16u16], 0, [{
    return as_$ReturnType(_mm256_subs_epu16((__m256i)$Arg0VarName, (__m256i)$Arg1VarName));
  }]>;


/*****************************************************************\
 * v32 and v64 section                                           *
\*****************************************************************/
defvar integer_v32v64_all = ExpandTypesByVFAndFlatten<[v1i8, v1u8, v1i16, v1u16, v1i32, v1u32, v1i64, v1u64], [32, 64]>.Tout;
defvar integer_v32v64_signed = ExpandTypesByVFAndFlatten<[v1i8, v1i16, v1i32, v1i64], [32, 64]>.Tout;
defvar integer_v32v64_unsigned = ExpandTypesByVFAndFlatten<[v1u8, v1u16, v1u32, v1u64], [32, 64]>.Tout;

OclBuiltinImpl abs_v32v64_signed = OclBuiltinImpl<abs, integer_v32v64_signed, 0, Expand1>;

OclBuiltinImpl abs_v32v64_unsigned = OclBuiltinImpl<abs, integer_v32v64_unsigned, 0, [{
    return $Arg0VarName;
  }]>;

OclBuiltinImpl abs_diff_v32v64 = OclBuiltinImpl<abs_diff, integer_v32v64_all, 0, [{
    return __builtin_astype(($Arg0Type)(max($Arg0VarName, $Arg1VarName) - min($Arg0VarName, $Arg1VarName)), $ReturnType);
  }]>;

OclBuiltinImpl add_sat_v32v64_signed  = OclBuiltinImpl<add_sat, integer_v32v64_signed, 0, add_sat_svector_code>;

OclBuiltinImpl add_sat_v32v64_unsigned  = OclBuiltinImpl<add_sat, integer_v32v64_unsigned, 0, add_sat_unsigned_code>;

OclBuiltinImpl hadd_v32v64 = OclBuiltinImpl<hadd, integer_v32v64_all, 0, [{
    $ReturnType s, c;
    s = $Arg0VarName ^ $Arg1VarName;
    c = $Arg0VarName & $Arg1VarName;
    return (s >> (($ReturnType)1)) + c;
  }]>;

OclBuiltinImpl rhadd_v32v64 = OclBuiltinImpl<rhadd, integer_v32v64_all, 0, rhadd_igeneric_code>;

OclBuiltinImpl clamp_v32v64 = OclBuiltinImpl<clamp, integer_v32v64_all, 0, [{
    return max(min($Arg0VarName, $Arg2VarName), $Arg1VarName);
  }]>;

OclBuiltinImpl clz_v32v64_unsigned = OclBuiltinImpl<clz, integer_v32v64_all, 0, Expand1>;

OclBuiltinImpl mad_hi_v32v64 = OclBuiltinImpl<mad_hi, integer_v32v64_all, 0, [{
    return mul_hi($Arg0VarName, $Arg1VarName) + $Arg2VarName;
  }]>;

OclBuiltinImpl mad_sat_v32v64  = OclBuiltinImpl<mad_sat, integer_v32v64_all, 0, Expand3>;

OclBuiltinImpl mul_hi_v32v64  = OclBuiltinImpl<mul_hi, integer_v32v64_all, 0, Expand2>;

OclBuiltinImpl rotate_v32v64_signed = OclBuiltinImpl<rotate, integer_v32v64_signed, 0, [{
    return __builtin_astype(rotate(__builtin_astype($Arg0VarName, u$Arg0Type), __builtin_astype($Arg1VarName, u$Arg1Type)), $ReturnType);
  }]>;

OclBuiltinImpl rotate_v32v64_unsigned = OclBuiltinImpl<rotate, integer_v32v64_unsigned, 0, [{
    $Arg1VarName &= ($Arg1BaseType)($BitWidth - 1);
    return __builtin_astype(( $Arg0VarName << $Arg1VarName ) | $Arg0VarName >> ( ($Arg1BaseType)$BitWidth - $Arg1VarName ), $ReturnType);
  }]>;

OclBuiltinImpl sub_sat_v32v64_signed = OclBuiltinImpl<sub_sat, integer_v32v64_signed , 0, sub_sat_svector_code>;

OclBuiltinImpl sub_sat_v32v64_unsigned = OclBuiltinImpl<sub_sat, integer_v32v64_unsigned , 0, sub_sat_unsigned_code>;

// upsample does not apply to 64-bit integers
defvar upsample_integer_v32v64_signed = ExpandTypesByVFAndFlatten<[v1i8, v1i16, v1i32], [32, 64]>.Tout;
defvar upsample_integer_v32v64_unsigned = ExpandTypesByVFAndFlatten<[v1u8, v1u16, v1u32], [32, 64]>.Tout;

OclBuiltinImpl upsample_v32v64_signed = OclBuiltinImpl<upsample, upsample_integer_v32v64_signed, 0, [{
    return __builtin_astype(upsample(__builtin_astype($Arg0VarName, u$Arg0Type), $Arg1VarName), $ReturnType);
  }]>;

OclBuiltinImpl upsample_v32v64_unsigned = OclBuiltinImpl<upsample, upsample_integer_v32v64_unsigned, 0, [{
    return (convert_$ReturnType($Arg0VarName) << ($ReturnType)$BitWidth) | convert_$ReturnType($Arg1VarName);
  }]>;

OclBuiltinImpl popcount_v32v64 = OclBuiltinImpl<popcount, integer_v32v64_all , 0, Expand1>;

OclBuiltinImpl ctz_v32v64 = OclBuiltinImpl<ctz, integer_v32v64_all, 0, Expand1>;
