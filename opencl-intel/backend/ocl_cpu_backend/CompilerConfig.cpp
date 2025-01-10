// INTEL CONFIDENTIAL
//
// Copyright 2010 Intel Corporation.
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

#include "CompilerConfig.h"
#include "PipeCommon.h"
#include "cl_config.h"
#include "cl_env.h"
#include "cl_sys_defines.h"
#include "cl_utils.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Transforms/SYCLTransforms/Utils/SYCLStatistic.h"

#include <sstream>
#include <string.h>

using namespace llvm;

extern cl::opt<std::string> OptReqdSubGroupSizes;

namespace Intel {
namespace OpenCL {
namespace DeviceBackend {

using Intel::OpenCL::Utils::ConfigFile;

static ETransposeSize parseTransposeSize(int TSize) {
  static constexpr int ValidTSizes[] = {
      TRANSPOSE_SIZE_NOT_SET, TRANSPOSE_SIZE_AUTO, TRANSPOSE_SIZE_1,
      TRANSPOSE_SIZE_4,       TRANSPOSE_SIZE_8,    TRANSPOSE_SIZE_16,
      TRANSPOSE_SIZE_32,      TRANSPOSE_SIZE_64};
  if (std::find(std::begin(ValidTSizes), std::end(ValidTSizes), TSize) ==
      std::end(ValidTSizes))
    return TRANSPOSE_SIZE_INVALID;
  return (ETransposeSize)TSize;
}

void GlobalCompilerConfig::LoadConfig() {
  std::string Env;
#ifndef NDEBUG
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_ENABLE_TIMING"))
    m_enableTiming = ConfigFile::ConvertStringToType<bool>(Env);
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_INFO_OUTPUT_FILE"))
    m_infoOutputFile = Env;
#endif // NDEBUG
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_DISABLE_STACK_TRACE"))
    m_disableStackDump = ConfigFile::ConvertStringToType<bool>(Env);

  // Stat options are set as llvm options for 2 reasons
  // they are available also for opt
  // no need to fuse them all the way down to all passes

  // If environment variable CL_CONFIG_DUMP_IR_AFTER_OPTIMIZER is set to true,
  // then IR containing statistic information will be dumped.
  if ((Intel::OpenCL::Utils::getEnvVar(Env,
                                       "CL_CONFIG_DUMP_IR_AFTER_OPTIMIZER") &&
       ConfigFile::ConvertStringToType<bool>(Env)) ||
      (Intel::OpenCL::Utils::getEnvVar(Env,
                                       "CL_CONFIG_DUMP_IR_BEFORE_OPTIMIZER") &&
       ConfigFile::ConvertStringToType<bool>(Env))) {
    SYCLStatistic::enableStats();
    // all statistic will be dumped.
    SYCLStatistic::setCurrentStatType("all");
  }

  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_CPU_REQD_SUB_GROUP_SIZE"))
    m_LLVMOptions.emplace_back("-" + OptReqdSubGroupSizes.ArgStr.str() + "=" +
                               Env);

  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_CPU_O0_VECTORIZATION") &&
      ConfigFile::ConvertStringToType<bool>(Env)) {
    // Enable O0 vectorization for SYCL pipeline
    m_LLVMOptions.emplace_back("-sycl-enable-o0-vectorization");
    // Enable O0 vectorization for C++ pipeline
    m_LLVMOptions.emplace_back("-enable-o0-vectorization");
  }
}

void GlobalCompilerConfig::ApplyRuntimeOptions(
    const ICLDevBackendOptions *pBackendOptions) {
  if (nullptr == pBackendOptions)
    return;

  m_infoOutputFile = pBackendOptions->GetStringValue(
      (int)CL_DEV_BACKEND_OPTION_TIME_PASSES, m_infoOutputFile.c_str());
  m_enableTiming = !m_infoOutputFile.empty();

  // C++ pipeline command line options.
  m_LLVMOptions.emplace_back("-enable-epilogue-vectorization=false");
  ETransposeSize TransposeSize =
      parseTransposeSize(pBackendOptions->GetIntValue(
          (int)CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE, TRANSPOSE_SIZE_NOT_SET));
  if (TRANSPOSE_SIZE_AUTO != TransposeSize &&
      TRANSPOSE_SIZE_NOT_SET != TransposeSize)
    m_LLVMOptions.emplace_back("-sycl-force-vf=" +
                               std::to_string((int)TransposeSize));
  // This flag avoids vectorizer bailout in case of unsafe scalar store. In some
  // cases it is hard to reason from IR whether the store is safe. Even if it is
  // unsafe and there is race condition, it is probably undefind behavior in the
  // test because each lane in whole function vectorization is an independent
  // work-item and there is no guaranteed order of their executions.
  // m_LLVMOptions.emplace_back("-vplan-allow-scalar-stores");

  m_targetDevice = static_cast<DeviceMode>(pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_DEVICE, CPU_DEVICE));

  if (FPGA_EMU_DEVICE == m_targetDevice) {
    int channelDepthEmulationMode = pBackendOptions->GetIntValue(
        (int)CL_DEV_BACKEND_OPTION_CHANNEL_DEPTH_EMULATION_MODE,
        (int)CHANNEL_DEPTH_MODE_STRICT);
    m_LLVMOptions.emplace_back("--sycl-channel-depth-emulation-mode=" +
                               std::to_string(channelDepthEmulationMode));
    m_LLVMOptions.emplace_back("--sycl-remove-fpga-reg");
    m_LLVMOptions.emplace_back("--sycl-demangle-fpga-pipes");
  }

