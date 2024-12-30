///////////////////////////////////////////////////////////
//  CPUDeviceTest.cpp
///////////////////////////////////////////////////////////

#include "CL/cl_ext.h"
#include "cl_config.h"
#include "cl_cpu_detect.h"
#include "cl_device_api.h"
#include "cl_sys_info.h"
#include "cl_utils.h"
#include "common_utils.h"
#include "cpu_dev_limits.h"
#include "cpu_dev_test.h"
#include "gtest_wrapper.h"
#include "image_test.h"
#include "kernel_execute_test.h"
#include "logger_test.h"
#include "program.h"
#include "program_service_test.h"
#include "task_executor.h"
#include "tbb/global_control.h"
#include <assert.h>
#include <random>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <windows.h>
#else
#include <sched.h>
#endif
#include <hw_utils.h>

#define STR_LEN 100

using namespace Intel::OpenCL::TaskExecutor;
using namespace Intel::OpenCL::Utils;

extern bool memoryTest(bool profiling);
extern bool mapTest();
extern bool AffinityRootDeviceTest(affinityMask_t *pMask);
extern bool AffinitySubDeviceTest(affinityMask_t *pMask);

IOCLDeviceAgent *dev_entry;
cl_ulong profile_run = 0;
cl_ulong profile_complete = 0;
RTMemObjService localRTMemService;
affinityMask_t *pMask = NULL;

// Static variables for testing
static TestKernel_param_t gNativeKernelParam;
volatile bool gExecDone = true;

unsigned int gDeviceIdInType = 0;

std::string SYCLAffinity;
std::string SYCLPlace;
unsigned int NumProcessors;
bool UseHalfProcessors;

void CPUTestCallbacks::clDevCmdStatusChanged(cl_dev_cmd_id cmd_id, void *data,
                                             cl_int cmd_status,
                                             cl_int completion_result,
                                             cl_ulong timer) {
  unsigned int cmdId = (unsigned int)(size_t)cmd_id;

  printf("The command status changed %u status is %u, result %X\n", cmdId,
         cmd_status, completion_result);
  if (CL_COMPLETE == cmd_status) {
    switch (cmdId) {
    case CL_DEV_CMD_EXEC_NATIVE:
    case CL_DEV_CMD_COPY:
    case CL_DEV_CMD_EXEC_KERNEL:
    case CL_DEV_CMD_EXEC_TASK:
    case CL_DEV_CMD_READ:
    case CL_DEV_CMD_WRITE:
    case CL_DEV_CMD_MAP:
    case CL_DEV_CMD_UNMAP:
      gExecDone = true;
      break;
    }
    profile_complete = timer;

#if defined(_WIN32)
    printf("Elapsed time is %llu nano second\n",
           profile_complete - profile_run);
#else
    printf("Elapsed time is %lu nano second\n", profile_complete - profile_run);
#endif
  }
  if (CL_RUNNING == cmd_status) {
    profile_run = timer;
  }

  std::lock_guard<std::mutex> mutex(m_mutex);
  for (std::set<IOCLFrameworkCallbacks *>::iterator iter =
           m_userCallbacks.begin();
       iter != m_userCallbacks.end(); iter++) {
    (*iter)->clDevCmdStatusChanged(cmd_id, data, cmd_status, completion_result,
                                   timer);
  }
}

Intel::OpenCL::TaskExecutor::ITaskExecutor *
CPUTestCallbacks::clDevGetTaskExecutor() {
  return GetTaskExecutor();
}

// GetDeviceInfo with CL_DEVICE_TYPE test
bool clGetDeviceInfo_TypeTest() {
  cl_device_type device_type;
  size_t param_value_size;

  cl_int iRes =
      clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_TYPE,
                         sizeof(cl_device_type), NULL, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }

  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_TYPE,
                            sizeof(cl_device_type), &device_type,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {
    if (param_value_size != sizeof(cl_device_type)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_device_type));
      return false;
    }
    if (device_type != CL_DEVICE_TYPE_ACCELERATOR &&
        device_type != CL_DEVICE_TYPE_CPU) {
#if defined(_WIN32)
      printf("clDevGetDeviceInfo failed wrong device type %llu "
             "instead of %d\n",
             device_type, CL_DEVICE_TYPE_CPU);
#else
      printf("clDevGetDeviceInfo failed wrong device type %lu "
             "instead of %d\n",
             device_type, CL_DEVICE_TYPE_CPU);
#endif
      return false;
    }
    printf("clDevGetDeviceInfo succeeded\n");
    return true;
  }
}

