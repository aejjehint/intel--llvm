#
# Copyright (C) 2024 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this
# software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.

set(TARGET context_test_type)

find_sources()
calculate_target_sources()

set(TARGET_LIBS
  ${LLVM_MODULE_LIBS}
  LLVMBinaryFormat
  LLVMDebugInfoBTF
  LLVMDebugInfoDWARF
  LLVMDebugInfoTraceBack
  LLVMInstrumentation
  LLVMIntel_Debug
  LLVMMC
  LLVMMCDisassembler
  LLVMMCParser
  LLVMObject
  LLVMOrcTargetProcess
  LLVMTargetParser
  LLVMVPOTransforms
  LLVMVectorize
  intelocl${BUILD_PLATFORM}
  clang_compiler
  cl_logger
  cl_sys_utils
  task_executor
  test_utils
  ${COMMON_CLANG_LIB}
  Context
  Execution
  Framework
  MemoryAllocator
  OclPluginManager
  Platform
  )

if(WIN32)
  list(APPEND TARGET_LIBS lldCOFF lldCommon)
endif()

add_ocl_unittest(${TARGET} SOURCE_FILES ${TARGET_SOURCES} LINK_LIBRARIES
                 ${TARGET_LIBS})

link_target_with_tbb_library(${TARGET})

target_include_directories(${TARGET} PRIVATE
  ${opencl-cpp-header_SOURCE_DIR}/include
  ${CL_LOADER}/loader
  ${OCL_SOURCE_DIR}/framework
  ${OCL_SOURCE_DIR}/framework/Context
  ${OCL_SOURCE_DIR}/framework/Execution
  ${OCL_SOURCE_DIR}/framework/MemoryAllocator
  ${OCL_SOURCE_DIR}/framework/export
  ${OCL_SOURCE_DIR}/framework/Platform
  ${OCL_SOURCE_DIR}/framework/Tracing
  ${OCL_SOURCE_DIR}/utils/cl_sys_utils/export)
