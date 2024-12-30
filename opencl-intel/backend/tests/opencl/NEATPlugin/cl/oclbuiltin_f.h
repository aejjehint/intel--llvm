//
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
//

#define IN_VARS_A                                                              \
  float a_in;                                                                  \
  float2 a2_in;                                                                \
  float3 a3_in;                                                                \
  float4 a4_in;                                                                \
  float8 a8_in;                                                                \
  float16 a16_in;
#define IN_VARS_B                                                              \
  float b_in;                                                                  \
  float2 b2_in;                                                                \
  float3 b3_in;                                                                \
  float4 b4_in;                                                                \
  float8 b8_in;                                                                \
  float16 b16_in;
#define IN_VARS_C                                                              \
  float c_in;                                                                  \
  float2 c2_in;                                                                \
  float3 c3_in;                                                                \
  float4 c4_in;                                                                \
  float8 c8_in;                                                                \
  float16 c16_in;

#define OUT_VARS                                                               \
  float a_out;                                                                 \
  float2 a2_out;                                                               \
  float3 a3_out;                                                               \
  float4 a4_out;                                                               \
  float8 a8_out;                                                               \
  float16 a16_out;

#define SET_IN_ONEARG(_idx)                                                    \
  a_in = input[_idx];                                                          \
  a2_in.s0 = a_in;                                                             \
  a2_in.s1 = input[_idx + 1];                                                  \
  a3_in.s01 = a2_in;                                                           \
  a3_in.s2 = input[_idx + 2];                                                  \
  a4_in.s012 = a3_in;                                                          \
  a4_in.s3 = input[_idx + 3];                                                  \
  a8_in.lo = a4_in;                                                            \
  a8_in.s4 = input[_idx + 4];                                                  \
  a8_in.s5 = input[_idx + 5];                                                  \
  a8_in.s6 = input[_idx + 6];                                                  \
  a8_in.s7 = input[_idx + 7];                                                  \
  a16_in.lo = a8_in;                                                           \
  a16_in.s8 = input[_idx + 8];                                                 \
  a16_in.s9 = input[_idx + 9];                                                 \
  a16_in.sA = input[_idx + 10];                                                \
  a16_in.sB = input[_idx + 11];                                                \
  a16_in.sC = input[_idx + 12];                                                \
  a16_in.sD = input[_idx + 13];                                                \
  a16_in.sE = input[_idx + 14];                                                \
  a16_in.sF = input[_idx + 15];

#define CALL_BI_ONEARG(_func)                                                  \
  a_out = _func(a_in);                                                         \
  a2_out = _func(a2_in);                                                       \
  a3_out = _func(a3_in);                                                       \
  a4_out = _func(a4_in);                                                       \
  a8_out = _func(a8_in);                                                       \
  a16_out = _func(a16_in);

#define OUTPUT_ONE_VEC_FLOAT_UPTO_4(_idx)                                      \
  output[_idx] = a_out;                                                        \
  output[_idx + 1] = a2_out.s0;                                                \
  output[_idx + 2] = a2_out.s1;                                                \
  output[_idx + 3] = a3_out.s0;                                                \
  output[_idx + 4] = a3_out.s1;                                                \
  output[_idx + 5] = a3_out.s2;                                                \
  output[_idx + 6] = a4_out.s0;                                                \
  output[_idx + 7] = a4_out.s1;                                                \
  output[_idx + 8] = a4_out.s2;                                                \
  output[_idx + 9] = a4_out.s3;

#define OUTPUT_ONE_VEC_FLOAT(_idx)                                             \
  OUTPUT_ONE_VEC_FLOAT_UPTO_4(_idx)                                            \
  output[_idx + 10] = a8_out.s0;                                               \
  output[_idx + 11] = a8_out.s1;                                               \
  output[_idx + 12] = a8_out.s2;                                               \
  output[_idx + 13] = a8_out.s3;                                               \
  output[_idx + 14] = a8_out.s4;                                               \
  output[_idx + 15] = a8_out.s5;                                               \
  output[_idx + 16] = a8_out.s6;                                               \
  output[_idx + 17] = a8_out.s7;                                               \
  output[_idx + 18] = a16_out.s0;                                              \
  output[_idx + 19] = a16_out.s1;                                              \
  output[_idx + 20] = a16_out.s2;                                              \
  output[_idx + 21] = a16_out.s3;                                              \
  output[_idx + 22] = a16_out.s4;                                              \
  output[_idx + 23] = a16_out.s5;                                              \
  output[_idx + 24] = a16_out.s6;                                              \
  output[_idx + 25] = a16_out.s7;                                              \
  output[_idx + 26] = a16_out.s8;                                              \
  output[_idx + 27] = a16_out.s9;                                              \
  output[_idx + 28] = a16_out.sA;                                              \
  output[_idx + 29] = a16_out.sB;                                              \
  output[_idx + 30] = a16_out.sC;                                              \
  output[_idx + 31] = a16_out.sD;                                              \
  output[_idx + 32] = a16_out.sE;                                              \
  output[_idx + 33] = a16_out.sF;