bool clGetDeviceInfo_Test() {

  size_t param_value_size;
  size_t image2DMaxWidth, image3DMaxDepth, profilingTimerResolution;
  cl_uint maxWorkItemDimension, preferredVecortWidthShort, maxClockFreq,
      globalMemCacheLineSize;
  cl_ulong globalMemCacheSize;
  bool ret = true;

  cl_int iRes;

  // CL_DEVICE_MAX_WORK_ITEM_DIMENSION test
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS,
                            sizeof(maxWorkItemDimension), &maxWorkItemDimension,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(maxWorkItemDimension)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_uint));
      ret = false;
    }
    printf("maxWorkItemDimension %d\n", maxWorkItemDimension);
  }
  // CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT test
  iRes = clDevGetDeviceInfo(gDeviceIdInType,
                            CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT,
                            sizeof(preferredVecortWidthShort),
                            &preferredVecortWidthShort, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(preferredVecortWidthShort)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_uint));
      ret = false;
    }
    printf("preferredVecortWidthShort %d\n", preferredVecortWidthShort);
  }

  // CL_DEVICE_MAX_CLOCK_FREQUENCY test
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_MAX_CLOCK_FREQUENCY,
                            sizeof(maxClockFreq), &maxClockFreq,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(maxClockFreq)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_uint));
      ret = false;
    }
    printf("maxClockFreq %d\n", maxClockFreq);
  }

  // CL_DEVICE_IMAGE2D_MAX_WIDTH test
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_IMAGE2D_MAX_WIDTH,
                            sizeof(image2DMaxWidth), &image2DMaxWidth,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(image2DMaxWidth)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_uint));
      ret = false;
    }
    printf("image2DMaxWidth %zu\n", image2DMaxWidth);
  }
  // CL_DEVICE_IMAGE3D_MAX_DEPTH test
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_IMAGE3D_MAX_DEPTH,
                            sizeof(image3DMaxDepth), &image3DMaxDepth,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(image3DMaxDepth)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_uint));
      ret = false;
    }
    printf("image3DMaxDepth %zu\n", image3DMaxDepth);
  }
  // CL_DEVICE_GLOBAL_MEM_CACHE_SIZE test
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE,
                            sizeof(globalMemCacheSize), &globalMemCacheSize,
                            &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(globalMemCacheSize)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(cl_ulong));
      ret = false;
    }
#if defined(_WIN32)
    printf("globalMemCacheSize %llu\n", globalMemCacheSize);
#else
    printf("globalMemCacheSize %lu\n", globalMemCacheSize);
#endif
  }
  // CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE test
  iRes =
      clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE,
                         sizeof(globalMemCacheLineSize),
                         &globalMemCacheLineSize, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(globalMemCacheLineSize)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(globalMemCacheLineSize));
      ret = false;
    }
    printf("globalMemCacheLineSize %u\n", globalMemCacheLineSize);
  }

  // CL_DEVICE_PROFILING_TIMER_RESOLUTION test
  iRes =
      clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_PROFILING_TIMER_RESOLUTION,
                         sizeof(profilingTimerResolution),
                         &profilingTimerResolution, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    ret = false;
  } else {
    if (param_value_size != sizeof(profilingTimerResolution)) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %zu\n",
             param_value_size, sizeof(profilingTimerResolution));
      ret = false;
    }
    printf("profilingTimerResolution %zu\n", profilingTimerResolution);
  }

  return ret;
}

// GetDeviceInfo with CL_DEVICE_VENDOR_ID test
bool clGetDeviceInfo_VendorIdTest() {
  cl_uint uVendorId;
  size_t param_value_size;
  cl_uint input_size = sizeof(cl_uint);

  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_VENDOR_ID,
                                   input_size, &uVendorId, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {
    if (param_value_size != input_size) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %d\n",
             param_value_size, input_size);
      return false;
    }
    printf("Vendor id is %u\n", uVendorId);
    return true;
  }
}

// GetDeviceInfo with CL_DEVICE_MAX_COMPUTE_UNITS test
bool clGetDeviceInfo_MaxComputeUnitTest() {
  cl_uint uCoreNum;
  size_t param_value_size;
  cl_uint input_size = sizeof(cl_uint);

  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_MAX_COMPUTE_UNITS,
                                   input_size, &uCoreNum, &param_value_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {
    if (param_value_size != input_size) {
      printf("clDevGetDeviceInfo failed param value size is in wrong size: %zu "
             "instead of %d\n",
             param_value_size, input_size);
      return false;
    }
    printf("Max Compute Units is %u\n", uCoreNum);
    return true;
  }
}

// GetDeviceInfo with CL_DEVICE_AVAILABLE test
bool clGetDeviceInfo_DeviceAvilable() {
  cl_bool bDevice;
  cl_uint input_size = sizeof(cl_bool);

  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_AVAILABLE,
                                   input_size, &bDevice, NULL);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {
    if (bDevice) {
      printf("Device is avilable");
      return true;
    } else {
      printf("Device is not avilable");
      return false;
    }
    return true;
  }
}

