// Tests for the __devicelib_exit builtin.
//

#include "TestsHelpClasses.h"
#include "bi_tests.h"
#include "common_utils.h"

#include <vector>

extern cl_device_type gDeviceType;

namespace {

const char *KERNEL_CODE_STR = "void __devicelib_exit();"
                              "__kernel void hello(__global uchar* bufOut)"
                              "{"
                              " size_t gid = get_global_id(0);"
                              " bufOut[gid] = 1;"
                              " __devicelib_exit();"
                              " bufOut[gid] = 2;"
                              "}";

} // namespace

class DeviceLibExitTest : public BITest {
protected:
  virtual void SetUp() { BITest::SetUp(); }
};

#if defined(_WIN64)
TEST_F(DeviceLibExitTest, DISABLED_DeviceLibExit) {
#else
TEST_F(DeviceLibExitTest, DeviceLibExit) {
#endif
  cl_int ret = CL_SUCCESS;

  cl_command_queue queue = createCommandQueue();

  cl_program prog = clCreateProgramWithSource(
      context, 1, (const char **)&KERNEL_CODE_STR, nullptr, &ret);
  ASSERT_OCL_SUCCESS(ret, "clCreateProgramWithSource");

  ret = clBuildProgram(prog, 1, &device, nullptr, nullptr, nullptr);
  if (ret != CL_SUCCESS) {
    char buildLog[2048];
    clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, sizeof(buildLog),
                          buildLog, nullptr);
    printf("Build Failed, log:\n %s\n", buildLog);
  }
  ASSERT_OCL_SUCCESS(ret, "clGetProgramBuildInfo");

  cl_kernel kernel = clCreateKernel(prog, "hello", &ret);
  ASSERT_OCL_SUCCESS(ret, "clCreateKernel");

  size_t dataLength = 4;
  cl_mem buffOut =
      createBuffer(sizeof(cl_uchar) * dataLength, CL_MEM_READ_WRITE);

  ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), &buffOut);
  ASSERT_OCL_SUCCESS(ret, "clSetKernelArg");

  size_t globalSize = dataLength;
  ret = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &globalSize, nullptr,
                               0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(ret, "clGetPlatformIDs");

  ret = clFinish(queue);
  ASSERT_OCL_SUCCESS(ret, "clFinish");

  std::vector<cl_uchar> buffVec(dataLength);
  ret = clEnqueueReadBuffer(queue, buffOut, CL_TRUE, 0,
                            sizeof(cl_uchar) * dataLength, buffVec.data(), 0,
                            nullptr, nullptr);
  ASSERT_OCL_SUCCESS(ret, "clEnqueueReadBuffer");

  for (size_t i = 0; i < dataLength; ++i)
    ASSERT_TRUE(buffVec[i] == 1);

  ret = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(ret, "clReleaseKernel");

  ret = clReleaseProgram(prog);
  ASSERT_OCL_SUCCESS(ret, "clReleaseProgram");
}
