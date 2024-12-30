__kernel void test(__global DSTTYPE *dst, __global SRCTYPEA *a,
                   __global SRCTYPEB *b, __global DSTTYPE *acc) {
  size_t i = get_global_id(0);
  dst[i] = DOT_ACC_SAT(a[i], b[i], acc[i]);
}
