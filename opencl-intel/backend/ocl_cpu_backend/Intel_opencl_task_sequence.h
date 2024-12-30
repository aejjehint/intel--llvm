// Copyright 2021 Intel Corporation.
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

#include "IBlockToKernelMapper.h"
#include "ICLDevBackendServiceFactory.h"
#include "cl_types.h"
#include <vector>

class IDeviceCommandManager;

// Original layout of task_sequence
struct task_sequence {
  unsigned outstanding;
  void *spirv_TaskSequence;
};

struct task_sequence_data {
  std::vector<char *> results;     // Buffers to store returned values
  std::vector<clk_event_t> events; // OCL events to observe async tasks
  size_t result_size; // Size of every single value returned by __get()
  unsigned delivered; // Number of __get() being invoked
  int32_t pipelined;
  int32_t fpga_cluster;
  uint32_t response_capacity;
  uint32_t invocation_capacity;
  unsigned outstanding;
};

extern "C" LLVM_BACKEND_API void *
__ocl_task_sequence_create(size_t ret_type_size, int pipelined,
                           int fpga_cluster, int response_capacity,
                           int invocation_capacity);

extern "C" LLVM_BACKEND_API void __ocl_task_sequence_async(
    task_sequence *obj, void *block_invoke, void *block_literal,
    IDeviceCommandManager *DCM,
    Intel::OpenCL::DeviceBackend::IBlockToKernelMapper *B2K,
    void *RuntimeHandle);

extern "C" LLVM_BACKEND_API void *
__ocl_task_sequence_get(task_sequence *obj, IDeviceCommandManager *DCM);

extern "C" LLVM_BACKEND_API void
__ocl_task_sequence_release(task_sequence *obj);