// GetDeviceInfo with CL_DEVICE_EXECUTION_CAPABILITIES test
bool clGetDeviceInfo_DeviceExecutionProperties() {
  cl_device_exec_capabilities capabilities;
  cl_uint input_size = sizeof(cl_device_exec_capabilities);

  cl_int iRes =
      clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_EXECUTION_CAPABILITIES,
                         input_size, &capabilities, NULL);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {

    if (capabilities & CL_EXEC_NATIVE_KERNEL) {
      printf("Device has CL_EXEC_NATIVE_FN_AS_KERNEL capabilities\n");
    }
    if (capabilities & CL_EXEC_KERNEL) {
      printf("Device has CL_EXEC_KERNEL capabilities\n");
      return true;
    } else {
      printf("Device doesnt have basic capabilities\n");
      // Return true for now
      return true;
    }
    return true;
  }
}

// GetDeviceInfo with CL_DEVICE_QUEUE_PROPERTIES test
bool clGetDeviceInfo_QueueProperties() {
  cl_command_queue_properties queueProperties;
  cl_uint input_size = sizeof(cl_command_queue_properties);

  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_QUEUE_PROPERTIES,
                                   input_size, &queueProperties, NULL);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  } else {

    if (queueProperties & CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE) {
      printf("Device has CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE queue "
             "properties\n");
    }
    if (queueProperties & CL_QUEUE_PROFILING_ENABLE) {
      printf("Device has CL_QUEUE_PROFILING_ENABLE queue properties\n");
    } else {
      printf("Device doesnt have basic properties\n");
      return false;
    }
    return true;
  }
}

// Extension: cl_intel_device_attribute_query
// https://github.com/KhronosGroup/OpenCL-Docs/blob/master/extensions/cl_intel_device_attribute_query.asciidoc
// GetDeviceInfo with CL_DEVICE_IP_VERSION_INTEL, CL_DEVICE_ID_INTEL,
// CL_DEVICE_NUM_SLICES_INTEL, CL_DEVICE_NUM_SUB_SLICES_PER_SLICE_INTEL,
// CL_DEVICE_NUM_EUS_PER_SUB_SLICE_INTEL, CL_DEVICE_NUM_THREADS_PER_EU_INTEL,
// CL_DEVICE_FEATURE_CAPABILITIES_INTEL
bool clGetDeviceInfo_DeviceAttributeQueries() {
  cl_version DeviceIPVer;
  size_t SizeRet;
  cl_int Res = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_IP_VERSION_INTEL,
                                  sizeof(cl_version), &DeviceIPVer, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed for CL_DEVICE_IP_VERSION_INTEL: "
      << clDevErr2Txt((cl_dev_err_code)Res);
  // For CL_DEVICE_IP_VERSION_INTEL, we can only check whether it's supported
  // ECPU value.
  EXPECT_TRUE(DeviceIPVer < Intel::OpenCL::Utils::CPU_LAST_ARCH);
  printf("Device IP version: 0x%x\n", DeviceIPVer);

  cl_uint DeviceID;
  Res = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_ID_INTEL, sizeof(cl_uint),
                           &DeviceID, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed for CL_DEVICE_ID_INTEL: "
      << clDevErr2Txt((cl_dev_err_code)Res);
  printf("Device ID: 0x%x\n", DeviceID);

  cl_uint NumSlices;
  Res = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_NUM_SLICES_INTEL,
                           sizeof(cl_uint), &NumSlices, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed for CL_DEVICE_NUM_SLICES_INTEL: "
      << clDevErr2Txt((cl_dev_err_code)Res);
  printf("Number of slices (NUMA nodes): %u\n", NumSlices);

  cl_uint SubslicesPerSlice;
  Res = clDevGetDeviceInfo(gDeviceIdInType,
                           CL_DEVICE_NUM_SUB_SLICES_PER_SLICE_INTEL,
                           sizeof(cl_uint), &SubslicesPerSlice, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS) << "clDevGetDeviceInfo failed for "
                                    "CL_DEVICE_NUM_SUB_SLICES_PER_SLICE_INTEL: "
                                 << clDevErr2Txt((cl_dev_err_code)Res);
  EXPECT_EQ(SubslicesPerSlice, 1)
      << "CL_DEVICE_NUM_SUB_SLICES_PER_SLICE_INTEL always return 1";

  cl_uint EUsPerSubslice;
  Res =
      clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_NUM_EUS_PER_SUB_SLICE_INTEL,
                         sizeof(cl_uint), &EUsPerSubslice, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS) << "clDevGetDeviceInfo failed for "
                                    "CL_DEVICE_NUM_EUS_PER_SUB_SLICE_INTEL: "
                                 << clDevErr2Txt((cl_dev_err_code)Res);
  printf("Number of EUs per subslice (physical cores per NUMA node): %u\n",
         EUsPerSubslice);

  cl_uint ThreadsPerEU;
  Res = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_NUM_THREADS_PER_EU_INTEL,
                           sizeof(cl_uint), &ThreadsPerEU, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS) << "clDevGetDeviceInfo failed for "
                                    "CL_DEVICE_NUM_THREADS_PER_EU_INTEL: "
                                 << clDevErr2Txt((cl_dev_err_code)Res);
  printf("Number of threads per EU (threads per physical core): %u\n",
         ThreadsPerEU);

  // FIXME: std::thread::hardware_concurrency() is just a hint of total number
  // of threads. Replace it with a more reliable API.
  // EXPECT_EQ(NumSlices * SubslicesPerSlice * EUsPerSubslice * ThreadsPerEU,
  //           std::thread::hardware_concurrency())
  //     << "Total number of threads is incorrect!";

  cl_device_feature_capabilities_intel Features;
  Res = clDevGetDeviceInfo(
      gDeviceIdInType, CL_DEVICE_FEATURE_CAPABILITIES_INTEL,
      sizeof(cl_device_feature_capabilities_intel), &Features, &SizeRet);
  EXPECT_EQ(Res, CL_DEV_SUCCESS) << "clDevGetDeviceInfo failed for "
                                    "CL_DEVICE_FEATURE_CAPABILITIES_INTEL: "
                                 << clDevErr2Txt((cl_dev_err_code)Res);
  EXPECT_EQ(Features, 0) << "No feature to support on CPU";
  return true;
}

