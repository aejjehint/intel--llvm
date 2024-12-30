#include "TestsHelpClasses.h"
#include "common_utils.h"
#include "cpu_dev_limits.h"
#include "tbb/global_control.h"

extern cl_device_type gDeviceType;

constexpr unsigned STACK_SIZE = 17825792;

class PrivateMemSizeTest : public ::testing::Test {
protected:
  void SetUp() override {
    cl_int err = clGetPlatformIDs(1, &platform_private, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetPlatrormIDs");

    err = clGetDeviceIDs(platform_private, gDeviceType, 1, &device_private,
                         nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceIDs");
  }

  void TearDown() override {
    if (buffer_private)
      clReleaseMemObject(buffer_private);
    if (kernel_private)
      clReleaseKernel(kernel_private);
    if (queue_private)
      clReleaseCommandQueue(queue_private);
    if (program_private)
      clReleaseProgram(program_private);
    if (context_private)
      clReleaseContext(context_private);
  }

protected:
  void testBody(const std::string &);

  cl_platform_id platform_private = nullptr;
  cl_device_id device_private = nullptr;
  cl_context context_private = nullptr;
  cl_command_queue queue_private = nullptr;
  cl_kernel kernel_private = nullptr;
  cl_mem buffer_private = nullptr;
  cl_program program_private = nullptr;
};

static bool vectorizerMode(bool enabled) {
  std::string mode = enabled ? "True" : "False";
  return SETENV("CL_CONFIG_USE_VECTORIZER", mode.c_str());
}

#if defined(_WIN32) && !defined(_WIN64)
TEST_F(PrivateMemSizeTest, DISABLED_Basic) {
#else
TEST_F(PrivateMemSizeTest, Basic) {
#endif
  std::string programSources = "__kernel void test(__global int* o)\n"
                               "{\n"
                               "    const int size = (STACK_SIZE/17) / "
                               "sizeof(int);\n" // (STACK_SIZE/(SIMD_WIDTH+1))MB
                                                // of private
                                                // memory
                               "    __private volatile int buf[size];\n"
                               "    int gid = get_global_id(0);\n"
                               "    for (int i = 0; i < size; ++i)\n"
                               "        buf[i] = gid;\n"
                               "    o[gid] = buf[gid + 1] + 2;\n"
                               "}";

  printf("cl_device_private_mem_size_test\n");

  bool enabledVectorizer = vectorizerMode(true);
  ASSERT_TRUE(CheckCondition("vectorizerMode", enabledVectorizer == true));

  ASSERT_NO_FATAL_FAILURE(testBody(programSources));
}

TEST_F(PrivateMemSizeTest, LargePrivateMemory) {
  std::string programSources =
      "__kernel void test(__global int* o)\n"
      "{\n"
      "    // STACK_SIZE bytes of private memory\n"
      "    const int size = (STACK_SIZE * 2) / sizeof(int);\n"
      "    printf(\"SIZE: %d \\n\", size);\n"
      "    __private volatile int buf[size];\n"
      "    int gid = get_global_id(0);\n"
      "    for (int i = 0; i < size; ++i)\n"
      "        buf[i] = gid;\n"
      "    o[gid] = buf[gid + 1] + 2;\n"
      "}";

  printf("cl_device_private_mem_size_test_out_of_resources\n");

  bool disabledVectorizer = vectorizerMode(false);
  ASSERT_TRUE(CheckCondition("vectorizerMode", disabledVectorizer == true));

  ASSERT_NO_FATAL_FAILURE(testBody(programSources));
}

#if defined(_WIN32) && !defined(_WIN64)
TEST_F(PrivateMemSizeTest, DISABLED_WithoutVectorizer) {
#else
TEST_F(PrivateMemSizeTest, WithoutVectorizer) {
#endif
  std::string programSources =
      "__kernel void test(__global int* o)\n"
      "{\n"
      "    const int size = (STACK_SIZE - 1024*1024) / "
      "sizeof(int);\n" // STACK_SIZE MB - 1MB of private memory
      "    printf(\"SIZE: %d \\n\", size);\n"
      "    __private volatile int buf[size];\n"
      "    int gid = get_global_id(0);\n"
      "    for (int i = 0; i < size; ++i)\n"
      "        buf[i] = gid;\n"
      "    o[gid] = buf[gid + 1] + 2;\n"
      "}";

  printf("cl_device_private_mem_size_test_without_vectorizer\n");

  bool disabledVectorizer = vectorizerMode(false);
  ASSERT_TRUE(CheckCondition("vectorizerMode", disabledVectorizer == true));

  ASSERT_NO_FATAL_FAILURE(testBody(programSources));

  bool enableVectorizer = vectorizerMode(true);
  ASSERT_TRUE(CheckCondition("vectorizerMode", enableVectorizer == true));
}

TEST_F(PrivateMemSizeTest, LargeStackSize) {
  std::string programSources =
      "__kernel void test(__global int* o)\n"
      "{\n"
      "    const int size = (STACK_SIZE/2) / sizeof(int);\n" // (STACK_SIZE/2)MB
                                                             // of private
                                                             // memory
      "    printf(\"SIZE: %d \\n\", size);\n"
      "    __private volatile int buf[size];\n"
      "    int gid = get_global_id(0);\n"
      "    for (int i = 0; i < size; ++i)\n"
      "        buf[i] = gid;\n"
      "    o[gid] = buf[gid + 1] + 2;\n"
      "}";

  printf("cl_device_private_mem_size_test\n");

  bool enabledVectorizer = vectorizerMode(true);
  ASSERT_TRUE(CheckCondition("vectorizerMode", enabledVectorizer == true));

  ASSERT_NO_FATAL_FAILURE(testBody(programSources));
}

void PrivateMemSizeTest::testBody(const std::string &programSources) {
  cl_int err;

  cl_context_properties prop[3] = {CL_CONTEXT_PLATFORM,
                                   (cl_context_properties)platform_private, 0};
  context_private =
      clCreateContext(prop, 1, &device_private, nullptr, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateContext");

  queue_private = clCreateCommandQueueWithProperties(
      context_private, device_private, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateCommandQueueWithProperties");

  const char *ps = programSources.c_str();
  std::string options = "-DSTACK_SIZE=" + std::to_string(STACK_SIZE);
  ASSERT_TRUE(BuildProgramSynch(context_private, 1, (const char **)&ps, nullptr,
                                options.c_str(), &program_private));

  const size_t global_work_size = 1;
  buffer_private =
      clCreateBuffer(context_private, CL_MEM_READ_WRITE,
                     global_work_size * sizeof(cl_int), nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer");

  kernel_private = clCreateKernel(program_private, "test", &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");

  err = clSetKernelArg(kernel_private, 0, sizeof(cl_mem), &buffer_private);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg");

  err = clEnqueueNDRangeKernel(queue_private, kernel_private, 1, nullptr,
                               &global_work_size, nullptr, 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");

  err = clFinish(queue_private);
  ASSERT_OCL_SUCCESS(err, "clFinish");

  cl_int data[global_work_size] = {0};

  err = clEnqueueReadBuffer(queue_private, buffer_private, CL_TRUE, 0,
                            global_work_size * sizeof(cl_int), data, 0, nullptr,
                            nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer");

  for (size_t i = 0; i < global_work_size; ++i) {
    ASSERT_EQ((cl_int)(i + 2), data[i]) << "kernel_private results verify fail";
  }
}
