; RUN: SATest -BUILD --config=%s.cfg --dump-llvm-file - | FileCheck %s

; CHECK-DAG: define dso_local void @test{{.*}} !private_memory_size ![[PRIV_MEM_SIZE:[0-9]+]]
; CHECK-DAG: ![[PRIV_MEM_SIZE]] = !{i64 524288}

; CHECK-DAG: Test program was successfully built.
