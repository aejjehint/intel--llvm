//===--- device_info.cpp -                                      -*- C++ -*-===//
//
// Copyright (C) 2018 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //
//
// Internal tests for platform and device information correctness
//
// ===--------------------------------------------------------------------=== //

#include "CL/cl.h"
#include "base_fixture.h"
#include "cl_cpu_detect.h"
#include "gtest_wrapper.h"

using namespace Intel::OpenCL::Utils;

class TestInfo : public OCLFPGABaseFixture {
protected:
  void checkPlatform(cl_platform_info info, const char *ref) {
    char m_str[1024];
    int err =
        clGetPlatformInfo(platform(), info, sizeof(m_str), m_str, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_STREQ(ref, m_str);
  }

  void checkDevice(cl_device_id device, cl_device_info info, const char *ref) {
    char m_str[1024];
    int err = clGetDeviceInfo(device, info, sizeof(m_str), m_str, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_STREQ(ref, m_str);
  }
};

TEST_F(TestInfo, Platform) {
  checkPlatform(CL_PLATFORM_PROFILE, "EMBEDDED_PROFILE");
  checkPlatform(CL_PLATFORM_VERSION,
                "OpenCL 1.2 Intel(R) FPGA SDK for OpenCL(TM), Version 20.3");
  checkPlatform(CL_PLATFORM_NAME,
                "Intel(R) FPGA Emulation Platform for OpenCL(TM)");
  checkPlatform(CL_PLATFORM_VENDOR, "Intel(R) Corporation");
}

TEST_F(TestInfo, Device) {
  for (auto device : devices()) {
    checkDevice(device, CL_DEVICE_PROFILE, "EMBEDDED_PROFILE");
    checkDevice(device, CL_DEVICE_VERSION, "OpenCL 1.2 ");
    checkDevice(device, CL_DEVICE_NAME, "Intel(R) FPGA Emulation Device");
    checkDevice(device, CL_DEVICE_VENDOR, "Intel(R) Corporation");
    checkDevice(device, CL_DEVICE_OPENCL_C_VERSION, "OpenCL C 1.2 ");
    checkDevice(
        device, CL_DEVICE_EXTENSIONS,
        "cl_khr_spirv_linkonce_odr cl_khr_fp64 "
        "cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics "
        "cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics "
        "cl_khr_3d_image_writes cl_khr_byte_addressable_store "
        "cl_khr_depth_images cl_khr_extended_bit_ops cl_khr_icd "
        "cl_khr_il_program "
        "cl_khr_suggested_local_work_size "
        "cl_intel_unified_shared_memory "
        "cl_intel_fpga_host_pipe cl_intel_program_scope_host_pipe "
        "cles_khr_int64 cl_intel_channels");

    cl_device_type type;
    cl_int err =
        clGetDeviceInfo(device, CL_DEVICE_TYPE, sizeof(type), &type, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ((cl_device_type)CL_DEVICE_TYPE_ACCELERATOR, type);

    cl_uint vendorId;
    err = clGetDeviceInfo(device, CL_DEVICE_VENDOR_ID, sizeof(vendorId),
                          &vendorId, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ((cl_uint)4466, vendorId);

    cl_ulong localMemSize;
    err = clGetDeviceInfo(device, CL_DEVICE_LOCAL_MEM_SIZE,
                          sizeof(localMemSize), &localMemSize, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ(static_cast<cl_ulong>(64 * 1024 * 1024), localMemSize);

    cl_uint uiPreferredVecWidth = 0;
    err = clGetDeviceInfo(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT,
                          sizeof(cl_uint), &uiPreferredVecWidth, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ(1, uiPreferredVecWidth);

    uiPreferredVecWidth = -1;
    err = clGetDeviceInfo(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF,
                          sizeof(cl_uint), &uiPreferredVecWidth, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ(0, uiPreferredVecWidth)
        << "check device preferred vector width for half";

    cl_uint uiNativeVecWidth = 0;
    err = clGetDeviceInfo(device, CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT,
                          sizeof(cl_uint), &uiNativeVecWidth, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    auto *const CPUID = CPUDetect::GetInstance();
    if (CPUID->IsFeatureSupported(CFS_AVX512F))
      ASSERT_EQ(16, uiNativeVecWidth) << "check value AVX512";
    else if (CPUID->IsFeatureSupported(CFS_AVX20))
      ASSERT_EQ(8, uiNativeVecWidth) << "check value AVX2";
    else if (CPUID->IsFeatureSupported(CFS_AVX10))
      ASSERT_EQ(8, uiNativeVecWidth) << "check value AVX";
    else
      ASSERT_EQ(4, uiNativeVecWidth) << "check value SSE42";

    uiNativeVecWidth = -1;
    err = clGetDeviceInfo(device, CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF,
                          sizeof(cl_uint), &uiNativeVecWidth, nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ(0, uiNativeVecWidth)
        << "check device native vector width for half";

    // Refer to "cl_khr_fp16 support for FPGA emulator"
    // https://github.com/intel-restricted/applications.compilers.llvm-project/blob/xmain/opencl-intel/doc/fpga/cl_khr_fp16.rst#extension
    char buffer[1024];
    err = clGetDeviceInfo(device, CL_DEVICE_EXTENSIONS, sizeof(buffer), buffer,
                          nullptr);
    ASSERT_EQ(CL_SUCCESS, err);
    ASSERT_EQ(strstr(buffer, "cl_khr_fp16"), nullptr);

    cl_device_fp_config config = 0;
    size_t size_ret = 0;
    err = clGetDeviceInfo(device, CL_DEVICE_HALF_FP_CONFIG, sizeof(config),
                          &config, &size_ret);
    ASSERT_EQ(CL_SUCCESS, err) << "CL_DEVICE_HALF_FP_CONFIG";
    ASSERT_EQ(sizeof(config), size_ret);
    ASSERT_EQ(CL_FP_INF_NAN | CL_FP_ROUND_TO_NEAREST, config);

    // No support for cl_khr_device_uuid extension on FPGA Emulator
    ASSERT_TRUE(sizeof(buffer) >= CL_UUID_SIZE_KHR * sizeof(cl_uchar))
        << "buffer size is too small";
    err = clGetDeviceInfo(device, CL_DEVICE_UUID_KHR, sizeof(buffer), buffer,
                          nullptr);
    ASSERT_EQ(CL_INVALID_VALUE, err) << "CL_DEVICE_UUID_KHR";
    err = clGetDeviceInfo(device, CL_DRIVER_UUID_KHR, sizeof(buffer), buffer,
                          nullptr);
    ASSERT_EQ(CL_INVALID_VALUE, err) << "CL_DRIVER_UUID_KHR";
    err = clGetDeviceInfo(device, CL_DEVICE_LUID_VALID_KHR, sizeof(buffer),
                          buffer, nullptr);
    ASSERT_EQ(CL_INVALID_VALUE, err) << "CL_DEVICE_LUID_VALID_KHR";
    err = clGetDeviceInfo(device, CL_DEVICE_LUID_KHR, sizeof(buffer), buffer,
                          nullptr);
    ASSERT_EQ(CL_INVALID_VALUE, err) << "CL_DEVICE_LUID_KHR";
    err = clGetDeviceInfo(device, CL_DEVICE_NODE_MASK_KHR, sizeof(buffer),
                          buffer, nullptr);
    ASSERT_EQ(CL_INVALID_VALUE, err) << "CL_DEVICE_NODE_MASK_KHR";
  }
}
