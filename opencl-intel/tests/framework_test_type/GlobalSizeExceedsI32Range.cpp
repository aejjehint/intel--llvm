// Copyright (C) 2024 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

#include "CL/cl.h"
#include "CL/cl_ext.h"
#include "TestsHelpClasses.h"
#include "common_utils.h"
#include "test_utils.h"

extern cl_device_type gDeviceType;

class GlobalSizeExceedsI32RangeTest : public testing::Test {
protected:
  cl_platform_id Platform;
  cl_device_id Device;
  cl_context Context;
  cl_command_queue Queue;

  const std::string Source = R"(
    __kernel void test(__global int *a) {
      ulong gid = get_global_id(0);
      a[gid] = 1;
    }
  )";

  void SetUp() override {
    cl_int Err = clGetPlatformIDs(1, &Platform, nullptr);
    ASSERT_OCL_SUCCESS(Err, "clGetPlatformIDs");
    Err = clGetDeviceIDs(Platform, gDeviceType, 1, &Device, nullptr);
    ASSERT_OCL_SUCCESS(Err, "clGetDeviceIDs");
    Context = clCreateContext(nullptr, 1, &Device, nullptr, nullptr, &Err);
    ASSERT_OCL_SUCCESS(Err, "clCreateContext");
    Queue = clCreateCommandQueueWithProperties(Context, Device, 0, &Err);
    ASSERT_OCL_SUCCESS(Err, "clCreateCommandQueueWithProperties");
  }

  void TearDown() override {
    cl_int Err = CL_SUCCESS;
    if (Queue) {
      Err = clReleaseCommandQueue(Queue);
      ASSERT_OCL_SUCCESS(Err, "clReleaseCommandQueue");
    }
    if (Context) {
      Err = clReleaseContext(Context);
      ASSERT_OCL_SUCCESS(Err, "clReleaseContext");
    }
  }
};

TEST_F(GlobalSizeExceedsI32RangeTest, Test) {
  cl_int Err = CL_SUCCESS;
  const char *S = Source.c_str();
  cl_program Program = clCreateProgramWithSource(Context, 1, &S, nullptr, &Err);
  ASSERT_OCL_SUCCESS(Err, "clCreateProgramWithSource");
  Err = clBuildProgram(Program, 1, &Device, "-cl-std=CL2.0", nullptr, nullptr);
  ASSERT_OCL_SUCCESS(Err, "clBuildProgram");

  size_t GlobalSize = 0x1'0000'0001;
  size_t LocalSize = 0x1000;
  std::vector<int> OutBuffer(GlobalSize, 0);
  cl_kernel Kernel = clCreateKernel(Program, "test", &Err);
  ASSERT_OCL_SUCCESS(Err, "clCreateKernel");
  Err = clSetKernelArgMemPointerINTEL(Kernel, 0, OutBuffer.data());
  ASSERT_OCL_SUCCESS(Err, "clSetKernelArgMemPointerINTEL");
  Err = clEnqueueNDRangeKernel(Queue, Kernel, 1, nullptr, &GlobalSize,
                               &LocalSize, 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(Err, "clEnqueueNDRangeKernel");
  Err = clFinish(Queue);
  ASSERT_OCL_SUCCESS(Err, "clFinish");

  // Only check last element to save time.
  ASSERT_EQ(OutBuffer[GlobalSize - 1], 1);

  Err = clReleaseKernel(Kernel);
  ASSERT_OCL_SUCCESS(Err, "clReleaseKernel");
  Err = clReleaseProgram(Program);
  ASSERT_OCL_SUCCESS(Err, "clReleaseProgram");
}
