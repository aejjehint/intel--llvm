//
// Copyright (C) 2024 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.
//

#pragma once

#include "Context.h"
#include "cl_utils.h"
#include "llvm/ADT/IntrusiveRefCntPtr.h"

namespace Intel {
namespace OpenCL {
namespace Framework {

// Holds the backend library program and kernels in a context.
class ProgramLibrary : public llvm::RefCountedBase<ProgramLibrary> {
public:
  ProgramLibrary() = default;
  ~ProgramLibrary() { release(); }
  ProgramLibrary(ProgramLibrary &) = delete;
  ProgramLibrary &operator=(ProgramLibrary &) = delete;

  cl_int initialize(SharedPtr<Context> Ctx, const cl_uint NumDevices,
                    SharedPtr<FissionableDevice> *Devices);

  cl_int release();

  SharedPtr<Kernel> getLibraryKernel(const std::string &Name);

  SharedPtr<Kernel> createKernelForThread(const threadid_t TID,
                                          const std::string &Name);

private:
  SharedPtr<Program> Prog;
  std::map<threadid_t, std::map<std::string, SharedPtr<Kernel>>> Kernels;
};

/// Holds map from context to ProgramLibrary instance. Each context has its own
/// ProgramLibrary instance since a program is associated with a context.
class ProgramLibraries {
public:
  cl_int create(SharedPtr<Context> Ctx, const cl_uint NumDevices,
                SharedPtr<FissionableDevice> *Devices);
  cl_int retain(Context *Ctx);
  cl_int release(Context *Ctx);

  SharedPtr<Kernel> getLibraryKernel(Context *Ctx, const std::string &Name);

private:
  std::map<Context *, ProgramLibrary *> m_programLibraries;
  std::mutex m_mutex;
};

} // namespace Framework
} // namespace OpenCL
} // namespace Intel
