__kernel void test(__global DSTTYPE *dst, __global SRCTYPEA *a,
                   __global SRCTYPEB *b) {
  size_t i = get_global_id(0);
  dst[i] = DOT(a[i], b[i]);
}
