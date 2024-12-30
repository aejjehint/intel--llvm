#define CONCAT(a, b) a##b
#define VTYPE(type, size) CONCAT(type, size)

typedef VTYPE(TYPE, 4) TYPE4;
typedef VTYPE(ITYPE, 4) ITYPE4;
typedef VTYPE(UTYPE, 4) UTYPE4;

__kernel void test(__global int *out) {
  // input is greater than 0.
  TYPE4 base = {1, 2, 3, 4};
  TYPE4 insert = {1, 2, 3, 4};
  TYPE4 res1 = bitfield_insert(base, insert, 2, 4);
  ITYPE4 res2 = bitfield_extract_signed(base, 2, 4);
  UTYPE4 res3 = bitfield_extract_unsigned(base, 2, 4);
  TYPE4 res4 = bit_reverse(base);
  out[0] = res1.s0 == 5 && res1.s1 == 10 && res1.s2 == 15 && res1.s3 == 16;
  out[1] = res2.s0 == 0 && res2.s1 == 0 && res2.s2 == 0 && res2.s3 == 1;
  out[2] = res3.s0 == 0 && res3.s1 == 0 && res3.s2 == 0 && res3.s3 == 1;
  out[3] = res4.s0 == -128 && res4.s1 == 64 && res4.s2 == -64 && res4.s3 == 32;
  // input is less than 0.
  base = (TYPE4)(-1, -2, -3, -4);
  insert = (TYPE4)(-1, -2, -3, -4);
  res1 = bitfield_insert(base, insert, 2, 4);
  res2 = bitfield_extract_signed(base, 2, 4);
  res3 = bitfield_extract_unsigned(base, 2, 4);
  res4 = bit_reverse(base);
  out[0] &= res1.s0 == -1 && res1.s1 == -6 && res1.s2 == -11 && res1.s3 == -16;
  out[1] &= res2.s0 == -1 && res2.s1 == -1 && res2.s2 == -1 && res2.s3 == -1;
  out[2] &= res3.s0 == 15 && res3.s1 == 15 && res3.s2 == 15 && res3.s3 == 15;
  out[3] &= res4.s0 == -1 && res4.s1 == 127 && res4.s2 == -65 && res4.s3 == 63;
}
