#pragma OPENCL EXTENSION cl_khr_fp16 : enable

__kernel void test(__global half4 *in) {
  printf("%2v4hf\n", in[0]);
  printf("%2.2v4hf\n", in[0]);

  printf("%s", "a");
  printf("%s", "bar\n");
  printf("foo\n");
  printf("%c", 'c');
  printf("%s\n", "bar");
}