  bool EnableSubgroupEmulation = pBackendOptions->GetBooleanValue(
      (int)CL_DEV_BACKEND_OPTION_SUBGROUP_EMULATION, true);
  if (!EnableSubgroupEmulation)
    m_LLVMOptions.emplace_back("-sycl-enable-subgroup-emulation=false");

  size_t MaxPrivateMemSize = []() {
#ifdef _WIN32
    // Main thread stack size is 1MB by default on Windows.
    return 1024 * 1024 - CPU_DEV_BASE_STACK_SIZE - CPU_DEV_LCL_MEM_SIZE;
#else
    return CPU_DEV_MAX_WG_PRIVATE_SIZE;
#endif
  }();
  m_LLVMOptions.emplace_back("-sycl-kernel-max-private-mem-size=" +
                             std::to_string(MaxPrivateMemSize));

  // Set machinesink's machine-sink-load-instrs-threshold and
  // machine-sink-load-blocks-threshold to 0 otherwise it may possibly
  // increase ocl's jit compile time dramatically, especially for large
  // kernels.
  m_LLVMOptions.emplace_back("-machine-sink-load-instrs-threshold=0");
  m_LLVMOptions.emplace_back("-machine-sink-load-blocks-threshold=0");

  // Reduce codegen compile time in a llama example.
  // m_LLVMOptions.emplace_back("-region-splitting-iterate-threshold=100000000");

  // Handle CL_DEV_BACKEND_OPTION_LLVM_OPTION at the end so that it can pass an
  // option to overturn a previously added option.
  std::string LLVMOption = pBackendOptions->GetStringValue(
      (int)CL_DEV_BACKEND_OPTION_LLVM_OPTION, "");
  if (!LLVMOption.empty()) {
    std::vector<std::string> Options = SplitString(LLVMOption, ' ');
    m_LLVMOptions.append(Options.begin(), Options.end());
  }
}

void CompilerConfig::LoadConfig() {
  std::string Env;
  // TODO: Add validation code
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_CPU_TARGET_ARCH"))
    m_cpuArch = Env;
#ifndef NDEBUG
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_CPU_FEATURES")) {
    // The validity of the cpud features are checked upon parsing of optimizer
    // options
    m_cpuFeatures = Env;
  }

  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_DEBUG"))
    llvm::DebugFlag = true;
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_DEBUG_ONLY"))
    setCurrentDebugType(Env.c_str());
#endif // NDEBUG
  if (Intel::OpenCL::Utils::getEnvVar(Env, "CL_CONFIG_DUMP_FILE_NAME_PREFIX")) {
    // base name for stat files
    m_dumpFilenamePrefix = Env;
  }
}

void CompilerConfig::ApplyRuntimeOptions(
    const ICLDevBackendOptions *pBackendOptions) {
  if (nullptr == pBackendOptions) {
    return;
  }
  m_cpuArch = pBackendOptions->GetStringValue(
      (int)CL_DEV_BACKEND_OPTION_SUBDEVICE, m_cpuArch.c_str());
  m_cpuFeatures = pBackendOptions->GetStringValue(
      (int)CL_DEV_BACKEND_OPTION_SUBDEVICE_FEATURES, m_cpuFeatures.c_str());
  m_deviceMaxWGSize = (size_t)pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_CPU_MAX_WG_SIZE, (int)m_deviceMaxWGSize);

  m_transposeSize = parseTransposeSize(pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE, m_transposeSize));
  m_rtLoopUnrollFactor = pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_RT_LOOP_UNROLL_FACTOR, m_rtLoopUnrollFactor);
  m_useVTune = pBackendOptions->GetBooleanValue(
      (int)CL_DEV_BACKEND_OPTION_USE_VTUNE, m_useVTune);
  m_serializeWorkGroups = pBackendOptions->GetBooleanValue(
      (int)CL_DEV_BACKEND_OPTION_SERIALIZE_WORK_GROUPS, m_serializeWorkGroups);
  m_dumpHeuristicIR = pBackendOptions->GetBooleanValue(
      (int)CL_DEV_BACKEND_OPTION_DUMP_HEURISTIC_IR, m_dumpHeuristicIR);
  m_streamingAlways = pBackendOptions->GetBooleanValue(
      (int)CL_DEV_BACKEND_OPTION_STREAMING_ALWAYS, m_streamingAlways);
  m_expensiveMemOpts = pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_EXPENSIVE_MEM_OPTS, m_expensiveMemOpts);
  m_targetDevice = static_cast<DeviceMode>(pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_DEVICE, CPU_DEVICE));
  m_passManagerType = static_cast<PassManagerType>(pBackendOptions->GetIntValue(
      CL_DEV_BACKEND_OPTION_PASS_MANAGER_TYPE, PM_NONE));
  m_subGroupConstructionMode = pBackendOptions->GetIntValue(
      (int)CL_DEV_BACKEND_OPTION_SUB_GROUP_CONSTRUCTION, 0);
}

} // namespace DeviceBackend
} // namespace OpenCL
} // namespace Intel
