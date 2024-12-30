#include "CL/cl_half.h"
#include "TestsHelpClasses.h"
#include "common_utils.h"
#include <cmath>
#include <limits>

/// This test checks float atomics builtins:
///   atomic_load, atomic_load_explicit,
///   atomic_store, atomic_store_explicit,
///   atomic_exchange, atomic_exchange_explicit.

extern cl_device_type gDeviceType;

namespace {

const char *defaultMemoryOrderAndScopeWithGlobalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load(&srcA[tid]);                                "
    "  T varB = atomic_load(&srcB[tid]);                                "
    "  atomic_store(&srcB[tid], varA);                                  "
    "  T varC = atomic_exchange(&srcC[tid], varB);                      "
    "  atomic_store(&srcA[tid], varC);                                  "
    "}";

const char *defaultMemoryOrderAndScopeWithLocalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load(&srcA[tid]);                                "
    "  T varB = atomic_load(&srcB[tid]);                                "
    "  T varC = atomic_load(&srcC[tid]);                                "
    "  __local T localA[8];                                             "
    "  __local T localB[8];                                             "
    "  __local T localC[8];                                             "
    "  atomic_store((volatile __local AT*)&localA[tid], varA);          "
    "  atomic_store((volatile __local AT*)&localB[tid], varB);          "
    "  atomic_store((volatile __local AT*)&localC[tid], varC);          "
    "  varA = atomic_load((volatile __local AT*)&localA[tid]);          "
    "  varB = atomic_load((volatile __local AT*)&localB[tid]);          "
    "  atomic_store((volatile __local AT*)&localB[tid], varA);          "
    "  varC = atomic_exchange((volatile __local AT*)&localC[tid], varB);"
    "  atomic_store((volatile __local AT*)&localA[tid], varC);          "
    "  varA = atomic_load((volatile __local AT*)&localA[tid]);          "
    "  varB = atomic_load((volatile __local AT*)&localB[tid]);          "
    "  varC = atomic_load((volatile __local AT*)&localC[tid]);          "
    "  atomic_store(&srcA[tid], varA);                                  "
    "  atomic_store(&srcB[tid], varB);                                  "
    "  atomic_store(&srcC[tid], varC);                                  "
    "}";

const char *defaultMemoryScopeWithGlobalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load_explicit(&srcA[tid], ORDER);                "
    "  T varB = atomic_load_explicit(&srcB[tid], ORDER);                "
    "  atomic_store_explicit(&srcB[tid], varA, ORDER);                  "
    "  T varC = atomic_exchange_explicit(&srcC[tid], varB, ORDER);      "
    "  atomic_store_explicit(&srcA[tid], varC, ORDER);                  "
    "}";

const char *defaultMemoryScopeWithLocalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load_explicit(&srcA[tid], ORDER);                "
    "  T varB = atomic_load_explicit(&srcB[tid], ORDER);                "
    "  T varC = atomic_load_explicit(&srcC[tid], ORDER);                "
    "  __local T localA[8];                                             "
    "  __local T localB[8];                                             "
    "  __local T localC[8];                                             "
    "  atomic_store_explicit((volatile __local AT*)&localA[tid],        "
    "                        varA, ORDER);                              "
    "  atomic_store_explicit((volatile __local AT*)&localB[tid],        "
    "                        varB, ORDER);                              "
    "  atomic_store_explicit((volatile __local AT*)&localC[tid],        "
    "                        varC, ORDER);                              "
    "  varA = atomic_load_explicit((volatile __local AT*)&localA[tid],  "
    "                              ORDER);                              "
    "  varB = atomic_load_explicit((volatile __local AT*)&localB[tid],  "
    "                              ORDER);                              "
    "  atomic_store_explicit((volatile __local AT*)&localB[tid],        "
    "                        varA, ORDER);                              "
    "  varC = atomic_exchange_explicit((volatile __local AT*)           "
    "                                  &localC[tid], varB, ORDER);      "
    "  atomic_store_explicit((volatile __local AT*)&localA[tid],        "
    "                        varC, ORDER);                              "
    "  varA = atomic_load_explicit((volatile __local AT*)&localA[tid],  "
    "                              ORDER);                              "
    "  varB = atomic_load_explicit((volatile __local AT*)&localB[tid],  "
    "                              ORDER);                              "
    "  varC = atomic_load_explicit((volatile __local AT*)&localC[tid],  "
    "                              ORDER);                              "
    "  atomic_store_explicit(&srcA[tid], varA, ORDER);                  "
    "  atomic_store_explicit(&srcB[tid], varB, ORDER);                  "
    "  atomic_store_explicit(&srcC[tid], varC, ORDER);                  "
    "}";

const char *customizedMemoryOrderAndScopeWithGlobalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load_explicit(&srcA[tid], ORDER, SCOPE);         "
    "  T varB = atomic_load_explicit(&srcB[tid], ORDER, SCOPE);         "
    "  atomic_store_explicit(&srcB[tid], varA, ORDER, SCOPE);           "
    "  T varC = atomic_exchange_explicit(&srcC[tid], varB, ORDER,SCOPE);"
    "  atomic_store_explicit(&srcA[tid], varC, ORDER, SCOPE);           "
    "}";

const char *customizedMemoryOrderAndScopeWithLocalAddrCodeStr =
    "__kernel void testAtomicFloat(__global AT *srcA,                   "
    "                              __global AT *srcB,                   "
    "                              __global AT *srcC) {                 "
    "  int tid = get_global_id(0);                                      "
    "  T varA = atomic_load_explicit(&srcA[tid], ORDER, SCOPE);         "
    "  T varB = atomic_load_explicit(&srcB[tid], ORDER, SCOPE);         "
    "  T varC = atomic_load_explicit(&srcC[tid], ORDER, SCOPE);         "
    "  __local T localA[8];                                             "
    "  __local T localB[8];                                             "
    "  __local T localC[8];                                             "
    "  atomic_store_explicit((volatile __local AT*)&localA[tid],        "
    "                        varA, ORDER, SCOPE);                       "
    "  atomic_store_explicit((volatile __local AT*)&localB[tid],        "
    "                        varB, ORDER, SCOPE);                       "
    "  atomic_store_explicit((volatile __local AT*)&localC[tid],        "
    "                        varC, ORDER, SCOPE);                       "
    "  varA = atomic_load_explicit((volatile __local AT*)&localA[tid],  "
    "                              ORDER, SCOPE);                       "
    "  varB = atomic_load_explicit((volatile __local AT*)&localB[tid],  "
    "                              ORDER, SCOPE);                       "
    "  atomic_store_explicit((volatile __local AT*)&localB[tid],        "
    "                        varA, ORDER, SCOPE);                       "
    "  varC = atomic_exchange_explicit((volatile __local AT*)           "
    "                                 &localC[tid], varB, ORDER, SCOPE);"
    "  atomic_store_explicit((volatile __local AT*)&localA[tid],        "
    "                        varC, ORDER, SCOPE);                       "
    "  varA = atomic_load_explicit((volatile __local AT*)&localA[tid],  "
    "                              ORDER, SCOPE);                       "
    "  varB = atomic_load_explicit((volatile __local AT*)&localB[tid],  "
    "                              ORDER, SCOPE);                       "
    "  varC = atomic_load_explicit((volatile __local AT*)&localC[tid],  "
    "                              ORDER, SCOPE);                       "
    "  atomic_store_explicit(&srcA[tid], varA, ORDER, SCOPE);           "
    "  atomic_store_explicit(&srcB[tid], varB, ORDER, SCOPE);           "
    "  atomic_store_explicit(&srcC[tid], varC, ORDER, SCOPE);           "
    "}";

const std::vector<int> orders = {__ATOMIC_RELAXED, __ATOMIC_ACQUIRE,
                                 __ATOMIC_RELEASE, __ATOMIC_ACQ_REL,
                                 __ATOMIC_SEQ_CST};
const std::vector<int> scopes = {
    __OPENCL_MEMORY_SCOPE_WORK_ITEM,       __OPENCL_MEMORY_SCOPE_SUB_GROUP,
    __OPENCL_MEMORY_SCOPE_WORK_GROUP,      __OPENCL_MEMORY_SCOPE_DEVICE,
    __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES,
};
} // namespace

