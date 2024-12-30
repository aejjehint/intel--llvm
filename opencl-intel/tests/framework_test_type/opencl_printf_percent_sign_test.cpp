// INTEL CONFIDENTIAL
//
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

#define CL_HPP_ENABLE_EXCEPTIONS
#define CL_HPP_TARGET_OPENCL_VERSION 200

#include "CL/cl.h"
#include "cl_utils.h"
#include "test_utils.h"

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4290)
#endif // _MSC_VER
#include "CL/opencl.hpp"
#ifdef _MSC_VER
#pragma warning(pop)
#endif // _MSC_VER
#include <iostream>
#include <string>

using namespace std;

extern cl_device_type gDeviceType;

namespace {
const char *KERNEL_CODE_STR = R"(__kernel void test() {
                                  __constant char* format1 = "%s\n";
                                  __constant char* format2 = "%%s%s\n";
                                  __constant char* format3 = "%%%s%%\n";
                                  __constant char* format4 = "%%%d%%\n";
                                  __constant char* value1 = "foo";
                                  __constant int value2 = 1023456789;
                                  printf(format1, value1);
                                  printf(format2, value1);
                                  printf(format3, value1);
                                  printf(format4, value2);
                                })";

const char *EXPECTED_OUTPUT = "foo\n"
                              "%sfoo\n"
                              "%foo%\n"
                              "%1023456789%\n";
} // namespace

bool opencl_printf_percent_sign_test() {
  cl_int err = CL_SUCCESS;
  string kernel_code = KERNEL_CODE_STR;

  cout << "---------------------------------------\n";
  cout << "opencl_printf_percent_sign_test\n";
  cout << "---------------------------------------\n";

  try {
    vector<cl::Platform> platforms;
    cl::Platform::get(&platforms);
    if (platforms.size() == 0) {
      cout << "FAIL: 0 platforms found\n";
      return false;
    }

    cl_context_properties properties[] = {
        CL_CONTEXT_PLATFORM, (cl_context_properties)(platforms[0])(), 0};
    cl::Context context(gDeviceType, properties);

    vector<cl::Device> devices = context.getInfo<CL_CONTEXT_DEVICES>();

    cl::CommandQueue queue(context, devices[0], 0, &err);

    cl::Program::Sources source(1, kernel_code);
    cl::Program program_ = cl::Program(context, source);

    if (CL_SUCCESS != program_.build(devices, "-cl-std=CL1.2")) {
      string buildlog;
      program_.getBuildInfo(devices[0], CL_PROGRAM_BUILD_LOG, &buildlog);
      cout << "FAIL: Build log:\n" << buildlog << endl;
      return false;
    }

    cl::Kernel kernel(program_, "test", &err);

    if (!CaptureStdout()) {
      cout << "Can't create a temporary file for capturing stdout\n";
      return false;
    }
    queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(1),
                               cl::NullRange, NULL, NULL);
    queue.finish();

    string out = GetCapturedStdout();
    if (!compare_kernel_output(EXPECTED_OUTPUT, out)) {
      cout << "FAIL: kernel output verification failed" << endl
           << "Expected:\n"
           << EXPECTED_OUTPUT << "------------\n"
           << "Got:\n"
           << out << "------------\n";
      return false;
    }
    return true;
  } catch (const cl::Error &err) {
    cout << "FAIL: " << err.what() << "(" << err.err() << ")" << endl;
    cout << "ClErrTxt error: " << ClErrTxt(err.err()) << endl;
    return false;
  }
  return true;
}
