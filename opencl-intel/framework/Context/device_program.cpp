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

#include "device_program.h"
#include "Device.h"
#include "ElfReader.h"
#include "cache_binary_handler.h"
#include "cl_shared_ptr.hpp"
#include "cl_sys_defines.h"
#include "elf_binary.h"
#include "events_manager.h"
#include "fe_compiler.h"
#include "framework_proxy.h"

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/TargetParser/Triple.h"

using namespace llvm;
using namespace Intel::OpenCL::Utils;
using namespace Intel::OpenCL::ELFUtils;
using namespace Intel::OpenCL::Framework;

DeviceProgram::DeviceProgram()
    : m_state(DEVICE_PROGRAM_INVALID), m_bBuiltFromSource(false),
      m_bFECompilerSuccess(false), m_bIsClone(false), m_pDevice(nullptr),
      m_deviceHandle(0), m_programHandle(0), m_parentProgramHandle(0),
      m_parentProgramContext(0), m_uiBuildLogSize(0), m_szBuildLog(nullptr),
      m_emptyString('\0'), m_szBuildOptions(nullptr), m_pBinaryBits(nullptr),
      m_uiBinaryBitsSize(0), m_clBinaryBitsType(CL_PROGRAM_BINARY_TYPE_NONE) {}

DeviceProgram::DeviceProgram(const Intel::OpenCL::Framework::DeviceProgram &dp)
    : m_state(DEVICE_PROGRAM_INVALID), m_bBuiltFromSource(false),
      m_bFECompilerSuccess(false), m_bIsClone(true), m_pDevice(nullptr),
      m_deviceHandle(0), m_programHandle(0), m_parentProgramHandle(0),
      m_uiBuildLogSize(0), m_szBuildLog(nullptr), m_emptyString('\0'),
      m_szBuildOptions(nullptr), m_pBinaryBits(nullptr), m_uiBinaryBitsSize(0),
      m_clBinaryBitsType(CL_PROGRAM_BINARY_TYPE_NONE) {
  SetDevice(dp.m_pDevice);
  SetHandle(dp.m_parentProgramHandle);
  SetContext(dp.m_parentProgramContext);
  m_bBuiltFromSource = dp.m_bBuiltFromSource;
  m_bFECompilerSuccess = dp.m_bFECompilerSuccess;
  // Todo: in the future it's a good idea to copy a completed binary from my
  // source, or to add myself as an observer for its completion
  //  Currently, force a real re-build of the program even if we're copying a
  //  built program Thus, no use for m_bIsClone currently
  m_bIsClone = false;
}

DeviceProgram::~DeviceProgram() {
  if (m_pBinaryBits) {
    delete[] m_pBinaryBits;
    m_pBinaryBits = nullptr;
    m_uiBinaryBitsSize = 0;
  }
  if (m_szBuildOptions) {
    delete[] m_szBuildOptions;
    m_szBuildOptions = nullptr;
  }
  if (m_szBuildLog != nullptr) {
    delete[] m_szBuildLog;
    m_szBuildLog = nullptr;
    m_uiBuildLogSize = 0;
  }
  if (m_pDevice) {
    if (0 != m_programHandle) {
      m_pDevice->GetDeviceAgent()->clDevReleaseProgram(m_programHandle);
    }
  }
}

