// INTEL CONFIDENTIAL
//
// Copyright 2020 Intel Corporation.
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

#include "SGEmulationTest.h"
#include "common_utils.h"

cl_device_type gDeviceType = CL_DEVICE_TYPE_CPU;

void SGEmulationTest::SetUp() {
  if (GetParam() &&
      !SETENV("OPENCL_PROGRAM_COMPILE_OPTIONS", "-cl-opt-disable"))
    FAIL() << "Failed to set OPENCL_PROGRAM_COMPILE_OPTIONS";
  CL_base::SetUp();
  ASSERT_LE(OPENCL_VERSION::OPENCL_VERSION_2_1, m_version)
      << "Test required OpenCL2.1 version at least";
}

void SGEmulationTest::TearDown() {
  if (GetParam() && !UNSETENV("OPENCL_PROGRAM_COMPILE_OPTIONS"))
    FAIL() << "Failed to unset OPENCL_PROGRAM_COMPILE_OPTIONS";
  CL_base::TearDown();
}

INSTANTIATE_TEST_SUITE_P(SubGroupTestType, SGEmulationTest,
                         ::testing::Values(false, true));

#ifdef _WIN32
bool AtExitTaskExecutor::EnableTaskExecutorFinalizing = true;
#endif

int main(int argc, char **argv) {
#ifdef _WIN32
  AtExitTaskExecutor guard;
#endif

  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
