#pragma OPENCL EXTENSION cl_khr_fp16 : enable

#define CONVERT_FP16(VF)                                                       \
  kernel void convert_fp16_v##VF(                                              \
      global uchar##VF *ucData, global ushort##VF *usData,                     \
      global uint##VF *uiData, global ulong##VF *ulData,                       \
      global char##VF *cData, global short##VF *sData, global int##VF *iData,  \
      global long##VF *lData, global float##VF *fData,                         \
      global double##VF *dData, global half##VF *hData) {                      \
    size_t gid = get_global_id(0);                                             \
    half##VF v = hData[gid];                                                   \
    ucData[gid] =                                                              \
        convert_uchar##VF(v) + convert_uchar##VF##_rte(v) +                    \
        convert_uchar##VF##_rtp(v) + convert_uchar##VF##_rtn(v) +              \
        convert_uchar##VF##_rtz(v) + convert_uchar##VF##_sat(v) +              \
        convert_uchar##VF##_sat_rte(v) + convert_uchar##VF##_sat_rtp(v) +      \
        convert_uchar##VF##_sat_rtn(v) + convert_uchar##VF##_sat_rtz(v);       \
                                                                               \
    usData[gid] =                                                              \
        convert_ushort##VF(v) + convert_ushort##VF##_rte(v) +                  \
        convert_ushort##VF##_rtp(v) + convert_ushort##VF##_rtn(v) +            \
        convert_ushort##VF##_rtz(v) + convert_ushort##VF##_sat(v) +            \
        convert_ushort##VF##_sat_rte(v) + convert_ushort##VF##_sat_rtp(v) +    \
        convert_ushort##VF##_sat_rtn(v) + convert_ushort##VF##_sat_rtz(v);     \
                                                                               \
    uiData[gid] =                                                              \
        convert_uint##VF(v) + convert_uint##VF##_rte(v) +                      \
        convert_uint##VF##_rtp(v) + convert_uint##VF##_rtn(v) +                \
        convert_uint##VF##_rtz(v) + convert_uint##VF##_sat(v) +                \
        convert_uint##VF##_sat_rte(v) + convert_uint##VF##_sat_rtp(v) +        \
        convert_uint##VF##_sat_rtn(v) + convert_uint##VF##_sat_rtz(v);         \
                                                                               \
    ulData[gid] =                                                              \
        convert_ulong##VF(v) + convert_ulong##VF##_rte(v) +                    \
        convert_ulong##VF##_rtp(v) + convert_ulong##VF##_rtn(v) +              \
        convert_ulong##VF##_rtz(v) + convert_ulong##VF##_sat(v) +              \
        convert_ulong##VF##_sat_rte(v) + convert_ulong##VF##_sat_rtp(v) +      \
        convert_ulong##VF##_sat_rtn(v) + convert_ulong##VF##_sat_rtz(v);       \
                                                                               \
    cData[gid] =                                                               \
        convert_char##VF(v) + convert_char##VF##_rte(v) +                      \
        convert_char##VF##_rtp(v) + convert_char##VF##_rtn(v) +                \
        convert_char##VF##_rtz(v) + convert_char##VF##_sat(v) +                \
        convert_char##VF##_sat_rte(v) + convert_char##VF##_sat_rtp(v) +        \
        convert_char##VF##_sat_rtn(v) + convert_char##VF##_sat_rtz(v);         \
                                                                               \
    sData[gid] =                                                               \
        convert_short##VF(v) + convert_short##VF##_rte(v) +                    \
        convert_short##VF##_rtp(v) + convert_short##VF##_rtn(v) +              \
        convert_short##VF##_rtz(v) + convert_short##VF##_sat(v) +              \
        convert_short##VF##_sat_rte(v) + convert_short##VF##_sat_rtp(v) +      \
        convert_short##VF##_sat_rtn(v) + convert_short##VF##_sat_rtz(v);       \
                                                                               \
    iData[gid] = convert_int##VF(v) + convert_int##VF##_rte(v) +               \
                 convert_int##VF##_rtp(v) + convert_int##VF##_rtn(v) +         \
                 convert_int##VF##_rtz(v) + convert_int##VF##_sat(v) +         \
                 convert_int##VF##_sat_rte(v) + convert_int##VF##_sat_rtp(v) + \
                 convert_int##VF##_sat_rtn(v) + convert_int##VF##_sat_rtz(v);  \
                                                                               \
    lData[gid] =                                                               \
        convert_long##VF(v) + convert_long##VF##_rte(v) +                      \
        convert_long##VF##_rtp(v) + convert_long##VF##_rtn(v) +                \
        convert_long##VF##_rtz(v) + convert_long##VF##_sat(v) +                \
        convert_long##VF##_sat_rte(v) + convert_long##VF##_sat_rtp(v) +        \
        convert_long##VF##_sat_rtn(v) + convert_long##VF##_sat_rtz(v);         \
                                                                               \
    fData[gid] = convert_float##VF(v) + convert_float##VF##_rte(v) +           \
                 convert_float##VF##_rtp(v) + convert_float##VF##_rtn(v) +     \
                 convert_float##VF##_rtz(v);                                   \
                                                                               \
    dData[gid] = convert_double##VF(v) + convert_double##VF##_rte(v) +         \
                 convert_double##VF##_rtp(v) + convert_double##VF##_rtn(v) +   \
                 convert_double##VF##_rtz(v);                                  \
  }