// Return true on success. If false is returned, the argument info is
// unavailable to users.
static bool
parseKernelArgsInfo(Function &F,
                    std::vector<cl_kernel_argument_info> &ArgsInfo) {
  MDNode *AddressQualifiers = F.getMetadata("kernel_arg_addr_space");
  MDNode *AccessQualifiers = F.getMetadata("kernel_arg_access_qual");
  MDNode *TypeNames = F.getMetadata("kernel_arg_type");
  MDNode *TypeQualifiers = F.getMetadata("kernel_arg_type_qual");
  MDNode *ArgNames = F.getMetadata("kernel_arg_name");
  MDNode *HostAccessible = F.getMetadata("kernel_arg_host_accessible");
  MDNode *LocalMemSize = F.getMetadata("local_mem_size");

  unsigned KernelArgCount = F.arg_size();
  for (unsigned int I = 0; I < KernelArgCount; ++I) {
    Argument *Arg = F.getArg(I);
    cl_kernel_argument_info ArgInfo;
    memset(&ArgInfo, 0, sizeof(ArgInfo));

    // Address qualifier
    unsigned AddrQ = 0;
    if (AddressQualifiers) {
      assert(AddressQualifiers->getNumOperands() == KernelArgCount &&
             "If kernel has 'kernel_arg_addr_space' metadata, its operand "
             "count must match with kernel arg count!");
      ConstantInt *AddressQualifier =
          mdconst::dyn_extract<ConstantInt>(AddressQualifiers->getOperand(I));
      assert(AddressQualifier &&
             "AddressQualifier is not a valid ConstantInt*");
      AddrQ = AddressQualifier->getZExtValue();
    } else {
      // kernel_arg_addr_space might not exist for a SYCL kernel.
      // Decode from the kernel argument itself.
      if (auto *PTy = dyn_cast<PointerType>(Arg->getType()))
        AddrQ = PTy->getAddressSpace();
    }
    switch (AddrQ) {
    case 0:
      ArgInfo.addressQualifier = CL_KERNEL_ARG_ADDRESS_PRIVATE;
      break;
    case 1:
      ArgInfo.addressQualifier = CL_KERNEL_ARG_ADDRESS_GLOBAL;
      break;
    case 2:
      ArgInfo.addressQualifier = CL_KERNEL_ARG_ADDRESS_CONSTANT;
      break;
    case 3:
      ArgInfo.addressQualifier = CL_KERNEL_ARG_ADDRESS_LOCAL;
      break;
    default:
      // This only happens for the block enqueued by `enqueue_kernel` builtin.
      // The address space might be 4 (GENERIC).
      // In such case the arg info shouldn't be available to users anyway.
      return false;
    }

    // Access qualifier
    // kernel_arg_access_qual might not exist for a SYCL kernel, leave it as
    // "none" by default.
    StringRef AccessQ = "none";
    if (AccessQualifiers) {
      assert(AccessQualifiers->getNumOperands() == KernelArgCount &&
             "If kernel has 'kernel_arg_access_qual' metadata, its operand "
             "count must match with kernel arg count!");
      AccessQ = cast<MDString>(AccessQualifiers->getOperand(I))->getString();
    }
    ArgInfo.accessQualifier =
        StringSwitch<cl_kernel_arg_access_qualifier>(AccessQ)
            .Case("read_only", CL_KERNEL_ARG_ACCESS_READ_ONLY)
            .Case("write_only", CL_KERNEL_ARG_ACCESS_WRITE_ONLY)
            .Case("read_write", CL_KERNEL_ARG_ACCESS_READ_WRITE)
            .Default(CL_KERNEL_ARG_ACCESS_NONE);

    // Type qualifier
    // kernel_arg_type_qual might not exist for a SYCL kernel, leave it as ""
    // by default.
    StringRef TypeQ = "";
    if (TypeQualifiers) {
      assert(TypeQualifiers->getNumOperands() == KernelArgCount &&
             "If kernel has 'kernel_arg_type_qual' metadata, its operand "
             "count must match with kernel arg count!");
      TypeQ = cast<MDString>(TypeQualifiers->getOperand(I))->getString();
    }
    ArgInfo.typeQualifier = 0;
    if (TypeQ.contains("const"))
      ArgInfo.typeQualifier |= CL_KERNEL_ARG_TYPE_CONST;
    if (TypeQ.contains("restrict"))
      ArgInfo.typeQualifier |= CL_KERNEL_ARG_TYPE_RESTRICT;
    if (TypeQ.contains("volatile"))
      ArgInfo.typeQualifier |= CL_KERNEL_ARG_TYPE_VOLATILE;
    if (TypeQ.contains("pipe"))
      ArgInfo.typeQualifier |= CL_KERNEL_ARG_TYPE_PIPE;

    // Type name
    std::string TypeName = "";
    if (TypeNames) {
      assert(TypeNames->getNumOperands() == KernelArgCount &&
             "If kernel has 'kernel_arg_type' metadata, its operand count "
             "must match with kernel arg count!");
      TypeName = cast<MDString>(TypeNames->getOperand(I))->getString().str();
    } else {
      // kernel_arg_type might not exist for a SYCL kernel.
      // Decode from the kernel argument itself.
      raw_string_ostream OS(TypeName);
      // FIXME: Type::print function is empty in release build, so TypeName will
      // be empty string. We need to look for solution to get type name although
      // empty string may not lead to stability issue.
      Arg->getType()->print(OS, /*IsForDebug*/ false, /*NoDetails*/ true);
      OS.flush();
    }
    ArgInfo.typeName = STRDUP(TypeName.c_str());

    if (ArgNames) {
      // Parameter name
      MDString *ArgName = cast<MDString>(ArgNames->getOperand(I));
      ArgInfo.name = STRDUP(ArgName->getString().str().c_str());
    }

    if (HostAccessible) {
      auto *HostAccessibleFlag =
          cast<ConstantAsMetadata>(HostAccessible->getOperand(I));

      ArgInfo.hostAccessible =
          HostAccessibleFlag &&
          cast<ConstantInt>(HostAccessibleFlag->getValue())->isOne();
    }

    if (LocalMemSize) {
      auto *LocalMemSizeFlag =
          cast<ConstantAsMetadata>(LocalMemSize->getOperand(I));

      ArgInfo.localMemSize =
          cast<ConstantInt>(LocalMemSizeFlag->getValue())->getZExtValue();
    }

    ArgsInfo.push_back(ArgInfo);
  }
  return true;
}