#define KERNEL_BI_ONEARG(_func)                                                \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    CALL_BI_ONEARG(_func)                                                      \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

// the second input argument of function is a copy of the first argument
#define SET_IN_TWOARGS(_idx)                                                   \
  SET_IN_ONEARG(_idx);                                                         \
  b_in = a_in;                                                                 \
  b2_in = a2_in;                                                               \
  b3_in = a3_in;                                                               \
  b4_in = a4_in;                                                               \
  b8_in = a8_in;                                                               \
  b16_in = a16_in;

#define CALL_BI_TWOARGS(_func)                                                 \
  a_out = _func(a_in, b_in);                                                   \
  a2_out = _func(a2_in, b2_in);                                                \
  a3_out = _func(a3_in, b3_in);                                                \
  a4_out = _func(a4_in, b4_in);                                                \
  a8_out = _func(a8_in, b8_in);                                                \
  a16_out = _func(a16_in, b16_in);

#define KERNEL_BI_TWOARGS(_func)                                               \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    IN_VARS_B                                                                  \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_TWOARGS(tid)                                                        \
    CALL_BI_TWOARGS(_func)                                                     \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

// the second input argument of function is a copy of the first argument
#define SET_IN_THREEARGS(_idx)                                                 \
  SET_IN_TWOARGS(_idx);                                                        \
  c_in = a_in;                                                                 \
  c2_in = a2_in;                                                               \
  c3_in = a3_in;                                                               \
  c4_in = a4_in;                                                               \
  c8_in = a8_in;                                                               \
  c16_in = a16_in;

#define CALL_BI_THREEARGS(_func)                                               \
  a_out = _func(a_in, b_in, c_in);                                             \
  a2_out = _func(a2_in, b2_in, c2_in);                                         \
  a3_out = _func(a3_in, b3_in, c3_in);                                         \
  a4_out = _func(a4_in, b4_in, c4_in);                                         \
  a8_out = _func(a8_in, b8_in, c8_in);                                         \
  a16_out = _func(a16_in, b16_in, c16_in);

#define KERNEL_BI_THREEARGS(_func)                                             \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    IN_VARS_B                                                                  \
    IN_VARS_C                                                                  \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_THREEARGS(tid)                                                      \
    CALL_BI_THREEARGS(_func)                                                   \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

#define KERNEL_BI_MINMAX(_func)                                                \
  __kernel void _func##_s_f(__global float *input, __global int *input_int,    \
                            __global float *output, __global float *output2) { \
    IN_VARS_A                                                                  \
    OUT_VARS                                                                   \
    float b_in = 0.5;                                                          \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    a2_out = _func(a2_in, b_in);                                               \
    a3_out = _func(a3_in, b_in);                                               \
    a4_out = _func(a4_in, b_in);                                               \
    a8_out = _func(a8_in, b_in);                                               \
    a16_out = _func(a16_in, b_in);                                             \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

#define KERNEL_BI_GEOM_ONEARG(_func)                                           \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    float a_in;                                                                \
    float2 a2_in;                                                              \
    float3 a3_in;                                                              \
    float4 a4_in;                                                              \
    uint tid = 0;                                                              \
    a_in = input[tid];                                                         \
    a2_in.s0 = a_in;                                                           \
    a2_in.s1 = input[tid + 1];                                                 \
    a3_in.s01 = a2_in;                                                         \
    a3_in.s2 = input[tid + 2];                                                 \
    a4_in.s012 = a3_in;                                                        \
    a4_in.s3 = input[tid + 3];                                                 \
    output[tid] = _func(a_in);                                                 \
    output[tid + 1] = _func(a2_in);                                            \
    output[tid + 2] = _func(a3_in);                                            \
    output[tid + 3] = _func(a4_in);                                            \
  }

