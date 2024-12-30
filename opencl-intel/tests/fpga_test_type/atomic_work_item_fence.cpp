//===--- atomic_work_item_fence.cpp -                           -*- C++ -*-===//
//
// Copyright (C) 2023 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //
//
// Internal tests for memory scope on FPGA-emu
//
// ===--------------------------------------------------------------------=== //
#include "CL/cl.h"
#include "gtest_wrapper.h"
#include "simple_fixture.h"
#include "test_utils.h"

#include <string>

class TestAtomicWorkItemFence : public OCLFPGASimpleFixture {};

static const std::string program_sources =
    "__kernel void saxpy_kernel(__global float *A,                                              \n\
                                __global float *B,                                              \n\
                                __global float *C){                                             \n\
        int index = get_global_id(0);                                                           \n\
        C[index] = A[index] + B[index];                                                         \n\
        atomic_work_item_fence(CLK_GLOBAL_MEM_FENCE, memory_order_release                       \n\
        , MEMORY_SCOPE);                                                                        \n\
    }";

static void buildProgramAndCheckLog(cl_context context, cl_device_id device,
                                    const std::string &program_sources,
                                    const std::string &option,
                                    cl_int expectedBuildRet,
                                    const std::string &expectedBuildLog) {
  cl_int ret = CL_SUCCESS;
  const char *sources_str = program_sources.c_str();
  cl_program program_with_source =
      clCreateProgramWithSource(context, 1, &sources_str, nullptr, &ret);
  ASSERT_EQ(CL_SUCCESS, ret) << "clCreateProgramWithSource failed.";
  ret = clBuildProgram(program_with_source, 0, nullptr, option.c_str(), nullptr,
                       nullptr);
  ASSERT_EQ(expectedBuildRet, ret) << "Unexpected build result.";

  // Get build log and check if the log contains the expected string.
  std::string build_log;
  GetBuildLog(device, program_with_source, build_log);
  ASSERT_NE(std::string::npos, build_log.find(expectedBuildLog));

  // Release the program
  ret = clReleaseProgram(program_with_source);
  ASSERT_EQ(ret, CL_SUCCESS) << "clReleaseProgram failed";
}

TEST_F(TestAtomicWorkItemFence, UnsupportedFPGAMemoryScope) {
  const char *error_msg =
      "error: Use unsupported memory scope in function saxpy_kernel for FPGA "
      "emulator platform!";
  ASSERT_NO_FATAL_FAILURE(buildProgramAndCheckLog(
      getContext(), getDevice(), program_sources,
      "-cl-std=CL2.0 -DMEMORY_SCOPE=3", CL_BUILD_PROGRAM_FAILURE, error_msg));
}

TEST_F(TestAtomicWorkItemFence, SupportedFPGAMemoryScope) {
  for (size_t idx = 0; idx < 5; ++idx) {
    // Build the program which uses supported memory scope on FPGA emulator.
    // Supported memory scope for FPGA emulator is:
    // memory_scope_work_item = 0;
    // memory_scope_work_group = 1;
    // memory_scope_device = 2;
    // memory_scope_sub_group = 4;
    if (idx == 3)
      continue;
    std::string option = "-cl-std=CL2.0 -DMEMORY_SCOPE=" + std::to_string(idx);
    ASSERT_TRUE(createAndBuildProgram(program_sources, option))
        << "createAndBuildProgram failed.";
  }
}