void DeviceProgram::initializeAllKernelArgsInfoFromIRData() {
  // Mark kernel arg infos as cached, no matter we succeeded or not.
  // If we failed to get kernel arg infos for the current program binary, we
  // should not try again.
  m_bKernelArgsInfoCached = true;

  // Try to parse module from binary.
  const char *Binary = GetBinaryInternal();
  size_t BinSize = GetBinarySizeInternal();
  if (!Binary || 0 == BinSize)
    return;

  // Check binary type
  cl_prog_binary_type BinType;
  if (!CheckProgramBinary(BinSize, Binary, &BinType))
    return;

  // Get IR binary
  const void *IRBuffer = nullptr;
  size_t IRBufferSize = 0;
  if (BinType >= CL_PROG_BIN_COMPILED_LLVM &&
      BinType <= CL_PROG_BIN_EXECUTABLE_LLVM) {
    // ELF object, get IR section data
    auto *Reader = CLElfLib::CElfReader::Create(Binary, BinSize);
    const char *TmpPtr = nullptr;
    Reader->GetSectionData(ELFUtils::g_irSectionName, TmpPtr, IRBufferSize);
    IRBuffer = TmpPtr;
    CLElfLib::CElfReader::Delete(Reader);
  } else if (BinType == CL_PROG_BIN_COMPILED_SPIR ||
             BinType == CL_PROG_BIN_COMPILED_SPV_IR) {
    // LLVM IR or SPIR-V Friendly LLVM IR
    IRBuffer = Binary;
    IRBufferSize = BinSize;
  }

  if (!IRBuffer || 0 == IRBufferSize)
    return;

  StringRef IRData(static_cast<const char *>(IRBuffer), IRBufferSize);
  auto IRBuff = MemoryBuffer::getMemBuffer(IRData, "", false);
  auto Ctx = std::make_unique<LLVMContext>();
  auto ModuleOrErr = parseBitcodeFile(IRBuff->getMemBufferRef(), *Ctx);
  if (!ModuleOrErr)
    return;

  // Collect kernel argument info
  for (auto &F : *ModuleOrErr.get()) {
    if (F.isDeclaration() || F.getCallingConv() != CallingConv::SPIR_KERNEL)
      continue;
    std::vector<cl_kernel_argument_info> ArgsInfo;
    bool IsAvailable = parseKernelArgsInfo(F, ArgsInfo);
    if (IsAvailable)
      m_KernelArgsInfo.insert({F.getName().str(), ArgsInfo});
  }
}

cl_err_code DeviceProgram::queryKernelArgsInfo(
    const char *KernelName, std::vector<cl_kernel_argument_info> &ArgsInfo) {
  std::lock_guard<std::mutex> Lock(m_KernelArgsInfoMutex);
  if (!m_bKernelArgsInfoCached)
    initializeAllKernelArgsInfoFromIRData();

  assert(m_bKernelArgsInfoCached && "Kernel args info should be cached now.");
  if (m_KernelArgsInfo.find(KernelName) == m_KernelArgsInfo.end())
    return CL_KERNEL_ARG_INFO_NOT_AVAILABLE;

  ArgsInfo = m_KernelArgsInfo[KernelName];
  return CL_SUCCESS;
}

void DeviceProgram::SetDevice(const SharedPtr<FissionableDevice> &pDevice) {
  m_pDevice = pDevice;
  // Must not give NULL ptr
  assert(m_pDevice);
  m_deviceHandle = m_pDevice->GetHandle();
}