#define KERNEL_BI_GEOM_TWOARGS(_func)                                          \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    float a_in;                                                                \
    float2 a2_in;                                                              \
    float3 a3_in;                                                              \
    float4 a4_in;                                                              \
    float b_in;                                                                \
    float2 b2_in;                                                              \
    float3 b3_in;                                                              \
    float4 b4_in;                                                              \
    uint tid = 0;                                                              \
    a_in = input[tid];                                                         \
    a2_in.s0 = a_in;                                                           \
    a2_in.s1 = input[tid + 1];                                                 \
    a3_in.s01 = a2_in;                                                         \
    a3_in.s2 = input[tid + 2];                                                 \
    a4_in.s012 = a3_in;                                                        \
    a4_in.s3 = input[tid + 3];                                                 \
    b_in = a_in;                                                               \
    b2_in = a2_in;                                                             \
    b3_in = a3_in;                                                             \
    b4_in = a4_in;                                                             \
    output[tid] = _func(a_in, b_in);                                           \
    output[tid + 1] = _func(a2_in, b2_in);                                     \
    output[tid + 2] = _func(a3_in, b3_in);                                     \
    output[tid + 3] = _func(a4_in, b4_in);                                     \
  }

#define KERNEL_BI_NORMALIZE(_func)                                             \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    float a_in;                                                                \
    float2 a2_in;                                                              \
    float3 a3_in;                                                              \
    float4 a4_in;                                                              \
    float a_out;                                                               \
    float2 a2_out;                                                             \
    float3 a3_out;                                                             \
    float4 a4_out;                                                             \
    uint tid = 0;                                                              \
    a_in = input[tid];                                                         \
    a2_in.s0 = a_in;                                                           \
    a2_in.s1 = input[tid + 1];                                                 \
    a3_in.s01 = a2_in;                                                         \
    a3_in.s2 = input[tid + 2];                                                 \
    a4_in.s012 = a3_in;                                                        \
    a4_in.s3 = input[tid + 3];                                                 \
    a_out = _func(a_in);                                                       \
    a2_out = _func(a2_in);                                                     \
    a3_out = _func(a3_in);                                                     \
    a4_out = _func(a4_in);                                                     \
    OUTPUT_ONE_VEC_FLOAT_UPTO_4(tid)                                           \
  }

