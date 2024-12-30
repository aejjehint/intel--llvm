//
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
//

#include "CL/cl.h"
#include "framework_proxy.h"
#include "gtest_wrapper.h"
#include "test_utils.h"

using namespace Intel::OpenCL::Framework;

extern cl_device_type gDeviceType;

class ProgramLibraryTest : public ::testing::Test {
protected:
  void SetUp() override {
    FrameworkProxy *framework = FrameworkProxy::Instance();
    ASSERT_NE(framework, nullptr);
    PlatformModule *platformModule = framework->GetPlatformModule();
    ASSERT_NE(platformModule, nullptr);
    m_ctxModule = framework->GetContextModule();
    ASSERT_NE(m_ctxModule, nullptr);

    cl_platform_id platform = nullptr;
    cl_int err = platformModule->GetPlatformIDs(1, &platform, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetPlatformIDs");

    err = platformModule->GetDeviceIDs(platform, gDeviceType, 1, &m_device,
                                       nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceIDs");
  }

  void TearDown() override { FrameworkProxy::Destroy(); }

protected:
  ContextModule *m_ctxModule = nullptr;
  cl_device_id m_device = nullptr;
};

TEST_F(ProgramLibraryTest, RetainReleaseContext) {
  cl_int err;
  cl_context context =
      m_ctxModule->CreateContext(nullptr, 1, &m_device, nullptr, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateContext");

  SharedPtr<Context> ctx = m_ctxModule->GetContext(context);

  std::string kernelName = "copy";
  {
    SharedPtr<Kernel> kernel =
        m_ctxModule->GetLibraryKernel(ctx.GetPtr(), kernelName);
    ASSERT_NE(kernel, 0);
  }

  err = m_ctxModule->RetainContext(context);
  EXPECT_OCL_SUCCESS(err, "clRetainContext");
  {
    SharedPtr<Kernel> kernel =
        m_ctxModule->GetLibraryKernel(ctx.GetPtr(), kernelName);
    ASSERT_NE(kernel, 0);
  }

  err = m_ctxModule->ReleaseContext(context);
  EXPECT_OCL_SUCCESS(err, "clReleaseContext");
  {
    SharedPtr<Kernel> kernel =
        m_ctxModule->GetLibraryKernel(ctx.GetPtr(), kernelName);
    ASSERT_NE(kernel, 0);
  }

  err = m_ctxModule->ReleaseContext(context);
  EXPECT_OCL_SUCCESS(err, "clReleaseContext");
  {
    SharedPtr<Kernel> kernel =
        m_ctxModule->GetLibraryKernel(ctx.GetPtr(), kernelName);
    ASSERT_EQ(kernel, 0);
  }
}