cl_err_code DeviceProgram::SetBinary(size_t uiBinarySize,
                                     const unsigned char *pBinary,
                                     cl_int *piBinaryStatus) {
  cl_prog_binary_type uiBinaryType;
  // Check if binary format is known by the runtime and device
  if (!CheckProgramBinary(uiBinarySize, pBinary, &uiBinaryType)) {
    // Binary format is not supported by both runtime and device
    if (piBinaryStatus) {
      *piBinaryStatus = CL_INVALID_BINARY;
    }
    return CL_INVALID_BINARY;
  }

  cl_program_binary_type clBinaryType = CL_PROGRAM_BINARY_TYPE_NONE;

  switch (uiBinaryType) {
  case CL_PROG_BIN_COMPILED_SPIR:
    clBinaryType = CL_PROGRAM_BINARY_TYPE_INTERMEDIATE;
    break;
  case CL_PROG_BIN_COMPILED_LLVM:
  case CL_PROG_BIN_COMPILED_SPV_IR:
    clBinaryType = CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT;
    break;
  case CL_PROG_BIN_LINKED_LLVM:
    clBinaryType = CL_PROGRAM_BINARY_TYPE_LIBRARY;
    break;
  case CL_PROG_BIN_EXECUTABLE_LLVM:
    clBinaryType = CL_PROGRAM_BINARY_TYPE_EXECUTABLE;
    break;
  default:
    if (piBinaryStatus) {
      *piBinaryStatus = CL_INVALID_BINARY;
    }
    return CL_INVALID_BINARY;
  }

  if (piBinaryStatus) {
    *piBinaryStatus = CL_SUCCESS;
  }

  // if binary is valid binary create program binary object and add it to the
  // program object
  return SetBinaryInternal(uiBinarySize, pBinary, clBinaryType);
}

cl_err_code
DeviceProgram::SetBinaryInternal(size_t uiBinarySize, const void *pBinary,
                                 cl_program_binary_type clBinaryType) {
  if (m_uiBinaryBitsSize > 0) {
    assert(m_pBinaryBits);
    delete[] m_pBinaryBits;
  }

  m_uiBinaryBitsSize = uiBinarySize;
  m_pBinaryBits = new char[uiBinarySize];
  MEMCPY_S(m_pBinaryBits, m_uiBinaryBitsSize, pBinary, m_uiBinaryBitsSize);

  SetBinaryTypeInternal(clBinaryType);

  // Clear cached kernel arg info
  {
    std::lock_guard<std::mutex> Lock(m_KernelArgsInfoMutex);
    if (m_bKernelArgsInfoCached) {
      m_KernelArgsInfo.clear();
      m_bKernelArgsInfoCached = false;
    }
  }

  return CL_SUCCESS;
}

cl_err_code
DeviceProgram::SetBinaryTypeInternal(cl_program_binary_type clBinaryType) {
  m_clBinaryBitsType = clBinaryType;
  return CL_SUCCESS;
}

cl_err_code DeviceProgram::ClearBuildLogInternal() {
  if (m_szBuildLog) {
    delete[] m_szBuildLog;
    m_szBuildLog = nullptr;
  }

  return CL_SUCCESS;
}

cl_err_code DeviceProgram::SetBuildLogInternal(const char *szBuildLog) {
  size_t uiLogSize = strlen(szBuildLog) + 1;

  if (m_szBuildLog) {
    size_t uiNewBuildLogSize =
        m_uiBuildLogSize + uiLogSize - 1; // no need for two NULL termination

    char *szNewBuildLog = new char[uiNewBuildLogSize];

    STRCPY_S(szNewBuildLog, uiNewBuildLogSize, m_szBuildLog);
    STRCAT_S(szNewBuildLog, uiNewBuildLogSize, szBuildLog);

    m_uiBuildLogSize = uiNewBuildLogSize;
    delete[] m_szBuildLog;
    m_szBuildLog = szNewBuildLog;

    return CL_SUCCESS;
  }

  m_szBuildLog = new char[uiLogSize];

  STRCPY_S(m_szBuildLog, uiLogSize, szBuildLog);
  m_uiBuildLogSize = uiLogSize;

  return CL_SUCCESS;
}

cl_err_code DeviceProgram::SetBuildOptionsInternal(const char *szBuildOptions) {
  if (m_szBuildOptions) {
    delete[] m_szBuildOptions;
    m_szBuildOptions = nullptr;
  }

  if (szBuildOptions) {
    size_t uiOptionLength = strlen(szBuildOptions) + 1;
    m_szBuildOptions = new char[uiOptionLength];
    MEMCPY_S(m_szBuildOptions, uiOptionLength, szBuildOptions, uiOptionLength);
  }

  return CL_SUCCESS;
}

const char *DeviceProgram::GetBuildOptionsInternal() {
  return m_szBuildOptions;
}

cl_err_code DeviceProgram::SetStateInternal(EDeviceProgramState state) {
  // TODO: maybe add state machine
  m_state = state;

  return CL_SUCCESS;
}

bool DeviceProgram::Acquire() {
  if (0 == m_currentAccesses++) {
    return true;
  }
  m_currentAccesses--;
  return false;
}

