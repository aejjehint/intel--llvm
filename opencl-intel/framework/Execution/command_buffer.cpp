//==------------------------ command_buffer.cpp --------------------- C++ -*==//
//
// Copyright (C) 2024 Intel Corporation. All rights reserved.
//
// The information and source code contained herein is the exclusive property
// of Intel Corporation and may not be disclosed, examined or reproduced in
// whole or in part without explicit written authorization from the company.
//
// ===--------------------------------------------------------------------=== //

#include "command_buffer.h"
#include "command_queue.h"
#include "enqueue_commands.h"
#include <mutex>

using namespace Intel::OpenCL::Framework;

cl_int CommandBuffer::finalize() {
  std::lock_guard<std::mutex> Lock(StatusMutex);
  if (Status != CB_RECORDING)
    return CL_INVALID_OPERATION;

  Status = CB_EXECUTABLE;
  return CL_SUCCESS;
}

cl_err_code CommandBuffer::GetInfo(cl_int param_name, size_t param_value_size,
                                   void *param_value,
                                   size_t *param_value_size_ret) const {
  switch (param_name) {
  case CL_COMMAND_BUFFER_NUM_QUEUES_KHR:
    if (param_value) {
      if (param_value_size < sizeof(cl_uint))
        return CL_INVALID_VALUE;
      *reinterpret_cast<cl_uint *>(param_value) = Queues.size();
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_uint);
    break;
  case CL_COMMAND_BUFFER_QUEUES_KHR:
    if (param_value) {
      if (param_value_size < sizeof(cl_command_queue) * Queues.size())
        return CL_INVALID_VALUE;
      for (size_t I = 0; I < Queues.size(); ++I)
        reinterpret_cast<cl_command_queue *>(param_value)[I] =
            Queues[I]->GetHandle();
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_command_queue) * Queues.size();
    break;
  case CL_COMMAND_BUFFER_REFERENCE_COUNT_KHR:
    if (param_value) {
      if (param_value_size < sizeof(cl_uint))
        return CL_INVALID_VALUE;
      *reinterpret_cast<cl_uint *>(param_value) = OCLObject::m_uiRefCount;
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_uint);
    break;
  case CL_COMMAND_BUFFER_STATE_KHR:
    if (param_value) {
      if (param_value_size < sizeof(cl_command_buffer_state_khr))
        return CL_INVALID_VALUE;
      std::lock_guard<std::mutex> Lock(StatusMutex);
      *reinterpret_cast<cl_command_buffer_state_khr *>(param_value) = Status;
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_command_buffer_state_khr);
    break;
  case CL_COMMAND_BUFFER_PROPERTIES_ARRAY_KHR: {
    std::vector<cl_command_buffer_properties_khr> PropArray;
    for (const auto &Pair : Props) {
      PropArray.push_back(Pair.first);
      PropArray.push_back(Pair.second);
    }
    PropArray.push_back(0);
    if (param_value) {
      if (param_value_size <
          PropArray.size() * sizeof(cl_command_buffer_properties_khr))
        return CL_INVALID_VALUE;
      std::copy(
          PropArray.begin(), PropArray.end(),
          reinterpret_cast<cl_command_buffer_properties_khr *>(param_value));
    }
    if (param_value_size_ret)
      *param_value_size_ret =
          PropArray.size() * sizeof(cl_command_buffer_properties_khr);
    break;
  }
  case CL_COMMAND_BUFFER_CONTEXT_KHR:
    if (param_value) {
      if (param_value_size < sizeof(cl_context))
        return CL_INVALID_VALUE;
      *reinterpret_cast<cl_context *>(param_value) = Ctx->GetHandle();
    }
    if (param_value_size_ret)
      *param_value_size_ret = sizeof(cl_context);
    break;
  default:
    return CL_INVALID_VALUE;
  }
  return CL_SUCCESS;
}

cl_int CommandBuffer::enqueue(cl_uint num_events_in_wait_list,
                              const cl_event *event_wait_list,
                              cl_event *event) {
  return enqueue(Queues, num_events_in_wait_list, event_wait_list, event);
}

