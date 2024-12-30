kernel void test(global TYPE *base, global TYPE *insert, global TYPE *dst) {
  size_t i = get_global_id(0);
  dst[i] = bitfield_insert(base[i], insert[i], 4, 5) +
           bitfield_extract_signed(base[i], 4, 5) +
           bitfield_extract_unsigned(base[i], 4, 5) + bit_reverse(base[i]);
#ifdef MASKED
  // Add subgroup call in order to enable masked vectorized kernel.
  dst[i] += get_sub_group_size();
#endif
}
