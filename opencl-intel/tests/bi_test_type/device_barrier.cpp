#include "TestsHelpClasses.h"
#include "bi_tests.h"

extern cl_device_type gDeviceType;

class RGBarrier : public BITest {
protected:
  virtual void TearDown() {
    cl_int Err;
    if (MKernel) {
      Err = clReleaseKernel(MKernel);
      EXPECT_OCL_SUCCESS(Err, "clReleaseKernel");
    }
    if (MProgram) {
      Err = clReleaseProgram(MProgram);
      EXPECT_OCL_SUCCESS(Err, "clReleaseProgram");
    }
    BITest::TearDown();
  }

  void testBody(const char *buildOptions);

  cl_program MProgram = nullptr;
  cl_kernel MKernel = nullptr;
};

#define GSIZE 32 * 8
#define LSIZE 8

static void buildProgram(cl_context Context, cl_device_id Device,
                         const char *Source[], int Count,
                         const char *BuildOptions, cl_program &Program) {
  cl_int Err;
  Program = clCreateProgramWithSource(Context, Count, Source, nullptr, &Err);
  ASSERT_OCL_SUCCESS(Err, "clCreateProgramWithSource");
  Err = clBuildProgram(Program, 1, &Device, BuildOptions, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(Err, "clBuildProgram");
}

void RGBarrier::testBody(const char *BuildOptions) {
  // Build program.
  const char *Source[] = {
      "void __attribute__((overloadable)) intel_device_barrier\n"
      "                      (cl_mem_fence_flags, memory_scope);\n"
      "bool __attribute__((overloadable)) intel_is_device_barrier_valid();\n"
      "__kernel void test(__global int *data,\n"
      "  __global int *result) {\n"
      "  int gsize = get_global_size(0);\n"
      "  int gid = get_global_id(0);\n"
      "  data[gid] = gid;\n"
      "  if(!intel_is_device_barrier_valid())\n"
      "      return;"

      "  intel_device_barrier(CLK_GLOBAL_MEM_FENCE, memory_scope_device);\n"
      "  result[gid] = data[gid] * \n"
      "            data[gsize - gid - 1];\n"

      "  intel_device_barrier(CLK_GLOBAL_MEM_FENCE, memory_scope_device);\n"
      "  if (gid < gsize / 2){\n"
      "     int temp = result[gid];\n"
      "     result[gid] = result[gsize - gid - 1];\n"
      "     result[gsize - gid - 1] = temp;"
      "  }"
      "}\n"};

  cl_command_queue Queue = createCommandQueue();

  ASSERT_NO_FATAL_FAILURE(
      buildProgram(context, device, Source, 1, BuildOptions, MProgram));

  const size_t GSize = GSIZE;
  const size_t LSize = LSIZE;

  cl_int Err;

  cl_uint Alignment = 0;
  int *Buffer = (int *)clSharedMemAllocINTEL(
      context, device, nullptr, GSIZE * sizeof(int), Alignment, &Err);
  ASSERT_OCL_SUCCESS(Err, "clSharedMemAllocINTEL");

  int *Result = (int *)clSharedMemAllocINTEL(
      context, device, nullptr, GSIZE * sizeof(int), Alignment, &Err);
  ASSERT_OCL_SUCCESS(Err, "clSharedMemAllocINTEL");

  MKernel = clCreateKernel(MProgram, "test", &Err);
  ASSERT_OCL_SUCCESS(Err, "clCreateKernel");

  Err = clSetKernelArgMemPointerINTEL(MKernel, 0, Buffer);
  ASSERT_OCL_SUCCESS(Err, "clSetKernelArgMemPointerINTEL");

  Err = clSetKernelArgMemPointerINTEL(MKernel, 1, Result);
  ASSERT_OCL_SUCCESS(Err, "clSetKernelArgMemPointerINTEL");

  size_t MaxWGCount = 0;
  Err = clGetKernelMaxConcurrentWorkGroupCountINTEL(Queue, MKernel, 1, nullptr,
                                                    &LSize, &MaxWGCount);
  ASSERT_OCL_SUCCESS(Err, "clGetKernelMaxConcurrentWorkGroupCountINTEL");
  ASSERT_TRUE(MaxWGCount >= GSize / LSize);

  cl_uint DispatchType = CL_KERNEL_EXEC_INFO_DISPATCH_TYPE_CONCURRENT_INTEL;
  Err = clSetKernelExecInfo(MKernel, CL_KERNEL_EXEC_INFO_DISPATCH_TYPE_INTEL,
                            sizeof(cl_uint), &DispatchType);
  ASSERT_OCL_SUCCESS(Err, "clSetKernelExecInfo");

  // MXCSR register contains control and status information for SIMD
  // floating-point operations, including denormals-as-zero mode (Bit 6),
  // exception mask (Bits 7-12), rounding mode (Bits 13-14) and flush-to-zero
  // mode (Bit 15). These control bits should be restored after kernel
  // execution.
  const unsigned int CSRstate = _mm_getcsr() & ~_MM_EXCEPT_MASK;
  cl_event E;
  Err = clEnqueueNDRangeKernel(Queue, MKernel, 1, nullptr, &GSize, &LSize, 0,
                               nullptr, &E);
  ASSERT_OCL_SUCCESS(Err, "clEnqueueNDRangeKernel");

  Err = clWaitForEvents(1, &E);
  ASSERT_OCL_SUCCESS(Err, "clWaitForEvents");
  EXPECT_EQ(CSRstate, _mm_getcsr() & ~_MM_EXCEPT_MASK)
      << "MXCSR register control bits are not restored";

  Err = clReleaseEvent(E);
  ASSERT_OCL_SUCCESS(Err, "clReleaseEvent");

  // Check result
  int RefInput[GSIZE];
  int RefResult[GSIZE];
  for (size_t Idx = 0; Idx < GSIZE; ++Idx) {
    RefInput[Idx] = Idx;
  }
  for (size_t Idx = 0; Idx < GSIZE; ++Idx) {
    RefResult[Idx] = RefInput[Idx] * RefInput[GSIZE - Idx - 1];
  }
  for (size_t Idx = 0; Idx < GSIZE / 2; ++Idx) {
    int Temp = RefResult[Idx];
    RefResult[Idx] = RefResult[GSIZE - Idx - 1];
    RefResult[GSIZE - Idx - 1] = Temp;
  }
  for (size_t Idx = 0; Idx < GSIZE; ++Idx) {
    ASSERT_TRUE(Result[Idx] == RefResult[Idx]);
  }

  Err = clMemBlockingFreeINTEL(context, Buffer);
  ASSERT_OCL_SUCCESS(Err, "clMemBlockingFreeINTEL");
  Err = clMemBlockingFreeINTEL(context, Result);
  ASSERT_OCL_SUCCESS(Err, "clMemBlockingFreeINTEL");
}

TEST_F(RGBarrier, DeviceBarrier) {
  ASSERT_NO_FATAL_FAILURE(testBody("-cl-std=CL2.0"));
}

TEST_F(RGBarrier, DeviceBarrierDAZ) {
  ASSERT_NO_FATAL_FAILURE(testBody("-cl-std=CL2.0 -cl-denorms-are-zero"));
}
