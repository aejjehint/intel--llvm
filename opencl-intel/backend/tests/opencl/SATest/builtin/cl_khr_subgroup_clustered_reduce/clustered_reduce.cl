__attribute__((intel_reqd_sub_group_size(8))) kernel void
test(global int *out1, global float *out2, global int *out3, global int *out4,
     global int *in1, global float *in2, uint cluster_size) {
  int sglid = get_sub_group_local_id();
  switch (cluster_size) {
  case 2:
    out1[sglid] = sub_group_clustered_reduce_add(in1[sglid], 2);
    out2[sglid] = sub_group_clustered_reduce_max(in2[sglid], 2);
    out3[sglid] = sub_group_clustered_reduce_and(in1[sglid], 2);
    out4[sglid] = sub_group_clustered_reduce_logical_xor(in1[sglid], 2);
    break;
  case 4:
    out1[sglid] = sub_group_clustered_reduce_add(in1[sglid], 4);
    out2[sglid] = sub_group_clustered_reduce_max(in2[sglid], 4);
    out3[sglid] = sub_group_clustered_reduce_and(in1[sglid], 4);
    out4[sglid] = sub_group_clustered_reduce_logical_xor(in1[sglid], 4);
    break;
  default:
    out1[sglid] = sub_group_clustered_reduce_add(in1[sglid], 1);
    out2[sglid] = sub_group_clustered_reduce_max(in2[sglid], 1);
    out3[sglid] = sub_group_clustered_reduce_and(in1[sglid], 1);
    out4[sglid] = sub_group_clustered_reduce_logical_xor(in1[sglid], 1);
  }
}
