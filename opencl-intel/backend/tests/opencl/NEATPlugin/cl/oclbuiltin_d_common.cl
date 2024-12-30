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

File Name:  oclbuiltin_d.cl


\*****************************************************************************/

#include "oclbuiltin_d.h"

KERNEL_BI_THREEARGS(
    clamp) // gentype clamp (gentype x, gentype minval, gentype maxval)

// gentype clamp (gentype x, sgentype minval, sgentype maxval)
__kernel void clamp_s_d(__global double *input, __global int *input_int,
                        __global double *output, __global double *output2) {
  IN_VARS_A
  double b_in, c_in;
  OUT_VARS
  uint tid = 0;
  SET_IN_ONEARG(tid)
  b_in = 0.25; // set minval
  c_in = 0.55; // set maxval
  a_out = clamp(a_in, b_in, c_in);
  a2_out = clamp(a2_in, b_in, c_in);
  a3_out = clamp(a3_in, b_in, c_in);
  a4_out = clamp(a4_in, b_in, c_in);
  a8_out = clamp(a8_in, b_in, c_in);
  a16_out = clamp(a16_in, b_in, c_in);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

KERNEL_BI_MINMAX(min)
KERNEL_BI_MINMAX(max)

__kernel void
step_s_d(__global double *input, __global int *input_int,
         __global double *output,
         __global double *output2) // gentypef step (double edge, gentypef x)
{
  IN_VARS_A
  OUT_VARS
  uint tid = 0;
  double edge = 0.5;
  SET_IN_ONEARG(tid)
  a_out = step(edge, a_in);
  a2_out = step(edge, a2_in);
  a3_out = step(edge, a3_in);
  a4_out = step(edge, a4_in);
  a8_out = step(edge, a8_in);
  a16_out = step(edge, a16_in);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

KERNEL_BI_THREEARGS(
    smoothstep) // gentype smoothstep (gentype edge0,gentype edge1,gentype x)

__kernel void smoothstep_s_d(
    __global double *input, __global int *input_int, __global double *output,
    __global double
        *output2) // gentype smoothstep (gentype edge0,gentype edge1,gentype x)
{
  IN_VARS_A
  OUT_VARS
  uint tid = 0;
  double edge0 = 0.25;
  double edge1 = 0.55;
  SET_IN_ONEARG(tid)
  a_out = smoothstep(edge0, edge1, a_in);
  a2_out = smoothstep(edge0, edge1, a2_in);
  a3_out = smoothstep(edge0, edge1, a3_in);
  a4_out = smoothstep(edge0, edge1, a4_in);
  a8_out = smoothstep(edge0, edge1, a8_in);
  a16_out = smoothstep(edge0, edge1, a16_in);
  OUTPUT_ONE_VEC_FLOAT(tid)
}

KERNEL_BI_THREEARGS(mix) // gentype mix (gentype x,gentype y, gentype a)

__kernel void mix_s_d(
    __global double *input, __global int *input_int, __global double *output,
    __global double *output2) // gentypef mix (gentypef x,gentypef y, double a)
{
  IN_VARS_A
  IN_VARS_B
  double c_in = 0.5;
  OUT_VARS
  uint tid = 0;
  a2_out = mix(a2_in, b2_in, c_in);
  a3_out = mix(a3_in, b3_in, c_in);
  a4_out = mix(a4_in, b4_in, c_in);
  a8_out = mix(a8_in, b8_in, c_in);
  a16_out = mix(a16_in, b16_in, c_in);
  OUTPUT_ONE_VEC_FLOAT(tid)
}
