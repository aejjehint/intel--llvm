//==------------------------ command_buffer.h ----------------------- C++ -*==//
//
// Copyright (C) 2024 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //

#ifndef OCL_FRAMEWORK_EXECUTION_COMMAND_BUFFER_H
#define OCL_FRAMEWORK_EXECUTION_COMMAND_BUFFER_H

#include "Context.h"
#include "cl_object.h"
#include "cl_shared_ptr.h"
#include "ocl_command_queue.h"
#include <unordered_map>

using CBPropMap = std::unordered_map<cl_command_buffer_properties_khr,
                                     cl_command_buffer_properties_khr>;

namespace Intel {
namespace OpenCL {
namespace Framework {

// https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_API.html#_command_buffers
// A command-buffer object represents a series of operations to be enqueued on
// one or more command-queues without any applicaiton code interaction. Grouping
// the operations together allows efficient enqueuing of repetitive operations,
// as well as enabling driver optimizations.
class CommandBuffer : public OCLObject<_cl_object> {
public:
  PREPARE_SHARED_PTR(CommandBuffer)

  static SharedPtr<CommandBuffer>
  Allocate(const SharedPtr<Context> &Ctx,
           const std::vector<SharedPtr<IOclCommandQueueBase>> &Queues,
           const CBPropMap &Props) {
    return SharedPtr<CommandBuffer>(new CommandBuffer(Ctx, Queues, Props));
  }

  const SharedPtr<IOclCommandQueueBase> &getDefaultQueue() const {
    return Queues[0];
  }

  // Places the command-buffer in the Executable state where commands can no
  // longer be recorded, at this point the command-buffer is ready to be
  // enqueued.
  cl_int finalize();

  cl_int enqueue(cl_uint num_events_in_wait_list,
                 const cl_event *event_wait_list, cl_event *event);

  cl_int enqueue(std::vector<SharedPtr<IOclCommandQueueBase>> &ExecutionQueues,
                 cl_uint num_events_in_wait_list,
                 const cl_event *event_wait_list, cl_event *event);

  // To be called each time when all recorded commands, as a group, completes
  // execution.
  void onCommandsCompletion();

  // CommandBuffer will take ownership of Cmd and manage its lifecycle.
  // The caller should not try to delete Cmd.
  cl_int record(std::unique_ptr<Command> &&Cmd,
                cl_uint num_sync_points_in_wait_list,
                const cl_sync_point_khr *sync_point_list,
                cl_sync_point_khr *sync_point);

  cl_int recordBarrier(cl_uint num_sync_points_in_wait_list,
                       const cl_sync_point_khr *sync_point_list,
                       cl_sync_point_khr *sync_point);

  bool isInRecordingState() const {
    std::lock_guard<std::mutex> Lock(StatusMutex);
    return Status == CB_RECORDING;
  }

  cl_err_code GetInfo(cl_int param_name, size_t param_value_size,
                      void *param_value,
                      size_t *param_value_size_ret) const override;

private:
  enum CBStatus {
    CB_RECORDING = CL_COMMAND_BUFFER_STATE_RECORDING_KHR,
    CB_EXECUTABLE = CL_COMMAND_BUFFER_STATE_EXECUTABLE_KHR,
    CB_PENDING = CL_COMMAND_BUFFER_STATE_PENDING_KHR
  };

  CommandBuffer(const SharedPtr<Context> &Ctx,
                const std::vector<SharedPtr<IOclCommandQueueBase>> &Queues,
                const CBPropMap &Props)
      : OCLObject<_cl_object>(Ctx->GetHandle(), "CommandBuffer"), Ctx(Ctx),
        Props(Props), Queues(Queues), Status(CB_RECORDING), PendingCount(0),
        RecordedCommands() {
    assert(Queues.size() == 1 && "Only one queue is supported");
    // Randomize initial value for the sync point counter.
    SyncPointCounter = reinterpret_cast<size_t>(this);

    // Parse properties
    if (this->Props.count(CL_COMMAND_BUFFER_FLAGS_KHR))
      AllowSimultaneousUse = this->Props[CL_COMMAND_BUFFER_FLAGS_KHR] &
                             CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR;
  }
  ~CommandBuffer() = default;

  cl_int enqueue(const SharedPtr<IOclCommandQueueBase> &Queue,
                 cl_uint num_events_in_wait_list,
                 const cl_event *event_wait_list, cl_event *event);

  cl_sync_point_khr createNextSyncPoint() {
    cl_uint Id = SyncPointCounter.fetch_add(1, std::memory_order_relaxed);
    return Id | (1 << 31); // Guarantee non-zero value
  }

  Command *getCommandFromSyncPoint(cl_sync_point_khr SyncPoint) const {
    if (SyncPoint == 0 || (SyncPoint & (1 << 31)) == 0)
      return nullptr;
    assert(SyncPoints.size() == RecordedCommands.size() &&
           "SyncPoints and RecordedCommands sizes must match");
    for (unsigned I = 0; I < SyncPoints.size(); ++I)
      if (SyncPoints[I] == SyncPoint)
        return RecordedCommands[I].get();
    return nullptr;
  }

private:
  SharedPtr<Context> Ctx;
  CBPropMap Props;

  // While constructing a command-buffer it is valid for the user to interleave
  // calls to the same queue which create commands, such as
  // clCommandNDRangeKernelKHR, with queue submission calls, such as
  // clEnqueueNDRangeKernel or clEnqueueCommandBufferKHR. That is, there is no
  // effect on queue state from recording commands. The purpose of the queue
  // parameter is to define the device and properties of the command, which are
  // constant queries on the queue object.
  std::vector<SharedPtr<IOclCommandQueueBase>> Queues;

  // A command-buffer is always in one of the following states:
  //
  // Recording
  // Initial state of a command-buffer on creation, where commands can be
  // recorded to the command-buffer.
  //
  // Executable
  // State after command recording has finished with clFinalizeCommandBufferKHR
  // and the command-buffer may be enqueued.
  //
  // Pending
  // Once a command-buffer has been enqueued to a command-queue it enters the
  // Pending state until completion, at which point it moves back to the
  // Executable state.
  CBStatus Status = CB_RECORDING;

  // The Pending Count is the number of copies of the command buffer in the
  // Pending state. By default a command-buffer’s Pending Count must be 0 or 1.
  // If the command-buffer was created with
  // CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR then the command-buffer may have a
  // Pending Count greater than 1.
  unsigned int PendingCount = 0;
  bool AllowSimultaneousUse = false;

  // Mutex to protect the status of the command buffer
  mutable std::mutex StatusMutex;

  std::vector<std::unique_ptr<Command>> RecordedCommands;
  // Non-zero SyncPoints[I] indicates a user sync point.
  // Size of SyncPoints and RecordedCommands must match.
  std::vector<cl_sync_point_khr> SyncPoints;
  std::atomic_uint SyncPointCounter{0};

  // CommandDependencies[Cmd] = {Cmd1, Cmd2, ...} means Cmd depends on Cmd1,
  // Cmd2, ...
  std::unordered_map<Command *, std::vector<Command *>> CommandDependencies;
};

} // namespace Framework
} // namespace OpenCL
} // namespace Intel

#endif // OCL_FRAMEWORK_EXECUTION_COMMAND_BUFFER_H
