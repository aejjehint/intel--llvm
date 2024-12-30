#include "CL_BASE.h"
#include "TestsHelpClasses.h"

extern cl_device_type gDeviceType;

class SubDeviceTest : public CL_base {
protected:
  using UUID = std::array<cl_uchar, CL_UUID_SIZE_KHR>;

  // UUID's last two bytes represent sub device index
  unsigned short GetSubDeviceIdFromUUID(const UUID &deviceUUID) {
    return *reinterpret_cast<const unsigned short *>(&deviceUUID[14]);
  }

  bool CompareDeviceUUID(const UUID &uuid_l, const UUID &uuid_r,
                         bool ignoreSubDeviceId) {
    return ignoreSubDeviceId
               ? std::equal(uuid_l.begin(), uuid_l.begin() + 14, uuid_r.begin())
               : uuid_l == uuid_r;
  }
};

TEST_F(SubDeviceTest, DeviceUUID) {
  unsigned short deviceCounter = 0;
  UUID rootDeviceUuid = {0};
  cl_int err = clGetDeviceInfo(m_device, CL_DEVICE_UUID_KHR, sizeof(UUID),
                               &rootDeviceUuid[0], nullptr);
  ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo") << "CL_DEVICE_UUID_KHR";
  unsigned short subDeviceID = GetSubDeviceIdFromUUID(rootDeviceUuid);
  EXPECT_EQ(subDeviceID, deviceCounter++)
      << "Root device should have always sub device index 0";

  UUID uuid = {0};
  cl_uint computeUnits = 0;
  err = clGetDeviceInfo(m_device, CL_DEVICE_MAX_COMPUTE_UNITS, sizeof(cl_uint),
                        &computeUnits, nullptr);
  ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo") << "CL_DEVICE_MAX_COMPUTE_UNITS";
  constexpr cl_uint SubDeviceNum = 2;
  cl_device_partition_property partitionProperties[3] = {
      CL_DEVICE_PARTITION_EQUALLY, computeUnits / SubDeviceNum, 0};
  cl_device_id *subDevices =
      (cl_device_id *)malloc(SubDeviceNum * sizeof(cl_device_id));
  cl_uint numSubDeviceRet;
  err = clCreateSubDevices(m_device, partitionProperties, SubDeviceNum,
                           subDevices, &numSubDeviceRet);
  ASSERT_OCL_SUCCESS(err, "clCreateSubDevices")
      << "CL_DEVICE_PARTITION_EQUALLY";
  EXPECT_EQ(numSubDeviceRet, SubDeviceNum);

  // Check the UUID of two sub devices partitioned from root device
  for (cl_uint i = 0; i < SubDeviceNum; i++) {
    uuid.fill(0);
    err = clGetDeviceInfo(subDevices[i], CL_DEVICE_UUID_KHR, 16, uuid.data(),
                          nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo") << "CL_DEVICE_UUID_KHR";
    EXPECT_TRUE(CompareDeviceUUID(rootDeviceUuid, uuid, true))
        << "Device UUID should be identical when sub device index is ignored";

    subDeviceID = GetSubDeviceIdFromUUID(uuid);
    EXPECT_EQ(subDeviceID, deviceCounter++);
  }

  // Check the UUID of sub-sub devices partitioned from each sub device
  for (cl_uint i = 0; i < SubDeviceNum; i++) {
    cl_uint subDeviceComputeUnits;
    err = clGetDeviceInfo(subDevices[i], CL_DEVICE_MAX_COMPUTE_UNITS,
                          sizeof(cl_uint), &subDeviceComputeUnits, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo") << "CL_DEVICE_MAX_COMPUTE_UNITS";
    if (subDeviceComputeUnits <= 1)
      continue;

    cl_device_partition_property subPartitionProperties[] = {
        CL_DEVICE_PARTITION_EQUALLY, 1, 0};
    cl_device_id *subSubDevices =
        (cl_device_id *)malloc(subDeviceComputeUnits * sizeof(cl_device_id));
    cl_uint numSubSubDeviceRet;
    err = clCreateSubDevices(subDevices[i], subPartitionProperties,
                             subDeviceComputeUnits, subSubDevices,
                             &numSubSubDeviceRet);
    ASSERT_OCL_SUCCESS(err, "clCreateSubDevices")
        << "CL_DEVICE_PARTITION_EQUALLY";
    EXPECT_EQ(numSubSubDeviceRet, subDeviceComputeUnits);

    for (cl_uint j = 0; j < subDeviceComputeUnits; j++) {
      uuid.fill(0);
      err = clGetDeviceInfo(subSubDevices[j], CL_DEVICE_UUID_KHR, 16,
                            uuid.data(), nullptr);

      ASSERT_OCL_SUCCESS(err, "clGetDeviceInfo") << "CL_DEVICE_UUID_KHR";
      EXPECT_TRUE(CompareDeviceUUID(rootDeviceUuid, uuid, true))
          << "Device UUID should be identical when sub device index is ignored";

      subDeviceID = GetSubDeviceIdFromUUID(uuid);
      EXPECT_EQ(subDeviceID, deviceCounter++);

      err = clReleaseDevice(subSubDevices[j]);
      ASSERT_OCL_SUCCESS(err, "clReleaseDevice");
    }
    free(subSubDevices);
  }

  for (cl_uint i = 0; i < SubDeviceNum; i++) {
    err = clReleaseDevice(subDevices[i]);
    ASSERT_OCL_SUCCESS(err, "clReleaseDevice");
  }

  free(subDevices);
}
