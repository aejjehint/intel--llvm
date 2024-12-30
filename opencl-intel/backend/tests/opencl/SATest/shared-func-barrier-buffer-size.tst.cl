__attribute__((noinline)) void foo(__global int *x, int s) {
  int tmp[1024 * 64];
  int gid = get_global_id(0);
  s += x[gid];
  barrier(CLK_LOCAL_MEM_FENCE);
  x[gid] = s;
  barrier(CLK_LOCAL_MEM_FENCE);
  tmp[gid] = s;

  int sglid = get_sub_group_local_id();
  x[gid] += sub_group_reduce_add(x[sglid]);
}

__attribute__((intel_reqd_sub_group_size(64)))
__kernel void k(__global int *x) {
  foo(x, 0);
}
