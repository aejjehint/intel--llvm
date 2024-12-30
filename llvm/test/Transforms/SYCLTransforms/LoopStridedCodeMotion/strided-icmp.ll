; RUN: opt -passes=sycl-kernel-loop-strided-code-motion -S %s | FileCheck %s
; RUN: opt -passes=sycl-kernel-loop-strided-code-motion -S %s -enable-debugify -disable-output 2>&1 | FileCheck -check-prefix=DEBUGIFY %s

; Check that stride is computed from operands of icmp.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux"

define void @test() {
; CHECK-LABEL: @test
; CHECK: [[STRIDED:%[0-9]+]] = phi <16 x i32> [ {{.*}} ], [ %strided.add
; CHECK: icmp eq <16 x i32> [[STRIDED]], <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>

dim_0_vector_pre_head:
  br label %entryvector_func

entryvector_func:                                 ; preds = %pred.load.continue24vector_func, %dim_0_vector_pre_head
  %dim_0_vector_ind_var = phi i32 [ 0, %dim_0_vector_pre_head ], [ %dim_0_vector_inc_ind_var, %pred.load.continue24vector_func ]
  %broadcast.splatinsertvector_func = insertelement <16 x i32> zeroinitializer, i32 %dim_0_vector_ind_var, i64 0
  %broadcast.splatvector_func = shufflevector <16 x i32> %broadcast.splatinsertvector_func, <16 x i32> zeroinitializer, <16 x i32> zeroinitializer
  %0 = icmp eq <16 x i32> %broadcast.splatvector_func, <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>
  br label %pred.load.continue24vector_func

pred.load.continue24vector_func:                  ; preds = %entryvector_func
  %dim_0_vector_inc_ind_var = add nuw nsw i32 %dim_0_vector_ind_var, 16
  br label %entryvector_func
}

define void @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUl12item_wrapperILi1EEE_() {
; CHECK-LABEL: @_ZTSZZ4mainENKUlRN4sycl3_V17handlerEE_clES2_EUl12item_wrapperILi1EEE_
; CHECK: %1 = icmp ult <16 x i64> %0, <i64 2147483648, i64 2147483647, i64 2147483646, i64 2147483645, i64 2147483644, i64 2147483643, i64 2147483642, i64 2147483641, i64 2147483640, i64 2147483639, i64 2147483638, i64 2147483637, i64 2147483636, i64 2147483635, i64 2147483634, i64 2147483633>

entry:
  br label %entryvector_func

entryvector_func:                                 ; preds = %entryvector_func, %entry
  %dim_0_vector_ind_var = phi i64 [ %dim_0_vector_inc_ind_var, %entryvector_func ], [ 0, %entry ]
  %broadcast.splatinsertvector_func = insertelement <16 x i64> zeroinitializer, i64 %dim_0_vector_ind_var, i64 0
  %broadcast.splatvector_func = shufflevector <16 x i64> %broadcast.splatinsertvector_func, <16 x i64> zeroinitializer, <16 x i32> zeroinitializer
  %0 = icmp ult <16 x i64> %broadcast.splatvector_func, <i64 2147483648, i64 2147483647, i64 2147483646, i64 2147483645, i64 2147483644, i64 2147483643, i64 2147483642, i64 2147483641, i64 2147483640, i64 2147483639, i64 2147483638, i64 2147483637, i64 2147483636, i64 2147483635, i64 2147483634, i64 2147483633>
  %dim_0_vector_inc_ind_var = add i64 %dim_0_vector_ind_var, 16
  br label %entryvector_func
}

define void @trunc() {
; CHECK-LABEL: @trunc
; CHECK: [[STRIDED:%[0-9]+]] = phi <16 x i32> [ {{.*}} ], [ %strided.add
; CHECK: icmp eq <16 x i32> [[STRIDED]], <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>

dim_1_vector_pre_head:
  br label %entryvector_func

entryvector_func:                                 ; preds = %pred.load.continue28vector_func, %dim_1_vector_pre_head
  %dim_1_vector_ind_var = phi i64 [ 0, %dim_1_vector_pre_head ], [ %dim_1_vector_inc_ind_var, %pred.load.continue28vector_func ]
  %0 = trunc i64 %dim_1_vector_ind_var to i32
  %broadcast.splatinsertvector_func = insertelement <16 x i32> zeroinitializer, i32 %0, i64 0
  %broadcast.splatvector_func = shufflevector <16 x i32> %broadcast.splatinsertvector_func, <16 x i32> zeroinitializer, <16 x i32> zeroinitializer
  %1 = icmp eq <16 x i32> %broadcast.splatvector_func, <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>
  br label %pred.load.continue28vector_func

pred.load.continue28vector_func:                  ; preds = %entryvector_func
  %dim_1_vector_inc_ind_var = add nuw nsw i64 %dim_1_vector_ind_var, 16
  br label %entryvector_func
}

define void @icmp_has_user() {
; CHECK-LABEL: @icmp_has_user
; CHECK: [[STRIDED:%[0-9]+]] = phi <16 x i32> [ {{.*}} ], [ %strided.add
; CHECK: icmp eq <16 x i32> [[STRIDED]], <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>

dim_1_vector_pre_head:
  br label %entryvector_func

entryvector_func:                                 ; preds = %pred.load.continue28vector_func, %dim_1_vector_pre_head
  %dim_1_vector_ind_var = phi i64 [ 0, %dim_1_vector_pre_head ], [ %dim_1_vector_inc_ind_var, %pred.load.continue28vector_func ]
  %0 = trunc i64 %dim_1_vector_ind_var to i32
  %broadcast.splatinsertvector_func = insertelement <16 x i32> zeroinitializer, i32 %0, i64 0
  %broadcast.splatvector_func = shufflevector <16 x i32> %broadcast.splatinsertvector_func, <16 x i32> zeroinitializer, <16 x i32> zeroinitializer
  %1 = icmp eq <16 x i32> %broadcast.splatvector_func, <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>
  %2 = bitcast <16 x i1> %1 to i16
  br label %pred.load.continue28vector_func

pred.load.continue28vector_func:                  ; preds = %entryvector_func
  %dim_1_vector_inc_ind_var = add nuw nsw i64 %dim_1_vector_ind_var, 16
  br label %entryvector_func
}

; Strided IV has non-hoisted user other than icmp.

define void @non_hoisted_user() {
; CHECK-LABEL: @non_hoisted_user
; CHECK: [[STRIDED:%[0-9]+]] = phi <16 x i32> [ {{.*}} ], [ %strided.add
; CHECK: [[EXT:%[0-9]+]] = extractelement <16 x i32> [[STRIDED]], i64 0
; CHECK: add nsw i32 [[EXT]]
; CHECK: icmp eq <16 x i32> [[STRIDED]], <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>

dim_1_vector_pre_head:
  br label %entryvector_func

entryvector_func:                                 ; preds = %pred.load.continue28vector_func, %dim_1_vector_pre_head
  %dim_1_vector_ind_var = phi i64 [ 0, %dim_1_vector_pre_head ], [ %dim_1_vector_inc_ind_var, %pred.load.continue28vector_func ]
  %0 = trunc i64 %dim_1_vector_ind_var to i32
  %broadcast.splatinsertvector_func = insertelement <16 x i32> poison, i32 %0, i64 0
  %broadcast.splatvector_func = shufflevector <16 x i32> %broadcast.splatinsertvector_func, <16 x i32> poison, <16 x i32> zeroinitializer
  %1 = add nsw i32 %0, 0
  %2 = icmp eq <16 x i32> %broadcast.splatvector_func, <i32 0, i32 -1, i32 -2, i32 -3, i32 -4, i32 -5, i32 -6, i32 -7, i32 -8, i32 -9, i32 -10, i32 -11, i32 -12, i32 -13, i32 -14, i32 -15>
  br label %pred.load.continue28vector_func

pred.load.continue28vector_func:                  ; preds = %entryvector_func
  %dim_1_vector_inc_ind_var = add nuw nsw i64 %dim_1_vector_ind_var, 16
  br label %entryvector_func
}

; DEBUGIFY-NOT: WARNING
