/*****************************************************************************\

Copyright (c) Intel Corporation (2012).

INTEL MAKES NO WARRANTY OF ANY KIND REGARDING THE CODE.  THIS CODE IS
LICENSED ON AN "AS IS" BASIS AND INTEL WILL NOT PROVIDE ANY SUPPORT,
ASSISTANCE, INSTALLATION, TRAINING OR OTHER SERVICES.  INTEL DOES NOT
PROVIDE ANY UPDATES, ENHANCEMENTS OR EXTENSIONS.  INTEL SPECIFICALLY
DISCLAIMS ANY WARRANTY OF MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR ANY
PARTICULAR PURPOSE, OR ANY OTHER WARRANTY.  Intel disclaims all liability,
including liability for infringement of any proprietary rights, relating to
use of the code. No license, express or implied, by estoppels or otherwise,
to any intellectual property rights is granted herein.

File Name:  oclbuiltin_f.cl


\*****************************************************************************/

#include "oclbuiltin_f.h"

__kernel void vload_f(__global float *input, __global int *input_int,
                      __global float *output, __global float *output2) {
  OUT_VARS
  uint tid = 0;
  a2_out = vload2(0, input);
  a3_out = vload3(0, input);
  a4_out = vload4(0, input);
  a8_out = vload8(0, input);
  a16_out = vload16(0, input);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

__kernel void vstore_f(__global float *input, __global int *input_int,
                       __global float *output, __global float *output2) {
  IN_VARS_A
  OUT_VARS
  uint tid = 0;
  SET_IN_ONEARG(tid)
  vstore2(a2_in, 0, (float *)&a2_out);
  vstore3(a3_in, 0, (float *)&a3_out);
  vstore4(a4_in, 0, (float *)&a4_out);
  vstore8(a8_in, 0, (float *)&a8_out);
  vstore16(a16_in, 0, (float *)&a16_out);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

__kernel void convert_float_uint_f(__global float *input,
                                   __global int *input_int,
                                   __global float *output,
                                   __global float *output2) {
  OUT_VARS
  uint tid = 0;
  uint in = 3;
  a_out = convert_float(in);
  a2_out = convert_float2((uint2)in);
  a3_out = convert_float3((uint3)in);
  a4_out = convert_float4((uint4)in);
  a8_out = convert_float8((uint8)in);
  a16_out = convert_float16((uint16)in);

  OUTPUT_ONE_VEC_FLOAT(tid)
}
__kernel void convert_float_int_f(__global float *input,
                                  __global int *input_int,
                                  __global float *output,
                                  __global float *output2) {
  OUT_VARS
  uint tid = 0;
  int in = 3;
  a_out = convert_float(in);
  a2_out = convert_float2((int2)in);
  a3_out = convert_float3((int3)in);
  a4_out = convert_float4((int4)in);
  a8_out = convert_float8((int8)in);
  a16_out = convert_float16((int16)in);

  OUTPUT_ONE_VEC_FLOAT(tid)
}

KERNEL_BI_FOUT_FIN_IIN(rootn)
KERNEL_BI_FOUT_FIN_IIN(ldexp) // floatn ldexp (floatn x, intn k)
KERNEL_BI_SINGLE_LDEXP(ldexp) // floatn ldexp (floatn x, int k)

KERNEL_BI_TWOOUTARGS(modf)
KERNEL_BI_FREXP(frexp)

KERNEL_BI_THREEARGS(fma)
KERNEL_BI_THREEARGS(mad)
KERNEL_BI_MINMAX(fmin)  // gentype fmax (gentype x, float y)
KERNEL_BI_MINMAX(fmax)  // gentype fmax (gentype x, float y)
KERNEL_BI_SINGLE_POW(pown)

__kernel void ilogb_f(__global float *input, __global int *input_int,
                      __global float *output, __global float *output2) {
  IN_VARS_A
  int i_out;
  int2 i2_out;
  int3 i3_out;
  int4 i4_out;
  int8 i8_out;
  int16 i16_out;
  uint tid = 0;
  SET_IN_ONEARG(tid)
  i_out = ilogb(a_in);
  i2_out = ilogb(a2_in);
  i3_out = ilogb(a3_in);
  i4_out = ilogb(a4_in);
  i8_out = ilogb(a8_in);
  i16_out = ilogb(a16_in);
}

__kernel void nan_f(__global float *input, __global int *input_int,
                    __global float *output, __global float *output2) {
  uint ui_in = 0;
  uint2 ui2_in = 0;
  uint3 ui3_in = 0;
  uint4 ui4_in = 0;
  uint8 ui8_in = 0;
  uint16 ui16_in = 0;
  uint tid = 0;
  OUT_VARS
  a_out = nan(ui_in);
  a2_out = nan(ui2_in);
  a3_out = nan(ui3_in);
  a4_out = nan(ui4_in);
  a8_out = nan(ui8_in);
  a16_out = nan(ui16_in);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

KERNEL_BI_TWOOUTARGS(fract)
KERNEL_BI_FREXP(lgamma_r)

KERNEL_BI_THREEARGS(bitselect)

__kernel void select_f(__global float *input, __global int *input_int,
                       __global float *output, __global float *output2) {
  IN_VARS_A
  IN_VARS_B
  OUT_VARS
  uint tid = 0;
  SET_IN_TWOARGS(tid)

  int i_in = 0;
  int2 i2_in = 0;
  int3 i3_in = 0;
  int4 i4_in = 0;
  int8 i8_in = 0;
  int16 i16_in = 0;
  uint ui_in = 0;
  uint2 ui2_in = 0;
  uint3 ui3_in = 0;
  uint4 ui4_in = 0;
  uint8 ui8_in = 0;
  uint16 ui16_in = 0;

  a_out = select(a_in, b_in, i_in);
  a2_out = select(a2_in, b2_in, i2_in);
  a3_out = select(a3_in, b3_in, i3_in);
  a4_out = select(a4_in, b4_in, i4_in);
  a8_out = select(a8_in, b8_in, i8_in);
  a16_out = select(a16_in, b16_in, i16_in);

  a_out = select(a_in, b_in, ui_in);
  a2_out = select(a2_in, b2_in, ui2_in);
  a3_out = select(a3_in, b3_in, ui3_in);
  a4_out = select(a4_in, b4_in, ui4_in);
  a8_out = select(a8_in, b8_in, ui8_in);
  a16_out = select(a16_in, b16_in, ui16_in);

  OUTPUT_ONE_VEC_FLOAT(tid)
}

__kernel void remquo_f(__global float *input, __global int *input_int,
                       __global float *output, __global float *output2) {
  IN_VARS_A
  IN_VARS_B
  OUT_VARS
  uint tid = 0;
  SET_IN_TWOARGS(tid)
  int i_out;
  int2 i2_out;
  int3 i3_out;
  int4 i4_out;
  int8 i8_out;
  int16 i16_out;
  a_out = remquo(a_in, b_in, &i_out);
  a2_out = remquo(a2_in, b2_in, &i2_out);
  a3_out = remquo(a3_in, b3_in, &i3_out);
  a4_out = remquo(a4_in, b4_in, &i4_out);
  a8_out = remquo(a8_in, b8_in, &i8_out);
  a16_out = remquo(a16_in, b16_in, &i16_out);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

// possible data types for suffle and shuffle2 built-ins are vectors{2|4|8|16}
__kernel void shuffle_f(__global float *input, __global int *input_int,
                        __global float *output, __global float *output2) {
  float2 a2_in;
  float4 a4_in;
  float8 a8_in;
  float16 a16_in;
  float2 a2_out;
  float4 a4_out;
  float8 a8_out;
  float16 a16_out;

  uint2 ui2_in = {1, 0};
  uint4 ui4_in = {1, 0, 1, 0};
  uint8 ui8_in = {1, 0, 1, 0, 1, 0, 1, 0};
  uint16 ui16_in = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0};
  uint tid = 0;

  a2_in.s0 = input[tid];
  a2_in.s1 = input[tid + 1];
  a4_in.s01 = a2_in;
  a4_in.s2 = input[tid + 2];
  a4_in.s3 = input[tid + 3];
  a8_in.lo = a4_in;
  a8_in.s4 = input[tid + 4];
  a8_in.s5 = input[tid + 5];
  a8_in.s6 = input[tid + 6];
  a8_in.s7 = input[tid + 7];
  a16_in.lo = a8_in;
  a16_in.s8 = input[tid + 8];
  a16_in.s9 = input[tid + 9];
  a16_in.sA = input[tid + 10];
  a16_in.sB = input[tid + 11];
  a16_in.sC = input[tid + 12];
  a16_in.sD = input[tid + 13];
  a16_in.sE = input[tid + 14];
  a16_in.sF = input[tid + 15];

  a2_out = shuffle(a2_in, ui2_in);
  a2_out = shuffle(a4_in, ui2_in);
  a2_out = shuffle(a8_in, ui2_in);
  a2_out = shuffle(a16_in, ui2_in);
  a4_out = shuffle(a2_in, ui4_in);
  a4_out = shuffle(a4_in, ui4_in);
  a4_out = shuffle(a8_in, ui4_in);
  a4_out = shuffle(a16_in, ui4_in);
  a8_out = shuffle(a2_in, ui8_in);
  a8_out = shuffle(a4_in, ui8_in);
  a8_out = shuffle(a8_in, ui8_in);
  a8_out = shuffle(a16_in, ui8_in);
  a16_out = shuffle(a2_in, ui16_in);
  a16_out = shuffle(a4_in, ui16_in);
  a16_out = shuffle(a8_in, ui16_in);
  a16_out = shuffle(a16_in, ui16_in);

  output[tid + 1] = a2_out.s0;
  output[tid + 2] = a2_out.s1;
  output[tid + 6] = a4_out.s0;
  output[tid + 7] = a4_out.s1;
  output[tid + 8] = a4_out.s2;
  output[tid + 9] = a4_out.s3;
  output[tid + 10] = a8_out.s0;
  output[tid + 11] = a8_out.s1;
  output[tid + 12] = a8_out.s2;
  output[tid + 13] = a8_out.s3;
  output[tid + 14] = a8_out.s4;
  output[tid + 15] = a8_out.s5;
  output[tid + 16] = a8_out.s6;
  output[tid + 17] = a8_out.s7;
  output[tid + 18] = a16_out.s0;
  output[tid + 19] = a16_out.s1;
  output[tid + 20] = a16_out.s2;
  output[tid + 21] = a16_out.s3;
  output[tid + 22] = a16_out.s4;
  output[tid + 23] = a16_out.s5;
  output[tid + 24] = a16_out.s6;
  output[tid + 25] = a16_out.s7;
  output[tid + 26] = a16_out.s8;
  output[tid + 27] = a16_out.s9;
  output[tid + 28] = a16_out.sA;
  output[tid + 29] = a16_out.sB;
  output[tid + 30] = a16_out.sC;
  output[tid + 31] = a16_out.sD;
  output[tid + 32] = a16_out.sE;
  output[tid + 33] = a16_out.sF;
}

__kernel void shuffle2_f(__global float *input, __global int *input_int,
                         __global float *output, __global float *output2) {
  float2 b2_in;
  float4 b4_in;
  float8 b8_in;
  float16 b16_in;
  float2 a2_in;
  float4 a4_in;
  float8 a8_in;
  float16 a16_in;
  float2 a2_out;
  float4 a4_out;
  float8 a8_out;
  float16 a16_out;

  uint2 ui2_in = {1, 0};
  uint4 ui4_in = {1, 0, 1, 0};
  uint8 ui8_in = {1, 0, 1, 0, 1, 0, 1, 0};
  uint16 ui16_in = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0};
  uint tid = 0;

  a2_in.s0 = input[tid];
  a2_in.s1 = input[tid + 1];
  a4_in.s01 = a2_in;
  a4_in.s2 = input[tid + 2];
  a4_in.s3 = input[tid + 3];
  a8_in.lo = a4_in;
  a8_in.s4 = input[tid + 4];
  a8_in.s5 = input[tid + 5];
  a8_in.s6 = input[tid + 6];
  a8_in.s7 = input[tid + 7];
  a16_in.lo = a8_in;
  a16_in.s8 = input[tid + 8];
  a16_in.s9 = input[tid + 9];
  a16_in.sA = input[tid + 10];
  a16_in.sB = input[tid + 11];
  a16_in.sC = input[tid + 12];
  a16_in.sD = input[tid + 13];
  a16_in.sE = input[tid + 14];
  a16_in.sF = input[tid + 15];

  b2_in = a2_in;
  b4_in = a4_in;
  b8_in = a8_in;
  b16_in = a16_in;

  a2_out = shuffle2(a2_in, b2_in, ui2_in);
  a2_out = shuffle2(a4_in, b4_in, ui2_in);
  a2_out = shuffle2(a8_in, b8_in, ui2_in);
  a2_out = shuffle2(a16_in, b16_in, ui2_in);
  a4_out = shuffle2(a2_in, b2_in, ui4_in);
  a4_out = shuffle2(a4_in, b4_in, ui4_in);
  a4_out = shuffle2(a8_in, b8_in, ui4_in);
  a4_out = shuffle2(a16_in, b16_in, ui4_in);
  a8_out = shuffle2(a2_in, b2_in, ui8_in);
  a8_out = shuffle2(a4_in, b4_in, ui8_in);
  a8_out = shuffle2(a8_in, b8_in, ui8_in);
  a8_out = shuffle2(a16_in, b16_in, ui8_in);
  a16_out = shuffle2(a2_in, b2_in, ui16_in);
  a16_out = shuffle2(a4_in, b4_in, ui16_in);
  a16_out = shuffle2(a8_in, b8_in, ui16_in);
  a16_out = shuffle2(a16_in, b16_in, ui16_in);

  output[tid + 1] = a2_out.s0;
  output[tid + 2] = a2_out.s1;
  output[tid + 6] = a4_out.s0;
  output[tid + 7] = a4_out.s1;
  output[tid + 8] = a4_out.s2;
  output[tid + 9] = a4_out.s3;
  output[tid + 10] = a8_out.s0;
  output[tid + 11] = a8_out.s1;
  output[tid + 12] = a8_out.s2;
  output[tid + 13] = a8_out.s3;
  output[tid + 14] = a8_out.s4;
  output[tid + 15] = a8_out.s5;
  output[tid + 16] = a8_out.s6;
  output[tid + 17] = a8_out.s7;
  output[tid + 18] = a16_out.s0;
  output[tid + 19] = a16_out.s1;
  output[tid + 20] = a16_out.s2;
  output[tid + 21] = a16_out.s3;
  output[tid + 22] = a16_out.s4;
  output[tid + 23] = a16_out.s5;
  output[tid + 24] = a16_out.s6;
  output[tid + 25] = a16_out.s7;
  output[tid + 26] = a16_out.s8;
  output[tid + 27] = a16_out.s9;
  output[tid + 28] = a16_out.sA;
  output[tid + 29] = a16_out.sB;
  output[tid + 30] = a16_out.sC;
  output[tid + 31] = a16_out.sD;
  output[tid + 32] = a16_out.sE;
  output[tid + 33] = a16_out.sF;
}
