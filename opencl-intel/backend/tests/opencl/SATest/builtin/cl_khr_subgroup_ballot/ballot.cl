__attribute__((intel_reqd_sub_group_size(8))) kernel void
test(global uint4 *out1, global uint *out2, global uint *out3, global int *out4,
     global int *out5, global uint *out6, global uint *out7, global int *out8,
     global uint4 *out9, global uint4 *out10, global uint4 *out11,
     global uint4 *out12, global uint4 *out13, global uint4 *in1) {
  int sglid = get_sub_group_local_id();
  out1[sglid] = sub_group_ballot(sglid % 2);
  out2[sglid] = sub_group_ballot_find_lsb(in1[sglid]);
  out3[sglid] = sub_group_ballot_find_msb(in1[sglid]);
  out4[sglid] = sub_group_inverse_ballot(out1[sglid]);
  out5[sglid] = sub_group_ballot_bit_extract(out1[sglid], sglid);
  out6[sglid] = sub_group_ballot_bit_count(out1[sglid]);
  out7[sglid] = sub_group_ballot_inclusive_scan(out1[sglid]);
  out8[sglid] = sub_group_ballot_exclusive_scan(out1[sglid]);
  out9[sglid] = get_sub_group_eq_mask();
  out10[sglid] = get_sub_group_ge_mask();
  out11[sglid] = get_sub_group_gt_mask();
  out12[sglid] = get_sub_group_le_mask();
  out13[sglid] = get_sub_group_lt_mask();
}
