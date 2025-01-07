# Copyright (C) 2024 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this software
# or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express or
# implied warranties, other than those that are expressly stated in the License.

# set(SVML_OCL_SOURCE_DIR $ENV{ICS_WORKDIR}/libdev/svml_ocl)
# if(NOT EXISTS ${SVML_OCL_SOURCE_DIR})
#   message(FATAL_ERROR "Cannot find OCL SVML source directory")
# endif()

# if(CMAKE_SYSROOT AND CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN)
#   set(LIBDEV_COMMON_CFLAGS " --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN} ")
#   set(LIBDEV_COMMON_LDFLAGS " --sysroot=${CMAKE_SYSROOT} --gcc-toolchain=${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN} ")
# endif()

# if(WIN32)
#   set(LIBDEV_COMMON_LDFLAGS "${LIBDEV_COMMON_LDFLAGS} /DEPENDENTLOADFLAG:0x2000 ")
# endif()

# if(NOT BUILD_THREAD_NUM)
#   cmake_host_system_information(RESULT BUILD_THREAD_NUM
#                                 QUERY NUMBER_OF_LOGICAL_CORES)
# endif()

# add_custom_target(svml_ocl_build
#   COMMAND make -f makefile
#   CC=icx
#   OUT=${CMAKE_CURRENT_BINARY_DIR}
#   ARCH=ia32e
#   LIBDEV_COMMON_CFLAGS=${LIBDEV_COMMON_CFLAGS}
#   LIBDEV_COMMON_LDFLAGS=${LIBDEV_COMMON_LDFLAGS}
#   -j${BUILD_THREAD_NUM}
#   WORKING_DIRECTORY ${SVML_OCL_SOURCE_DIR}
#   COMMENT "Building svml ocl libraries")

if(WIN32)
  set(PLATFORM win32e)
else()
  set(PLATFORM linux32e)
endif()

set(SVML_OCL_LIBS
  ${CMAKE_CURRENT_BINARY_DIR}/lib/${PLATFORM}/libocl_svml_e9${DLL_SUFIX}
  ${CMAKE_CURRENT_BINARY_DIR}/lib/${PLATFORM}/libocl_svml_h8${DLL_SUFIX}
  ${CMAKE_CURRENT_BINARY_DIR}/lib/${PLATFORM}/libocl_svml_l9${DLL_SUFIX}
  ${CMAKE_CURRENT_BINARY_DIR}/lib/${PLATFORM}/libocl_svml_z0${DLL_SUFIX}
  ${CMAKE_CURRENT_BINARY_DIR}/lib/${PLATFORM}/libocl_svml_z1${DLL_SUFIX})

message("SVML: SVML_OCL_LIBS: ${SVML_OCL_LIBS}")

add_custom_target(copy_svml_ocl
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${SVML_OCL_LIBS}
          ${OCL_OUTPUT_LIBRARY_DIR}
  # DEPENDS svml_ocl_build
  WORKING_DIRECTORY ${SVML_OCL_SOURCE_DIR}
  COMMENT "Copying svml ocl libraries to ${OCL_OUTPUT_LIBRARY_DIR}")

install_to(${SVML_OCL_LIBS} DESTINATION ${OCL_INSTALL_LIBRARY_DIR}
           COMPONENT ocl-svml)

set(SVML_NAME_PREFIX libocl_svml_ CACHE STRING "")
