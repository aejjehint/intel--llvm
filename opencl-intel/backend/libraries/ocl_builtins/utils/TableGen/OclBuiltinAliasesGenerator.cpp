// INTEL CONFIDENTIAL
//
// Copyright 2024 Intel Corporation.
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

#include "OclBuiltinAliasesGenerator.h"

using namespace llvm;

OclBuiltinAliasesGenerator::OclBuiltinAliasesGenerator(const RecordKeeper &R)
    : m_Records(R), m_DB(R, false) {}

void OclBuiltinAliasesGenerator::run(raw_ostream &OS) {
  std::unordered_map<std::string, std::string> mapAliasToBuiltin;
  const std::vector<const Record *> &aliasMaps =
      m_Records.getAllDerivedDefinitions("AliasMap");
  for (const Record *pMap : aliasMaps) {
    const ListInit *aliasList = pMap->getValueAsListInit("AliasList");
    for (const Init *const item : *aliasList) {
      auto aliasItem = cast<ListInit>(item);
      const size_t aliasSize = aliasItem->size();
      assert(aliasSize >= 2 && "Alias item must have as least one alias name");

      const std::string &builtinDefName =
          cast<StringInit>(aliasItem->getElement(0))->getAsUnquotedString();
      const OclBuiltin *pBuiltin = m_DB.getOclBuiltin(builtinDefName);
      assert(pBuiltin != nullptr && "Undefined OclBuiltin record");

      for (size_t i = 1; i < aliasSize; ++i) {
        assert(pBuiltin->getCFunc() !=
                   cast<StringInit>(aliasItem->getElement(i))
                       ->getAsUnquotedString() &&
               "Alias should not be same as the builtin.");
        auto pairRes = mapAliasToBuiltin.insert(
            {cast<StringInit>(aliasItem->getElement(i))->getAsUnquotedString(),
             pBuiltin->getCFunc()});
        if (!pairRes.second && pairRes.first->second != pBuiltin->getCFunc())
          report_fatal_error("One alias cannot map to multiple builtins.");
      }
    }
  }

  for (const auto &e : mapAliasToBuiltin)
    OS << "{\"" << e.first << "\", \"" << e.second << "\"},\n";
}