// GetDeviceInfo with CL_DEVICE_NAME, CL_DEVICE_VENDOR, CL_DEVICE_PROFILE,
// CL_DEVICE_VERSION test
bool clGetDeviceInfo_DeviceStrings() {

  char name[STR_LEN];

  size_t str_size = 0;

  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_NAME, STR_LEN,
                                   name, &str_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }
  if ('\0' != name[str_size - 1]) {
    printf("clDevGetDeviceInfo invalid device name\n");
    return false;
  }
  printf("Device name is %s\n", name);

  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_VENDOR, STR_LEN, name,
                            &str_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }
  if ('\0' != name[str_size - 1]) {
    printf("clDevGetDeviceInfo invalid vendor name\n");
    return false;
  }

  printf("Device vendor %s\n", name);

  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_PROFILE, STR_LEN, name,
                            &str_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }
  if ('\0' != name[str_size - 1]) {
    printf("clDevGetDeviceInfo invalid device profile\n");
    return false;
  }

  printf("Device profile is %s\n", name);

  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_VERSION, STR_LEN, name,
                            &str_size);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevGetDeviceInfo failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }
  if ('\0' != name[str_size - 1]) {
    printf("clDevGetDeviceInfo invalid device version\n");
    return false;
  }

  printf("Device version is %s\n", name);

  return true;
}