cl_build_status DeviceProgram::GetBuildStatus() const {
  switch (m_state) {
  default:
  case DEVICE_PROGRAM_INVALID:
    return CL_BUILD_ERROR;

  case DEVICE_PROGRAM_SOURCE:
  case DEVICE_PROGRAM_LOADED_IR:
  case DEVICE_PROGRAM_CUSTOM_BINARY:
  case DEVICE_PROGRAM_SPIRV:
    return CL_BUILD_NONE;

  case DEVICE_PROGRAM_FE_COMPILING:
  case DEVICE_PROGRAM_FE_LINKING:
  case DEVICE_PROGRAM_BE_BUILDING:
    return CL_BUILD_IN_PROGRESS;

  case DEVICE_PROGRAM_CREATING_AUTORUN:
  case DEVICE_PROGRAM_COMPILED:
  case DEVICE_PROGRAM_LINKED:
  case DEVICE_PROGRAM_BUILD_DONE:
  case DEVICE_PROGRAM_BUILTIN_KERNELS:
  case DEVICE_PROGRAM_LIBRARY_KERNELS:
    return CL_BUILD_SUCCESS;
  }

  return CL_BUILD_ERROR;
}

cl_err_code DeviceProgram::GetBuildInfo(cl_program_build_info clParamName,
                                        size_t uiParamValueSize,
                                        void *pParamValue,
                                        size_t *puiParamValueSizeRet) const {
  size_t uiParamSize = 0;
  void *pValue = nullptr;
  cl_build_status clBuildStatus;
  cl_program_binary_type clBinaryType;
  char emptyString = '\0';

  switch (clParamName) {
  case CL_PROGRAM_BUILD_STATUS:
    uiParamSize = sizeof(cl_build_status);
    clBuildStatus = GetBuildStatus();
    pValue = &clBuildStatus;
    break;

  case CL_PROGRAM_BINARY_TYPE:
    uiParamSize = sizeof(cl_program_binary_type);
    clBinaryType = GetBinaryTypeInternal();
    pValue = &clBinaryType;
    break;

  case CL_PROGRAM_BUILD_OPTIONS:
    if (nullptr != m_szBuildOptions) {
      uiParamSize = strlen(m_szBuildOptions) + 1;
      pValue = m_szBuildOptions;
      break;
    }
    uiParamSize = 1;
    pValue = &emptyString;
    break;

  case CL_PROGRAM_BUILD_LOG:
    switch (m_state) {
    default:
    case DEVICE_PROGRAM_INVALID:
    case DEVICE_PROGRAM_SOURCE:
    case DEVICE_PROGRAM_LOADED_IR:
    case DEVICE_PROGRAM_CUSTOM_BINARY:
    case DEVICE_PROGRAM_BUILTIN_KERNELS:
    case DEVICE_PROGRAM_LIBRARY_KERNELS:
    case DEVICE_PROGRAM_FE_COMPILING:
    case DEVICE_PROGRAM_FE_LINKING:
    case DEVICE_PROGRAM_BE_BUILDING:
      uiParamSize = 1;
      pValue = &emptyString;
      break;

    case DEVICE_PROGRAM_COMPILED:
    case DEVICE_PROGRAM_LINKED:
    case DEVICE_PROGRAM_COMPILE_FAILED:
    case DEVICE_PROGRAM_LINK_FAILED:
      if (m_szBuildLog) {
        uiParamSize = m_uiBuildLogSize;
        pValue = m_szBuildLog;
      } else {
        uiParamSize = 1;
        pValue = &emptyString;
      }
      break;

    case DEVICE_PROGRAM_BUILD_DONE:
    case DEVICE_PROGRAM_BUILD_FAILED: {
      cl_dev_err_code clDevErr = CL_DEV_SUCCESS;
      // still need to append the FE build log
      // First of all calculate the size
      clDevErr = m_pDevice->GetDeviceAgent()->clDevGetBuildLog(
          m_programHandle, 0, nullptr, &uiParamSize);
      if CL_DEV_FAILED (clDevErr) {
        if (CL_DEV_INVALID_PROGRAM == clDevErr) {
          return CL_INVALID_PROGRAM;
        } else {
          return CL_INVALID_VALUE;
        }
      }
      if (nullptr != m_szBuildLog) {
        uiParamSize += m_uiBuildLogSize;
        // Now we have reserved place for two '\0's. Remove one.
        uiParamSize--;
      }
      if (nullptr != pParamValue && uiParamSize > uiParamValueSize) {
        return CL_INVALID_VALUE;
      }

      // if pParamValue == NULL return param value size
      if (nullptr != puiParamValueSizeRet) {
        *puiParamValueSizeRet = uiParamSize;
      }

      // get the actual log
      if (nullptr != pParamValue) {
        if (nullptr != m_szBuildLog) {
          // Copy the FE log minus the terminating NULL
          MEMCPY_S(pParamValue, uiParamValueSize, m_szBuildLog,
                   m_uiBuildLogSize - 1);
          // and let the device write the rest of the log
          uiParamSize -= (m_uiBuildLogSize - 1);

          clDevErr = m_pDevice->GetDeviceAgent()->clDevGetBuildLog(
              m_programHandle, uiParamSize,
              ((char *)pParamValue) + m_uiBuildLogSize - 1, nullptr);
        } else {
          clDevErr = m_pDevice->GetDeviceAgent()->clDevGetBuildLog(
              m_programHandle, uiParamSize, (char *)pParamValue, nullptr);
        }
      }
      if CL_DEV_FAILED (clDevErr) {
        if (CL_DEV_INVALID_PROGRAM == clDevErr) {
          return CL_INVALID_PROGRAM;
        } else {
          return CL_INVALID_VALUE;
        }
      }
      return CL_SUCCESS;
      break;
    }
    }

    break;

  case CL_PROGRAM_BUILD_GLOBAL_VARIABLE_TOTAL_SIZE: {
    cl_dev_err_code clDevErr = CL_DEV_SUCCESS;
    if (nullptr != pParamValue && sizeof(size_t) > uiParamValueSize) {
      return CL_INVALID_VALUE;
    }
    if (nullptr != pParamValue) {
      clDevErr = m_pDevice->GetDeviceAgent()->clDevGetGlobalVariableTotalSize(
          m_programHandle, (size_t *)pParamValue);
    }
    if CL_DEV_FAILED (clDevErr) {
      if (CL_DEV_INVALID_PROGRAM == clDevErr) {
        return CL_INVALID_PROGRAM;
      } else {
        return CL_INVALID_VALUE;
      }
    }
    if (nullptr != puiParamValueSizeRet) {
      *puiParamValueSizeRet = sizeof(size_t);
    }
    return CL_SUCCESS;
    break;
  }

  default:
    return CL_INVALID_VALUE;
  }

  if (nullptr != pParamValue && uiParamSize > uiParamValueSize) {
    return CL_INVALID_VALUE;
  }

  // if pParamValue == NULL return only param value size
  if (nullptr != puiParamValueSizeRet) {
    *puiParamValueSizeRet = uiParamSize;
  }

  if (nullptr != pParamValue && uiParamSize > 0) {
    MEMCPY_S(pParamValue, uiParamValueSize, pValue, uiParamSize);
  }

  return CL_SUCCESS;
}

