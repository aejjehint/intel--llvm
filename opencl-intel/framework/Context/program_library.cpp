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

#include "program_library.h"
#include "program_with_library_kernels.h"

using namespace Intel::OpenCL::Framework;

cl_int ProgramLibrary::initialize(SharedPtr<Context> Ctx,
                                  const cl_uint NumDevices,
                                  SharedPtr<FissionableDevice> *Devices) {
  assert(NumDevices > 0 && "Invalid uiNumDevices");
  assert(Devices && "Invalid Devices");

  // Create program object.
  std::string KernelNames;
  cl_int Err;
  Prog = ProgramWithLibraryKernels::Allocate(Ctx, NumDevices, Devices,
                                             KernelNames, &Err);
  if (CL_SUCCESS != Err) {
    return Err;
  }

  // Create kernels for current thread.
  threadid_t TID = clMyThreadId();
  std::vector<std::string> KernelNamesVec = SplitString(KernelNames, ';');
  for (auto &KName : KernelNamesVec) {
    SharedPtr<Kernel> K = createKernelForThread(TID, KName);
    if (!K) {
      return CL_OUT_OF_RESOURCES;
    }
  }

  return Err;
}

cl_int ProgramLibrary::release() {
  // Release kernels.
  for (auto I = Kernels.begin(), E = Kernels.end(); I != E; ++I) {
    for (auto &K : I->second) {
      cl_kernel CLKernel = K.second->GetHandle();
      long NewRef = K.second->Release();
      if (NewRef < 0) {
        return CL_INVALID_KERNEL;
      } else if (0 == NewRef) {
        if (auto Err = Prog->RemoveKernel(CLKernel); CL_FAILED(Err))
          return Err;
      }
    }
  }

  long NewRef = Prog->Release();
  if (NewRef < 0)
    return CL_INVALID_PROGRAM;

  return CL_SUCCESS;
}

SharedPtr<Kernel>
ProgramLibrary::createKernelForThread(threadid_t TID, const std::string &Name) {
  SharedPtr<Kernel> K = nullptr;
  cl_err_code Err = Prog->CreateKernel(Name.c_str(), &K);
  if (CL_FAILED(Err))
    return nullptr;

  Kernels[TID][Name] = K;
  return K;
}

SharedPtr<Kernel> ProgramLibrary::getLibraryKernel(const std::string &Name) {
  threadid_t TID = clMyThreadId();
  SharedPtr<Kernel> K = (Kernels.count(TID) && Kernels[TID].count(Name))
                            ? Kernels[TID][Name]
                            : nullptr;
  if (!K)
    K = createKernelForThread(TID, Name);

  return K;
}

cl_int ProgramLibraries::create(SharedPtr<Context> Ctx,
                                const cl_uint NumDevices,
                                SharedPtr<FissionableDevice> *Devices) {
  std::lock_guard<std::mutex> Lock(m_mutex);
  cl_int Err;
  try {
    auto *PL = new ProgramLibrary();
    Err = PL->initialize(Ctx, NumDevices, Devices);
    if (Err == CL_SUCCESS) {
      PL->Retain();
      m_programLibraries[Ctx.GetPtr()] = PL;
    } else {
      delete PL;
    }
  } catch (std::bad_alloc &) {
    Err = CL_OUT_OF_HOST_MEMORY;
  }
  return Err;
}

cl_int ProgramLibraries::retain(Context *Ctx) {
  std::lock_guard<std::mutex> Lock(m_mutex);
  if (auto It = m_programLibraries.find(Ctx); It != m_programLibraries.end()) {
    It->second->Retain();
    return CL_SUCCESS;
  }
  return CL_INVALID_OPERATION;
}

cl_int ProgramLibraries::release(Context *Ctx) {
  std::lock_guard<std::mutex> Lock(m_mutex);
  if (auto It = m_programLibraries.find(Ctx); It != m_programLibraries.end()) {
    unsigned UseCount = It->second->UseCount();
    It->second->Release();
    if (UseCount == 1)
      m_programLibraries.erase(It);
    return CL_SUCCESS;
  }
  return CL_INVALID_OPERATION;
}

SharedPtr<Kernel> ProgramLibraries::getLibraryKernel(Context *Ctx,
                                                     const std::string &Name) {
  std::lock_guard<std::mutex> Lock(m_mutex);
  if (auto it = m_programLibraries.find(Ctx); it != m_programLibraries.end())
    return it->second->getLibraryKernel(Name);

  return nullptr;
}
