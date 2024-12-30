#pragma OPENCL EXTENSION cl_khr_fp16 : enable

#define CONCAT(a, b) a##b
#define VTYPE(type, size) CONCAT(type, size)

typedef VTYPE(TYPE, 4) TYPE4;

__kernel void test(__global int *out) {
  TYPE4 x = {1.0, 2.0, 3.0, 4.0};
  TYPE4 y = {5.0, 6.0, 7.0, 8.0};

  out[0] = all(cross(x, y) == (TYPE4)(-4.0, 8.0, -4.0, 0.));
  out[1] = dot(x, y) == 70;
  out[2] = distance(x, y) == 8;
  out[3] = length(x) == sqrt((TYPE)30);
  TYPE4 z = {1.0, 1.0, 1.0, 1.0};
  out[4] = all(normalize(z) == (TYPE4)(0.5, 0.5, 0.5, 0.5));
  TYPE w = {65504, 1.0, 1.0, 1.0};
  out[5] = isfinite(length(w));
}
