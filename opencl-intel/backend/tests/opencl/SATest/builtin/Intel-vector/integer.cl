kernel void test(global TYPE *a, global TYPE *b, global TYPE *c,
                 global TYPE *dst, global UTYPE *b2, global UPTYPE *dst2) {

  size_t i = get_global_id(0);
  dst[i] = abs(a[i]) + abs_diff(a[i], b[i]) + add_sat(a[i], b[i]) +
           hadd(a[i], b[i]) + rhadd(a[i], b[i]) + clamp(a[i], b[i], c[i]) +
           clz(a[i]) + mad_hi(a[i], b[i], c[i]) + mad_sat(a[i], b[i], c[i]) +
           max(a[i], b[i]) + min(a[i], b[i]) + mul_hi(a[i], b[i]) +
           rotate(a[i], b[i]) + sub_sat(a[i], b[i]) + popcount(a[i]) +
           ctz(a[i]);

#ifndef NO_UPSAMPLE
  dst2[i] = upsample(a[i], b2[i]);
#endif

#ifdef MASKED
  // Add subgroup call in order to enable masked vectorized kernel.
  dst[i] += get_sub_group_size();
#endif
}
