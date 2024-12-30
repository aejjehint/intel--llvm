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

KERNEL_BI_GEOM_TWOARGS(dot)

KERNEL_BI_NORMALIZE(normalize)
KERNEL_BI_NORMALIZE(fast_normalize)

__kernel void
cross_f(__global float *input, __global int *input_int, __global float *output,
        __global float *output2) // gentypef step (float edge, gentypef x)
{
  float3 a3_in, b3_in, a3_out;
  float4 a4_in, b4_in, a4_out;
  uint tid = 0;
  a3_in.s0 = input[tid];
  a3_in.s1 = input[tid + 1];
  a3_in.s2 = input[tid + 2];
  a4_in.s012 = a3_in;
  a4_in.s3 = input[tid + 3];
  a3_out = cross(a3_in, b3_in);
  a4_out = cross(a4_in, b4_in);
  output[tid] = a3_out.s0;
  output[tid + 1] = a3_out.s1;
  output[tid + 2] = a3_out.s2;
  output[tid + 3] = a4_out.s0;
  output[tid + 4] = a4_out.s1;
  output[tid + 5] = a4_out.s2;
  output[tid + 6] = a4_out.s3;
}

KERNEL_BI_GEOM_ONEARG(length)
KERNEL_BI_GEOM_ONEARG(fast_length)
KERNEL_BI_GEOM_TWOARGS(distance)
KERNEL_BI_GEOM_TWOARGS(fast_distance)
