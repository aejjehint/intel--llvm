// INTEL CONFIDENTIAL
//
// Copyright 2006 Intel Corporation.
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

#include "framework_proxy.h"
#include "Logger.h"
#include "cl_shared_ptr.hpp"
#include "cl_sys_defines.h"
#include "cl_sys_info.h"
#include "task_executor.h"
#include "llvm/Support/Threading.h"

#if defined(_WIN32)
#include <windows.h>
#else
#include "cl_secure_string_linux.h"
#endif
using namespace Intel::OpenCL::Framework;
using namespace Intel::OpenCL::TaskExecutor;
using namespace Intel::OpenCL::Utils;

cl_monitor_init

    cl_icd_dispatch FrameworkProxy::ICDDispatchTable;
SOCLCRTDispatchTable FrameworkProxy::CRTDispatchTable;
ocl_entry_points FrameworkProxy::OclEntryPoints;

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy()
///////////////////////////////////////////////////////////////////////////////////////////////////
FrameworkProxy::FrameworkProxy() {
  m_pPlatformModule = nullptr;
  m_pContextModule = nullptr;
  m_pExecutionModule = nullptr;
  m_pFileLogHandler = nullptr;
  m_pConfig = nullptr;
  m_pLoggerClient = nullptr;
  m_pTaskExecutor = nullptr;
  m_pTaskList = nullptr;
  m_pTaskList_immediate = nullptr;

  Initialize();
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// ~FrameworkProxy()
///////////////////////////////////////////////////////////////////////////////////////////////////
FrameworkProxy::~FrameworkProxy() {}

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#elif defined(_WIN32) && !defined(_WIN64)
#pragma warning(push)
#pragma warning(disable : 4996)
#endif
void FrameworkProxy::InitOCLEntryPoints() {
  OclEntryPoints.icdDispatch = &ICDDispatchTable;
  OclEntryPoints.crtDispatch = &CRTDispatchTable;

  /// ICD functions
  ICDDispatchTable.clGetPlatformIDs = clGetPlatformIDs;
  ICDDispatchTable.clGetPlatformInfo = clGetPlatformInfo;
  ICDDispatchTable.clGetDeviceIDs = clGetDeviceIDs;
  ICDDispatchTable.clGetDeviceInfo = clGetDeviceInfo;
  ICDDispatchTable.clCreateContext = clCreateContext;
  ICDDispatchTable.clCreateContextFromType = clCreateContextFromType;
  ICDDispatchTable.clSetContextDestructorCallback =
      clSetContextDestructorCallback;
  ICDDispatchTable.clSetProgramReleaseCallback = clSetProgramReleaseCallback;
  ICDDispatchTable.clRetainContext = clRetainContext;
  ICDDispatchTable.clReleaseContext = clReleaseContext;
  ICDDispatchTable.clGetContextInfo = clGetContextInfo;
  ICDDispatchTable.clCreateCommandQueue = clCreateCommandQueue;
  ICDDispatchTable.clCreateCommandQueueWithProperties =
      clCreateCommandQueueWithProperties;
  ICDDispatchTable.clRetainCommandQueue = clRetainCommandQueue;
  ICDDispatchTable.clReleaseCommandQueue = clReleaseCommandQueue;
  ICDDispatchTable.clGetCommandQueueInfo = clGetCommandQueueInfo;
  ICDDispatchTable.clSetCommandQueueProperty = clSetCommandQueueProperty;
  ICDDispatchTable.clCreateBuffer = clCreateBuffer;
  ICDDispatchTable.clCreateBufferWithProperties = clCreateBufferWithProperties;
  ICDDispatchTable.clCreateImage = clCreateImage;
  ICDDispatchTable.clCreateImageWithProperties = clCreateImageWithProperties;
  ICDDispatchTable.clCreateImage2D = clCreateImage2D;
  ICDDispatchTable.clCreateImage3D = clCreateImage3D;
  ICDDispatchTable.clRetainMemObject = clRetainMemObject;
  ICDDispatchTable.clReleaseMemObject = clReleaseMemObject;
  ICDDispatchTable.clGetSupportedImageFormats = clGetSupportedImageFormats;
  ICDDispatchTable.clGetMemObjectInfo = clGetMemObjectInfo;
  ICDDispatchTable.clGetImageInfo = clGetImageInfo;
  ICDDispatchTable.clCreateSampler = clCreateSampler;
  ICDDispatchTable.clCreateSamplerWithProperties =
      clCreateSamplerWithProperties;
  ICDDispatchTable.clRetainSampler = clRetainSampler;
  ICDDispatchTable.clReleaseSampler = clReleaseSampler;
  ICDDispatchTable.clGetSamplerInfo = clGetSamplerInfo;
  ICDDispatchTable.clCreateProgramWithSource = clCreateProgramWithSource;
  ICDDispatchTable.clSetDefaultDeviceCommandQueue =
      clSetDefaultDeviceCommandQueue;
  ICDDispatchTable.clCreateProgramWithBinary = clCreateProgramWithBinary;
  ICDDispatchTable.clCreateProgramWithBuiltInKernels =
      clCreateProgramWithBuiltInKernels;
  ICDDispatchTable.clCreateProgramWithIL = clCreateProgramWithIL;
  ICDDispatchTable.clRetainProgram = clRetainProgram;
  ICDDispatchTable.clReleaseProgram = clReleaseProgram;
  ICDDispatchTable.clBuildProgram = clBuildProgram;
  ICDDispatchTable.clCompileProgram = clCompileProgram;
  ICDDispatchTable.clLinkProgram = clLinkProgram;
  ICDDispatchTable.clUnloadCompiler = clUnloadCompiler;
  ICDDispatchTable.clUnloadPlatformCompiler = clUnloadPlatformCompiler;
  ICDDispatchTable.clGetProgramInfo = clGetProgramInfo;
  ICDDispatchTable.clGetProgramBuildInfo = clGetProgramBuildInfo;
  ICDDispatchTable.clCreateKernel = clCreateKernel;
  ICDDispatchTable.clCreateKernelsInProgram = clCreateKernelsInProgram;
  ICDDispatchTable.clRetainKernel = clRetainKernel;
  ICDDispatchTable.clReleaseKernel = clReleaseKernel;
  ICDDispatchTable.clSetKernelArg = clSetKernelArg;
  ICDDispatchTable.clGetKernelInfo = clGetKernelInfo;
  ICDDispatchTable.clCloneKernel = clCloneKernel;
  ICDDispatchTable.clGetHostTimer = clGetHostTimer;
  ICDDispatchTable.clGetDeviceAndHostTimer = clGetDeviceAndHostTimer;
  ICDDispatchTable.clGetKernelWorkGroupInfo = clGetKernelWorkGroupInfo;
  ICDDispatchTable.clGetKernelSubGroupInfo = clGetKernelSubGroupInfo;
  ICDDispatchTable.clGetKernelSubGroupInfoKHR = clGetKernelSubGroupInfoKHR;
  ICDDispatchTable.clWaitForEvents = clWaitForEvents;
  ICDDispatchTable.clGetEventInfo = clGetEventInfo;
  ICDDispatchTable.clRetainEvent = clRetainEvent;
  ICDDispatchTable.clReleaseEvent = clReleaseEvent;
  ICDDispatchTable.clGetEventProfilingInfo = clGetEventProfilingInfo;
  ICDDispatchTable.clFlush = clFlush;
  ICDDispatchTable.clFinish = clFinish;
  ICDDispatchTable.clEnqueueReadBuffer = clEnqueueReadBuffer;
  ICDDispatchTable.clEnqueueWriteBuffer = clEnqueueWriteBuffer;
  ICDDispatchTable.clEnqueueCopyBuffer = clEnqueueCopyBuffer;
  ICDDispatchTable.clEnqueueFillBuffer = clEnqueueFillBuffer;
  ICDDispatchTable.clEnqueueFillImage = clEnqueueFillImage;
  ICDDispatchTable.clEnqueueReadImage = clEnqueueReadImage;
  ICDDispatchTable.clEnqueueWriteImage = clEnqueueWriteImage;
  ICDDispatchTable.clEnqueueCopyImage = clEnqueueCopyImage;
  ICDDispatchTable.clEnqueueCopyImageToBuffer = clEnqueueCopyImageToBuffer;
  ICDDispatchTable.clEnqueueCopyBufferToImage = clEnqueueCopyBufferToImage;
  ICDDispatchTable.clEnqueueMapBuffer = clEnqueueMapBuffer;
  ICDDispatchTable.clEnqueueMapImage = clEnqueueMapImage;
  ICDDispatchTable.clEnqueueUnmapMemObject = clEnqueueUnmapMemObject;
  ICDDispatchTable.clEnqueueNDRangeKernel = clEnqueueNDRangeKernel;
  ICDDispatchTable.clEnqueueTask = clEnqueueTask;
  ICDDispatchTable.clEnqueueNativeKernel = clEnqueueNativeKernel;
  ICDDispatchTable.clEnqueueMarker = clEnqueueMarker;
  ICDDispatchTable.clEnqueueMarkerWithWaitList = clEnqueueMarkerWithWaitList;
  ICDDispatchTable.clEnqueueBarrierWithWaitList = clEnqueueBarrierWithWaitList;
  ICDDispatchTable.clEnqueueWaitForEvents = clEnqueueWaitForEvents;
  ICDDispatchTable.clEnqueueBarrier = clEnqueueBarrier;
  ICDDispatchTable.clGetExtensionFunctionAddress =
      clGetExtensionFunctionAddress;
  ICDDispatchTable.clGetExtensionFunctionAddressForPlatform =
      clGetExtensionFunctionAddressForPlatform;
  ICDDispatchTable.clCreateFromGLBuffer = nullptr;
  ICDDispatchTable.clCreateFromGLTexture = nullptr;
  ICDDispatchTable.clCreateFromGLTexture2D = nullptr;
  ICDDispatchTable.clCreateFromGLTexture3D = nullptr;
  ICDDispatchTable.clCreateFromGLRenderbuffer = nullptr;
  ICDDispatchTable.clGetGLObjectInfo = nullptr;
  ICDDispatchTable.clGetGLTextureInfo = nullptr;
  ICDDispatchTable.clEnqueueAcquireGLObjects = nullptr;
  ICDDispatchTable.clEnqueueReleaseGLObjects = nullptr;
  ICDDispatchTable.clGetGLContextInfoKHR = nullptr;
  ICDDispatchTable.clGetDeviceIDsFromD3D10KHR = nullptr;
  ICDDispatchTable.clCreateFromD3D10BufferKHR = nullptr;
  ICDDispatchTable.clCreateFromD3D10Texture2DKHR = nullptr;
  ICDDispatchTable.clCreateFromD3D10Texture3DKHR = nullptr;
  ICDDispatchTable.clEnqueueAcquireD3D10ObjectsKHR = nullptr;
  ICDDispatchTable.clEnqueueReleaseD3D10ObjectsKHR = nullptr;
  ICDDispatchTable.clSetEventCallback = clSetEventCallback;
  ICDDispatchTable.clCreateSubBuffer = clCreateSubBuffer;
  ICDDispatchTable.clSetMemObjectDestructorCallback =
      clSetMemObjectDestructorCallback;
  ICDDispatchTable.clCreateUserEvent = clCreateUserEvent;
  ICDDispatchTable.clSetUserEventStatus = clSetUserEventStatus;
  ICDDispatchTable.clEnqueueReadBufferRect = clEnqueueReadBufferRect;
  ICDDispatchTable.clEnqueueWriteBufferRect = clEnqueueWriteBufferRect;
  ICDDispatchTable.clEnqueueCopyBufferRect = clEnqueueCopyBufferRect;
  ICDDispatchTable.clEnqueueMigrateMemObjects = clEnqueueMigrateMemObjects;
  ICDDispatchTable.clCreateSubDevices = clCreateSubDevices;
  ICDDispatchTable.clRetainDevice = clRetainDevice;
  ICDDispatchTable.clReleaseDevice = clReleaseDevice;
  ICDDispatchTable.clGetKernelArgInfo = clGetKernelArgInfo;

  ICDDispatchTable.clEnqueueBarrierWithWaitList = clEnqueueBarrierWithWaitList;
  ICDDispatchTable.clCompileProgram = clCompileProgram;
  ICDDispatchTable.clLinkProgram = clLinkProgram;
  ICDDispatchTable.clEnqueueMarkerWithWaitList = clEnqueueMarkerWithWaitList;

  ICDDispatchTable.clSVMAlloc = clSVMAlloc;
  ICDDispatchTable.clSVMFree = clSVMFree;
  ICDDispatchTable.clEnqueueSVMFree = clEnqueueSVMFree;
  ICDDispatchTable.clEnqueueSVMMemcpy = clEnqueueSVMMemcpy;
  ICDDispatchTable.clEnqueueSVMMemFill = clEnqueueSVMMemFill;
  ICDDispatchTable.clEnqueueSVMMap = clEnqueueSVMMap;
  ICDDispatchTable.clEnqueueSVMMigrateMem = clEnqueueSVMMigrateMem;
  ICDDispatchTable.clEnqueueSVMUnmap = clEnqueueSVMUnmap;
  ICDDispatchTable.clSetKernelArgSVMPointer = clSetKernelArgSVMPointer;
  ICDDispatchTable.clSetKernelExecInfo = clSetKernelExecInfo;

  ICDDispatchTable.clCreatePipe = clCreatePipe;
  ICDDispatchTable.clGetPipeInfo = clGetPipeInfo;

  ICDDispatchTable.clSetProgramSpecializationConstant =
      clSetProgramSpecializationConstant;

  /// Extra functions for Common Runtime
  CRTDispatchTable.clGetKernelArgInfo = clGetKernelArgInfo;
  CRTDispatchTable.clGetDeviceIDsFromDX9INTEL = nullptr;
  CRTDispatchTable.clCreateFromDX9MediaSurfaceINTEL = nullptr;
  CRTDispatchTable.clEnqueueAcquireDX9ObjectsINTEL = nullptr;
  CRTDispatchTable.clEnqueueReleaseDX9ObjectsINTEL = nullptr;

  ICDDispatchTable.clGetDeviceIDsFromDX9MediaAdapterKHR = nullptr;
  ICDDispatchTable.clCreateFromDX9MediaSurfaceKHR = nullptr;
  ICDDispatchTable.clEnqueueAcquireDX9MediaSurfacesKHR = nullptr;
  ICDDispatchTable.clEnqueueReleaseDX9MediaSurfacesKHR = nullptr;

  ICDDispatchTable.clGetDeviceIDsFromD3D11KHR = nullptr;
  ICDDispatchTable.clCreateFromD3D11BufferKHR = nullptr;
  ICDDispatchTable.clCreateFromD3D11Texture2DKHR = nullptr;
  ICDDispatchTable.clCreateFromD3D11Texture3DKHR = nullptr;
  ICDDispatchTable.clEnqueueAcquireD3D11ObjectsKHR = nullptr;
  ICDDispatchTable.clEnqueueReleaseD3D11ObjectsKHR = nullptr;
  // Nullify entries which are not relevant for CPU
  CRTDispatchTable.clGetImageParamsINTEL = nullptr;
  CRTDispatchTable.clCreatePerfCountersCommandQueueINTEL = nullptr;
  CRTDispatchTable.clCreateAcceleratorINTEL = nullptr;
  CRTDispatchTable.clGetAcceleratorInfoINTEL = nullptr;
  CRTDispatchTable.clRetainAcceleratorINTEL = nullptr;
  CRTDispatchTable.clReleaseAcceleratorINTEL = nullptr;
  CRTDispatchTable.clCreateProfiledProgramWithSourceINTEL = nullptr;
  CRTDispatchTable.clCreateKernelProfilingJournalINTEL = nullptr;
  CRTDispatchTable.clCreateFromVAMediaSurfaceINTEL = nullptr;
  CRTDispatchTable.clGetDeviceIDsFromVAMediaAdapterINTEL = nullptr;
  CRTDispatchTable.clEnqueueReleaseVAMediaSurfacesINTEL = nullptr;
  CRTDispatchTable.clEnqueueAcquireVAMediaSurfacesINTEL = nullptr;
  CRTDispatchTable.clCreatePipeINTEL = clCreatePipeINTEL;
  CRTDispatchTable.clSetDebugVariableINTEL = nullptr;
  CRTDispatchTable.clSetAcceleratorInfoINTEL = nullptr;

  /// Extra CPU specific functions
}
#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#elif defined(_WIN32) && !defined(_WIN64)
#pragma warning(pop)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Initialize()
///////////////////////////////////////////////////////////////////////////////////////////////////
void FrameworkProxy::Initialize() {

  // Initialize entry points table
  InitOCLEntryPoints();

  // initialize configuration file
  m_pConfig = new OCLConfig();
  m_pConfig->Initialize(GetConfigFilePath());

  bool bUseLogger = m_pConfig->UseLogger();
  if (bUseLogger) {
    string str = m_pConfig->GetLogFile();
    if (str != "") {
      // Construct file name with process ID
      // Search for file extension
      size_t ext = str.rfind(".");
      if (string::npos == ext) {
        // If "." not found -> no extension
        ext = str.length();
      }
      // Add Process if before the "."
      // Calculate Extension lenght
      std::string procId;
      const unsigned int pid_length = 16;
      procId.resize(pid_length);
      SPRINTF_S(&procId[0], pid_length, "_%d", GetProcessId());
      procId.resize(strlen(&procId[0]));
      str.insert(ext, procId);

      // Prepare log title
      char strProcName[MAX_PATH];
      GetProcessName(strProcName, MAX_PATH);
      std::string title = "---------------------------------> ";
      title += strProcName;
      title += " <-----------------------------------\n";

      // initialise logger
      m_pFileLogHandler = new FileLogHandler(TEXT("cl_framework"));
      cl_err_code clErrRet =
          m_pFileLogHandler->Init(LL_DEBUG, str.c_str(), title.c_str());
      if (CL_SUCCEEDED(clErrRet)) {
        Logger::GetInstance()->AddLogHandler(m_pFileLogHandler);
      }
    }
  }
  Logger::GetInstance()->SetActive(bUseLogger);

  INIT_LOGGER_CLIENT(TEXT("FrameworkProxy"), LL_DEBUG);
#if defined(USE_ITT)
  m_GPAData.bUseGPA = m_pConfig->EnableITT();
  m_GPAData.bEnableAPITracing = m_pConfig->EnableAPITracing();
  m_GPAData.bEnableContextTracing = m_pConfig->EnableContextTracing();
  m_GPAData.cStatusMarkerFlags = 0;
  if (m_GPAData.bUseGPA) {
    if (m_pConfig->ShowQueuedMarker())
      m_GPAData.cStatusMarkerFlags |= ITT_SHOW_QUEUED_MARKER;
    if (m_pConfig->ShowSubmittedMarker())
      m_GPAData.cStatusMarkerFlags |= ITT_SHOW_SUBMITTED_MARKER;
    if (m_pConfig->ShowRunningMarker())
      m_GPAData.cStatusMarkerFlags |= ITT_SHOW_RUNNING_MARKER;
    if (m_pConfig->ShowCompletedMarker())
      m_GPAData.cStatusMarkerFlags |= ITT_SHOW_COMPLETED_MARKER;

    // Create domains
    m_GPAData.pDeviceDomain = __itt_domain_create("OpenCL.Device");
    m_GPAData.pAPIDomain = __itt_domain_create("OpenCL.API");

    m_GPAData.pNDRangeHandle = __itt_string_handle_create("NDRange");
    m_GPAData.pReadHandle = __itt_string_handle_create("Read MemoryObject");
    m_GPAData.pWriteHandle = __itt_string_handle_create("Write MemoryObject");
    m_GPAData.pCopyHandle = __itt_string_handle_create("Copy MemoryObject");
    m_GPAData.pFillHandle = __itt_string_handle_create("Fill MemoryObject");
    m_GPAData.pMapHandle = __itt_string_handle_create("Map MemoryObject");
    m_GPAData.pUnmapHandle = __itt_string_handle_create("Unmap MemoryObject");
    m_GPAData.pSyncDataHandle = __itt_string_handle_create("Sync Data");
    m_GPAData.pSizeHandle = __itt_string_handle_create("Size W/H/D");
    m_GPAData.pWorkGroupSizeHandle =
        __itt_string_handle_create("Work Group Size");
    m_GPAData.pNumberOfWorkGroupsHandle =
        __itt_string_handle_create("Number of Work Groups");
    m_GPAData.pWorkGroupRangeHandle =
        __itt_string_handle_create("Work Group Range");
    m_GPAData.pMarkerHandle = __itt_string_handle_create("Marker");
    m_GPAData.pWorkDimensionHandle =
        __itt_string_handle_create("Work Dimension");
    m_GPAData.pGlobalWorkSizeHandle =
        __itt_string_handle_create("Global Work Size W/H/D");
    m_GPAData.pLocalWorkSizeHandle =
        __itt_string_handle_create("Local Work Size W/H/D");
    m_GPAData.pGlobalWorkOffsetHandle =
        __itt_string_handle_create("Global Work Offset");

    m_GPAData.pStartPos = __itt_string_handle_create("Start W/H/D");
    m_GPAData.pEndPos = __itt_string_handle_create("End W/H/D");

    m_GPAData.pIsBlocking = __itt_string_handle_create("Blocking");
    m_GPAData.pNumEventsInWaitList =
        __itt_string_handle_create("#Events in Wait List");
  }
#endif // ITT

  LOG_INFO(
      TEXT("%s"),
      "Initialize platform module: m_PlatformModule = new PlatformModule()");
  m_pPlatformModule = new PlatformModule();
  m_pPlatformModule->Initialize(&OclEntryPoints, m_pConfig, &m_GPAData);

  LOG_INFO(TEXT("Initialize context module: m_pContextModule = new "
                "ContextModule(%d)"),
           m_pPlatformModule);
  m_pContextModule = new ContextModule(m_pPlatformModule);
  m_pContextModule->Initialize(&OclEntryPoints, &m_GPAData);

  LOG_INFO(TEXT("Initialize context module: m_pExecutionModule = new "
                "ExecutionModule(%p,%p)"),
           m_pPlatformModule, m_pContextModule);
  m_pExecutionModule = new ExecutionModule(m_pPlatformModule, m_pContextModule);
  m_pExecutionModule->Initialize(&OclEntryPoints, m_pConfig, &m_GPAData);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::NeedToDisableAPIsAtShutdown()
///////////////////////////////////////////////////////////////////////////////////////////////////
bool FrameworkProxy::NeedToDisableAPIsAtShutdown() const {
  // On Windows OS kills all threads at shutdown except of one that is used to
  // call atexit() and DllMain(). As all thread killing is done when threads
  // are in an arbitrary state we cannot assume that they are not owning some
  // lock or that they freed their per-thread resources. As our OpenCL
  // implementation objects lifetime is based on reference counted objects we
  // cannot assume that performing normal shutdown will not block or will free
  // resources. So on Windows we should just block our external APIs to avoid
  // global object destructors from DLLs to enter our OpenCL DLLs.
  //
  // On FPGA emulator we should not kill contexts, execution modules, etc.
  // because program can contain `while (true)` kernels which can not be
  // finished using regular finish operation on command queue.
  //
  // On Linux all threads are alive and fully functional at atexit() time - so
  // full shutdown is possible.
  //
  // The shutdown mechanism is disabled for all configurations now.
  // The functionality provides is not required by the OpenCL specification
  // and there is no known customer request for it. But it leads to the
  // problems in real application quite often due to problems in the mechanism
  // itself. For example, some applications just hang at exit instead of
  // finishing with leaks. Some crashes due to bugs. Those problems are very
  // hard to debug because environment the logic works in is very specific -
  // multi-thread multi-library process shutdown.

  return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Destroy()
///////////////////////////////////////////////////////////////////////////////////////////////////
void FrameworkProxy::Destroy() {
#if !DISABLE_SHUTDOWN
  // Only enter shutdown process if the instance has been created.
  if (m_instance)
    m_instance->Release(true);
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Release()
///////////////////////////////////////////////////////////////////////////////////////////////////
void FrameworkProxy::Release(bool bTerminate) {
  // Intentionally disable this code on windows due to shutdown issue
#if !defined(_WIN32)
  // Many modules assume that FrameWorkProxy singleton, execution_module,
  // context_module and platform_module exist all the time -> we must ensure
  // that everything is shut down before deleting them.
  Instance()->m_pContextModule->ShutDown(true);
#endif

  if (nullptr != m_pExecutionModule) {
#if !defined(_WIN32)
    // Since we still have some TBB related issues on windows that have not been
    // resolved, we can't release it yet.
    m_pExecutionModule->Release();
#endif
    delete m_pExecutionModule;
  }

  if (nullptr != m_pContextModule) {
    m_pContextModule->Release(bTerminate);
    delete m_pContextModule;
  }

  if (nullptr != m_pPlatformModule) {
    // Intentionally disable this code on windows due to shutdown issue
#if !defined(_WIN32)
    m_pPlatformModule->Release(bTerminate);
#endif
    delete m_pPlatformModule;
  }

  m_pTaskExecutor = nullptr;

  if (nullptr != m_pFileLogHandler) {
    m_pFileLogHandler->Flush();
    delete m_pFileLogHandler;
    m_pFileLogHandler = nullptr;
  }
  if (nullptr != m_pConfig) {
    m_pConfig->Release();
    delete m_pConfig;
    m_pConfig = nullptr;
  }
  cl_monitor_summary;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Instance()
///////////////////////////////////////////////////////////////////////////////////////////////////
FrameworkProxy *FrameworkProxy::m_instance = nullptr;
FrameworkProxy *FrameworkProxy::Instance() {
  static FrameworkProxy *S = [] {
    m_instance = new FrameworkProxy();
    return m_instance;
  }();
  return S;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::GetTaskExecutor()
///////////////////////////////////////////////////////////////////////////////////////////////////
Intel::OpenCL::TaskExecutor::ITaskExecutor *
FrameworkProxy::GetTaskExecutor() const {
  // teInitialize > 0 means task executor is initialized successfully.
  // teInitialize == 0 means task executor is not initialized succcessfully.
  static int teInitialized = 1;
  static llvm::once_flag OnceFlag;
  llvm::call_once(OnceFlag, [&]() {
    LOG_INFO(TEXT("%s"), "Initialize Executor");
    m_pTaskExecutor = TaskExecutor::GetTaskExecutor();
    assert(m_pTaskExecutor);
    auto deviceMode = m_pConfig->GetDeviceMode();
    teInitialized =
        m_pTaskExecutor->Init(m_pConfig->GetNumTBBWorkers(), &m_GPAData,
                              m_pConfig->GetStackDefaultSize(), deviceMode);
  });

  if (0 == teInitialized)
    return nullptr;

  return m_pTaskExecutor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::ActivateTaskExecutor()
///////////////////////////////////////////////////////////////////////////////////////////////////
bool FrameworkProxy::ActivateTaskExecutor() {
  ITaskExecutor *pTaskExecutor = GetTaskExecutor();

  // Quit as early as possible if task executor initialization fails.
  if (nullptr == pTaskExecutor)
    return false;

  static llvm::once_flag OnceFlag;

  llvm::call_once(OnceFlag, [&]() {
    // create root device in flat mode. Use all available HW threads
    // and allow non-worker threads to participate in execution but do not
    // assume they will join.
    SharedPtr<ITEDevice> pTERootDevice = pTaskExecutor->CreateRootDevice(
        RootDeviceCreationParam(TE_AUTO_THREADS, TE_ENABLE_MASTERS_JOIN, 1));

    if (0 != pTERootDevice) {
      m_pTaskList = pTERootDevice->CreateTaskList(TE_CMD_LIST_IN_ORDER);
      m_pTaskList_immediate =
          pTERootDevice->CreateTaskList(TE_CMD_LIST_IMMEDIATE);
    }
  });

  return nullptr != m_pTaskList.GetPtr() &&
         nullptr != m_pTaskList_immediate.GetPtr();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::ExecuteImmediate()
///////////////////////////////////////////////////////////////////////////////////////////////////
bool FrameworkProxy::ExecuteImmediate(
    const Intel::OpenCL::Utils::SharedPtr<
        Intel::OpenCL::TaskExecutor::ITaskBase> &pTask) const {
  assert(m_pTaskList_immediate);
  if (nullptr == m_pTaskList_immediate.GetPtr()) {
    return false;
  }

  m_pTaskList_immediate->Enqueue(pTask);
  return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Execute()
///////////////////////////////////////////////////////////////////////////////////////////////////
bool FrameworkProxy::Execute(
    const Intel::OpenCL::Utils::SharedPtr<
        Intel::OpenCL::TaskExecutor::ITaskBase> &pTask) const {
  if (nullptr == m_pTaskList.GetPtr()) {
    return false;
  }

  m_pTaskList->Enqueue(pTask);
  m_pTaskList->Flush();
  return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FrameworkProxy::Execute()
///////////////////////////////////////////////////////////////////////////////////////////////////
void FrameworkProxy::CancelAllTasks(bool wait_for_finish) const {
  if (nullptr != m_pTaskList.GetPtr()) {
    m_pTaskList->Cancel();
    if (wait_for_finish) {
      m_pTaskList->WaitForCompletion(nullptr);
    }
  }
}
