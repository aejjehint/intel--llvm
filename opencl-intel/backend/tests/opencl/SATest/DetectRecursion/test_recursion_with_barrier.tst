; RUN: SATest -BUILD --cpuarch=skx -tsize=16 --config=%s.cfg 2>&1 | FileCheck %s

; CHECK: Test program was successfully built.
