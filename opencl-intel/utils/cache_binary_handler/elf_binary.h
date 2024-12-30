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

#pragma once

#include "ElfReader.h"
#include "ElfWriter.h"
#include "cl_device_api.h"

#include <assert.h>
#include <memory>
#include <string>

namespace Intel {
namespace OpenCL {
namespace ELFUtils {
struct ElfReaderDeleter {
  void operator()(CLElfLib::CElfReader *ElfReader) const {
    CLElfLib::CElfReader::Delete(ElfReader);
  }
};
using ElfReaderPtr = std::unique_ptr<CLElfLib::CElfReader, ElfReaderDeleter>;

struct ElfWriterDeleter {
  void operator()(CLElfLib::CElfWriter *ElfWriter) const {
    CLElfLib::CElfWriter::Delete(ElfWriter);
  }
};
using ElfWriterPtr = std::unique_ptr<CLElfLib::CElfWriter, ElfWriterDeleter>;

class OCLElfBinaryReader {
public:
  static bool IsValidOpenCLBinary(const char *pBinary, size_t uiBinarySize);

  OCLElfBinaryReader(const char *pBinary, size_t uiBinarySize);

  void GetIR(const char *&pData, size_t &uiSize) const;

  cl_prog_binary_type GetBinaryType() const;

private:
  mutable ElfReaderPtr m_pReader;
};
} // namespace ELFUtils
} // namespace OpenCL
} // namespace Intel
