#include "TestsHelpClasses.h"
#include "common_utils.h"
#include "test_utils.h"

extern cl_device_type gDeviceType;

class SetCommandQueuePropertyTest : public ::testing::Test {
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
};

TEST_F(SetCommandQueuePropertyTest, invalidOperation) {
  std::vector<cl_command_queue_properties> queue_property_options = {
      0, CL_QUEUE_PROFILING_ENABLE, CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE,
      CL_QUEUE_PROFILING_ENABLE | CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE};
  cl_command_queue_properties old_properties = 0;
  for (auto prop : queue_property_options) {
    cl_int err =
        clSetCommandQueueProperty(m_queue, prop, CL_FALSE, &old_properties);
    ASSERT_EQ(err, CL_INVALID_OPERATION)
        << "clSetCommandQueueProperty return CL_INVALID_OPERATION";
    err = clSetCommandQueueProperty(m_queue, prop, CL_TRUE, &old_properties);
    ASSERT_EQ(err, CL_INVALID_OPERATION)
        << "clSetCommandQueueProperty return CL_INVALID_OPERATION";
  }
}
