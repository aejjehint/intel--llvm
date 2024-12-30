__kernel void test_atomic_compare_exchange_weak_int(__global int *lock,
                                                    __global int *desired) {
  int expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_int *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_int(__global int *lock,
                                               __global int *desired) {
  int expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_scope_int(__global int *lock,
                                                     __global int *desired) {
  int expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_int *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_int *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_int__private(__global int *lock,
                                               __global int *desired) {
  __private int expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_int *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_int__private(__global int *lock,
                                                        __global int *desired) {
  __private int expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_int__private(
    __global int *lock, __global int *desired) {
  __private int expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_uint(__global uint *lock,
                                                     __global uint *desired) {
  uint expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_uint *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_uint(__global uint *lock,
                                                __global uint *desired) {
  uint expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_scope_uint(__global uint *lock,
                                                      __global uint *desired) {
  uint expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_uint *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_uint *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_uint__private(__global uint *lock,
                                                __global uint *desired) {
  __private uint expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_uint *)lock, &expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_uint__private(
    __global uint *lock, __global uint *desired) {
  __private uint expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_uint__private(
    __global uint *lock, __global uint *desired) {
  __private uint expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_long(__global long *lock,
                                                     __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_long *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_long(__global long *lock,
                                                __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_scope_long(__global long *lock,
                                                      __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_long *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_long *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_long__private(__global long *lock,
                                                __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_long *)lock, &expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_long__private(
    __global long *lock, __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_long__private(
    __global long *lock, __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_ulong(__global ulong *lock,
                                                      __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_ulong *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_ulong(__global ulong *lock,
                                                 __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_ulong(
    __global ulong *lock, __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_ulong *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_ulong *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_ulong__private(__global ulong *lock,
                                                 __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_ulong *)lock, &expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_ulong__private(
    __global ulong *lock, __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_ulong__private(
    __global ulong *lock, __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_float(__global float *lock,
                                                      __global float *desired) {
  float expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_float *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_float(__global float *lock,
                                                 __global float *desired) {
  float expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_float(
    __global float *lock, __global float *desired) {
  float expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_float *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired =
      atomic_compare_exchange_weak((volatile atomic_float *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_float__private(__global float *lock,
                                                 __global float *desired) {
  __private float expected = 0;
  *desired =
      atomic_compare_exchange_weak((volatile atomic_float *)lock, &expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_float__private(
    __global float *lock, __global float *desired) {
  __private float expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_float__private(
    __global float *lock, __global float *desired) {
  __private float expected = 0;
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_double(__global double *lock,
                                         __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak((volatile atomic_double *)lock,
                                          &expected, 1);
}
__kernel void
test_atomic_compare_exchange_weak_explicit_double(__global double *lock,
                                                  __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_double(
    __global double *lock, __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_double__global(__global double *lock,
                                                 __global double *expected,
                                                 __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_double *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_double__global(
    __global double *lock, __global double *expected,
    __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_double__global(
    __global double *lock, __global double *expected,
    __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_weak_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_weak((volatile atomic_double *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_weak_double__private(__global double *lock,
                                                  __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak((volatile atomic_double *)lock,
                                          &expected, 1);
}
__kernel void test_atomic_compare_exchange_weak_explicit_double__private(
    __global double *lock, __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_weak_explicit_scope_double__private(
    __global double *lock, __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_weak_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_int(__global int *lock,
                                                      __global int *desired) {
  int expected = 0;
  *desired =
      atomic_compare_exchange_strong((volatile atomic_int *)lock, &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_int(__global int *lock,
                                                 __global int *desired) {
  int expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_scope_int(__global int *lock,
                                                       __global int *desired) {
  int expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired =
      atomic_compare_exchange_strong((volatile atomic_int *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_int__global(
    __global int *lock, __global int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired =
      atomic_compare_exchange_strong((volatile atomic_int *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_int__local(
    __global int *lock, __local int *expected, __global int *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_int__private(__global int *lock,
                                                 __global int *desired) {
  __private int expected = 0;
  *desired =
      atomic_compare_exchange_strong((volatile atomic_int *)lock, &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_int__private(
    __global int *lock, __global int *desired) {
  __private int expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_int__private(
    __global int *lock, __global int *desired) {
  __private int expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_int *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_uint(__global uint *lock,
                                                       __global uint *desired) {
  uint expected = 0;
  *desired = atomic_compare_exchange_strong((volatile atomic_uint *)lock,
                                            &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_uint(__global uint *lock,
                                                  __global uint *desired) {
  uint expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_uint(
    __global uint *lock, __global uint *desired) {
  uint expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired =
      atomic_compare_exchange_strong((volatile atomic_uint *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_uint__global(
    __global uint *lock, __global uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired =
      atomic_compare_exchange_strong((volatile atomic_uint *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_uint__local(
    __global uint *lock, __local uint *expected, __global uint *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_uint__private(__global uint *lock,
                                                  __global uint *desired) {
  __private uint expected = 0;
  *desired = atomic_compare_exchange_strong((volatile atomic_uint *)lock,
                                            &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_uint__private(
    __global uint *lock, __global uint *desired) {
  __private uint expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_uint__private(
    __global uint *lock, __global uint *desired) {
  __private uint expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_uint *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_long(__global long *lock,
                                                       __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_long *)lock,
                                            &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_long(__global long *lock,
                                                  __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_long(
    __global long *lock, __global long *desired) {
  long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_strong((volatile atomic_long *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_long__global(
    __global long *lock, __global long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired =
      atomic_compare_exchange_strong((volatile atomic_long *)lock, expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_long__local(
    __global long *lock, __local long *expected, __global long *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_long__private(__global long *lock,
                                                  __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_long *)lock,
                                            &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_long__private(
    __global long *lock, __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_long__private(
    __global long *lock, __global long *desired) {
  __private long expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_long *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_ulong(__global ulong *lock,
                                          __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_ulong *)lock,
                                            &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_ulong(__global ulong *lock,
                                                   __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_ulong(
    __global ulong *lock, __global ulong *desired) {
  ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_ulong *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_ulong__global(
    __global ulong *lock, __global ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_ulong *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_ulong__local(
    __global ulong *lock, __local ulong *expected, __global ulong *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_ulong__private(__global ulong *lock,
                                                   __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_ulong *)lock,
                                            &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_ulong__private(
    __global ulong *lock, __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_ulong__private(
    __global ulong *lock, __global ulong *desired) {
  __private ulong expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_ulong *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_float(__global float *lock,
                                          __global float *desired) {
  float expected = 0;
  *desired = atomic_compare_exchange_strong((volatile atomic_float *)lock,
                                            &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_float(__global float *lock,
                                                   __global float *desired) {
  float expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_float(
    __global float *lock, __global float *desired) {
  float expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong((volatile atomic_float *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_float__global(
    __global float *lock, __global float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong((volatile atomic_float *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_float__local(
    __global float *lock, __local float *expected, __global float *desired) {
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_float__private(__global float *lock,
                                                   __global float *desired) {
  __private float expected = 0;
  *desired = atomic_compare_exchange_strong((volatile atomic_float *)lock,
                                            &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_float__private(
    __global float *lock, __global float *desired) {
  __private float expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_float__private(
    __global float *lock, __global float *desired) {
  __private float expected = 0;
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_float *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_double(__global double *lock,
                                           __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_double *)lock,
                                            &expected, 1);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_double(__global double *lock,
                                                    __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_double(
    __global double *lock, __global double *desired) {
  double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_double__global(__global double *lock,
                                                   __global double *expected,
                                                   __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_double *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_double__global(
    __global double *lock, __global double *expected,
    __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_double__global(
    __global double *lock, __global double *expected,
    __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void test_atomic_compare_exchange_strong_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_double *)lock,
                                            expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void test_atomic_compare_exchange_strong_explicit_scope_double__local(
    __global double *lock, __local double *expected, __global double *desired) {
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
__kernel void
test_atomic_compare_exchange_strong_double__private(__global double *lock,
                                                    __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong((volatile atomic_double *)lock,
                                            &expected, 1);
}
__kernel void test_atomic_compare_exchange_strong_explicit_double__private(
    __global double *lock, __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_relaxed);
}
__kernel void
test_atomic_compare_exchange_strong_explicit_scope_double__private(
    __global double *lock, __global double *desired) {
  __private double expected = 0;
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable
  *desired = atomic_compare_exchange_strong_explicit(
      (volatile atomic_double *)lock, &expected, 1, memory_order_relaxed,
      memory_order_seq_cst, memory_scope_device);
}