#define KERNEL_BI_SINGLE_POW(_func)                                            \
  __kernel void _func##_s_f(__global float *input, __global int *input_int,    \
                            __global float *output, __global float *output2) { \
    IN_VARS_A                                                                  \
    int i_in = 3;                                                              \
    int2 i2_in = 3;                                                            \
    int3 i3_in = 3;                                                            \
    int4 i4_in = 3;                                                            \
    int8 i8_in = 3;                                                            \
    int16 i16_in = 3;                                                          \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    a_out = _func(a_in, i_in);                                                 \
    a2_out = _func(a2_in, i2_in);                                              \
    a3_out = _func(a3_in, i3_in);                                              \
    a4_out = _func(a4_in, i4_in);                                              \
    a8_out = _func(a8_in, i8_in);                                              \
    a16_out = _func(a16_in, i16_in);                                           \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

#define KERNEL_BI_SINGLE_LDEXP(_func)                                          \
  __kernel void _func##_s_f(__global float *input, __global int *input_int,    \
                            __global float *output, __global float *output2) { \
    IN_VARS_A                                                                  \
    int i_in = 3;                                                              \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    a_out = _func(a_in, i_in);                                                 \
    a2_out = _func(a2_in, i_in);                                               \
    a3_out = _func(a3_in, i_in);                                               \
    a4_out = _func(a4_in, i_in);                                               \
    a8_out = _func(a8_in, i_in);                                               \
    a16_out = _func(a16_in, i_in);                                             \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

#define KERNEL_BI_FOUT_FIN_IIN(_func)                                          \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    int i_in;                                                                  \
    int2 i2_in;                                                                \
    int3 i3_in;                                                                \
    int4 i4_in;                                                                \
    int8 i8_in;                                                                \
    int16 i16_in;                                                              \
    OUT_VARS                                                                   \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    i_in = input_int[tid];                                                     \
    i2_in.s0 = i_in;                                                           \
    i2_in.s1 = input_int[tid + 1];                                             \
    i3_in.s01 = i2_in;                                                         \
    i3_in.s2 = input_int[tid + 2];                                             \
    i4_in.s012 = i3_in;                                                        \
    i4_in.s3 = input_int[tid + 3];                                             \
    i8_in.lo = i4_in;                                                          \
    i8_in.s4 = input_int[tid + 4];                                             \
    i8_in.s5 = input_int[tid + 5];                                             \
    i8_in.s6 = input_int[tid + 6];                                             \
    i8_in.s7 = input_int[tid + 7];                                             \
    i16_in.lo = i8_in;                                                         \
    i16_in.s8 = input_int[tid + 8];                                            \
    i16_in.s9 = input_int[tid + 9];                                            \
    i16_in.sA = input_int[tid + 10];                                           \
    i16_in.sB = input_int[tid + 11];                                           \
    i16_in.sC = input_int[tid + 12];                                           \
    i16_in.sD = input_int[tid + 13];                                           \
    i16_in.sE = input_int[tid + 14];                                           \
    i16_in.sF = input_int[tid + 15];                                           \
    a_out = _func(a_in, i_in);                                                 \
    a2_out = _func(a2_in, i2_in);                                              \
    a3_out = _func(a3_in, i3_in);                                              \
    a4_out = _func(a4_in, i4_in);                                              \
    a8_out = _func(a8_in, i8_in);                                              \
    a16_out = _func(a16_in, i16_in);                                           \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

#define KERNEL_BI_TWOOUTARGS(_func)                                            \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    OUT_VARS                                                                   \
    float b_out;                                                               \
    float2 b2_out;                                                             \
    float3 b3_out;                                                             \
    float4 b4_out;                                                             \
    float8 b8_out;                                                             \
    float16 b16_out;                                                           \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    a_out = _func(a_in, &b_out);                                               \
    a2_out = _func(a2_in, &b2_out);                                            \
    a3_out = _func(a3_in, &b3_out);                                            \
    a4_out = _func(a4_in, &b4_out);                                            \
    a8_out = _func(a8_in, &b8_out);                                            \
    a16_out = _func(a16_in, &b16_out);                                         \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
    output2[tid] = b_out;                                                      \
    output2[tid + 1] = b2_out.s0;                                              \
    output2[tid + 2] = b2_out.s1;                                              \
    output2[tid + 3] = b3_out.s0;                                              \
    output2[tid + 4] = b3_out.s1;                                              \
    output2[tid + 5] = b3_out.s2;                                              \
    output2[tid + 6] = b4_out.s0;                                              \
    output2[tid + 7] = b4_out.s1;                                              \
    output2[tid + 8] = b4_out.s2;                                              \
    output2[tid + 9] = b4_out.s3;                                              \
    output2[tid + 10] = b8_out.s0;                                             \
    output2[tid + 11] = b8_out.s1;                                             \
    output2[tid + 12] = b8_out.s2;                                             \
    output2[tid + 13] = b8_out.s3;                                             \
    output2[tid + 14] = b8_out.s4;                                             \
    output2[tid + 15] = b8_out.s5;                                             \
    output2[tid + 16] = b8_out.s6;                                             \
    output2[tid + 17] = b8_out.s7;                                             \
    output2[tid + 18] = b16_out.s0;                                            \
    output2[tid + 19] = b16_out.s1;                                            \
    output2[tid + 20] = b16_out.s2;                                            \
    output2[tid + 21] = b16_out.s3;                                            \
    output2[tid + 22] = b16_out.s4;                                            \
    output2[tid + 23] = b16_out.s5;                                            \
    output2[tid + 24] = b16_out.s6;                                            \
    output2[tid + 25] = b16_out.s7;                                            \
    output2[tid + 26] = b16_out.s8;                                            \
    output2[tid + 27] = b16_out.s9;                                            \
    output2[tid + 28] = b16_out.sA;                                            \
    output2[tid + 29] = b16_out.sB;                                            \
    output2[tid + 30] = b16_out.sC;                                            \
    output2[tid + 31] = b16_out.sD;                                            \
    output2[tid + 32] = b16_out.sE;                                            \
    output2[tid + 33] = b16_out.sF;                                            \
  }

#define KERNEL_BI_FREXP(_func)                                                 \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {   \
    IN_VARS_A                                                                  \
    OUT_VARS                                                                   \
    int i_out;                                                                 \
    int2 i2_out;                                                               \
    int3 i3_out;                                                               \
    int4 i4_out;                                                               \
    int8 i8_out;                                                               \
    int16 i16_out;                                                             \
    uint tid = 0;                                                              \
    SET_IN_ONEARG(tid)                                                         \
    a_out = _func(a_in, &i_out);                                               \
    a2_out = _func(a2_in, &i2_out);                                            \
    a3_out = _func(a3_in, &i3_out);                                            \
    a4_out = _func(a4_in, &i4_out);                                            \
    a8_out = _func(a8_in, &i8_out);                                            \
    a16_out = _func(a16_in, &i16_out);                                         \
    OUTPUT_ONE_VEC_FLOAT(tid)                                                  \
  }

// used for temporary disable functions
#define KERNEL_DUMMY(_func)                                                    \
  __kernel void _func##_f(__global float *input, __global int *input_int,      \
                          __global float *output, __global float *output2) {}