template <typename T> static bool isEqual(T expSum, T resSum) {
  if (expSum != resSum && !(std::isnan(expSum) && std::isnan(resSum))) {
    printf("Atomic addition error: got %f, expected %f\n", resSum, expSum);
    return false;
  }
  return true;
}

static bool isEqual(cl_half expSum, cl_half resSum) {
  if (expSum != resSum &&
      !((expSum & 0x7fff) > 0x7c00 && (resSum & 0x7fff) > 0x7c00)) {
    printf("Atomic addition error: got 0x%04x, expected 0x%04x\n", resSum,
           expSum);
    return false;
  }
  return true;
}

template <typename T>
static void initSrc(std::vector<T> &srcA, std::vector<T> &srcB,
                    std::vector<T> &srcC) {
  srcA = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
  srcB = {-1.0, -2.0, -3.0, -4.0, -5.0, -6.0, -7.0, -8.0};
  srcC = {8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0};
}

static void initSrc(std::vector<cl_half> &srcA, std::vector<cl_half> &srcB,
                    std::vector<cl_half> &srcC) {
  const std::vector<float> srcAF32 = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
  const std::vector<float> srcBF32 = {-1.0, -2.0, -3.0, -4.0,
                                      -5.0, -6.0, -7.0, -8.0};
  const std::vector<float> srcCF32 = {8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0};
  for (auto ele : srcAF32)
    srcA.push_back(cl_half_from_float(ele, CL_HALF_RTE));
  for (auto ele : srcBF32)
    srcB.push_back(cl_half_from_float(ele, CL_HALF_RTE));
  for (auto ele : srcCF32)
    srcC.push_back(cl_half_from_float(ele, CL_HALF_RTE));
}