// GetDeviceInfo with CL_DEVICE_UUID_KHR, CL_DRIVER_UUID_KHR,
// CL_DEVICE_LUID_VALID_KHR, CL_DEVICE_LUID_KHR, CL_DEVICE_NODE_MASK_KHR test
bool clGetDeviceInfo_DeviceUUID() {
  using UUID = std::array<cl_uchar, CL_UUID_SIZE_KHR>;
  using LUID = std::array<cl_uchar, CL_LUID_SIZE_KHR>;

  UUID uuidDevice = {0};
  uint32_t viCPUInfo[4] = {(uint32_t)-1};
  CPUID(viCPUInfo, 0);
  auto Vendor = CPUDetect::GetVendor();
  uint16_t vendor = (Vendor == GenuineIntel)
                        ? 0x8086
                        : ((Vendor == AuthenticAMD) ? 0x1022 : 0);
  uint16_t subDeviceId = 0;
  MEMCPY_S(&uuidDevice[0], sizeof(uint16_t), &vendor, sizeof(uint16_t));
  CPUID(viCPUInfo, 1);
  // CPU HW version info, e.g., stepping, model and family in EAX
  MEMCPY_S(&uuidDevice[2], sizeof(uint32_t), &viCPUInfo[0], sizeof(uint32_t));
  // CPU feature flag #1 and #2 in ECX and EDX
  MEMCPY_S(&uuidDevice[6], sizeof(uint32_t), &viCPUInfo[2], sizeof(uint32_t));
  MEMCPY_S(&uuidDevice[10], sizeof(uint32_t), &viCPUInfo[3], sizeof(uint32_t));
  // sub device index
  MEMCPY_S(&uuidDevice[14], sizeof(uint16_t), &subDeviceId, sizeof(uint16_t));

  UUID uuidDriver = {0};
  const char *prodVer = Intel::OpenCL::Utils::GetModuleProductVersion();
  MEMCPY_S(&uuidDriver[0], CL_UUID_SIZE_KHR, prodVer,
           std::min(static_cast<size_t>(CL_UUID_SIZE_KHR), strlen(prodVer)));

  UUID uuid = {0};
  size_t iRetSize = 0;
  cl_int iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_UUID_KHR,
                                   sizeof(UUID), &uuid[0], &iRetSize);

  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";

  EXPECT_EQ(uuidDevice, uuid) << "clDevGetDeviceInfo invalid device UUID\n";
  EXPECT_EQ(iRetSize, sizeof(cl_uchar) * CL_UUID_SIZE_KHR)
      << "clDevGetDeviceInfo invalid return value size\n";
  auto uidToStr = [](const auto &uid) -> std::string {
    std::stringstream strUID;
    for (cl_uchar ch : uid)
      strUID << std::hex << std::setw(2) << std::setfill('0')
             << static_cast<int>(ch);
    return strUID.str();
  };
  printf("Device UUID is %s\n", uidToStr(uuid).c_str());

  uuid.fill(0);
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DRIVER_UUID_KHR, sizeof(UUID),
                            &uuid[0], &iRetSize);
  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";
  EXPECT_EQ(uuidDriver, uuid)
      << "clDevGetDeviceInfo invalid driver UUID for the CPU device\n";
  EXPECT_EQ(iRetSize, sizeof(cl_uchar) * CL_UUID_SIZE_KHR)
      << "clDevGetDeviceInfo invalid return value size\n";
  printf("Driver UUID is %s\n", uidToStr(uuid).c_str());

  cl_bool bDeviceLUIDValid;
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_LUID_VALID_KHR,
                            sizeof(cl_bool), &bDeviceLUIDValid, &iRetSize);
  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";

  EXPECT_EQ(bDeviceLUIDValid, CL_FALSE)
      << "clDevGetDeviceInfo CPU device should not have a valid LUID\n";
  EXPECT_EQ(iRetSize, sizeof(cl_bool))
      << "clDevGetDeviceInfo invalid return value size\n";

  LUID luid = {0};
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_LUID_KHR, sizeof(LUID),
                            &luid[0], &iRetSize);
  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";
  EXPECT_EQ(LUID{0}, luid)
      << "clDevGetDeviceInfo CPU device should have zeroed LUID\n";
  EXPECT_EQ(iRetSize, sizeof(cl_uchar) * CL_LUID_SIZE_KHR)
      << "clDevGetDeviceInfo invalid return value size\n";
  printf("Device LUID is %s\n", uidToStr(luid).c_str());

  cl_uint iDeviceNodeMask;
  iRes = clDevGetDeviceInfo(gDeviceIdInType, CL_DEVICE_NODE_MASK_KHR,
                            sizeof(cl_uint), &iDeviceNodeMask, &iRetSize);
  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";
  EXPECT_EQ(iDeviceNodeMask, 0)
      << "clDevGetDeviceInfo CPU device node mask should be zero\n";
  EXPECT_EQ(iRetSize, sizeof(cl_uint))
      << "clDevGetDeviceInfo invalid return value size\n";

  return true;
}

// GetDeviceInfo with CL_DEVICE_INTEGER_DOT_PRODUCT_CAPABILITIES_KHR,
// CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_8BIT_KHR,
// CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_4x8BIT_PACKED_KHR test
bool clGetDeviceInfo_IntegerDotProduct() {
  using dot_product_capabilities =
      cl_device_integer_dot_product_capabilities_khr;
  dot_product_capabilities capabilities = 0;
  dot_product_capabilities expCapabilities =
      CL_DEVICE_INTEGER_DOT_PRODUCT_INPUT_4x8BIT_PACKED_KHR |
      CL_DEVICE_INTEGER_DOT_PRODUCT_INPUT_4x8BIT_KHR;

  size_t iRetSize = 0;
  cl_int iRes = clDevGetDeviceInfo(
      gDeviceIdInType, CL_DEVICE_INTEGER_DOT_PRODUCT_CAPABILITIES_KHR,
      sizeof(dot_product_capabilities), &capabilities, &iRetSize);
  EXPECT_EQ(iRes, CL_DEV_SUCCESS)
      << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
      << "\n";
  EXPECT_EQ(iRetSize, sizeof(dot_product_capabilities))
      << "clDevGetDeviceInfo invalid return value size\n";
  EXPECT_EQ(capabilities, expCapabilities)
      << "clDevGetDeviceInfo invalid integer dot product capabilities\n";

  using dot_product_acceleration_props =
      cl_device_integer_dot_product_acceleration_properties_khr;
  dot_product_acceleration_props accProps = {CL_FALSE, CL_FALSE, CL_FALSE,
                                             CL_FALSE, CL_FALSE, CL_FALSE};
  dot_product_acceleration_props expAccProps = {CL_TRUE, CL_TRUE, CL_TRUE,
                                                CL_TRUE, CL_TRUE, CL_TRUE};

  bool success = false;
  auto checkProps = [&](cl_device_info deviceInfo) {
    success = false;
    iRes = clDevGetDeviceInfo(gDeviceIdInType, deviceInfo,
                              sizeof(dot_product_acceleration_props), &accProps,
                              &iRetSize);
    EXPECT_EQ(iRes, CL_DEV_SUCCESS)
        << "clDevGetDeviceInfo failed: " << clDevErr2Txt((cl_dev_err_code)iRes)
        << "\n";
    EXPECT_EQ(iRetSize, sizeof(dot_product_acceleration_props))
        << "clDevGetDeviceInfo invalid return value size\n";

    if (accProps.signed_accelerated != expAccProps.signed_accelerated ||
        accProps.unsigned_accelerated != expAccProps.unsigned_accelerated ||
        accProps.mixed_signedness_accelerated !=
            expAccProps.mixed_signedness_accelerated ||
        accProps.accumulating_saturating_signed_accelerated !=
            expAccProps.accumulating_saturating_signed_accelerated ||
        accProps.accumulating_saturating_unsigned_accelerated !=
            expAccProps.accumulating_saturating_unsigned_accelerated ||
        accProps.accumulating_saturating_mixed_signedness_accelerated !=
            expAccProps.accumulating_saturating_mixed_signedness_accelerated) {
      printf("clDevGetDeviceInfo invalid integer dot product acceleration "
             "properties\n");
      return;
    }
    success = true;
  };
  checkProps(CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_8BIT_KHR);
  EXPECT_EQ(success, true);
  checkProps(
      CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_4x8BIT_PACKED_KHR);
  EXPECT_EQ(success, true);

  return true;
}