cl_int DeviceProgram::GetFunctionPointer(const char *func_name,
                                         cl_ulong *func_pointer_ret) {
  if (nullptr == m_programHandle) {
    return CL_INVALID_PROGRAM_EXECUTABLE;
  }

  return m_pDevice->GetDeviceAgent()->clDevGetFunctionPointerFor(
      m_programHandle, func_name, func_pointer_ret);
}

void DeviceProgram::CollectGlobalVariablePointers() {
  assert(nullptr != m_programHandle && "invalid program handle");

  const cl_prog_gv *gvPtrs;
  size_t gvCount;
  m_pDevice->GetDeviceAgent()->clDevGetGlobalVariablePointers(
      m_programHandle, &gvPtrs, &gvCount);
  for (size_t i = 0; i < gvCount; ++i) {
    m_gvPointers[std::string(gvPtrs[i].name)] = gvPtrs[i];
    if (gvPtrs[i].deco_name[0] != '\0') {
      m_gvPointers[std::string(gvPtrs[i].deco_name)] = gvPtrs[i];
    }
  }
}

cl_err_code DeviceProgram::GetBinary(size_t uiBinSize, void *pBin,
                                     size_t *puiBinSizeRet) {
  if (nullptr == pBin && nullptr == puiBinSizeRet) {
    return CL_INVALID_VALUE;
  }

  if (uiBinSize > 0 && nullptr == pBin) {
    return CL_INVALID_VALUE;
  }

  switch (m_state) {
  case DEVICE_PROGRAM_BUILD_DONE:
    // Return the resultant compiled binaries
    return m_pDevice->GetDeviceAgent()->clDevGetProgramBinary(
        m_programHandle, uiBinSize, pBin, puiBinSizeRet);

  case DEVICE_PROGRAM_COMPILED:
  case DEVICE_PROGRAM_LINKED:
  case DEVICE_PROGRAM_LOADED_IR:
  case DEVICE_PROGRAM_CUSTOM_BINARY:
    if (nullptr == pBin) {
      assert(m_uiBinaryBitsSize <= CL_MAX_UINT32);
      *puiBinSizeRet = (cl_uint)m_uiBinaryBitsSize;
      return CL_SUCCESS;
    }
    if (uiBinSize < m_uiBinaryBitsSize) {
      return CL_INVALID_VALUE;
    }
    MEMCPY_S(pBin, uiBinSize, m_pBinaryBits, m_uiBinaryBitsSize);
    return CL_SUCCESS;

  case DEVICE_PROGRAM_SOURCE:
    // Program source loaded but hasn't been built yet, so no binary to return.
    // Return success and zero binary size to be consistent with GEN.
    *puiBinSizeRet = 0;
    return CL_SUCCESS;

  default:
    if (nullptr == pBin) // When query for binary size and it's not available,
                         // we should return 0
    {
      *puiBinSizeRet = 0;
      return CL_SUCCESS;
    }
    // CL_INVALID_PROGRAM_EXECUTABLE might be more appropriate if m_state is
    // DEVICE_PROGRAM_COMPILE_FAILED. However, CL_INVALID_PROGRAM_EXECUTABLE
    // is only allowed for query of CL_PROGRAM_NUM_KERNELS and
    // CL_PROGRAM_KERNEL_NAMES.
    return CL_INVALID_PROGRAM;
  }
}

