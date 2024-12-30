; RUN: opt -passes=sycl-kernel-equalizer -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s
; RUN: opt -passes=sycl-kernel-equalizer -S %s | FileCheck %s

; This test checks that we fix incorrect canonicalized i8 GEP for joint matrix arrays.

%"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix" = type { <256 x float> }
%"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix.2" = type { <512 x i16> }
%"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix.3" = type { <512 x i16> }
%"class.sycl::_V1::ext::oneapi::bfloat16" = type { i16 }

; Function Attrs: nounwind
define spir_kernel void @_ZTS6MatMulILm16ELm16ELm32EE(ptr addrspace(1) align 2 %_arg_A, ptr addrspace(1) align 2 %_arg_B, ptr addrspace(1) align 4 %_arg_C, i64 %_arg_sgSize) {
entry:
  %tC.i = alloca [2 x [2 x %"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix"]], align 8
  %tA.i = alloca [2 x [1 x %"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix.2"]], align 8
  %tB.i = alloca [2 x [1 x %"struct.sycl::_V1::ext::oneapi::experimental::matrix::joint_matrix.3"]], align 8
  %i7 = bitcast ptr %tC.i to ptr
; CHECK: call void @llvm.lifetime.start.p0(i64 4096, ptr %i7)
  call void @llvm.lifetime.start.p0(i64 32, ptr %i7)
  %i8 = bitcast ptr %tC.i to ptr
; %tC.i contains [2 x [2 x <256 x float>]] array of matrices, offset of array end should be 2x2x256xsizeof(float) == 4096
; CHECK: %arrayctor.end.i = getelementptr inbounds i8, ptr %i8, i64 4096
  %arrayctor.end.i = getelementptr inbounds i8, ptr %i8, i64 32
  br label %arrayctor.loop.i

arrayctor.loop.i:                                 ; preds = %arrayctor.loop.i, %entry
  %arrayctor.cur.i = phi ptr [ %tC.i, %entry ], [ %i12, %arrayctor.loop.i ]
  %i9 = bitcast ptr %arrayctor.cur.i to ptr
; CHECK: %arrayctor.next.i = getelementptr inbounds i8, ptr %i9, i64 1024
  %arrayctor.next.i = getelementptr inbounds i8, ptr %i9, i64 8
  %i10 = ptrtoint ptr %arrayctor.next.i to i64
  %i11 = ptrtoint ptr %arrayctor.end.i to i64
  %arrayctor.done.i = icmp eq i64 %i10, %i11
  %i12 = bitcast ptr %arrayctor.next.i to ptr
  br i1 %arrayctor.done.i, label %arrayctor.cont.i, label %arrayctor.loop.i

arrayctor.cont.i:                                 ; preds = %arrayctor.loop.i
  %call.i.i.i.i.i.i.i = call <256 x float> @llvm.experimental.matrix.fill.v256f32.f32(float 0.000000e+00, i32 16, i32 16, metadata !"scope.subgroup", metadata !"matrix.use.accumulator")
  %i13 = bitcast ptr %tC.i to ptr
  store <256 x float> %call.i.i.i.i.i.i.i, ptr %i13, align 8
  %i14 = bitcast ptr %tC.i to ptr
; CHECK: %arrayidx4.i.i.i.i.i.i = getelementptr inbounds i8, ptr %i14, i64 1024
  %arrayidx4.i.i.i.i.i.i = getelementptr inbounds i8, ptr %i14, i64 8
  %call.i.i6.i.i.i.i.i = call <256 x float> @llvm.experimental.matrix.fill.v256f32.f32(float 0.000000e+00, i32 16, i32 16, metadata !"scope.subgroup", metadata !"matrix.use.accumulator")
  %i15 = bitcast ptr %arrayidx4.i.i.i.i.i.i to ptr
  store <256 x float> %call.i.i6.i.i.i.i.i, ptr %i15, align 8
  %i16 = bitcast ptr %tC.i to ptr
; CHECK: %arrayidx4.i.i.i.i6.i.i = getelementptr inbounds i8, ptr %i16, i64 2048
  %arrayidx4.i.i.i.i6.i.i = getelementptr inbounds i8, ptr %i16, i64 16
  %call.i.i.i.i.i7.i.i = call <256 x float> @llvm.experimental.matrix.fill.v256f32.f32(float 0.000000e+00, i32 16, i32 16, metadata !"scope.subgroup", metadata !"matrix.use.accumulator")
  %i17 = bitcast ptr %arrayidx4.i.i.i.i6.i.i to ptr
  store <256 x float> %call.i.i.i.i.i7.i.i, ptr %i17, align 8
  %i18 = bitcast ptr %tC.i to ptr
; CHECK: %arrayidx4.i6.i.i.i.i.i = getelementptr inbounds i8, ptr %i18, i64 3072
  %arrayidx4.i6.i.i.i.i.i = getelementptr inbounds i8, ptr %i18, i64 24
  %call.i.i7.i.i.i.i.i = call <256 x float> @llvm.experimental.matrix.fill.v256f32.f32(float 0.000000e+00, i32 16, i32 16, metadata !"scope.subgroup", metadata !"matrix.use.accumulator")
  %i19 = bitcast ptr %arrayidx4.i6.i.i.i.i.i to ptr
  store <256 x float> %call.i.i7.i.i.i.i.i, ptr %i19, align 8
  %i20 = bitcast ptr %tA.i to ptr
; CHECK: %arrayctor.end8.i = getelementptr inbounds i8, ptr %i20, i64 2048
  %arrayctor.end8.i = getelementptr inbounds i8, ptr %i20, i64 16
  %i21 = bitcast ptr %tB.i to ptr
; CHECK: %arrayctor.end15.i = getelementptr inbounds i8, ptr %i21, i64 2048
  %arrayctor.end15.i = getelementptr inbounds i8, ptr %i21, i64 16
  %i25 = bitcast ptr %tA.i to ptr
; CHECK: %arrayidx4.i.i.i.i.i.i24 = getelementptr inbounds i8, ptr %i25, i64 1024
  %arrayidx4.i.i.i.i.i.i24 = getelementptr inbounds i8, ptr %i25, i64 8
  %i29 = bitcast ptr %tB.i to ptr
; CHECK: %arrayidx4.i.i.i35.i.i.i = getelementptr inbounds i8, ptr %i29, i64 1024
  %arrayidx4.i.i.i35.i.i.i = getelementptr inbounds i8, ptr %i29, i64 8
  br label %end

end:
  %i92 = bitcast ptr %tC.i to ptr
; CHECK: call void @llvm.lifetime.end.p0(i64 4096, ptr %i92)
  call void @llvm.lifetime.end.p0(i64 32, ptr %i92)
  ret void
}

declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture)

declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture)

declare <256 x float> @llvm.experimental.matrix.fill.v256f32.f32(float, i32, i32, metadata, metadata)

; DEBUGIFY-NOT: WARNING
; DEBUGIFY: PASS
