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

KERNEL_BI_ONEARG(exp)
KERNEL_BI_ONEARG(exp2)
KERNEL_BI_ONEARG(exp10)
KERNEL_BI_ONEARG(expm1)
KERNEL_BI_ONEARG(log)
KERNEL_BI_ONEARG(log2)
KERNEL_BI_ONEARG(log10)
KERNEL_BI_ONEARG(log1p)
KERNEL_BI_ONEARG(logb)

KERNEL_BI_ONEARG(ceil)

KERNEL_BI_ONEARG(sqrt)
KERNEL_BI_ONEARG(rsqrt)
KERNEL_BI_ONEARG(fabs)

KERNEL_BI_ONEARG(radians)
KERNEL_BI_ONEARG(degrees)
KERNEL_BI_ONEARG(sign)
KERNEL_BI_ONEARG(floor)

KERNEL_BI_ONEARG(rint)
KERNEL_BI_ONEARG(round)
KERNEL_BI_ONEARG(trunc)
KERNEL_BI_ONEARG(cbrt)

KERNEL_BI_ONEARG(lgamma)
