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

#include "CPUBuiltinLibrary.h"
#include "SystemInfo.h"
#include "cl_env.h"
#include "cl_sys_info.h"
#include "exceptions.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"

#if defined(_WIN32)
#include <windows.h>
#else
#include <linux/limits.h>
#define MAX_PATH PATH_MAX
#endif

namespace Intel {
namespace OpenCL {
namespace DeviceBackend {

using namespace llvm;

void CPUBuiltinLibrary::Load() {
  // Klocwork warning - false alarm the Id is always in correct bounds
  const char *CPUPrefix = m_cpuId->GetCPUPrefix();
  std::string LibFileToCheck = std::string("clbltfn") + CPUPrefix + ".rtl";
  std::string PathStr = getModuleDirOrOverrideFromEnvOrFallback(
      LibFileToCheck, DEFAULT_OCL_LIBRARY_DIR);

  if (m_useDynamicSvmlLibrary) {
    // Load SVML functions
    assert(CPUPrefix && "CPUPrefix is null");
    SmallString<128> SVMLPath(PathStr);
    llvm::sys::path::append(SVMLPath, std::string("libocl_svml_") + CPUPrefix);
#if defined(_WIN32)
    const char *LibExt = ".dll";
#else
    const char *LibExt = ".so";
#endif
    SVMLPath += LibExt;
    if (!llvm::sys::fs::exists(SVMLPath)) {
      SmallString<128> OldSVMLPath(PathStr);
      llvm::sys::path::append(OldSVMLPath,
                              std::string("__ocl_svml_") + CPUPrefix);
      OldSVMLPath += LibExt;
      if (llvm::sys::fs::exists(OldSVMLPath))
        SVMLPath = std::move(OldSVMLPath);
    }

    std::string Err;
    if (sys::DynamicLibrary::LoadLibraryPermanently(SVMLPath.c_str(), &Err)) {
      throw Exceptions::DeviceBackendExceptionBase(
          std::string("Loading SVML library failed - ") + Err);
    }
  }

  // Load LLVM built-ins module(s)
  // Load target-specific built-in library
  SmallString<128> RTLPath(PathStr);
  llvm::sys::path::append(RTLPath, std::string("clbltfn") + CPUPrefix + ".rtl");
  ErrorOr<std::unique_ptr<MemoryBuffer>> RTLBufferOrErr =
      MemoryBuffer::getFile(RTLPath);
  if (!RTLBufferOrErr)
    throw Exceptions::DeviceBackendExceptionBase(
        std::string("Failed to load the builtins rtl library"));

  m_pRtlBuffer = std::move(RTLBufferOrErr.get());

  // Load shared built-in library
  // Deploy case:
  // lib/
  //    clbltfnshared.rtl
  //    x64/ or x86/
  //        other libraries
  SmallString<128> RTLSharedPath(PathStr);
  llvm::sys::path::append(RTLSharedPath, "..", "clbltfnshared.rtl");
  // Trying to load it
  ErrorOr<std::unique_ptr<MemoryBuffer>> RTLBufferSharedOrErr =
      MemoryBuffer::getFile(RTLSharedPath);
  if (!RTLBufferSharedOrErr) {
    // TODO: Fix build layout to not support this case
    // Development install case:
    // shared library is in the same directory as other ones
    SmallString<128> RTLSharedPath(PathStr);
    llvm::sys::path::append(RTLSharedPath, "clbltfnshared.rtl");

    // Trying to load it
    RTLBufferSharedOrErr = MemoryBuffer::getFile(RTLSharedPath);
    if (!RTLBufferSharedOrErr)
      throw Exceptions::DeviceBackendExceptionBase(
          std::string("Failed to load the shared builtins rtl library"));
  }
  m_pRtlBufferSvmlShared = std::move(RTLBufferSharedOrErr.get());
}

} // namespace DeviceBackend
} // namespace OpenCL
} // namespace Intel