cl_int CommandBuffer::enqueue(
    std::vector<SharedPtr<IOclCommandQueueBase>> &ExecutionQueues,
    cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
    cl_event *event) {
  // CL_INVALID_VALUE if num_queues is > 0 and not the same value as num_queues
  // set on command_buffer creation.
  if (ExecutionQueues.size() != Queues.size())
    return CL_INVALID_VALUE;

  // CL_INVALID_CONTEXT if any element of queues does not have the same context
  // as the command-queue set on command_buffer creation at the same list index.
  // CL_INCOMPATIBLE_COMMAND_QUEUE_KHR if any element of queues is not
  // compatible with the command-queue set on command_buffer creation at the
  // same list index.
  for (unsigned I = 0; I < ExecutionQueues.size(); ++I) {
    if (ExecutionQueues[I]->GetContextId() != Queues[I]->GetContextId())
      return CL_INVALID_CONTEXT;
    if (!ExecutionQueues[I]->CompatibleWith(Queues[I]))
      return CL_INCOMPATIBLE_COMMAND_QUEUE_KHR;
  }

  {
    // Check status
    std::lock_guard<std::mutex> Lock(StatusMutex);
    if (Status == CB_RECORDING                              // not finalized
        || (!AllowSimultaneousUse && Status == CB_PENDING)) // already pending
      return CL_INVALID_OPERATION;

    // Set status
    Status = CB_PENDING;
    ++PendingCount;
    assert((AllowSimultaneousUse || PendingCount == 1) &&
           "Simultaneous use disabled, only allow one pending");
  }

  for (auto &Q : ExecutionQueues) {
    cl_err_code Ret =
        enqueue(Q, num_events_in_wait_list, event_wait_list, event);
    if (Ret != CL_SUCCESS)
      return CL_OUT_OF_RESOURCES;
  }

  return CL_SUCCESS;
}

cl_int CommandBuffer::enqueue(const SharedPtr<IOclCommandQueueBase> &Queue,
                              cl_uint num_events_in_wait_list,
                              const cl_event *event_wait_list,
                              cl_event *event) {
  // Enqueue recorded commands to a single queue.

  // Create a start marker command that waits for user given event list.
  auto *StartMarker = new CommandBufferStartMarkerCommand();
  StartMarker->AttachToCommandQueue(Queue);
  cl_event StartEvent = 0;
  cl_err_code Ret =
      Queue->EnqueueCommand(StartMarker, false, num_events_in_wait_list,
                            event_wait_list, &StartEvent, nullptr);
  if (Ret != CL_SUCCESS) {
    delete StartMarker;
    return Ret;
  }

  // Enqueue all recorded commands.
  // Store cl_event handles for all running commands, to be waited by end
  // marker.
  size_t NumOfCmds = RecordedCommands.size();
  std::vector<cl_event> AllEvents(NumOfCmds);
  std::unordered_map<Command *, cl_event> CmdEventsMap;
  for (size_t I = 0; I < NumOfCmds; ++I) {
    const auto &Cmd = RecordedCommands[I];
    auto *ClonedCmd = Cmd->clone();
    assert(ClonedCmd && "Command cloning failed");
    ClonedCmd->AttachToCommandQueue(Queue);
    Ret = ClonedCmd->Init();
    if (Ret != CL_SUCCESS) {
      delete ClonedCmd;
      return Ret;
    }

    // Depend on the start marker command.
    std::vector<cl_event> DependentEvents{StartEvent};
    // Build sync point dependencies.
    auto Deps = CommandDependencies.find(Cmd.get());
    if (Deps != CommandDependencies.end()) {
      for (Command *Dep : Deps->second) {
        assert(CmdEventsMap.find(Dep) != CmdEventsMap.end() &&
               "Dependent command not found in CmdEventsMap");
        cl_event DepEvent = CmdEventsMap[Dep];
        assert(DepEvent && "Dependent event not found");
        DependentEvents.push_back(DepEvent);
      }
    }

    // ClonedCmd will be released automatically if on successful execution.
    cl_event Event = 0;
    if (ClonedCmd->GetCommandType() == CL_COMMAND_BARRIER) {
      Ret = Queue->EnqueueRuntimeCommandWaitEvents(
          IOclCommandQueueBase::BARRIER, ClonedCmd, DependentEvents.size(),
          DependentEvents.data(), &Event, nullptr);
    } else {
      Ret = Queue->EnqueueCommand(ClonedCmd, false, DependentEvents.size(),
                                  DependentEvents.data(), &Event, nullptr);
    }
    if (Ret != CL_SUCCESS) {
      delete ClonedCmd;
      return Ret;
    }
    assert(Event && "Event not created");
    AllEvents[I] = Event;
    CmdEventsMap[Cmd.get()] = Event;
  }

  // Create an end marker command that waits for all commands to complete.
  auto *EndMarker = new CommandBufferEndMarkerCommand(this);
  EndMarker->AttachToCommandQueue(Queue);
  Ret = Queue->EnqueueCommand(EndMarker, false, NumOfCmds, AllEvents.data(),
                              event, nullptr);
  if (Ret != CL_SUCCESS) {
    delete EndMarker;
    return Ret;
  }
  return CL_SUCCESS;
}

