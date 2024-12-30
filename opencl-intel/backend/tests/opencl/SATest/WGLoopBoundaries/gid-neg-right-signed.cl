/// b that equals -10 is less than a, which is 4.

kernel void test_ge(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (-10 >= a - gid)
    dst[gid] = gid;
}

kernel void test_gt(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (-10 > a - gid)
    dst[gid] = gid;
}

/// b that equals 6 is greater than a, which is 4.
/// upper-bound = min(-2, init.upper.bound0) ---> -2
/// loop-size = upper-bound - base.gid0  ---> slt 0, loop is not active.
kernel void test_le(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (6 <= a - gid)
    dst[gid] = gid;
}

kernel void test_lt(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (6 < a - gid)
    dst[gid] = gid;
}

/// b equals a, which is 4

kernel void test_ge_aEQb(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (4 >= a - gid)
    dst[gid] = gid;
}

kernel void test_gt_aEQb(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (4 > a - gid)
    dst[gid] = gid;
}

kernel void test_le_aEQb(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (4 <= a - gid)
    dst[gid] = gid;
}

kernel void test_lt_aEQb(global ulong *dst, int a) {
  int gid = get_global_id(0);
  if (4 < a - gid)
    dst[gid] = gid;
}
