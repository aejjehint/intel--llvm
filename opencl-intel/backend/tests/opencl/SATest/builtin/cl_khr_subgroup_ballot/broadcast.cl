#define SUB_GROUP_SIZE 4

__attribute__((intel_reqd_sub_group_size(SUB_GROUP_SIZE))) __kernel void
broadcast(__global int *out1, __global int *out2, __global int *in) {
  int gid = get_global_id(0);
  int sglid = get_sub_group_local_id();

  // Algorithm:
  // For each subgroup,
  // broadcast gid of in[gid] for the first item;
  // broadcast -gid of in[gid] for other items.
  if (sglid < 1)
    out1[gid] = sub_group_non_uniform_broadcast(gid, in[gid]);
  else
    out1[gid] = sub_group_non_uniform_broadcast(-gid, in[gid]);

  if (sglid >= 2)
    out2[gid] = sub_group_broadcast_first(in[gid]);
  else
    out2[gid] = 0;
}
