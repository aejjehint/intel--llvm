// Low=-4, High=5, Low ugt High
kernel void test_add_ge(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 >= gid + 4)
    dst[gid] = gid;
}

kernel void test_add_gt(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 > gid + 4)
    dst[gid] = gid;
}

kernel void test_add_le(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 <= gid + 4)
    dst[gid] = gid;
}

kernel void test_add_lt(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 < gid + 4)
    dst[gid] = gid;
}

// Low = 4, High = 13, Low ult High
kernel void test_sub_ge(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 >= gid - 4)
    dst[gid] = gid;
}

kernel void test_sub_gt(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 > gid - 4)
    dst[gid] = gid;
}

kernel void test_sub_le(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 <= gid - 4)
    dst[gid] = gid;
}

kernel void test_sub_lt(global ulong *dst) {
  size_t gid = get_global_id(0);
  if (9 < gid - 4)
    dst[gid] = gid;
}
