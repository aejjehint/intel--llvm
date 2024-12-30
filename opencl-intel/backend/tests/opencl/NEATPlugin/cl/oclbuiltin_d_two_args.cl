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

KERNEL_BI_TWOARGS(atan2)
KERNEL_BI_TWOARGS(atan2pi)
KERNEL_BI_TWOARGS(pow)

KERNEL_BI_TWOARGS(min)
KERNEL_BI_TWOARGS(max)
KERNEL_BI_TWOARGS(hypot)
KERNEL_BI_TWOARGS(step) // gentype step (gentype edge, gentype x)

KERNEL_BI_TWOARGS(maxmag)
KERNEL_BI_TWOARGS(minmag)
KERNEL_BI_TWOARGS(copysign)
KERNEL_BI_TWOARGS(nextafter)
KERNEL_BI_TWOARGS(fdim)
KERNEL_BI_TWOARGS(powr)
KERNEL_BI_TWOARGS(fmod)
KERNEL_BI_TWOARGS(fmin) // gentype fmin (gentype x, gentype y)
KERNEL_BI_TWOARGS(fmax) // gentype fmax (gentype x, gentype y)

KERNEL_BI_TWOARGS(remainder)