void CommandBuffer::onCommandsCompletion() {
  std::lock_guard<std::mutex> Lock(StatusMutex);
  assert(Status == CB_PENDING && "Unexpected status for onCommandsCompletion");

  --PendingCount;
  assert(
      (AllowSimultaneousUse || PendingCount == 0) &&
      "Simultaneous use disabled, pending count must be zero after completion");
  if (PendingCount == 0)
    Status = CB_EXECUTABLE;
}

cl_int CommandBuffer::record(std::unique_ptr<Command> &&Cmd,
                             cl_uint num_sync_points_in_wait_list,
                             const cl_sync_point_khr *sync_point_list,
                             cl_sync_point_khr *sync_point) {
  // Check sync points
  if (num_sync_points_in_wait_list > 0 && !sync_point_list)
    return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;
  if (num_sync_points_in_wait_list == 0 && sync_point_list)
    return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;

  // Prevent status change during recording
  std::lock_guard<std::mutex> Lock(StatusMutex);
  assert(Status == CB_RECORDING && "CommandBuffer not in recording state");

  std::vector<Command *> WaitList;
  for (cl_uint I = 0; I < num_sync_points_in_wait_list; ++I) {
    Command *DepCmd = getCommandFromSyncPoint(sync_point_list[I]);
    if (!DepCmd)
      return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;
    WaitList.push_back(DepCmd);
  }
  CommandDependencies[Cmd.get()] = std::move(WaitList);
  RecordedCommands.push_back(std::move(Cmd));

  if (sync_point) {
    *sync_point = createNextSyncPoint();
    SyncPoints.push_back(*sync_point);
  } else {
    SyncPoints.push_back(0);
  }

  return CL_SUCCESS;
}

cl_int CommandBuffer::recordBarrier(cl_uint num_sync_points_in_wait_list,
                                    const cl_sync_point_khr *sync_point_list,
                                    cl_sync_point_khr *sync_point) {
  // Check sync points
  if (num_sync_points_in_wait_list > 0 && !sync_point_list)
    return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;
  if (num_sync_points_in_wait_list == 0 && sync_point_list)
    return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;

  auto BarrierCmd =
      std::make_unique<BarrierCommand>(/*IsDependentOnEvents*/ true);

  std::lock_guard<std::mutex> Lock(StatusMutex);
  assert(Status == CB_RECORDING && "CommandBuffer not in recording state");

  // If sync_point_wait_list is NULL, then this particular command waits until
  // all previous recorded commands to command_queue have completed.
  std::vector<Command *> WaitList;
  if (!sync_point_list) {
    // Add all recorded commands to dependent list.
    for (const auto &Cmd : RecordedCommands)
      WaitList.push_back(Cmd.get());
  } else {
    for (cl_uint I = 0; I < num_sync_points_in_wait_list; ++I) {
      Command *DepCmd = getCommandFromSyncPoint(sync_point_list[I]);
      if (!DepCmd)
        return CL_INVALID_SYNC_POINT_WAIT_LIST_KHR;
      WaitList.push_back(DepCmd);
    }
  }
  CommandDependencies[BarrierCmd.get()] = std::move(WaitList);
  RecordedCommands.push_back(std::move(BarrierCmd));

  if (sync_point) {
    *sync_point = createNextSyncPoint();
    SyncPoints.push_back(*sync_point);
  } else {
    SyncPoints.push_back(0);
  }

  return CL_SUCCESS;
}
