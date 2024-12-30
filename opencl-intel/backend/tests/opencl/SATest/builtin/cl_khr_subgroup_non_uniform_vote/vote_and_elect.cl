__attribute__((intel_reqd_sub_group_size(4))) kernel void
test(global int *out1, global int *out2, global int *out3, global int *out4,
     global int *in1, global int *in2) {
  int gid = get_global_id(0);
  if (gid % 2) {
    out1[gid] = sub_group_elect() != 0;
    out2[gid] = sub_group_non_uniform_all(in1[gid]) != 0;
    out3[gid] = -1;
    out4[gid] = -1;
  } else {
    out1[gid] = -1;
    out2[gid] = -1;
    out3[gid] = sub_group_non_uniform_any(in1[gid]) != 0;
    out4[gid] = sub_group_non_uniform_all_equal(in2[gid]) != 0;
  }
}