class AtomicLoadStoreExchangeFPTest : public ::testing::Test {
protected:
  void SetUp() override {
    cl_int err = clGetPlatformIDs(1, &platform, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetPlatformIDs");

    err = clGetDeviceIDs(platform, gDeviceType, 1, &device, nullptr);
    ASSERT_OCL_SUCCESS(err, "clGetDeviceIDs");

    cl_context_properties prop[] = {CL_CONTEXT_PLATFORM,
                                    (cl_context_properties)platform, 0};
    context = clCreateContext(prop, 1, &device, nullptr, nullptr, &err);
    ASSERT_OCL_SUCCESS(err, "clCreateContext");

    queue = clCreateCommandQueueWithProperties(context, device, NULL, &err);
    ASSERT_OCL_SUCCESS(err, "clCreateCommandQueueWithProperties");
  }

  void TearDown() override {
    cl_int err;
    if (queue) {
      err = clReleaseCommandQueue(queue);
      ASSERT_OCL_SUCCESS(err, "clReleaseCommandQueue");
    }
    if (context) {
      err = clReleaseContext(context);
      ASSERT_OCL_SUCCESS(err, "clReleaseContext");
    }
  }

  void buildProgramCreateKernel(const char *kernelString,
                                const char *kernelName,
                                const std::string &buildOption);

  template <typename T>
  void checkAtomic(std::string &buildOptions, const char *kernelString);

protected:
  cl_platform_id platform;
  cl_device_id device;
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
};

void AtomicLoadStoreExchangeFPTest::buildProgramCreateKernel(
    const char *kernelString, const char *kernelName,
    const std::string &buildOptions) {
  cl_int err;
  program = clCreateProgramWithSource(context, 1, &kernelString, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateProgramWithSource");

  printf("Building program with options %s\n", buildOptions.c_str());
  err = clBuildProgram(program, 1, &device, buildOptions.c_str(), nullptr,
                       nullptr);
  std::string buildLog;
  if (err != CL_SUCCESS)
    ASSERT_NO_FATAL_FAILURE(GetBuildLog(device, program, buildLog));
  ASSERT_OCL_SUCCESS(err, "clBuildProgram") << buildLog;

  kernel = clCreateKernel(program, kernelName, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateKernel");
}

template <typename T>
void AtomicLoadStoreExchangeFPTest::checkAtomic(std::string &buildOptions,
                                                const char *kernelString) {
  cl_int err = 0;

  bool isDouble = std::is_same<T, double>();
  bool isFloat = std::is_same<T, float>();
  buildOptions += " -cl-std=CL2.0";
  buildOptions += isDouble  ? " -D T=double -D AT=atomic_double"
                  : isFloat ? " -D T=float -D AT=atomic_float"
                            : " -D T=half -D AT=atomic_half";
  ASSERT_NO_FATAL_FAILURE(
      buildProgramCreateKernel(kernelString, "testAtomicFloat", buildOptions));

  std::vector<T> A, B, C;
  initSrc(A, B, C);
  std::vector<T> expA, expB, expC;
  expA = C;
  expB = A;
  expC = B;
  const size_t globalSizes = A.size();

  cl_mem MA = clCreateBuffer(context, CL_MEM_READ_WRITE,
                             sizeof(T) * globalSizes, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer srcA");
  cl_mem MB = clCreateBuffer(context, CL_MEM_READ_WRITE,
                             sizeof(T) * globalSizes, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer srcB");
  cl_mem MC = clCreateBuffer(context, CL_MEM_READ_WRITE,
                             sizeof(T) * globalSizes, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer srcC");

  err = clEnqueueWriteBuffer(queue, MA, CL_TRUE, 0, sizeof(T) * globalSizes,
                             &A[0], 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer MA");
  err = clEnqueueWriteBuffer(queue, MB, CL_TRUE, 0, sizeof(T) * globalSizes,
                             &B[0], 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer MB");
  err = clEnqueueWriteBuffer(queue, MC, CL_TRUE, 0, sizeof(T) * globalSizes,
                             &C[0], 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer MC");

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &MA);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg srcA");
  err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &MB);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg srcB");
  err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &MC);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg srcB");

  err = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &globalSizes, nullptr,
                               0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");

  err = clEnqueueReadBuffer(queue, MA, CL_TRUE, 0, sizeof(T) * globalSizes,
                            &A[0], 0, nullptr, nullptr);
  err = clEnqueueReadBuffer(queue, MB, CL_TRUE, 0, sizeof(T) * globalSizes,
                            &B[0], 0, nullptr, nullptr);
  err = clEnqueueReadBuffer(queue, MC, CL_TRUE, 0, sizeof(T) * globalSizes,
                            &C[0], 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer res sum");

  err = clReleaseMemObject(MA);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(MB);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(MC);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");

  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");
  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");

  for (size_t i = 0; i < A.size(); ++i) {
    ASSERT_TRUE(isEqual(A[i], expA[i]));
    ASSERT_TRUE(isEqual(B[i], expB[i]));
    ASSERT_TRUE(isEqual(C[i], expC[i]));
  }
}

TEST_F(AtomicLoadStoreExchangeFPTest, DefaultMemoryOrderAndScope) {
  std::string buildOptions;
  ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
      buildOptions, defaultMemoryOrderAndScopeWithLocalAddrCodeStr));
  ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
      buildOptions, defaultMemoryOrderAndScopeWithGlobalAddrCodeStr));
  ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
      buildOptions, defaultMemoryOrderAndScopeWithLocalAddrCodeStr));
  ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
      buildOptions, defaultMemoryOrderAndScopeWithGlobalAddrCodeStr));
  ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
      buildOptions, defaultMemoryOrderAndScopeWithLocalAddrCodeStr));
  ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
      buildOptions, defaultMemoryOrderAndScopeWithGlobalAddrCodeStr));
}

