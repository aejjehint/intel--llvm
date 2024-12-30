#include "TestsHelpClasses.h"
#include "common_utils.h"
#include "test_utils.h"

extern cl_device_type gDeviceType;

class GetKernelSuggestedLocalWorkSizeKHRTest : public ::testing::Test {
protected:
  void SetUp() override {
    cl_int err = clGetPlatformIDs(1, &m_platform, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetPlatformIDs");

    err = clGetDeviceIDs(m_platform, gDeviceType, 1, &m_device, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceIDs");

    m_context = clCreateContext(nullptr, 1, &m_device, nullptr, nullptr, &err);
    ASSERT_OCL_SUCCESS(err, "clCreateContext");

    m_queue =
        clCreateCommandQueueWithProperties(m_context, m_device, nullptr, &err);
    ASSERT_OCL_SUCCESS(err, "clCreateCommandQueueWithProperties");

    // Get extension function address
    m_clGetKernelSuggestedLocalWorkSizeKHR =
        (clGetKernelSuggestedLocalWorkSizeKHR_fn)
            clGetExtensionFunctionAddressForPlatform(
                m_platform, "clGetKernelSuggestedLocalWorkSizeKHR");
    ASSERT_NE(nullptr, m_clGetKernelSuggestedLocalWorkSizeKHR)
        << "clGetExtensionFunctionAddressForPlatform("
           "\"clGetKernelSuggestedLocalWorkSizeKHR\") failed.";
  }

  void TearDown() override {
    cl_int err = CL_SUCCESS;
    if (m_queue)
      err = clReleaseCommandQueue(m_queue);
    EXPECT_OCL_SUCCESS(err, "clReleaseCommandQueue");
    if (m_context)
      err = clReleaseContext(m_context);
    EXPECT_OCL_SUCCESS(err, "clReleaseContext");
  }

protected:
  cl_platform_id m_platform = nullptr;
  cl_device_id m_device = nullptr;
  cl_context m_context = nullptr;
  cl_command_queue m_queue = nullptr;
  clGetKernelSuggestedLocalWorkSizeKHR_fn
      m_clGetKernelSuggestedLocalWorkSizeKHR = nullptr;
};

TEST_F(GetKernelSuggestedLocalWorkSizeKHRTest, invalidDeviceProgram) {
  cl_uint numComputeUnits;
  cl_int err = clGetDeviceInfo(m_device, CL_DEVICE_MAX_COMPUTE_UNITS,
                               sizeof(cl_uint), &numComputeUnits, nullptr);
  ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo CL_DEVICE_MAX_COMPUTE_UNITS");
  if (numComputeUnits < 2)
    return;

  cl_uint numDevices = 2;
  std::vector<cl_device_id> subDevices(numDevices);
  cl_uint numDevicesRet;
  std::vector<cl_device_partition_property> properties(numDevices + 2);
  properties[0] = CL_DEVICE_PARTITION_BY_COUNTS;
  for (cl_uint i = 1; i <= numDevices; ++i)
    properties[i] = 1;
  properties[numDevices + 1] = 0;
  err = clCreateSubDevices(m_device, &properties[0], numDevices, &subDevices[0],
                           &numDevicesRet);
  ASSERT_OCL_SUCCESS(err, "clCreateSubDevices");
  ASSERT_EQ(numDevices, numDevicesRet);

  cl_context context = clCreateContext(nullptr, numDevices, &subDevices[0],
                                       nullptr, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateContext");

  const char *source = "kernel void test() {}";
  cl_program program = clCreateProgramWithSource(
      context, 1, (const char **)&source, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateProgramWithSource");

  // Build program for sub-device 0.
  err = clBuildProgram(program, 1, &subDevices[0], nullptr, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clBuildProgram");
  cl_kernel kernel = clCreateKernel(program, "test", &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");

  // Create command queue for sub-device 1.
  cl_command_queue queue =
      clCreateCommandQueueWithProperties(context, subDevices[1], nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateCommandQueueWithProperties");

  size_t global_work_size[1] = {96};
  size_t suggested_local_work_size[1] = {0};

  // Return CL_INVALID_PROGRAM_EXECUTABLE if there is no successfully built
  // program executable available for kernel for the device associated with
  // command_queue.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(
      queue, kernel, 1, nullptr, global_work_size, suggested_local_work_size);
  ASSERT_EQ(err, CL_INVALID_PROGRAM_EXECUTABLE)
      << "clGetKernelSuggestedLocalWorkSizeKHR return "
         "CL_INVALID_PROGRAM_EXECUTABLE";

  err = clReleaseCommandQueue(queue);
  ASSERT_OCL_SUCCESS(err, "clReleaseCommandQueue");

  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");

  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");

  err = clReleaseContext(context);
  ASSERT_OCL_SUCCESS(err, "clReleaseContext");

  for (auto *d : subDevices) {
    err = clReleaseDevice(d);
    ASSERT_OCL_SUCCESS(err, "clReleaseDevice");
  }
}

// Negative tests that check CL_INVALID_KERNEL_ARGS, CL_INVALID_COMMAND_QUEUE,
// CL_INVALID_KERNEL, CL_INVALID_CONTEXT, CL_INVALID_WORK_DIMENSION,
// CL_INVALID_GLOBAL_WORK_SIZE and CL_INVALID_VALUE.
TEST_F(GetKernelSuggestedLocalWorkSizeKHRTest, negativeTests) {
  cl_int err = CL_SUCCESS;
  size_t globalWorkSize[1] = {96};
  size_t suggestedLocalWorkSize[1] = {0};
  const char *oclTestProgram[] = {
      "__kernel void kernel_test(__global int* pBuff)\n"
      "{\n"
      "pBuff[0] = get_local_size(0);\n"
      "}"};
  cl_program program;
  ASSERT_TRUE(BuildProgramSynch(m_context, 1, (const char **)&oclTestProgram,
                                nullptr, nullptr, &program))
      << "BuildProgramSynch failed";
  cl_kernel kernel = clCreateKernel(program, "kernel_test", &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");
  int pBuff;
  cl_mem clBuff =
      clCreateBuffer(m_context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                     sizeof(pBuff), &pBuff, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer");

  // Return CL_INVALID_KERNEL_ARGS if all argument values for kernel have not
  // been set.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(
      m_queue, kernel, 1, nullptr, globalWorkSize, suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_KERNEL_ARGS)
      << "clGetKernelSuggestedLocalWorkSizeKHR";

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &clBuff);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg");

  // Return CL_INVALID_COMMAND_QUEUE if command_queue is not a valid host
  // command-queue.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(
      (cl_command_queue)m_context, kernel, 1, nullptr, globalWorkSize,
      suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_COMMAND_QUEUE)
      << "clGetKernelSuggestedLocalWorkSizeKHR";

  // Return CL_INVALID_KERNEL if kernel is not a valid kernel object.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(m_queue, (cl_kernel)m_context, 1,
                                               nullptr, globalWorkSize,
                                               suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_KERNEL) << "clGetKernelSuggestedLocalWorkSizeKHR";

  // Return CL_INVALID_CONTEXT if context associated with kernel is not same as
  // context associated with command_queue.
  cl_context context =
      clCreateContext(nullptr, 1, &m_device, nullptr, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateContext");

  cl_command_queue queue =
      clCreateCommandQueueWithProperties(context, m_device, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateCommandQueueWithProperties");
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(
      queue, kernel, 1, nullptr, globalWorkSize, suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_CONTEXT) << "clGetKernelSuggestedLocalWorkSizeKHR";

  // Return CL_INVALID_WORK_DIMENSION if work_dim is not a valid value(i.e. a
  // value between 1 and CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS).
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(
      m_queue, kernel, 0, nullptr, globalWorkSize, suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_WORK_DIMENSION)
      << "clGetKernelSuggestedLocalWorkSizeKHR";

  // CL_INVALID_GLOBAL_WORK_SIZE if globalWorkSize is NULL or if any of the
  // values specified in globalWorkSize are 0.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(m_queue, kernel, 1, nullptr,
                                               nullptr, suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_GLOBAL_WORK_SIZE)
      << "clGetKernelSuggestedLocalWorkSizeKHR";
  size_t invalidGlobalWorkSize[1] = {0};
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(m_queue, kernel, 1, nullptr,
                                               invalidGlobalWorkSize,
                                               suggestedLocalWorkSize);
  ASSERT_EQ(err, CL_INVALID_GLOBAL_WORK_SIZE)
      << "clGetKernelSuggestedLocalWorkSizeKHR";

  // Return CL_INVALID_VALUE if suggested_local_work_size is NULL.
  err = m_clGetKernelSuggestedLocalWorkSizeKHR(m_queue, kernel, 1, nullptr,
                                               globalWorkSize, nullptr);
  ASSERT_EQ(err, CL_INVALID_VALUE) << "clGetKernelSuggestedLocalWorkSizeKHR";

  err = clReleaseCommandQueue(queue);
  ASSERT_OCL_SUCCESS(err, "clReleaseCommandQueue");

  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");

  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");

  err = clReleaseContext(context);
  ASSERT_OCL_SUCCESS(err, "clReleaseContext");
}

TEST_F(GetKernelSuggestedLocalWorkSizeKHRTest, postiveTest) {
  cl_int err = CL_SUCCESS;
  size_t globalWorkSize[1] = {1};
  size_t suggestedLocalWorkSize[1] = {0};
  const char *oclTestProgram[] = {
      "__kernel void kernel_test(__global int* pBuff)\n"
      "{\n"
      "pBuff[0] = get_local_size(0);\n"
      "}"};
  cl_program program;
  ASSERT_TRUE(BuildProgramSynch(m_context, 1, (const char **)&oclTestProgram,
                                nullptr, nullptr, &program))
      << "BuildProgramSynch failed";
  cl_kernel kernel = clCreateKernel(program, "kernel_test", &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");
  int pBuff = 0, pDstBuff = 0;
  cl_mem clBuff =
      clCreateBuffer(m_context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
                     sizeof(pBuff), &pBuff, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer");

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &clBuff);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg");

  size_t max_work_items = 0;
  clGetDeviceInfo(m_device, CL_DEVICE_MAX_WORK_GROUP_SIZE,
                  sizeof(max_work_items), &max_work_items, NULL);
  for (size_t start = 1; start < max_work_items; start += 64) {
    globalWorkSize[0] = start;
    err = m_clGetKernelSuggestedLocalWorkSizeKHR(
        m_queue, kernel, 1, nullptr, globalWorkSize, suggestedLocalWorkSize);
    ASSERT_OCL_SUCCESS(err, "clGetKernelSuggestedLocalWorkSizeKHR");

    err = clEnqueueNDRangeKernel(m_queue, kernel, 1, nullptr, globalWorkSize,
                                 nullptr, 0, nullptr, nullptr);
    ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");
    err = clEnqueueReadBuffer(m_queue, clBuff, CL_TRUE, 0, sizeof(pDstBuff),
                              &pDstBuff, 0, NULL, NULL);
    ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer");
    ASSERT_EQ(pDstBuff, suggestedLocalWorkSize[0])
        << "clGetKernelSuggestedLocalWorkSizeKHR return wrong local work size";
  }

  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");

  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");
}