// test CommandList functions
bool CommandList_Test() {
  // Create command list
  cl_dev_cmd_list_props props = CL_DEV_LIST_ENABLE_OOO;
  cl_dev_cmd_list list;

  cl_int iRes = dev_entry->clDevCreateCommandList(props, 0, &list);
  if (CL_DEV_FAILED(iRes)) {
    printf("pclDevCreateCommandList failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }

  iRes = dev_entry->clDevReleaseCommandList(list);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevReleaseCommandList failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }

  return true;
}

// test native kernel execution
bool ExecuteNativeKernel_Test(bool profiling) {
  cl_int iRes;

  // Create command list
  cl_dev_cmd_param_native nativeParam;

  // Set Native Kernel Parameters
  gNativeKernelParam.count = 10;
  gNativeKernelParam.buff =
      (int *)malloc(gNativeKernelParam.count * sizeof(int));
  memset(gNativeKernelParam.buff, 0, gNativeKernelParam.count * sizeof(int));

  // Set Execute parameters
  memset(&nativeParam, 0, sizeof(cl_dev_cmd_param_native));
  nativeParam.func_ptr = _TestKernel;
  nativeParam.args = sizeof(TestKernel_param_t);
  nativeParam.argv = &gNativeKernelParam;

  // Execute command
  cl_dev_cmd_desc cmds;
  cl_uint count = 1;

  cmds.type = CL_DEV_CMD_EXEC_NATIVE;
  cmds.id = (cl_dev_cmd_id)CL_DEV_CMD_EXEC_NATIVE;
  cmds.params = &nativeParam;
  cmds.param_size = sizeof(cl_dev_cmd_param_native);
  cmds.profiling = profiling;

  gExecDone = false;

  cl_dev_cmd_desc *cmdsBuff = &cmds;
  iRes = dev_entry->clDevCommandListExecute(0, &cmdsBuff, count);
  if (CL_DEV_FAILED(iRes)) {
    printf("clDevCommandListExecute failed: %s\n",
           clDevErr2Txt((cl_dev_err_code)iRes));
    return false;
  }

  while (!gExecDone) {
    SLEEP(10);
  }

  bool match = true;

  // Test for kernel completion
  for (int i = 0; i < gNativeKernelParam.count; ++i) {
    match &= (gNativeKernelParam.buff[i] == i);
  }

  free(gNativeKernelParam.buff);
  if (match) {
    printf("Native Kernel Execution succeeded\n");
    return true;
  } else {
    printf("Native Kernel Execution failed\n");
    return false;
  }

  return true;
}

// The following tests replace the old "main" function of framework_test_type.
//
TEST(CpuDeviceTestType, Test_InitLogger) { EXPECT_TRUE(InitLoggerTest()); }

TEST(CpuDeviceTestType, Test_clGetDeviceInfo) {
  EXPECT_TRUE(clGetDeviceInfo_Test());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfoType) {
  EXPECT_TRUE(clGetDeviceInfo_TypeTest());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_VendorId) {
  EXPECT_TRUE(clGetDeviceInfo_VendorIdTest());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_MaxComputeUnit) {
  EXPECT_TRUE(clGetDeviceInfo_MaxComputeUnitTest());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_DeviceAvilable) {
  EXPECT_TRUE(clGetDeviceInfo_DeviceAvilable());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_DeviceExecutionProperties) {
  EXPECT_TRUE(clGetDeviceInfo_DeviceExecutionProperties());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_QueueProperties) {
  EXPECT_TRUE(clGetDeviceInfo_QueueProperties());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_DeviceAttributeQueries) {
  EXPECT_TRUE(clGetDeviceInfo_DeviceAttributeQueries());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_DeviceStrings) {
  EXPECT_TRUE(clGetDeviceInfo_DeviceStrings());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_DeviceUUID) {
  EXPECT_TRUE(clGetDeviceInfo_DeviceUUID());
}

TEST(CpuDeviceTestType, Test_clGetDeviceInfo_IntegerDotProduct) {
  EXPECT_TRUE(clGetDeviceInfo_IntegerDotProduct());
}

TEST(CpuDeviceTestType, Test_imageTest) { EXPECT_TRUE(imageTest(true)); }

TEST(CpuDeviceTestType, Test_CommandList) { EXPECT_TRUE(CommandList_Test()); }

TEST(CpuDeviceTestType, Test_ExecuteNativeKernel) {
  EXPECT_TRUE(ExecuteNativeKernel_Test(true));
}

TEST(CpuDeviceTestType, Test_BuildFromBinary) {
  std::string filename = get_exe_dir() + "test.bc";
  EXPECT_TRUE(BuildFromBinary_test(filename.c_str(), 2, "dot_product", 3));
}

TEST(CpuDeviceTestType, Test_memoryTest) { EXPECT_TRUE(memoryTest(true)); }

TEST(CpuDeviceTestType, Test_KernelExecute_Math) {
  std::string filename = get_exe_dir() + "test.bc";
  EXPECT_TRUE(KernelExecute_Math_Test(filename.c_str()));
}

#ifndef _WIN32
// Sporadic fails in Test_AffinityRootDevice
TEST(CpuDeviceTestType,
     DISABLED_Test_AffinityRootDevice)
{
  EXPECT_TRUE(AffinityRootDeviceTest(pMask));
}

TEST(CpuDeviceTestType, DISABLED_Test_AffinitySubDevice)
{
  EXPECT_TRUE(AffinitySubDeviceTest(pMask));
}
#endif
// Manual test, don't enable
// TEST(CpuDeviceTestType, Test_KernelExecute_Lcl_Mem)
//{
//  EXPECT_TRUE(KernelExecute_Lcl_Mem_Test("test.bc"));
//}

TEST(CpuDeviceTestType, Test_mapTest) { EXPECT_TRUE(mapTest()); }

// To run individual tests, use the --gtest_filter=<pattern> command-line
// option. For example, to only Test_EventCallbackTest, use:
// --gtest_filter=Test_EventCallbackTest
//
// To run all tests whose names end with ExecuteTest, use:
// --gtest_filter=*ExecuteTest
//
// Read the gtest documentation for more information.
//

CPUTestCallbacks g_dev_callbacks;

void initDpcppAffinity() {
#ifdef _WIN32
  NumProcessors = TE_AUTO_THREADS;
  UseHalfProcessors = false;
#else
  // ENV variable must be set before TaskExecutor::init()

  std::mt19937 rng(std::random_device{}());

  // Tests of master, close and spread can't be executed concurrently in LIT
  // and SYCL_CPU_CU_AFFINITY must be set for all tests because CPU device
  // instance is only initialized once even if there are multiple calls to
  // clDevCreateDeviceInstance.
  int idx = std::uniform_int_distribution<>{0, 2}(rng);
  SYCLAffinity = (idx == 0) ? "close" : (idx == 1) ? "spread" : "master";
  SETENV("SYCL_CPU_CU_AFFINITY", SYCLAffinity.c_str());
  idx = std::uniform_int_distribution<>{0, 2}(rng);
  SYCLPlace = (idx == 0) ? "sockets" : (idx == 1) ? "cores" : "threads";
  SETENV("SYCL_CPU_PLACES", SYCLPlace.c_str());

  NumProcessors = (unsigned)Intel::OpenCL::Utils::GetNumberOfProcessors();
  unsigned numUsedProcessors = NumProcessors;
  UseHalfProcessors = std::uniform_int_distribution<>{0, 1}(rng);
  if (UseHalfProcessors)
    numUsedProcessors /= 2;

  // SYCL_CPU_NUM_CUS/CL_CONFIG_CPU_TBB_NUM_WORKERS must be set for all tests
  // because TaskExecutor is only initialized once.
  const char *envNumThreads = std::uniform_int_distribution<>{0, 1}(rng)
                                  ? "SYCL_CPU_NUM_CUS"
                                  : "CL_CONFIG_CPU_TBB_NUM_WORKERS";
  std::string numUsedProcessorsStr = std::to_string(numUsedProcessors);
  SETENV(envNumThreads, numUsedProcessorsStr.c_str());
#endif
}

void CPUDeviceTest_Init(Intel::OpenCL::Utils::BasicCLConfigWrapper *config) {
  initDpcppAffinity();

  ITaskExecutor *pTaskExecutor = GetTaskExecutor();
  ASSERT_TRUE(pTaskExecutor != NULL);

  // Initialize Task Executor
  unsigned numThreads = UseHalfProcessors ? (NumProcessors / 2) : NumProcessors;
  size_t additionalStackSize = CPU_DEV_TBB_STACK_SIZE;
  int iThreads = pTaskExecutor->Init(numThreads, nullptr, additionalStackSize);
  ASSERT_EQ(pTaskExecutor->GetErrorCode(), 0);
  ASSERT_TRUE(iThreads > 0);

  // Check TBB stack size
  size_t stackSize =
      tbb::global_control::active_value(tbb::global_control::thread_stack_size);
  ASSERT_EQ(stackSize, (size_t)CPU_DEV_TBB_STACK_SIZE);

  // Create and Init the device
  static CPUTestLogger log_desc;

  size_t numDevicesInDeviceType = 0;
  cl_int iRes = clDevGetAvailableDeviceList(0, NULL, &numDevicesInDeviceType);
  ASSERT_TRUE(CL_DEV_SUCCEEDED(iRes) && numDevicesInDeviceType > 0);

  size_t deviceIdsListSizeRet = 0;
  unsigned int deviceIdsList[1] = {0};
  iRes = clDevGetAvailableDeviceList(1, deviceIdsList, &deviceIdsListSizeRet);
  ASSERT_TRUE(CL_DEV_SUCCEEDED(iRes) && deviceIdsListSizeRet > 0);

  gDeviceIdInType = deviceIdsList[0];
  iRes = clDevCreateDeviceInstance(gDeviceIdInType, &g_dev_callbacks, &log_desc,
                                   &dev_entry);
  ASSERT_TRUE(CL_DEV_SUCCEEDED(iRes));
}

#ifndef _WIN32
void printAffinityMask(affinityMask_t *affinityMask) {
  int max_cpus = CPU_SETSIZE;

  unsigned char aff;
  bool needPrint = false;
  for (int set = max_cpus; set > 7; set -= 8) {
    aff = 0;
    for (int cpu = set - 8; cpu < set; ++cpu) {
      if (CPU_ISSET(cpu, affinityMask)) {
        aff |= (1 << (cpu - set + 8));
      }
    }
    needPrint |= (aff != 0);
    if (needPrint) {
      printf("%hhx", aff);
    }
  }
  printf("\n");
}
void initAndPrintRandomMask(affinityMask_t *affinityMask) {
  CPU_ZERO(affinityMask);
  srand(time(NULL));
  unsigned long numProcessors = Intel::OpenCL::Utils::GetNumberOfProcessors();
  for (unsigned long i = 0; i < numProcessors; ++i) {
    if (rand() & 0x1) {
      CPU_SET(i, affinityMask);
    }
  }
  int count = CPU_COUNT(affinityMask);
  if (0 == count) {
    CPU_SET(rand() % numProcessors, affinityMask);
    ++count;
  }

  printf("Using mask 0x");
  printAffinityMask(affinityMask);
}

void translateAndPrintMask(affinityMask_t *affinityMask, unsigned long val) {
  CPU_ZERO(affinityMask);
  int i = 0;
  while (val > 0) {
    if (val & 0x1) {
      CPU_SET(i, affinityMask);
    }
    val >>= 1;
    ++i;
  }
  printf("Using mask 0x");
  printAffinityMask(affinityMask);
}
#endif

#ifdef _WIN32
bool AtExitTaskExecutor::EnableTaskExecutorFinalizing = true;
#endif

int main(int argc, char *argv[]) {
#ifdef _WIN32
  AtExitTaskExecutor guard;
#endif

  ::testing::InitGoogleTest(&argc, argv);
#ifndef _WIN32
  affinityMask_t affinityMask;
  // Check for parameters not to gtest
  if (argc > 1) {
    if (argc != 2) {
      printf("Usage: %s <-mask=val> where val is a number in hex format or "
             "RANDOM\n",
             argv[0]);
      return -1;
    }
    const char *param = argv[1];
    if (strlen(param) < strlen("-mask=")) {
      printf("Usage: %s <-mask=val> where val is a number in hex format or "
             "RANDOM\n",
             argv[0]);
      return -1;
    }

    if (!strcmp(param, "-mask=RANDOM")) {
      initAndPrintRandomMask(&affinityMask);
    } else {
      unsigned long aff = strtoul(param + 6, NULL, 0);
      if (0 == aff) {
        printf("illegal value specified for mask (%s)\n", param + 6);
        return -1;
      }
      translateAndPrintMask(&affinityMask, aff);
    }

    sched_setaffinity(0, sizeof(affinityMask), &affinityMask);
    pMask = &affinityMask;
  }
#endif
  using namespace Intel::OpenCL::Utils;
  BasicCLConfigWrapper *config = new BasicCLConfigWrapper();
  config->Initialize(GetConfigFilePath());
  CPUDeviceTest_Init(config);
  if (::testing::Test::HasFatalFailure())
    return -1;

  int rc = RUN_ALL_TESTS();
  // This is disabled due to shutdown issue and will be fixed.
  // dev_entry->clDevCloseDevice();
  delete config;
  return rc;
}
