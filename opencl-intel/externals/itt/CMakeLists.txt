#
# Copyright (C) 2005-2023 Intel Corporation
#
# SPDX-License-Identifier: GPL-2.0-only OR BSD-3-Clause
#

get_property(ITT_GENERATOR_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(CMAKE_GENERATOR STREQUAL "Ninja Multi-Config")
    # 'Ninja Multi-Config' specific, see:
    # https://cmake.org/cmake/help/latest/variable/CMAKE_DEFAULT_BUILD_TYPE.html
    set(CMAKE_DEFAULT_BUILD_TYPE "Release" CACHE STRING "CMake default build type")
elseif(NOT ITT_GENERATOR_MULTI_CONFIG)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "CMake build type")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release;Debug;RelWithDebInfo;MinSizeRel")
endif()

# project(itt)

option(FORCE_32 "Force a 32-bit compile on 64-bit" OFF)
option(ITT_API_IPT_SUPPORT "ptmarks support" OFF)

if(FORCE_32 AND UNIX)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32")
endif()

if(CMAKE_SIZEOF_VOID_P MATCHES "8" AND NOT(FORCE_32))
    set(ARCH_64 ON)
endif()

if(NOT DEFINED CMAKE_POSITION_INDEPENDENT_CODE)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)

foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBRARY_OUTPUT_PATH})
endforeach()

set(ITT_PUBLIC_HDRS
    include/ittnotify.h
    include/jitprofiling.h
    include/libittnotify.h
)

file(GLOB ITT_SRCS "ittnotify/*.c" "ittnotify/*.h")

if(NOT WIN32)
    set(PLATFORM_PATH "posix")
    set(PLATFORM_EXT "o")
else()
    set(PLATFORM_PATH "win32")
    set(PLATFORM_EXT "obj")
endif()

add_library(ittnotify STATIC ${ITT_SRCS} ${ITT_PUBLIC_HDRS} ${ITT_PT})

set(JITPROFILING_SRC "ittnotify/jitprofiling.c")
add_library(jitprofiling STATIC ${JITPROFILING_SRC})

if(WIN32)
    set_target_properties(ittnotify PROPERTIES OUTPUT_NAME libittnotify)
    set_target_properties(jitprofiling PROPERTIES OUTPUT_NAME libjitprofiling)
else()
    set_target_properties(ittnotify PROPERTIES OUTPUT_NAME ittnotify)
    set_target_properties(jitprofiling PROPERTIES OUTPUT_NAME jitprofiling)
endif()

target_link_libraries(ittnotify PRIVATE ${CMAKE_DL_LIBS})

set_target_properties(ittnotify PROPERTIES LINKER_LANGUAGE C)

target_include_directories(ittnotify
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE ittnotify
)

target_include_directories(jitprofiling
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE ittnotify
)

# install

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

install(TARGETS ittnotify EXPORT ittapi-targets INCLUDES DESTINATION ${OCL_INSTALL_LIBRARY_DIR} COMPONENT itt)
install(EXPORT ittapi-targets NAMESPACE ittapi:: DESTINATION ${OCL_INSTALL_LIBRARY_DIR}/cmake/ittapi)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
                   PATTERN "fortran" EXCLUDE)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ittapiConfig.cmake.in
                              ${CMAKE_CURRENT_BINARY_DIR}/share/ittapiConfig.cmake
    INSTALL_DESTINATION ${OCL_INSTALL_LIBRARY_DIR}/cmake/ittapi
    NO_SET_AND_CHECK_MACRO)

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/include/ittnotify.h" ITT_VERSION_PARTS REGEX "#define ITT_[A-Z]+[ ]+" )
string(REGEX REPLACE ".+ITT_MAJOR[ ]+([0-9]+).*" "\\1" ITT_MAJOR "${ITT_VERSION_PARTS}")
string(REGEX REPLACE ".+ITT_MINOR[ ]+([0-9]+).*" "\\1" ITT_MINOR "${ITT_VERSION_PARTS}")
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/share/ittapiConfigVersion.cmake
    VERSION ${ITT_MAJOR}.${ITT_MINOR}.0
    COMPATIBILITY SameMajorVersion)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/ittapiConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/share/ittapiConfigVersion.cmake
        DESTINATION ${OCL_INSTALL_LIBRARY_DIR}/cmake/ittapi)
