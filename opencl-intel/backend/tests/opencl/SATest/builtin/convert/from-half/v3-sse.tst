; Test that half convert builtins are compiled successfully.

; RUN: SATest -BUILD --config=%S/v3.cfg -tsize=0 -cpuarch="corei7" 2>&1 | FileCheck %s

CHECK: Test program was successfully built.