bool DeviceProgram::IsBinaryAvailable(
    cl_program_binary_type requestedType) const {
  cl_program_binary_type binaryType = CL_PROGRAM_BINARY_TYPE_NONE;

  if (CL_BUILD_SUCCESS == GetBuildStatus() &&
      CL_SUCCESS == GetBuildInfo(CL_PROGRAM_BINARY_TYPE, sizeof(binaryType),
                                 &binaryType, nullptr) &&
      binaryType == requestedType) {
    return true;
  }
  return false;
}

cl_err_code DeviceProgram::GetNumKernels(cl_uint *pszNumKernels) {
  assert(pszNumKernels);
  return m_pDevice->GetDeviceAgent()->clDevGetProgramKernels(
      m_programHandle, 0, nullptr, pszNumKernels);
}

cl_err_code DeviceProgram::GetKernelNames(char **ppNames, size_t *pszNameSizes,
                                          size_t szNumNames) {
  cl_uint numKernels;
  cl_err_code errRet = CL_SUCCESS;
  cl_dev_kernel *devKernels = new cl_dev_kernel[szNumNames];

  if (!pszNameSizes) {
    delete[] devKernels;
    return CL_INVALID_VALUE;
  }
  assert(szNumNames <= CL_MAX_UINT32);
  errRet = m_pDevice->GetDeviceAgent()->clDevGetProgramKernels(
      m_programHandle, (cl_uint)szNumNames, devKernels, &numKernels);
  if (CL_FAILED(errRet)) {
    delete[] devKernels;
    return errRet;
  }
  assert(numKernels == szNumNames);

  if (nullptr == ppNames) {
    for (size_t i = 0; i < numKernels; ++i) {
      errRet = m_pDevice->GetDeviceAgent()->clDevGetKernelInfo(
          devKernels[i], CL_DEV_KERNEL_NAME, 0, nullptr, 0, nullptr,
          pszNameSizes + i);
      if (CL_FAILED(errRet)) {
        delete[] devKernels;
        return errRet;
      }
    }
    delete[] devKernels;
    return CL_SUCCESS;
  }

  for (size_t i = 0; i < numKernels; ++i) {
    size_t kernelNameSize;
    errRet = m_pDevice->GetDeviceAgent()->clDevGetKernelInfo(
        devKernels[i], CL_DEV_KERNEL_NAME, 0, nullptr, pszNameSizes[i],
        ppNames[i], &kernelNameSize);
    if (CL_FAILED(errRet)) {
      delete[] devKernels;
      return errRet;
    }
    assert(kernelNameSize == pszNameSizes[i]);
  }

  delete[] devKernels;

  return CL_SUCCESS;
}

cl_err_code
DeviceProgram::GetAutorunKernelsNames(std::vector<std::string> &vsNames) {
  cl_uint numKernels = 0;
  cl_err_code errRet = CL_SUCCESS;

  try {
    auto devAgent = m_pDevice->GetDeviceAgent();
    errRet = devAgent->clDevGetProgramKernels(m_programHandle, 0, nullptr,
                                              &numKernels);
    if (CL_FAILED(errRet)) {
      return errRet;
    }

    if (numKernels > 0) {
      std::vector<cl_dev_kernel *> devKernels(numKernels);

      errRet = devAgent->clDevGetProgramKernels(
          m_programHandle, numKernels,
          const_cast<cl_dev_kernel *>(
              reinterpret_cast<const cl_dev_kernel *>(&devKernels.front())),
          nullptr);
      if (CL_FAILED(errRet)) {
        return errRet;
      }

      for (size_t i = 0; i < numKernels; ++i) {
        cl_bool isAutorun = CL_FALSE;
        errRet = devAgent->clDevGetKernelInfo(
            devKernels[i], CL_DEV_KERNEL_IS_AUTORUN, 0, nullptr,
            sizeof(cl_bool), &isAutorun, nullptr);
        if (CL_FAILED(errRet)) {
          return errRet;
        }

        if (isAutorun) {
          std::string name;
          size_t size;
          errRet = devAgent->clDevGetKernelInfo(
              devKernels[i], CL_DEV_KERNEL_NAME, 0, nullptr, 0, nullptr, &size);
          if (CL_FAILED(errRet)) {
            return errRet;
          }

          name.resize(size);
          errRet = devAgent->clDevGetKernelInfo(
              devKernels[i], CL_DEV_KERNEL_NAME, 0, nullptr,
              sizeof(char) * size, &name[0], nullptr);
          if (CL_FAILED(errRet)) {
            return errRet;
          }
          vsNames.push_back(name);
        }
      }
    }
  } catch (const std::bad_alloc &e) {
    return CL_OUT_OF_HOST_MEMORY;
  }

  return CL_SUCCESS;
}

