// INTEL CONFIDENTIAL
//
// Copyright 2008 Intel Corporation.
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

#pragma once

#include "Logger.h"
#include "cl_framework.h"
#include "command_buffer.h"
#include "command_queue.h"
#include "iexecution.h"
#include "ocl_config.h"
#include "ocl_itt.h"
#include <unordered_map>

// forward declarations

namespace Intel {
namespace OpenCL {
namespace Framework {
// forward declarations
class PlatformModule;
class ContextModule;
template <class HandleType, class ObjectType> class OCLObjectsMap;
class EventsManager;
class IOclCommandQueueBase;
class Context;
class MemoryObject;
using OclKernelEventMapTy = std::unordered_map<std::string, cl_event>;

/**
 * ExecutionModule class the platform module responsible of all execution
 * related operations. this might include queues events etc.
 */

///////////////////////////////////////////////////////////////////////////////////
// Class name:  ExecutionModule
//
// Description:    ExecutionModule class responsible of all execution related
//              operations. this include queues, events, enqueue calls etc.
//              TODO: verify synchronization on access to all functions!!!
//
///////////////////////////////////////////////////////////////////////////////////

class ExecutionModule : public IExecution {

public:
  ExecutionModule(PlatformModule *pPlatformModule,
                  ContextModule *pContextModule);
  virtual ~ExecutionModule();

  // Disable copy consructors
  ExecutionModule(const ExecutionModule &) = delete;
  ExecutionModule &operator=(const ExecutionModule &) = delete;

  // Initialization is done right after the construction in order to capture
  // errors on initialization.
  cl_err_code Initialize(ocl_entry_points *pOclEntryPoints,
                         OCLConfig *pOclConfig, ocl_gpa_data *pGPAData);

  // Command Queues functions
  cl_command_queue
  CreateCommandQueue(cl_context clContext, cl_device_id clDevice,
                     const cl_command_queue_properties *clQueueProperties,
                     cl_bool withProps, cl_int *pErrRet) override;
  cl_err_code RetainCommandQueue(cl_command_queue clCommandQueue) override;
  cl_err_code ReleaseCommandQueue(cl_command_queue clCommandQueue) override;
  cl_err_code
  SetDefaultDeviceCommandQueue(cl_context context, cl_device_id device,
                               cl_command_queue command_queue); // override;
  cl_err_code GetCommandQueueInfo(cl_command_queue clCommandQueue,
                                  cl_command_queue_info clParamName,
                                  size_t szParamValueSize, void *pParamValue,
                                  size_t *pszParamValueSizeRet) override;
  cl_err_code Flush(cl_command_queue clCommandQueue) override;
  cl_err_code Finish(cl_command_queue clCommandQueue) override;
  SharedPtr<OclCommandQueue> GetCommandQueue(cl_command_queue clCommandQueue);

