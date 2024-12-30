//==------------------- clCreateCommandBufferKHR.cpp ---------------- C++ -*==//
//
// Copyright (C) 2024 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //

#include "CL/cl.h"
#include "CL/cl_ext.h"
#include "gtest/gtest.h"

#define DECLARE_EXT_FUNC_PTR(name) name##_fn name = nullptr;

#define QUERY_EXT_FUNC_PTR(platform, name)                                     \
  name = (name##_fn)clGetExtensionFunctionAddressForPlatform(platform, #name); \
  ASSERT_NE(nullptr, name)                                                     \
      << "clGetExtensionFunctionAddressForPlatform(" #name ") failed.";

extern cl_device_type gDeviceType;

class CommandBufferKHRTest : public ::testing::Test {
protected:
  virtual cl_command_queue createQueue(cl_int *Err) {
    return clCreateCommandQueueWithProperties(Context, Device, nullptr, Err);
  }

  virtual void SetUp() override {
    cl_int Err = clGetPlatformIDs(1, &Platform, nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);

    Err = clGetDeviceIDs(Platform, gDeviceType, 1, &Device, nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);

    Context = clCreateContext(nullptr, 1, &Device, nullptr, nullptr, &Err);
    ASSERT_EQ(CL_SUCCESS, Err);

    Queue = createQueue(&Err);
    ASSERT_EQ(CL_SUCCESS, Err);

    QUERY_EXT_FUNC_PTR(Platform, clCreateCommandBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clRetainCommandBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clReleaseCommandBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clFinalizeCommandBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clEnqueueCommandBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandBarrierWithWaitListKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandCopyBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandCopyBufferRectKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandCopyBufferToImageKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandCopyImageKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandCopyImageToBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandFillBufferKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandFillImageKHR);
    QUERY_EXT_FUNC_PTR(Platform, clCommandNDRangeKernelKHR);
    QUERY_EXT_FUNC_PTR(Platform, clGetCommandBufferInfoKHR);
  }

  virtual void TearDown() override {
    cl_int Err = CL_SUCCESS;
    if (Queue) {
      Err = clReleaseCommandQueue(Queue);
      ASSERT_EQ(CL_SUCCESS, Err);
    }
    if (Context) {
      Err = clReleaseContext(Context);
      ASSERT_EQ(CL_SUCCESS, Err);
    }
  }

protected:
  cl_platform_id Platform;
  cl_device_id Device;
  cl_context Context;
  cl_command_queue Queue;

  DECLARE_EXT_FUNC_PTR(clCreateCommandBufferKHR)
  DECLARE_EXT_FUNC_PTR(clRetainCommandBufferKHR)
  DECLARE_EXT_FUNC_PTR(clReleaseCommandBufferKHR)
  DECLARE_EXT_FUNC_PTR(clFinalizeCommandBufferKHR)
  DECLARE_EXT_FUNC_PTR(clEnqueueCommandBufferKHR)
  DECLARE_EXT_FUNC_PTR(clCommandBarrierWithWaitListKHR)
  DECLARE_EXT_FUNC_PTR(clCommandCopyBufferKHR)
  DECLARE_EXT_FUNC_PTR(clCommandCopyBufferRectKHR)
  DECLARE_EXT_FUNC_PTR(clCommandCopyBufferToImageKHR)
  DECLARE_EXT_FUNC_PTR(clCommandCopyImageKHR)
  DECLARE_EXT_FUNC_PTR(clCommandCopyImageToBufferKHR)
  DECLARE_EXT_FUNC_PTR(clCommandFillBufferKHR)
  DECLARE_EXT_FUNC_PTR(clCommandFillImageKHR)
  DECLARE_EXT_FUNC_PTR(clCommandNDRangeKernelKHR)
  DECLARE_EXT_FUNC_PTR(clGetCommandBufferInfoKHR)
};

TEST_F(CommandBufferKHRTest, GetDeviceInfo) {
  // CL_DEVICE_COMMAND_BUFFER_REQUIRED_QUEUE_PROPERTIES_KHR
  cl_command_queue_properties RequiredQueueProps = 0;
  cl_int Err = clGetDeviceInfo(
      Device, CL_DEVICE_COMMAND_BUFFER_REQUIRED_QUEUE_PROPERTIES_KHR,
      sizeof(RequiredQueueProps), &RequiredQueueProps, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  // Our implementation doesn't have any requirement on the queue properties
  ASSERT_EQ(RequiredQueueProps, 0ul);

  // CL_DEVICE_COMMAND_BUFFER_CAPABILITIES_KHR
  cl_device_command_buffer_capabilities_khr Capabilities = 0;
  Err = clGetDeviceInfo(Device, CL_DEVICE_COMMAND_BUFFER_CAPABILITIES_KHR,
                        sizeof(Capabilities), &Capabilities, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  cl_device_command_buffer_capabilities_khr ExpectedCaps =
      CL_COMMAND_BUFFER_CAPABILITY_KERNEL_PRINTF_KHR |
      CL_COMMAND_BUFFER_CAPABILITY_DEVICE_SIDE_ENQUEUE_KHR |
      CL_COMMAND_BUFFER_CAPABILITY_SIMULTANEOUS_USE_KHR |
      CL_COMMAND_BUFFER_CAPABILITY_OUT_OF_ORDER_KHR;
  ASSERT_EQ(Capabilities, ExpectedCaps);
}

TEST_F(CommandBufferKHRTest, CreateAndRelease) {
  cl_int Err = CL_SUCCESS;
  cl_command_buffer_khr CommandBuffer =
      clCreateCommandBufferKHR(1, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(CommandBuffer, nullptr);

  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Invalid double release
  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_INVALID_COMMAND_BUFFER_KHR, Err);
}

TEST_F(CommandBufferKHRTest, CreateRetainRelease) {
  cl_int Err = CL_SUCCESS;
  cl_command_buffer_khr CommandBuffer =
      clCreateCommandBufferKHR(1, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(CommandBuffer, nullptr);

  Err = clRetainCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Invalid retain after release
  Err = clRetainCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_INVALID_COMMAND_BUFFER_KHR, Err);
}

TEST_F(CommandBufferKHRTest, GetCommandBufferInfo) {
  // Initialize Err with a different value to ensure it's updated on success.
  cl_int Err = CL_INVALID_VALUE;
  cl_command_buffer_properties_khr Props[] = {
      CL_COMMAND_BUFFER_FLAGS_KHR, CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR, 0};
  cl_command_buffer_khr CommandBuffer =
      clCreateCommandBufferKHR(1, &Queue, Props, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(CommandBuffer, nullptr);

  cl_uint NumQueues = 0;
  size_t RetSize = 0;
  Err =
      clGetCommandBufferInfoKHR(CommandBuffer, CL_COMMAND_BUFFER_NUM_QUEUES_KHR,
                                sizeof(NumQueues), &NumQueues, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(NumQueues, 1u);
  ASSERT_EQ(RetSize, sizeof(NumQueues));

  cl_command_queue Queues[1] = {nullptr};
  Err = clGetCommandBufferInfoKHR(CommandBuffer, CL_COMMAND_BUFFER_QUEUES_KHR,
                                  sizeof(Queues), Queues, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(Queues[0], Queue);
  ASSERT_EQ(RetSize, sizeof(Queues));

  cl_uint RefCount = 0;
  Err = clGetCommandBufferInfoKHR(CommandBuffer,
                                  CL_COMMAND_BUFFER_REFERENCE_COUNT_KHR,
                                  sizeof(RefCount), &RefCount, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(RefCount, 1u);

  Err = clRetainCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clGetCommandBufferInfoKHR(CommandBuffer,
                                  CL_COMMAND_BUFFER_REFERENCE_COUNT_KHR,
                                  sizeof(RefCount), &RefCount, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(RefCount, 2u);

  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clGetCommandBufferInfoKHR(CommandBuffer,
                                  CL_COMMAND_BUFFER_REFERENCE_COUNT_KHR,
                                  sizeof(RefCount), &RefCount, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(RefCount, 1u);

  cl_command_buffer_state_khr State = 0;
  Err = clGetCommandBufferInfoKHR(CommandBuffer, CL_COMMAND_BUFFER_STATE_KHR,
                                  sizeof(State), &State, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(State, (unsigned)CL_COMMAND_BUFFER_STATE_RECORDING_KHR);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clGetCommandBufferInfoKHR(CommandBuffer, CL_COMMAND_BUFFER_STATE_KHR,
                                  sizeof(State), &State, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(State, (unsigned)CL_COMMAND_BUFFER_STATE_EXECUTABLE_KHR);

  cl_command_buffer_properties_khr QueryProps[3] = {0, 0, 0};
  Err = clGetCommandBufferInfoKHR(CommandBuffer,
                                  CL_COMMAND_BUFFER_PROPERTIES_ARRAY_KHR,
                                  sizeof(QueryProps), QueryProps, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(QueryProps[0], (unsigned long)CL_COMMAND_BUFFER_FLAGS_KHR);
  ASSERT_EQ(QueryProps[1],
            (unsigned long)CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR);
  ASSERT_EQ(QueryProps[2], 0ul);

  cl_context QueryCtx = nullptr;
  Err = clGetCommandBufferInfoKHR(CommandBuffer, CL_COMMAND_BUFFER_CONTEXT_KHR,
                                  sizeof(QueryCtx), &QueryCtx, &RetSize);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(QueryCtx, Context);

  Err = clReleaseCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);
}

TEST_F(CommandBufferKHRTest, Invalid) {
  // Create
  cl_int Err = CL_SUCCESS;
  // CL_INVALID_VALUE if the cl_khr_command_buffer_multi_device extension is
  // supported and num_queues is zero, or if the
  // cl_khr_command_buffer_multi_device extension is not supported and
  // num_queues is not one.
  cl_command_buffer_khr CommandBuffer =
      clCreateCommandBufferKHR(0, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_INVALID_VALUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);

  // CL_INVALID_VALUE if queues is NULL.
  CommandBuffer = clCreateCommandBufferKHR(1, nullptr, nullptr, &Err);
  ASSERT_EQ(CL_INVALID_VALUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);

  // CL_INVALID_VALUE if values specified in properties are not valid, or if the
  // same property name is specified more than once.
  cl_command_buffer_properties_khr InvalidProps[] = {0x42, 0};
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, InvalidProps, &Err);
  ASSERT_EQ(CL_INVALID_VALUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);
  cl_command_buffer_properties_khr DuplicateProps[] = {
      CL_COMMAND_BUFFER_FLAGS_KHR, CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR,
      CL_COMMAND_BUFFER_FLAGS_KHR, CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR, 0};
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, DuplicateProps, &Err);
  ASSERT_EQ(CL_INVALID_VALUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);
  cl_command_buffer_properties_khr ExceedRangeProps[] = {
      CL_COMMAND_BUFFER_FLAGS_KHR, 0xFFFF, 0};
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, ExceedRangeProps, &Err);
  ASSERT_EQ(CL_INVALID_VALUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);

  // CL_INVALID_CONTEXT if any element of queues does not have the same context
  // as the command-queue set on command_buffer creation at the same list index.
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  cl_context AnotherContext =
      clCreateContext(nullptr, 1, &Device, nullptr, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  cl_command_queue AnotherQueue =
      clCreateCommandQueueWithProperties(AnotherContext, Device, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clEnqueueCommandBufferKHR(1, &AnotherQueue, CommandBuffer, 0, nullptr,
                                  nullptr);
  ASSERT_EQ(CL_INVALID_CONTEXT, Err);

  // CL_INVALID_CONTEXT if context associated with command_buffer and events in
  // event_wait_list are not the same.
  cl_event AnotherEvent = clCreateUserEvent(AnotherContext, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 1, &AnotherEvent,
                                  nullptr);
  ASSERT_EQ(CL_INVALID_CONTEXT, Err);

  // CL_INVALID_COMMAND_QUEUE if any command-queue in queues is not a valid
  // command-queue. Invalidate by releasing the queue
  Err = clReleaseCommandQueue(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);
  CommandBuffer = clCreateCommandBufferKHR(1, &Queue, nullptr, &Err);
  ASSERT_EQ(CL_INVALID_COMMAND_QUEUE, Err);
  ASSERT_EQ(CommandBuffer, nullptr);
  // Set queue to NULL to avoid double release
  Queue = nullptr;
}

class CommandBufferRecordTest : public CommandBufferKHRTest {
protected:
  virtual void SetUp() override {
    CommandBufferKHRTest::SetUp();

    cl_int Err = CL_SUCCESS;
    cl_command_buffer_properties_khr Props[] = {
        CL_COMMAND_BUFFER_FLAGS_KHR, CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR, 0};
    CommandBuffer = clCreateCommandBufferKHR(1, &Queue, Props, &Err);
    ASSERT_EQ(CL_SUCCESS, Err);
    ASSERT_NE(CommandBuffer, nullptr);

    prepareKernel();
  }

  void prepareKernel() {
    cl_int Err = CL_SUCCESS;
    Program = clCreateProgramWithSource(Context, 1, &KernelSrc, nullptr, &Err);
    ASSERT_EQ(CL_SUCCESS, Err);

    Err = clBuildProgram(Program, 1, &Device, nullptr, nullptr, nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);

    Kernel = clCreateKernel(Program, "single_task", &Err);
    ASSERT_EQ(CL_SUCCESS, Err);

    MemA = clCreateBuffer(Context, CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR,
                          sizeof(Data), &Data, &Err);
    ASSERT_EQ(CL_SUCCESS, Err);

    Err = clSetKernelArg(Kernel, 0, sizeof(MemA), &MemA);
    ASSERT_EQ(CL_SUCCESS, Err);
  }

  virtual void TearDown() override {
    cl_int Err = CL_SUCCESS;
    if (CommandBuffer) {
      Err = clReleaseCommandBufferKHR(CommandBuffer);
      ASSERT_EQ(CL_SUCCESS, Err);
    }
    if (Kernel) {
      Err = clReleaseKernel(Kernel);
      ASSERT_EQ(CL_SUCCESS, Err);
    }
    if (Program) {
      Err = clReleaseProgram(Program);
      ASSERT_EQ(CL_SUCCESS, Err);
    }
    CommandBufferKHRTest::TearDown();
  }

protected:
  cl_command_buffer_khr CommandBuffer;
  cl_program Program;
  cl_kernel Kernel;
  const char *KernelSrc =
      "__kernel void single_task(__global int *a) { *a += 1; }";
  int Data = 0;
  cl_mem MemA;
};

TEST_F(CommandBufferRecordTest, Finalize) {
  cl_int Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // It's okay to enqueue an empty command buffer.
  cl_event Event = 0;
  Err = clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, &Event);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Wait for event is still valid even though command buffer is empty.
  Err = clWaitForEvents(1, &Event);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Query command type from event.
  cl_command_type CommandType = 0;
  Err = clGetEventInfo(Event, CL_EVENT_COMMAND_TYPE, sizeof(CommandType),
                       &CommandType, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(CommandType, (unsigned)CL_COMMAND_COMMAND_BUFFER_KHR);

  // Invalid double finalize
  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_INVALID_OPERATION, Err);
}

TEST_F(CommandBufferRecordTest, NDRangeKernel) {
  size_t GWS = 1;
  size_t LWS = 1;
  cl_int Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr,
                                         Kernel, 1, nullptr, &GWS, &LWS, 0,
                                         nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  const int Runs = 5;
  for (int I = 0; I < Runs; ++I) {
    Err = clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr,
                                    nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);

    Err = clFinish(Queue);
    ASSERT_EQ(CL_SUCCESS, Err);
    ASSERT_EQ(Data, I + 1);
  }
}

TEST_F(CommandBufferRecordTest, NDRangeKernelChangeArg) {
  size_t GWS = 1;
  size_t LWS = 1;
  cl_int Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr,
                                         Kernel, 1, nullptr, &GWS, &LWS, 0,
                                         nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Change kernel arg after recording. The previous recorded kernel should
  // still use the old arg.
  int AnotherData = 0x42;
  cl_mem AnotherMem =
      clCreateBuffer(Context, CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR,
                     sizeof(AnotherData), &AnotherData, &Err);
  ASSERT_EQ(CL_SUCCESS, Err);
  Err = clSetKernelArg(Kernel, 0, sizeof(AnotherMem), &AnotherMem);
  ASSERT_EQ(CL_SUCCESS, Err);
  // Record the kernel again, the new arg should be used.
  Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr, Kernel, 1,
                                  nullptr, &GWS, &LWS, 0, nullptr, nullptr,
                                  nullptr);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  const int Runs = 5;
  for (int I = 0; I < Runs; ++I) {
    Data = I;
    Err = clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr,
                                    nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);

    Err = clFinish(Queue);
    ASSERT_EQ(CL_SUCCESS, Err);
    ASSERT_EQ(Data, I + 1);
    ASSERT_EQ(AnotherData, I + 1 + 0x42);
  }
}

TEST_F(CommandBufferRecordTest, SimultaneousUse) {
  size_t GWS = 1;
  size_t LWS = 1;
  cl_int Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr,
                                         Kernel, 1, nullptr, &GWS, &LWS, 0,
                                         nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  const int Runs = 5;
  // We use an in-order queue, so there's no race condition.
  for (int I = 0; I < Runs; ++I) {
    Err = clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr,
                                    nullptr);
    ASSERT_EQ(CL_SUCCESS, Err);
  }
  Err = clFinish(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_EQ(Data, Runs);
}

TEST_F(CommandBufferRecordTest, FillBuffer) {
  const int Pattern = 0x42;
  cl_mem Mem = clCreateBuffer(Context, CL_MEM_READ_WRITE,
                              1024 * sizeof(Pattern), nullptr, nullptr);
  ASSERT_NE(Mem, nullptr);
  cl_int Err = clCommandFillBufferKHR(
      CommandBuffer, nullptr, nullptr, Mem, &Pattern, sizeof(Pattern), 0,
      1024 * sizeof(Pattern), 0, nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> PatternRead(1024);
  Err = clEnqueueReadBuffer(Queue, Mem, CL_TRUE, 0, 1024 * sizeof(Pattern),
                            PatternRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, PatternRead[I]);
}

TEST_F(CommandBufferRecordTest, CopyBuffer) {
  // Setup source buffer.
  const int Pattern = 0x42;
  cl_mem MemSrc = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemSrc, nullptr);
  cl_int Err = clEnqueueFillBuffer(Queue, MemSrc, &Pattern, sizeof(Pattern), 0,
                                   1024 * sizeof(Pattern), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Record copy buffer command.
  cl_mem MemDst = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemDst, nullptr);

  Err = clCommandCopyBufferKHR(CommandBuffer, nullptr, nullptr, MemSrc, MemDst,
                               0, 0, 1024 * sizeof(int), 0, nullptr, nullptr,
                               nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Execute the command buffer.
  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> DataRead(1024);
  Err = clEnqueueReadBuffer(Queue, MemDst, CL_TRUE, 0, 1024 * sizeof(int),
                            DataRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, DataRead[I]);
}

TEST_F(CommandBufferRecordTest, FillImage) {
  const int Pattern = 0x42;
  cl_image_format Format = {CL_R, CL_SIGNED_INT32};
  cl_image_desc Desc = {CL_MEM_OBJECT_IMAGE1D, 1024, 0, 0, 0, 0, 0, 0, 0, {0}};
  cl_mem Mem = clCreateImage(Context, CL_MEM_READ_WRITE, &Format, &Desc,
                             nullptr, nullptr);
  ASSERT_NE(Mem, nullptr);
  size_t Origin[] = {0, 0, 0};
  size_t Region[] = {1024, 1, 1};
  cl_int Err =
      clCommandFillImageKHR(CommandBuffer, nullptr, nullptr, Mem, &Pattern,
                            Origin, Region, 0, nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> PatternRead(1024);
  size_t OriginRead[] = {0, 0, 0};
  size_t RegionRead[] = {1024, 1, 1};
  Err = clEnqueueReadImage(Queue, Mem, CL_TRUE, OriginRead, RegionRead, 0, 0,
                           PatternRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, PatternRead[I]);
}

TEST_F(CommandBufferRecordTest, CopyImage) {
  // Setup source image.
  const int Pattern = 0x42;
  cl_image_format Format = {CL_R, CL_SIGNED_INT32};
  cl_image_desc Desc = {CL_MEM_OBJECT_IMAGE1D, 1024, 0, 0, 0, 0, 0, 0, 0, {0}};
  cl_mem MemSrc = clCreateImage(Context, CL_MEM_READ_WRITE, &Format, &Desc,
                                nullptr, nullptr);
  ASSERT_NE(MemSrc, nullptr);
  size_t Origin[] = {0, 0, 0};
  size_t Region[] = {1024, 1, 1};
  cl_int Err = clEnqueueFillImage(Queue, MemSrc, &Pattern, Origin, Region, 0,
                                  nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Record copy image command.
  cl_mem MemDst = clCreateImage(Context, CL_MEM_READ_WRITE, &Format, &Desc,
                                nullptr, nullptr);
  ASSERT_NE(MemDst, nullptr);

  Err = clCommandCopyImageKHR(CommandBuffer, nullptr, nullptr, MemSrc, MemDst,
                              Origin, Origin, Region, 0, nullptr, nullptr,
                              nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Execute the command buffer.
  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> DataRead(1024);
  size_t OriginRead[] = {0, 0, 0};
  size_t RegionRead[] = {1024, 1, 1};
  Err = clEnqueueReadImage(Queue, MemDst, CL_TRUE, OriginRead, RegionRead, 0, 0,
                           DataRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, DataRead[I]);
}

TEST_F(CommandBufferRecordTest, CopyBufferToImage) {
  // Setup source buffer.
  const int Pattern = 0x42;
  cl_mem MemSrc = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemSrc, nullptr);
  cl_int Err = clEnqueueFillBuffer(Queue, MemSrc, &Pattern, sizeof(Pattern), 0,
                                   1024 * sizeof(Pattern), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Record copy buffer to image command.
  cl_image_format Format = {CL_R, CL_SIGNED_INT32};
  cl_image_desc Desc = {CL_MEM_OBJECT_IMAGE1D, 1024, 0, 0, 0, 0, 0, 0, 0, {0}};
  cl_mem MemDst = clCreateImage(Context, CL_MEM_READ_WRITE, &Format, &Desc,
                                nullptr, nullptr);
  ASSERT_NE(MemDst, nullptr);

  size_t Origin[] = {0, 0, 0};
  size_t Region[] = {1024, 1, 1};
  Err = clCommandCopyBufferToImageKHR(CommandBuffer, nullptr, nullptr, MemSrc,
                                      MemDst, 0, Origin, Region, 0, nullptr,
                                      nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Execute the command buffer.
  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> DataRead(1024);
  size_t OriginRead[] = {0, 0, 0};
  size_t RegionRead[] = {1024, 1, 1};
  Err = clEnqueueReadImage(Queue, MemDst, CL_TRUE, OriginRead, RegionRead, 0, 0,
                           DataRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, DataRead[I]);
}

TEST_F(CommandBufferRecordTest, CopyImageToBuffer) {
  // Setup source image.
  const int Pattern = 0x42;
  cl_image_format Format = {CL_R, CL_SIGNED_INT32};
  cl_image_desc Desc = {CL_MEM_OBJECT_IMAGE1D, 1024, 0, 0, 0, 0, 0, 0, 0, {0}};
  cl_mem MemSrc = clCreateImage(Context, CL_MEM_READ_WRITE, &Format, &Desc,
                                nullptr, nullptr);
  ASSERT_NE(MemSrc, nullptr);
  size_t Origin[] = {0, 0, 0};
  size_t Region[] = {1024, 1, 1};
  cl_int Err = clEnqueueFillImage(Queue, MemSrc, &Pattern, Origin, Region, 0,
                                  nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Record copy image to buffer command.
  cl_mem MemDst = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemDst, nullptr);

  Err = clCommandCopyImageToBufferKHR(CommandBuffer, nullptr, nullptr, MemSrc,
                                      MemDst, Origin, Region, 0, 0, nullptr,
                                      nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Execute the command buffer.
  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> DataRead(1024);
  Err = clEnqueueReadBuffer(Queue, MemDst, CL_TRUE, 0, 1024 * sizeof(int),
                            DataRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, DataRead[I]);
}

TEST_F(CommandBufferRecordTest, CopyBufferRect) {
  // Setup source buffer.
  const int Pattern = 0x42;
  cl_mem MemSrc = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemSrc, nullptr);
  cl_int Err = clEnqueueFillBuffer(Queue, MemSrc, &Pattern, sizeof(Pattern), 0,
                                   1024 * sizeof(Pattern), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Record copy buffer rect command.
  cl_mem MemDst = clCreateBuffer(Context, CL_MEM_READ_WRITE, 1024 * sizeof(int),
                                 nullptr, nullptr);
  ASSERT_NE(MemDst, nullptr);

  size_t SrcOrigin[] = {0, 0, 0};
  size_t DstOrigin[] = {0, 0, 0};
  size_t Region[] = {1024 * sizeof(int), 1, 1};
  size_t SrcRowPitch = 0;
  size_t SrcSlicePitch = 0;
  size_t DstRowPitch = 0;
  size_t DstSlicePitch = 0;
  Err = clCommandCopyBufferRectKHR(CommandBuffer, nullptr, nullptr, MemSrc,
                                   MemDst, SrcOrigin, DstOrigin, Region,
                                   SrcRowPitch, SrcSlicePitch, DstRowPitch,
                                   DstSlicePitch, 0, nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  // Execute the command buffer.
  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFlush(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  std::vector<int> DataRead(1024);
  Err = clEnqueueReadBuffer(Queue, MemDst, CL_TRUE, 0, 1024 * sizeof(int),
                            DataRead.data(), 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  for (int I = 0; I < 1024; ++I)
    ASSERT_EQ(Pattern, DataRead[I]);
}

class CommandBufferOOOTest : public CommandBufferRecordTest {
protected:
  virtual cl_command_queue createQueue(cl_int *Err) override {
    cl_command_queue_properties Props[] = {
        CL_QUEUE_PROPERTIES, CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE, 0};
    return clCreateCommandQueueWithProperties(Context, Device, Props, Err);
  }
};

TEST_F(CommandBufferOOOTest, SyncPoints) {
  const int InitVal = 0x42;
  cl_sync_point_khr FillBufferSP = 0;
  cl_int Err = clCommandFillBufferKHR(
      CommandBuffer, nullptr, nullptr, MemA, &InitVal, sizeof(InitVal), 0,
      sizeof(InitVal), 0, nullptr, &FillBufferSP, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(FillBufferSP, 0ul);

  size_t GWS = 1;
  size_t LWS = 1;
  Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr, Kernel, 1,
                                  nullptr, &GWS, &LWS, 1, &FillBufferSP,
                                  nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinish(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  ASSERT_EQ(Data, InitVal + 1);
}

TEST_F(CommandBufferOOOTest, BarrierWithWaitList) {
  const int InitVal = 0x42;
  cl_sync_point_khr FillBufferSP = 0;
  cl_int Err = clCommandFillBufferKHR(
      CommandBuffer, nullptr, nullptr, MemA, &InitVal, sizeof(InitVal), 0,
      sizeof(InitVal), 0, nullptr, &FillBufferSP, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(FillBufferSP, 0ul);

  cl_sync_point_khr BarrierSP = 0;
  Err = clCommandBarrierWithWaitListKHR(CommandBuffer, nullptr, nullptr, 1,
                                        &FillBufferSP, &BarrierSP, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(BarrierSP, 0ul);

  size_t GWS = 1;
  size_t LWS = 1;
  Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr, Kernel, 1,
                                  nullptr, &GWS, &LWS, 1, &BarrierSP, nullptr,
                                  nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinish(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  ASSERT_EQ(Data, InitVal + 1);
}

TEST_F(CommandBufferOOOTest, BarrierWaitAll) {
  const int InitVal = 0x42;
  cl_int Err = clCommandFillBufferKHR(
      CommandBuffer, nullptr, nullptr, MemA, &InitVal, sizeof(InitVal), 0,
      sizeof(InitVal), 0, nullptr, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  // If sync_point_wait_list is NULL, then this particular command waits until
  // all previous recorded commands to command_queue have completed.
  cl_sync_point_khr BarrierSP = 0;
  Err = clCommandBarrierWithWaitListKHR(CommandBuffer, nullptr, nullptr, 0,
                                        nullptr, &BarrierSP, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);
  ASSERT_NE(BarrierSP, 0ul);

  size_t GWS = 1;
  size_t LWS = 1;
  Err = clCommandNDRangeKernelKHR(CommandBuffer, nullptr, nullptr, Kernel, 1,
                                  nullptr, &GWS, &LWS, 1, &BarrierSP, nullptr,
                                  nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinalizeCommandBufferKHR(CommandBuffer);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err =
      clEnqueueCommandBufferKHR(1, &Queue, CommandBuffer, 0, nullptr, nullptr);
  ASSERT_EQ(CL_SUCCESS, Err);

  Err = clFinish(Queue);
  ASSERT_EQ(CL_SUCCESS, Err);

  ASSERT_EQ(Data, InitVal + 1);
}