cl_err_code
DeviceProgram::SetDeviceHandleInternal(cl_dev_program programHandle) {
  if (m_pDevice) {
    if (0 != m_programHandle) {
      m_pDevice->GetDeviceAgent()->clDevReleaseProgram(m_programHandle);
    }
  }
  m_programHandle = programHandle;
  return CL_SUCCESS;
}

bool DeviceProgram::CheckProgramBinary(size_t uiBinSize, const void *pBinary,
                                       cl_prog_binary_type *pBinaryType) {
  // check if it is Binary object
  if (CLElfLib::CElfReader::IsValidElf64((const char *)pBinary, uiBinSize)) {
    if (pBinaryType) {
      ElfReaderPtr pReader(
          CLElfLib::CElfReader::Create((const char *)pBinary, uiBinSize));
      switch (pReader->GetElfHeader()->Type) {
      case CLElfLib::EH_TYPE_OPENCL_OBJECTS:
        *pBinaryType = CL_PROG_BIN_COMPILED_LLVM;
        break;
      case CLElfLib::EH_TYPE_OPENCL_LIBRARY:
        *pBinaryType = CL_PROG_BIN_LINKED_LLVM;
        break;
      case CLElfLib::EH_TYPE_OPENCL_EXECUTABLE:
        *pBinaryType = CL_PROG_BIN_EXECUTABLE_LLVM;
        return CL_DEV_SUCCEEDED(
            m_pDevice->GetDeviceAgent()->clDevCheckProgramBinary(uiBinSize,
                                                                 pBinary));
      case CLElfLib::EH_TYPE_OPENCL_LINKED_OBJECTS:
        *pBinaryType = CL_PROG_BIN_EXECUTABLE_LLVM;
        break;
      case CLElfLib::EH_TYPE_NONE:
      case CLElfLib::EH_TYPE_RELOCATABLE:
      case CLElfLib::EH_TYPE_EXECUTABLE:
      case CLElfLib::EH_TYPE_DYNAMIC:
      case CLElfLib::EH_TYPE_CORE:
      case CLElfLib::EH_TYPE_OPENCL_SOURCE:
      default:
        return false;
      }
    }
    return true;
  }

  if (sizeof(_CL_LLVM_BITCODE_MASK_) > uiBinSize) {
    return false;
  }

  // check if it is LLVM IR object
  if (!memcmp(_CL_LLVM_BITCODE_MASK_, pBinary,
              sizeof(_CL_LLVM_BITCODE_MASK_) - 1)) {
    Expected<std::string> S = getBitcodeTargetTriple(
        MemoryBuffer::getMemBuffer(
            StringRef(static_cast<const char *>(pBinary), uiBinSize), "", false)
            ->getMemBufferRef());
    if (!S || *S == "")
      return false;
    Triple TT(*S);
    if (pBinaryType) {
      // "spir64_x86_64" triple <--> non-spirv CPU AOT
      // Input is SPV-IR (SPIRV-Friendly-IR) in this case.
      if (TT.isSPIR() && TT.getSubArch() == Triple::SPIRSubArch_x86_64) {
        *pBinaryType = CL_PROG_BIN_COMPILED_SPV_IR;
      } else {
        *pBinaryType = CL_PROG_BIN_COMPILED_SPIR;
      }
    }

    return CL_DEV_SUCCEEDED(
        m_pDevice->GetDeviceAgent()->clDevCheckProgramBinary(uiBinSize,
                                                             pBinary));
  }

  // check if it is SPIRV object
  if (sizeof(_CL_SPIRV_MAGIC_NUMBER_) < uiBinSize &&
      _CL_SPIRV_MAGIC_NUMBER_ == ((const unsigned int *)pBinary)[0]) {
    if (pBinaryType)
      *pBinaryType = CL_PROG_BIN_COMPILED_SPIRV;

    return true;
  }

  return false;
}
