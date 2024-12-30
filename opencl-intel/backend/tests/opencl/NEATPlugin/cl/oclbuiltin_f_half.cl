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

KERNEL_BI_ONEARG(half_log)
KERNEL_BI_ONEARG(half_log2)
KERNEL_BI_ONEARG(half_log10)
KERNEL_BI_ONEARG(half_exp)
KERNEL_BI_ONEARG(half_exp2)
KERNEL_BI_ONEARG(half_exp10)
KERNEL_BI_ONEARG(half_cos)
KERNEL_BI_TWOARGS(half_divide)
KERNEL_BI_TWOARGS(half_powr)
KERNEL_BI_ONEARG(half_recip)
KERNEL_BI_ONEARG(half_rsqrt)
KERNEL_BI_ONEARG(half_sin)
KERNEL_BI_ONEARG(half_sqrt)
KERNEL_BI_ONEARG(half_tan)
