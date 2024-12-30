// INTEL CONFIDENTIAL
//
// Copyright 2015 Intel Corporation.
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

#ifndef __CL21__
#define __CL21__

#include "CL_BASE.h"
#include "common_utils.h"
#include "test_utils.h"

class CL21 : public ::CL_base {
protected:
  virtual void SetUp() override {
    CL_base::SetUp();
    ASSERT_LE(OPENCL_VERSION::OPENCL_VERSION_2_1, m_version)
        << "Test required OpenCL2.1 version at least";
  }

  void GetDummyKernel(cl_kernel &kern, size_t reqd_sg_size = 0) {
    const std::vector<size_t> supported_SG_sizes = CPU_DEV_SUB_GROUP_SIZES;
    std::string kernel_builder;
    if (reqd_sg_size != 0) {
      auto iter = std::find(supported_SG_sizes.begin(),
                            supported_SG_sizes.end(), reqd_sg_size);
      ASSERT_NE(iter, supported_SG_sizes.end())
          << " Unsupported subgroup size: " << reqd_sg_size;
      kernel_builder.append("__attribute__((intel_reqd_sub_group_size(" +
                            std::to_string(reqd_sg_size) + "))) ");
    }
    kernel_builder.append("__kernel void dummy_kernel() {"
                          "  return;"
                          "}");
    const char *kernel = kernel_builder.data();
    const size_t kernel_size = kernel_builder.length();
    cl_int iRet = CL_SUCCESS;

    cl_program program =
        clCreateProgramWithSource(m_context, 1, &kernel, &kernel_size, &iRet);
    ASSERT_EQ(CL_SUCCESS, iRet) << " clCreateProgramWithSource failed. ";
    m_programs.push_back(program);

    iRet = clBuildProgram(program, 0, nullptr, "", nullptr, nullptr);
    if (CL_SUCCESS != iRet) {
      std::string log;
      ASSERT_NO_FATAL_FAILURE(GetBuildLog(m_device, program, log));
      FAIL() << log;
    }
    ASSERT_EQ(CL_SUCCESS, iRet) << " clBuildProgram failed. ";

    kern = clCreateKernel(program, "dummy_kernel", &iRet);
    ASSERT_EQ(CL_SUCCESS, iRet) << " clCreateKernel failed. ";
    m_kernels.push_back(kern);
  }
};

#endif /*__CL21__*/
