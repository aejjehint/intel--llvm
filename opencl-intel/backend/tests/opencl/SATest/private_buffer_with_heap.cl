void foo1(__global int *data_g, int lid) {
  __private int temp[1024 * 1024];
  for (int i = 0; i < 32; i++) {
    if (i == lid)
      temp[i] = 0;
    else
      temp[i] = i;
  }
  data_g[lid] += temp[lid];
}

void foo2(__global int *data_g, int lid) {
  __private int temp1[1024 * 1024];
  foo1(data_g, lid);
  __private int temp2[1024 * 4];
  foo1(data_g, lid);
}

__kernel void test(__global int *data_g) {
  __private int temp_p[1024 * 1024];

  int lid = get_local_id(0);
  for (int i = 0; i < 32; i++) {
    if (i == lid)
      temp_p[i] = i;
    else
      temp_p[i] = 0;
  }
  data_g[lid] = temp_p[lid];
  foo2(data_g, lid);
  foo2(data_g, lid);
}
