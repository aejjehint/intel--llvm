// Copyright 2024 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you (License). Unless the License provides otherwise, you may not
// use, modify, copy, publish, distribute, disclose or transmit this software or
// the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.
#ifdef _WIN32
#include "TestsHelpClasses.h"
#include "common_utils.h"
#include "llvm/Support/Path.h"

using namespace llvm;

extern cl_device_type gDeviceType;

class LLDJITDump : public ::testing::Test {
protected:
  virtual void SetUp() override {
    cl_int Err = clGetPlatformIDs(1, &m_platform, nullptr);
    ASSERT_OCL_SUCCESS(Err, "clGetPlatformIDs");

    Err = clGetDeviceIDs(m_platform, gDeviceType, 1, &m_device, nullptr);
    ASSERT_OCL_SUCCESS(Err, "clGetDeviceIDs");

    m_context = clCreateContext(nullptr, 1, &m_device, nullptr, nullptr, &Err);
    ASSERT_OCL_SUCCESS(Err, "clCreateContext");

    m_queue =
        clCreateCommandQueueWithProperties(m_context, m_device, nullptr, &Err);
    ASSERT_OCL_SUCCESS(Err, "clCreateCommandQueueWithProperties");
  }

  virtual void TearDown() override {
    cl_int Err;
    if (m_kernel) {
      Err = clReleaseKernel(m_kernel);
      EXPECT_OCL_SUCCESS(Err, "clReleaseKernel");
    }
    if (m_program) {
      Err = clReleaseProgram(m_program);
      EXPECT_OCL_SUCCESS(Err, "clReleaseProgram");
    }
    if (m_queue) {
      Err = clReleaseCommandQueue(m_queue);
      EXPECT_OCL_SUCCESS(Err, "clReleaseCommandQueue");
    }
    if (m_context) {
      Err = clReleaseContext(m_context);
      EXPECT_OCL_SUCCESS(Err, "clReleaseContext");
    }
  }

protected:
  cl_platform_id m_platform = nullptr;
  cl_device_id m_device = nullptr;
  cl_context m_context = nullptr;
  cl_command_queue m_queue = nullptr;
  cl_program m_program = nullptr;
  cl_kernel m_kernel = nullptr;
};

TEST_F(LLDJITDump, ProgramHash) {
  std::string Source = "kernel void test() {}";
  const char *Csource = Source.c_str();
  cl_int Err;
  m_program = clCreateProgramWithSource(m_context, 1, &Csource, nullptr, &Err);
  ASSERT_OCL_SUCCESS(Err, "clCreateProgramWithSource");

  cl_int err = clBuildProgram(m_program, 1, &m_device, "-g -cl-opt-disable",
                              nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clBuildProgram");

  // Create and execute Kernel
  cl_kernel m_kernel = clCreateKernel(m_program, "test", &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");
  size_t gdim = 1;
  err = clEnqueueNDRangeKernel(m_queue, m_kernel, 1, nullptr, &gdim, nullptr, 0,
                               nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");
  err = clFinish(m_queue);
  ASSERT_OCL_SUCCESS(err, "clFinish");

  SmallString<256> TmpPath;
  sys::path::system_temp_directory(/*erasedOnReboot*/ true, TmpPath);

  std::vector<std::string> Extensions = {"dll", "pdb"};
  for (auto &Ext : Extensions) {
    std::string FilenamePattern =
        "CPUDeviceProgram-[0-9a-f]{16}-[0-9a-f]{8}." + Ext;
    Regex R(FilenamePattern);
    std::vector<std::string> DumpFilenames =
        findFilesInDir(TmpPath.str().str(), R);
    ASSERT_TRUE(!DumpFilenames.empty()) << (FilenamePattern + " is not dumped");
  }
}
#endif