TEST_F(AtomicLoadStoreExchangeFPTest, DefaultMemoryScope) {
  for (auto order : orders) {
    std::string buildOptions = "-DORDER=" + std::to_string(order);
    ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
        buildOptions, defaultMemoryScopeWithLocalAddrCodeStr));
    ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
        buildOptions, defaultMemoryScopeWithGlobalAddrCodeStr));
    ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
        buildOptions, defaultMemoryScopeWithLocalAddrCodeStr));
    ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
        buildOptions, defaultMemoryScopeWithGlobalAddrCodeStr));
    ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
        buildOptions, defaultMemoryScopeWithLocalAddrCodeStr));
    ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
        buildOptions, defaultMemoryScopeWithGlobalAddrCodeStr));
  }
}

TEST_F(AtomicLoadStoreExchangeFPTest, CustomizedMemoryOrderAndScope) {
  for (auto order : orders) {
    std::string buildOptions = "-DORDER=" + std::to_string(order);
    for (auto scope : scopes) {
      buildOptions += " -DSCOPE=" + std::to_string(scope);
      ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
          buildOptions, customizedMemoryOrderAndScopeWithLocalAddrCodeStr));
      ASSERT_NO_FATAL_FAILURE(checkAtomic<float>(
          buildOptions, customizedMemoryOrderAndScopeWithGlobalAddrCodeStr));
      ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
          buildOptions, customizedMemoryOrderAndScopeWithLocalAddrCodeStr));
      ASSERT_NO_FATAL_FAILURE(checkAtomic<double>(
          buildOptions, customizedMemoryOrderAndScopeWithGlobalAddrCodeStr));
      ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
          buildOptions, customizedMemoryOrderAndScopeWithLocalAddrCodeStr));
      ASSERT_NO_FATAL_FAILURE(checkAtomic<cl_half>(
          buildOptions, customizedMemoryOrderAndScopeWithGlobalAddrCodeStr));
    }
  }
}
