/*****************************************************************************\

Copyright (c) Intel Corporation (2012).

INTEL MAKES NO WARRANTY OF ANY KIND REGARDING THE CODE.  THIS CODE IS
LICENSED ON AN "AS IS" BASIS AND INTEL WILL NOT PROVIDE ANY SUPPORT,
ASSISTANCE, INSTALLATION, TRAINING OR OTHER SERVICES.  INTEL DOES NOT
PROVIDE ANY UPDATES, ENHANCEMENTS OR EXTENSIONS.  INTEL SPECIFICALLY
DISCLAIMS ANY WARRANTY OF MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR ANY
PARTICULAR PURPOSE, OR ANY OTHER WARRANTY.  Intel disclaims all liability,
including liability for infringement of any proprietary rights, relating to
use of the code. No license, express or implied, by estoppels or otherwise,
to any intellectual property rights is granted herein.

File Name:  FactoryTest.cpp

\*****************************************************************************/

#include "BackendWrapper.h"
#include "gtest_wrapper.h"

using CPUDetect = Intel::OpenCL::Utils::CPUDetect;
using ECPU = Intel::OpenCL::Utils::ECPU;

TEST_F(BackEndTests_FactoryMethods, FactoryInitialization) {
  // get Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);
}

TEST_F(BackEndTests_FactoryMethods, CompilerServiceCreation) {
  // get Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);

  CompilationServiceOptions options;
  cl_dev_err_code ret;

  //-----------------------------------------------------------------
  // create valid set of options
  options.InitFromTestConfiguration(CPU_DEVICE, "auto", "", TRANSPOSE_SIZE_AUTO,
                                    false);
  EXPECT_FALSE(options.GetBooleanValue(CL_DEV_BACKEND_OPTION_USE_VTUNE, false));
  EXPECT_TRUE(STRING_EQ("", options.GetStringValue(
                                CL_DEV_BACKEND_OPTION_SUBDEVICE_FEATURES, "")));
  EXPECT_TRUE(STRING_EQ(
      "auto", options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
  EXPECT_EQ(TRANSPOSE_SIZE_AUTO,
            options.GetIntValue(CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE,
                                TRANSPOSE_SIZE_UNSUPPORTED));
  // call GetCompilationService with valid parameters - should success
  ICLDevBackendCompilationService *pCompileService = nullptr;
  ret = funcGetFactory->GetCompilationService(&options, &pCompileService);
  ICLDevBackendCompileServicePtr spCompileService(pCompileService);
  EXPECT_EQ(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // create another set of valid options
  ECPU curCPUEnum = CPUDetect::GetInstance()->GetCPU();
  std::string CPUStringName = CPUDetect::GetCPUName(curCPUEnum);
  options.InitFromTestConfiguration(CPU_DEVICE, CPUStringName, "",
                                    TRANSPOSE_SIZE_1, true);
  EXPECT_TRUE(options.GetBooleanValue(CL_DEV_BACKEND_OPTION_USE_VTUNE, false));
  EXPECT_TRUE(STRING_EQ("", options.GetStringValue(
                                CL_DEV_BACKEND_OPTION_SUBDEVICE_FEATURES, "")));
  EXPECT_TRUE(
      STRING_EQ(CPUStringName,
                options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
  EXPECT_EQ(TRANSPOSE_SIZE_1,
            options.GetIntValue(CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE,
                                TRANSPOSE_SIZE_UNSUPPORTED));
  // call GetCompilationService with valid parameters - should success
  ret = funcGetFactory->GetCompilationService(&options, &pCompileService);
  if (pCompileService != spCompileService.get())
    spCompileService.reset(pCompileService);
  EXPECT_EQ(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // create another set of valid options - enabling special features
  const bool avx1Support = CPUDetect::GetInstance()->HasAVX1();
  if (avx1Support) {
    options.InitFromTestConfiguration(CPU_DEVICE, CPUStringName, "+avx",
                                      TRANSPOSE_SIZE_16, false);
    EXPECT_FALSE(
        options.GetBooleanValue(CL_DEV_BACKEND_OPTION_USE_VTUNE, false));
    EXPECT_TRUE(STRING_EQ(
        "+avx",
        options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE_FEATURES, "")));
    EXPECT_TRUE(
        STRING_EQ(CPUStringName,
                  options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
    EXPECT_EQ(TRANSPOSE_SIZE_16,
              options.GetIntValue(CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE,
                                  TRANSPOSE_SIZE_UNSUPPORTED));
    // call GetCompilationService with valid parameters - should success
    ret = funcGetFactory->GetCompilationService(&options, &pCompileService);
    if (pCompileService != spCompileService.get())
      spCompileService.reset(pCompileService);
    EXPECT_EQ(CL_DEV_SUCCESS, ret);
  }
}

TEST_F(BackEndTests_FactoryMethods, CompilerServiceFailure) {
  // get the Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);

  CompilationServiceOptions options;
  cl_dev_err_code ret;

  //-----------------------------------------------------------------
  // create invalid set of options - unsupported architecture
  options.InitFromTestConfiguration(CPU_DEVICE, ARCH_UNSUPPORTED, "",
                                    TRANSPOSE_SIZE_AUTO, false);
  EXPECT_FALSE(options.GetBooleanValue(CL_DEV_BACKEND_OPTION_USE_VTUNE, false));
  EXPECT_TRUE(STRING_EQ("", options.GetStringValue(
                                CL_DEV_BACKEND_OPTION_SUBDEVICE_FEATURES, "")));
  EXPECT_EQ(TRANSPOSE_SIZE_AUTO,
            options.GetIntValue(CL_DEV_BACKEND_OPTION_TRANSPOSE_SIZE,
                                TRANSPOSE_SIZE_UNSUPPORTED));
  EXPECT_TRUE(STRING_EQ(
      ARCH_UNSUPPORTED,
      options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "auto")));
  // call GetCompilationService with Options invalid - should fail
  ICLDevBackendCompilationService *pCompileService = nullptr;
  ret = funcGetFactory->GetCompilationService(&options, &pCompileService);
  ICLDevBackendCompileServicePtr spCompileService(pCompileService);
  EXPECT_NE(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // test invalid parameters to the actuall GetCompilationService call
  // call GetCompilationService with Output variable NULL - should fail with no
  // crash
  ret = funcGetFactory->GetCompilationService(NULL, NULL);
  EXPECT_NE(CL_DEV_SUCCESS, ret);
}

TEST_F(BackEndTests_FactoryMethods, ExecutionServiceCreation) {
  // get the Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);

  ExecutionServiceOptions options;
  cl_dev_err_code ret;

  //-----------------------------------------------------------------
  // create valid set of options
  options.InitFromTestConfiguration(BW_CPU_DEVICE, "auto");
  EXPECT_TRUE(STRING_EQ(
      "auto", options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
  // call GetExecutionService with valid parameters - should success
  ICLDevBackendExecutionService *pExecutionService = nullptr;
  ret = funcGetFactory->GetExecutionService(&options, &pExecutionService);
  ICLDevBackendExecutionServicePtr spExecutionService(pExecutionService);
  EXPECT_EQ(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // create another set of valid options
  std::string currCPU =
      Intel::OpenCL::Utils::CPUDetect::GetInstance()->GetCPUName();
  options.InitFromTestConfiguration(CPU_DEVICE, currCPU);
  EXPECT_TRUE(STRING_EQ(
      currCPU, options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
  // call GetExecutionService with valid parameters - should success
  ret = funcGetFactory->GetExecutionService(&options, &pExecutionService);
  if (pExecutionService != spExecutionService.get())
    spExecutionService.reset(pExecutionService);
  EXPECT_EQ(CL_DEV_SUCCESS, ret);
}

TEST_F(BackEndTests_FactoryMethods, ExecutionServiceFailure) {
  // get the Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);

  ExecutionServiceOptions options;
  cl_dev_err_code ret;

  //-----------------------------------------------------------------
  // create invalid opthions parameters - unsupported architecture
  options.InitFromTestConfiguration(static_cast<DeviceMode>(UNSUPPORTED_DEVICE),
                                    ARCH_UNSUPPORTED);
  EXPECT_TRUE(STRING_EQ(
      ARCH_UNSUPPORTED,
      options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "auto")));
  // call GetExecutionService with Options invalid - should fail
  ICLDevBackendExecutionService *pExecutionService = nullptr;
  ret = funcGetFactory->GetExecutionService(&options, &pExecutionService);
  ICLDevBackendExecutionServicePtr spExecutionService(pExecutionService);
  EXPECT_NE(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // test invalid parameters to the actuall GetExecutionService call
  // call GetExecutionService with Output variable NULL - should fail
  ret = funcGetFactory->GetExecutionService(NULL, NULL);
  EXPECT_NE(CL_DEV_SUCCESS, ret);
}

TEST_F(BackEndTests_FactoryMethods, SerializationServiceFailure) {
  // get the Backend service factory
  ICLDevBackendServiceFactory *funcGetFactory =
      BackendWrapper::GetInstance().GetBackendServiceFactory();
  ASSERT_TRUE(funcGetFactory);
  // init the jit allocator and get instance
  JITAllocator::Init();
  JITAllocator *pJITAllocator = JITAllocator::GetInstance();
  ASSERT_TRUE(pJITAllocator);
  void *pJITAllocatorTemp;
  size_t size;
  SerializationServiceOptions options;
  cl_dev_err_code ret;

  //-----------------------------------------------------------------
  // create invalid set of options - unsupported architecture
  options.InitFromTestConfiguration(BW_CPU_DEVICE, ARCH_UNSUPPORTED,
                                    pJITAllocator);
  EXPECT_TRUE(STRING_EQ(
      ARCH_UNSUPPORTED,
      options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "auto")));
  pJITAllocatorTemp = NULL;
  size = 0;
  options.GetValue(CL_DEV_BACKEND_OPTION_JIT_ALLOCATOR, &pJITAllocatorTemp,
                   &size);
  EXPECT_EQ(pJITAllocator, pJITAllocatorTemp);
  // call GetSerializationService with Options invalid - should fail
  ICLDevBackendSerializationService *pSerializationService = nullptr;
  ret =
      funcGetFactory->GetSerializationService(&options, &pSerializationService);
  ICLDevBackendSerializationServicePtr spSerializationService(
      pSerializationService);
  EXPECT_NE(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // create another set of invalid options - CPU mode and not MIC mode
  options.InitFromTestConfiguration(BW_CPU_DEVICE, "auto", pJITAllocator);
  EXPECT_TRUE(STRING_EQ(
      "auto", options.GetStringValue(CL_DEV_BACKEND_OPTION_SUBDEVICE, "")));
  pJITAllocatorTemp = NULL;
  size = 0;
  options.GetValue(CL_DEV_BACKEND_OPTION_JIT_ALLOCATOR, &pJITAllocatorTemp,
                   &size);
  EXPECT_EQ(pJITAllocator, pJITAllocatorTemp);
  // call GetSerializationService with Options invalid - should fail with no
  // crash
  ret =
      funcGetFactory->GetSerializationService(&options, &pSerializationService);
  if (pSerializationService != spSerializationService.get())
    spSerializationService.reset(pSerializationService);
  EXPECT_NE(CL_DEV_SUCCESS, ret);

  //-----------------------------------------------------------------
  // test invalid parameters to the actuall GetSerializationService
  // call GetSerializationService with NULL in output variable - should fail
  ret = funcGetFactory->GetSerializationService(NULL, NULL);
  EXPECT_NE(CL_DEV_SUCCESS, ret);
}