  // Out Of Order Execution synch commands
  // ---------------------
  cl_err_code EnqueueMarker(cl_command_queue clCommandQueue, cl_event *pEvent,
                            Utils::ApiLogger *pApiLogger) override;
  cl_err_code EnqueueMarkerWithWaitList(cl_command_queue clCommandQueue,
                                        cl_uint uiNumEvents,
                                        const cl_event *pEventList,
                                        cl_event *pEvent,
                                        Utils::ApiLogger *pApiLogger);
  cl_err_code EnqueueWaitForEvents(cl_command_queue clCommandQueue,
                                   cl_uint uiNumEvents,
                                   const cl_event *cpEventList,
                                   Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueBarrier(cl_command_queue clCommandQueue,
                             Utils::ApiLogger *pApiLogger) override;
  cl_err_code EnqueueBarrierWithWaitList(cl_command_queue clCommandQueue,
                                         cl_uint uiNumEvents,
                                         const cl_event *pEventList,
                                         cl_event *pEvent,
                                         Utils::ApiLogger *pApiLogger);

  // Event objects functions
  cl_err_code WaitForEvents(cl_uint uiNumEvents,
                            const cl_event *cpEventList) override;
  cl_err_code GetEventInfo(cl_event clEvent, cl_event_info clParamName,
                           size_t szParamValueSize, void *pParamValue,
                           size_t *pszParamValueSizeRet) override;
  cl_err_code RetainEvent(cl_event clEevent) override;
  cl_err_code ReleaseEvent(cl_event clEvent) override;
  cl_event CreateUserEvent(cl_context context, cl_int *errcode_ret);
  cl_int SetUserEventStatus(cl_event evt, cl_int status);
  cl_err_code SetEventCallback(cl_event evt, cl_int status,
                               void(CL_CALLBACK *fn)(cl_event, cl_int, void *),
                               void *userData);

  // Enqueue commands
  cl_err_code EnqueueReadBuffer(cl_command_queue clCommandQueue,
                                cl_mem clBuffer, cl_bool bBlocking,
                                size_t szOffset, size_t szCb, void *pOutData,
                                cl_uint uNumEventsInWaitList,
                                const cl_event *cpEeventWaitList,
                                cl_event *pEvent,
                                Utils::ApiLogger *apiLogger) override;
  cl_err_code
  EnqueueWriteBuffer(cl_command_queue clCommandQueue, cl_mem clBuffer,
                     cl_bool bBlocking, size_t szOffset, size_t szCb,
                     const void *cpSrcData, cl_uint uNumEventsInWaitList,
                     const cl_event *cpEeventWaitList, cl_event *pEvent,
                     Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueCopyBuffer(cl_command_queue clCommandQueue,
                                cl_mem clSrcBuffer, cl_mem clDstBuffer,
                                size_t szSrcOffset, size_t szDstOffset,
                                size_t szCb, cl_uint uNumEventsInWaitList,
                                const cl_event *cpEeventWaitList,
                                cl_event *pEvent,
                                Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueFillBuffer(cl_command_queue clCommandQueue,
                                cl_mem clBuffer, const void *pattern,
                                size_t pattern_size, size_t offset, size_t size,
                                cl_uint num_events_in_wait_list,
                                const cl_event *event_wait_list,
                                cl_event *pEvent,
                                Utils::ApiLogger *apiLogger) override;

  cl_err_code
  EnqueueReadBufferRect(cl_command_queue clCommandQueue, cl_mem clBuffer,
                        cl_bool bBlocking, const size_t szBufferOrigin[3],
                        const size_t szHostOrigin[3], const size_t region[3],
                        size_t buffer_row_pitch, size_t buffer_slice_pitch,
                        size_t host_row_pitch, size_t host_slice_pitch,
                        void *pOutData, cl_uint uNumEventsInWaitList,
                        const cl_event *cpEeventWaitList, cl_event *pEvent,
                        Utils::ApiLogger *apiLogger);
  cl_err_code
  EnqueueWriteBufferRect(cl_command_queue clCommandQueue, cl_mem clBuffer,
                         cl_bool bBlocking, const size_t szBufferOrigin[3],
                         const size_t szHostOrigin[3], const size_t region[3],
                         size_t buffer_row_pitch, size_t buffer_slice_pitch,
                         size_t host_row_pitch, size_t host_slice_pitch,
                         const void *pOutData, cl_uint uNumEventsInWaitList,
                         const cl_event *cpEeventWaitList, cl_event *pEvent,
                         Utils::ApiLogger *apiLogger);
  cl_err_code EnqueueCopyBufferRect(
      cl_command_queue clCommandQueue, cl_mem clSrcBuffer, cl_mem clDstBuffer,
      const size_t szSrcBufferOrigin[3], const size_t szDstBufferOrigin[3],
      const size_t region[3], size_t src_buffer_row_pitch,
      size_t src_buffer_slice_pitch, size_t dst_buffer_row_pitch,
      size_t dst_buffer_slice_pitch, cl_uint uNumEventsInWaitList,
      const cl_event *cpEeventWaitList, cl_event *pEvent,
      Utils::ApiLogger *apiLogger);

  cl_err_code EnqueueReadImage(cl_command_queue clCommandQueue, cl_mem clImage,
                               cl_bool bBlocking, const size_t szOrigin[3],
                               const size_t szRegion[3], size_t szRowPitch,
                               size_t szSlicePitch, void *pOutData,
                               cl_uint uNumEventsInWaitList,
                               const cl_event *cpEeventWaitList,
                               cl_event *pEvent,
                               Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueWriteImage(cl_command_queue clCommandQueue, cl_mem clImage,
                                cl_bool bBlocking, const size_t szOrigin[3],
                                const size_t szRegion[3], size_t szRowPitch,
                                size_t szSlicePitch, const void *cpSrcData,
                                cl_uint uNumEventsInWaitList,
                                const cl_event *cpEeventWaitList,
                                cl_event *pEvent,
                                Utils::ApiLogger *apiLogger) override;
  cl_err_code
  EnqueueCopyImage(cl_command_queue clCommandQueue, cl_mem clSrcImage,
                   cl_mem clDstImage, const size_t szSrcOrigin[3],
                   const size_t szDstOrigin[3], const size_t szRegion[3],
                   cl_uint uNumEventsInWaitList,
                   const cl_event *cpEeventWaitList, cl_event *pEvent,
                   Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueFillImage(cl_command_queue clCommandQueue, cl_mem clImage,
                               const void *fillColor, const size_t *origin,
                               const size_t *region,
                               cl_uint num_events_in_wait_list,
                               const cl_event *event_wait_list, cl_event *event,
                               Utils::ApiLogger *apiLogger);

  cl_err_code EnqueueCopyImageToBuffer(
      cl_command_queue clCommandQueue, cl_mem clSrcImage, cl_mem clDstBuffer,
      const size_t szSrcOrigin[3], const size_t szRegion[3], size_t szDstOffset,
      cl_uint uNumEventsInWaitList, const cl_event *cpEeventWaitList,
      cl_event *pEvent, Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueCopyBufferToImage(
      cl_command_queue clCommandQueue, cl_mem clSrcBuffer, cl_mem clDstImage,
      size_t szSrcOffset, const size_t szDstOrigin[3], const size_t szRegion[3],
      cl_uint uNumEventsInWaitList, const cl_event *cpEeventWaitList,
      cl_event *pEvent, Utils::ApiLogger *apiLogger) override;
  void *EnqueueMapBuffer(cl_command_queue clCommandQueue, cl_mem clBuffer,
                         cl_bool bBlockingMap, cl_map_flags clMapFlags,
                         size_t szOffset, size_t szCb,
                         cl_uint uNumEventsInWaitList,
                         const cl_event *cpEeventWaitList, cl_event *pEvent,
                         cl_int *pErrcodeRet,
                         Utils::ApiLogger *apiLogger) override;
  void *EnqueueMapImage(cl_command_queue clCommandQueue, cl_mem clImage,
                        cl_bool bBlockingMap, cl_map_flags clMapFlags,
                        const size_t szOrigin[3], const size_t szRegion[3],
                        size_t *pszImageRowPitch, size_t *pszImageSlicePitch,
                        cl_uint uNumEventsInWaitList,
                        const cl_event *cpEeventWaitList, cl_event *pEvent,
                        cl_int *pErrcodeRet,
                        Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueUnmapMemObject(cl_command_queue clCommandQueue,
                                    cl_mem clMemObj, void *mappedPtr,
                                    cl_uint uNumEventsInWaitList,
                                    const cl_event *cpEeventWaitList,
                                    cl_event *pEvent,
                                    Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueNDRangeKernel(
      cl_command_queue clCommandQueue, cl_kernel clKernel, cl_uint uiWorkDim,
      const size_t *cpszGlobalWorkOffset, const size_t *cpszGlobalWorkSize,
      const size_t *cpszLocalWorkSize, cl_uint uNumEventsInWaitList,
      const cl_event *cpEeventWaitList, cl_event *pEvent,
      Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueTask(cl_command_queue clCommandQueue, cl_kernel clKernel,
                          cl_uint uNumEventsInWaitList,
                          const cl_event *cpEeventWaitList, cl_event *pEvent,
                          Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueNativeKernel(
      cl_command_queue clCommandQueue, void(CL_CALLBACK *pUserFnc)(void *),
      void *pArgs, size_t szCbArgs, cl_uint uNumMemObjects,
      const cl_mem *clMemList, const void **ppArgsMemLoc,
      cl_uint uNumEventsInWaitList, const cl_event *cpEeventWaitList,
      cl_event *pEvent, Utils::ApiLogger *apiLogger) override;
  cl_err_code EnqueueMigrateMemObjects(
      cl_command_queue clCommandQueue, cl_uint uiNumMemObjects,
      const cl_mem *pMemObjects, cl_mem_migration_flags clFlags,
      cl_uint uiNumEventsInWaitList, const cl_event *pEventWaitList,
      cl_event *pEvent, Utils::ApiLogger *apiLogger);
  cl_err_code
  EnqueueSVMMigrateMem(cl_command_queue clCommandQueue,
                       cl_uint num_svm_pointers, const void **svm_pointers,
                       const size_t *sizes, cl_mem_migration_flags flags,
                       cl_uint uiNumEventsInWaitList,
                       const cl_event *pEventWaitList, cl_event *pEvent,
                       Utils::ApiLogger *apiLogger);
  cl_err_code EnqueueUSMMemset(cl_command_queue command_queue, void *dst_ptr,
                               cl_int value, size_t size,
                               cl_uint num_events_in_wait_list,
                               const cl_event *event_wait_list, cl_event *event,
                               Utils::ApiLogger *api_logger);
  cl_err_code EnqueueUSMMemFill(cl_command_queue command_queue, void *dst_ptr,
                                const void *pattern, size_t pattern_size,
                                size_t size, cl_uint num_events_in_wait_list,
                                const cl_event *event_wait_list,
                                cl_event *event, Utils::ApiLogger *api_logger);
  cl_err_code EnqueueUSMMemcpy(cl_command_queue command_queue, cl_bool blocking,
                               void *dst_ptr, const void *src_ptr, size_t size,
                               cl_uint num_events_in_wait_list,
                               const cl_event *event_wait_list, cl_event *event,
                               Utils::ApiLogger *api_logger);
  cl_err_code EnqueueUSMMigrateMem(cl_command_queue command_queue,
                                   const void *ptr, size_t size,
                                   cl_mem_migration_flags flags,
                                   cl_uint num_events_in_wait_list,
                                   const cl_event *event_wait_list,
                                   cl_event *event,
                                   Utils::ApiLogger *api_logger);
  cl_err_code EnqueueUSMMemAdvise(cl_command_queue command_queue,
                                  const void *ptr, size_t size,
                                  cl_mem_advice_intel advice,
                                  cl_uint num_events_in_wait_list,
                                  const cl_event *event_wait_list,
                                  cl_event *event,
                                  Utils::ApiLogger *api_logger);

  cl_err_code EnqueueReadGlobalVariable(
      cl_command_queue command_queue, cl_program program, const char *name,
      bool blocking_read, size_t size, size_t offset, void *ptr,
      cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
      cl_event *event, Utils::ApiLogger *apiLogger);

  cl_err_code EnqueueWriteGlobalVariable(
      cl_command_queue command_queue, cl_program program, const char *name,
      bool blocking_write, size_t size, size_t offset, const void *ptr,
      cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
      cl_event *event, Utils::ApiLogger *apiLogger);

  cl_err_code EnqueueReadHostPipeINTEL(
      cl_command_queue command_queue, cl_program program,
      const char *pipe_symbol, cl_bool blocking_write, void *ptr, size_t size,
      cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
      cl_event *event, Utils::ApiLogger *apiLogger);

  cl_err_code
  EnqueueWriteHostPipeINTEL(cl_command_queue command_queue, cl_program program,
                            const char *pipe_symbol, cl_bool blocking_write,
                            const void *ptr, size_t size,
                            cl_uint num_events_in_wait_list,
                            const cl_event *event_wait_list, cl_event *event,
                            Utils::ApiLogger *apiLogger);

  // Profiling
  cl_err_code GetEventProfilingInfo(cl_event clEvent,
                                    cl_profiling_info clParamName,
                                    size_t szParamValueSize, void *pParamValue,
                                    size_t *pszParamValueSizeRet) override;

  cl_err_code Release();
  cl_err_code Finish(const SharedPtr<IOclCommandQueueBase> &pCommandQueue);
  void DeleteAllActiveQueues(bool preserve_user_handles);
  void CancelAllActiveQueues();
  void FinishAllActiveQueues();

  cl_int EnqueueSVMFree(cl_command_queue clCommandQueue,
                        cl_uint uiNumSvmPointers, void *pSvmPointers[],
                        void(CL_CALLBACK *pfnFreeFunc)(cl_command_queue queue,
                                                       cl_uint uiNumSvmPointers,
                                                       void *pSvmPointers[],
                                                       void *pUserData),
                        void *pUserData, cl_uint uiNumEventsInWaitList,
                        const cl_event *pEventWaitList, cl_event *pEvent,
                        Utils::ApiLogger *apiLogger);
  cl_int EnqueueSVMMemcpy(cl_command_queue clCommandQueue,
                          cl_bool bBlockingCopy, void *pDstPtr,
                          const void *pSrcPtr, size_t size,
                          cl_uint uiNumEventsInWaitList,
                          const cl_event *pEventWaitList, cl_event *pEvent,
                          Utils::ApiLogger *apiLogger);
  cl_int EnqueueSVMMemFill(cl_command_queue clCommandQueue, void *pSvmPtr,
                           const void *pPattern, size_t szPatternSize,
                           size_t size, cl_uint uiNumEventsInWaitList,
                           const cl_event *pEventWaitList, cl_event *pEvent,
                           Utils::ApiLogger *apiLogger);
  cl_int EnqueueSVMMap(cl_command_queue clCommandQueue, cl_bool bBlockingMap,
                       cl_map_flags mapflags, void *pSvmPtr, size_t size,
                       cl_uint uiNumEventsInWaitList,
                       const cl_event *pEventWaitList, cl_event *pEvent,
                       Utils::ApiLogger *apiLogger);
  cl_int EnqueueSVMUnmap(cl_command_queue clCommandQueue, void *pSvmPtr,
                         cl_uint uiNumEventsInWaitList,
                         const cl_event *pEventWaitList, cl_event *pEvent,
                         Utils::ApiLogger *apiLogger);

  cl_err_code RunAutorunKernels(const SharedPtr<Program> &program,
                                Utils::ApiLogger *apiLogger);

  OclKernelEventMapTy &getKernelEventMap() { return m_OclKernelEventMap; }

  EventsManager *GetEventsManager() const { return m_pEventsManager; }
  void ReleaseAllUserEvents(bool preserve_user_handles);

  ocl_entry_points *GetDispatchTable() const { return m_pOclEntryPoints; }

  ocl_gpa_data *GetGPAData() const { return m_pGPAData; }

  // Command buffer
  cl_command_buffer_khr
  CreateCommandBufferKHR(cl_uint num_queues, const cl_command_queue *queues,
                         const cl_command_buffer_properties_khr *properties,
                         cl_int *errcode_ret);

  cl_int RetainCommandBufferKHR(cl_command_buffer_khr command_buffer);

  cl_int ReleaseCommandBufferKHR(cl_command_buffer_khr command_buffer);

  cl_int FinalizeCommandBufferKHR(cl_command_buffer_khr command_buffer);

  cl_int GetCommandBufferInfoKHR(cl_command_buffer_khr command_buffer,
                                 cl_command_buffer_info_khr param_name,
                                 size_t param_value_size, void *param_value,
                                 size_t *param_value_size_ret);

  /// @brief enqueue a command-buffer to execute on command-queues
  /// @param num_queues is the number of command-queues listed in queues.
  /// @param queues is a pointer to an ordered list of command-queues compatible
  /// with the command-queues used on recording. queues can be NULL, in which
  /// case the default command-queues used on command-buffer creation are used
  /// and num_queues must be 0.
  /// @param command_buffer refers to a valid command-buffer object.
  /// @param num_events_in_wait_list
  /// @param event_wait_list specify events that need to complete before this
  /// particular command can be executed. If event_wait_list is NULL, then this
  /// particular command does not wait on any event to complete. If
  /// event_wait_list is NULL, num_events_in_wait_list must be 0. If
  /// event_wait_list is not NULL, the list of events pointed to by
  /// event_wait_list must be valid and num_events_in_wait_list must be greater
  /// than 0. The events specified in event_wait_list act as synchronization
  /// points. The context associated with events in event_wait_list and
  /// command_queue must be the same. The memory associated with event_wait_list
  /// can be reused or freed after the function returns.
  /// @param event will return an event object that identifies this command and
  /// can be used to query for profiling information or queue a wait for this
  /// particular command to complete. event can be NULL in which case it will
  /// not be possible for the application to wait on this command or query it
  /// for profiling information.
  cl_int EnqueueCommandBufferKHR(cl_uint num_queues, cl_command_queue *queues,
                                 cl_command_buffer_khr command_buffer,
                                 cl_uint num_events_in_wait_list,
                                 const cl_event *event_wait_list,
                                 cl_event *event);

  /// @brief record a command to execute a kernel on a device
  /// @param command_buffer refers to a valid command-buffer object.
  /// @param command_queue specifies the command-queue the command will be
  /// recorded to. If the cl_khr_command_buffer_multi_device extension is not
  /// supported, only a single command-queue is supported, and command_queue
  /// must be NULL. If the cl_khr_command_buffer_multi_device extension is
  /// supported and command_queue is NULL, then only one command-queue must have
  /// been set on command_buffer creation; otherwise, command_queue must not be
  /// NULL.
  /// @param properties specifies a list of properties for the kernel command
  /// and their corresponding values. Each property name is immediately followed
  /// by the corresponding desired value. The list is terminated with 0. If a
  /// supported property and its value is not specified in properties, its
  /// default value will be used. properties may be NULL, in which case the
  /// default values for supported properties will be used. The
  /// cl_khr_command_buffer extension does not define any properties, but
  /// supported properties defined by extensions are defined in the List of
  /// supported properties by clCommandNDRangeKernelKHR table.
  /// @param kernel is a valid kernel object which must have its arguments set.
  /// Any changes to kernel after calling clCommandNDRangeKernelKHR, such as
  /// with clSetKernelArg or clSetKernelExecInfo, have no effect on the recorded
  /// command. If kernel is recorded to a following clCommandNDRangeKernelKHR
  /// command however, then that command will capture the updated state of
  /// kernel.
  /// @param work_dim, global_work_offset, global_work_size, local_work_size
  /// Refer to clEnqueueNDRangeKernel.
  /// @param sync_point_wait_list, num_sync_points_in_wait_list specify
  /// synchronization-points that need to complete before this particular
  /// command can be executed.
  /// @param mutable_handle returns a handle to the command. If the
  /// cl_khr_command_buffer_mutable_dispatch extension is supported, and
  /// mutable_handle is not NULL, it can be used in the
  /// cl_mutable_dispatch_config_khr struct to update the command configuration
  /// between recordings. The lifetime of this handle is tied to the parent
  /// command-buffer, such that freeing the command-buffer will also free this
  /// handle.
  cl_int CommandNDRangeKernelKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties, cl_kernel kernel,
      cl_uint work_dim, const size_t *global_work_offset,
      const size_t *global_work_size, const size_t *local_work_size,
      cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

  cl_int CommandFillBufferKHR(cl_command_buffer_khr command_buffer,
                              cl_command_queue command_queue,
                              const cl_command_properties_khr *properties,
                              cl_mem buffer, const void *pattern,
                              size_t pattern_size, size_t offset, size_t size,
                              cl_uint num_sync_points_in_wait_list,
                              const cl_sync_point_khr *sync_point_wait_list,
                              cl_sync_point_khr *sync_point,
                              cl_mutable_command_khr *mutable_handle);

  cl_int CommandCopyBufferKHR(cl_command_buffer_khr command_buffer,
                              cl_command_queue command_queue,
                              const cl_command_properties_khr *properties,
                              cl_mem src_buffer, cl_mem dst_buffer,
                              size_t src_offset, size_t dst_offset, size_t size,
                              cl_uint num_sync_points_in_wait_list,
                              const cl_sync_point_khr *sync_point_wait_list,
                              cl_sync_point_khr *sync_point,
                              cl_mutable_command_khr *mutable_handle);

  cl_int CommandFillImageKHR(cl_command_buffer_khr command_buffer,
                             cl_command_queue command_queue,
                             const cl_command_properties_khr *properties,
                             cl_mem image, const void *fill_color,
                             const size_t *origin, const size_t *region,
                             cl_uint num_sync_points_in_wait_list,
                             const cl_sync_point_khr *sync_point_wait_list,
                             cl_sync_point_khr *sync_point,
                             cl_mutable_command_khr *mutable_handle);

  cl_int CommandCopyImageKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties, cl_mem src_image,
      cl_mem dst_image, const size_t *src_origin, const size_t *dst_origin,
      const size_t *region, cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

  cl_int CommandCopyBufferToImageKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties, cl_mem src_buffer,
      cl_mem dst_image, size_t src_offset, const size_t *dst_origin,
      const size_t *region, cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

  cl_int CommandCopyImageToBufferKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties, cl_mem src_image,
      cl_mem dst_buffer, const size_t *src_origin, const size_t *region,
      size_t dst_offset, cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

  cl_int CommandCopyBufferRectKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties, cl_mem src_buffer,
      cl_mem dst_buffer, const size_t *src_origin, const size_t *dst_origin,
      const size_t *region, size_t src_row_pitch, size_t src_slice_pitch,
      size_t dst_row_pitch, size_t dst_slice_pitch,
      cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

  cl_int CommandBarrierWithWaitListKHR(
      cl_command_buffer_khr command_buffer, cl_command_queue command_queue,
      const cl_command_properties_khr *properties,
      cl_uint num_sync_points_in_wait_list,
      const cl_sync_point_khr *sync_point_wait_list,
      cl_sync_point_khr *sync_point, cl_mutable_command_khr *mutable_handle);

private:
  // Private functions

  bool IsValidQueueHandle(cl_command_queue clCommandQueue);

  // command_queue will be changed to default queue if it is NULL
  cl_int CheckCommandBufferBeforeRecord(cl_command_buffer_khr command_buffer,
                                        cl_command_queue &command_queue,
                                        cl_mutable_command_khr *mutable_handle);

  // Input parameters validation commands
  cl_err_code CheckCreateCommandQueueParams(
      cl_context clContext, cl_device_id clDevice,
      const cl_command_queue_properties *clQueueProperties,
      SharedPtr<Context> *ppContext,
      std::vector<cl_command_queue_properties> &clQueuePropsArray,
      cl_command_queue_properties &queueProps, cl_uint &uiQueueSize,
      cl_bool withProps);

  // global_work_size and local_work_size pointer may be changed (for example,
  // forced WG size)
  cl_int CheckNDRangeKernelParams(cl_command_queue command_queue,
                                  cl_kernel kernel, cl_uint work_dim,
                                  const size_t *global_work_offset,
                                  const size_t *&global_work_size,
                                  const size_t *&local_work_size);

  cl_int CheckFillBufferParams(cl_command_queue command_queue, cl_mem buffer,
                               const void *pattern, size_t pattern_size,
                               size_t offset, size_t size);

  cl_int CheckCopyBufferParams(cl_command_queue command_queue,
                               cl_mem src_buffer, cl_mem dst_buffer,
                               size_t src_offset, size_t dst_offset,
                               size_t size);

  cl_int CheckFillImageParams(cl_command_queue command_queue, cl_mem image,
                              const void *fill_color, const size_t *origin,
                              const size_t *region);

  cl_int CheckCopyImageParams(cl_command_queue command_queue, cl_mem src_image,
                              cl_mem dst_image, const size_t *src_origin,
                              const size_t *dst_origin, const size_t *region);

  cl_int CheckCopyBetweenBufferAndImageParams(cl_command_queue command_queue,
                                              cl_mem src_mem, cl_mem dst_mem,
                                              size_t buffer_offset,
                                              const size_t *image_origin,
                                              const size_t *image_region,
                                              bool is_src_image = true);

  // pitches may be updated if they are 0.
  cl_int
  CheckCopyBufferRectParams(cl_command_queue command_queue, cl_mem src_buffer,
                            cl_mem dst_buffer, const size_t *src_origin,
                            const size_t *dst_origin, const size_t *region,
                            size_t &src_row_pitch, size_t &src_slice_pitch,
                            size_t &dst_row_pitch, size_t &dst_slice_pitch);

  cl_err_code CheckImageFormats(SharedPtr<MemoryObject> pSrcImage,
                                SharedPtr<MemoryObject> pDstImage);
  bool CheckMemoryObjectOverlapping(SharedPtr<MemoryObject> pMemObj,
                                    const size_t *szSrcOrigin,
                                    const size_t *szDstOrigin,
                                    const size_t *szRegion);

  /// Returns whether USM buffer can be accessed in current command queue.
  bool CanAccessUSM(SharedPtr<IOclCommandQueueBase> &queue,
                    SharedPtr<USMBuffer> &buf);

  size_t CalcRegionSizeInBytes(SharedPtr<MemoryObject> pImage,
                               const size_t *szRegion);
  cl_err_code FlushAllQueuesForContext(cl_context ctx);
  cl_err_code EnqueueMarkerWithWaitList(
      const SharedPtr<IOclCommandQueueBase> &clCommandQueue,
      cl_uint uiNumEvents, const cl_event *pEventList, cl_event *pEvent,
      Utils::ApiLogger *pApiLogger);
  cl_err_code
  EnqueueMarker(const SharedPtr<IOclCommandQueueBase> &clCommandQueue,
                cl_event *pEvent, Utils::ApiLogger *pApiLogger);

  /// Enqueue parallel copy.
  cl_err_code
  EnqueueLibraryCopy(SharedPtr<IOclCommandQueueBase> &queue, void *dst,
                     const void *src, size_t size, bool is_dst_svm,
                     bool is_dst_usm, bool is_src_svm, bool is_src_usm,
                     cl_bool blocking, cl_uint num_events_in_wait_list,
                     const cl_event *event_wait_list, cl_event *event,
                     Utils::ApiLogger *api_logger, cl_command_type cmdType);

  // Enqueue parallel set.
  cl_err_code EnqueueLibrarySet(
      SharedPtr<IOclCommandQueueBase> &queue, void *dst, const void *pattern,
      size_t pattern_size, size_t size, bool is_dst_svm, bool is_dst_usm,
      cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
      cl_event *event, Utils::ApiLogger *api_logger, cl_command_type cmdType);

  // Callback for Evt status change. if it's changed to CL_COMPLETE, we need to
  // remove it from kernel-event map.
  void callbackForKernelEventMap(cl_event Evt);

  SharedPtr<CommandBuffer>
  getCommandBuffer(cl_command_buffer_khr command_buffer);

  ContextModule *m_pContextModule; // Pointer to the context operation. This is
                                   // the internal interface of the module.
  OCLObjectsMap<_cl_command_queue_int, _cl_context_int>
      *m_pOclCommandQueueMap; // Holds the set of active queues.
  OCLObjectsMap<_cl_object, _cl_context_int>
      *m_pCommandBufferMap; // Holds the set of active command buffers.

  // Binding between a kernel to enqueue and an event assosiated with
  // the kernel. Need for kernel serialization on FPGA emulator.
  OclKernelEventMapTy m_OclKernelEventMap;
  EventsManager *m_pEventsManager; // Placeholder for all active events.

  Program *m_pActiveProgram; // FPGA devices only support a single program at a
                             // time, this variable is used to emulate such
                             // behavior on FPGA emulator.

  ocl_entry_points *m_pOclEntryPoints;

  ocl_gpa_data *m_pGPAData;

  Utils::OPENCL_VERSION m_opencl_ver = Utils::OPENCL_VERSION_UNKNOWN;

  // Whether parallel copy is enabled.
  bool m_enableParallelCopy = false;

  /// Sync for the access of ExecutionModule::m_OclKernelEventMap
  std::mutex KernelEventMutex;

  DECLARE_LOGGER_CLIENT; // Logger client for logging operations.
};

} // namespace Framework
} // namespace OpenCL
} // namespace Intel
