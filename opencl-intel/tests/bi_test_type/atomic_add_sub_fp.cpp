#include "CL/cl_half.h"
#include "TestsHelpClasses.h"
#include "common_utils.h"
#include <cmath>
#include <limits>

/// This test checks float atomics builtins:
///   atomic_add, atomic_fetch_add, atomic_fetch_add_explicit,
///   atomic_sub, atomic_fetch_sub, atomic_fetch_sub_explicit.

extern cl_device_type gDeviceType;

namespace {
const char *OCL12_KERNEL_ARIFM_TEST_CODE_STR =
    "__kernel void test_atomic_f_arifm(__global T *srcA,"
    "                                  __global T *srcB,"
    "                                  __global T *resOld,"
    "                                  __global T *resSum) {"
    "  int tid = get_global_id(0); "
    "  resSum[tid] = srcA[tid]; "
    "  resOld[tid] = atomic_op(&(resSum[tid]), srcB[tid]); "
    "}";

const char *OCL12_KERNEL_ATOM_TEST_CODE_STR =
    "__kernel void test_atomic_f_atomicity(__global T *addend,"
    "                                      __global T *resSum) {"
    "  for (int i = 0; i < 11; ++i)"
    "    atomic_op(resSum, *addend);"
    "}";

const char *OCL20_KERNEL_ARIFM_TEST_CODE_STR =

    "__kernel void test_atomic_f_arifm(__global T *srcA,"
    "                                  __global T *srcB,"
    "                                  __global T *resOld,"
    "                                  __global AT *resSum) {"
    "  int tid = get_global_id(0);"
    "  atomic_store_explicit(&(resSum[tid]), srcA[tid], memory_order_relaxed);"
    "  resOld[tid] = atomic_fetch_op_explicit(&(resSum[tid]), srcB[tid],"
    "                                         memory_order_relaxed,"
    "                                         memory_scope_device);"
    "}";

const char *OCL20_KERNEL_ATOM_TEST_CODE_STR =
    "__kernel void test_atomic_f_atomicity(__global T *addend,"
    "                                      __global AT *resSum) {"
    "  atomic_fetch_op(resSum, *addend);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_relaxed);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_acquire);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_release);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_acq_rel);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_seq_cst);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_relaxed,"
    "                           memory_scope_device);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_acquire,"
    "                           memory_scope_device);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_release,"
    "                           memory_scope_device);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_acq_rel,"
    "                           memory_scope_device);"
    "  atomic_fetch_op_explicit(resSum, *addend, memory_order_seq_cst,"
    "                           memory_scope_device);"
    "}";

const char *OCL20_KERNEL_LOCAL_ADDRSPACE_ARIFM_TEST_CODE_STR =
    "__kernel void test_atomic_f_arifm(__global T *srcA, "
    "                                  __global T *srcB, "
    "                                  __global T *resOld, "
    "                                  __global AT *resSum) { "
    "  int tid = get_global_id(0);"
    "  __local T sum;"
    "  atomic_store_explicit((volatile __local AT*)&sum, srcA[tid],"
    "                        memory_order_relaxed);"
    "  resOld[tid] = atomic_fetch_op_explicit((volatile __local AT*)&sum,"
    "                                         srcB[tid], memory_order_relaxed,"
    "                                         memory_scope_device); "
    "  atomic_store_explicit(&(resSum[tid]), sum, memory_order_relaxed);"
    "}";

const char *OCL20_KERNEL_LOCAL_ADDRSPACE_ATOM_TEST_CODE_STR =
    "__kernel void test_atomic_f_atomicity(__global T *addend,"
    "                                      __global AT *resSum) { "
    "  __local T sum;"
    "  if (get_local_id(0) == 0) {"
    "    atomic_store_explicit((volatile __local AT*)&sum, (T)0.0,"
    "                          memory_order_relaxed);"
    "  }"
    "  barrier(CLK_LOCAL_MEM_FENCE);"
    "  atomic_fetch_op((volatile __local AT*)&sum, *addend);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_relaxed);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_acquire);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_release);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_acq_rel);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_seq_cst);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_relaxed, memory_scope_device);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_acquire, memory_scope_device);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_release, memory_scope_device);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_acq_rel, memory_scope_device);"
    "  atomic_fetch_op_explicit((volatile __local AT*)&sum, *addend,"
    "                           memory_order_seq_cst, memory_scope_device); "
    "  barrier(CLK_LOCAL_MEM_FENCE);"
    "  if (get_local_id(0) == 0)"
    "    atomic_fetch_op_explicit(resSum, sum, memory_order_relaxed,"
    "                             memory_scope_device);"
    "}";
} // namespace

template <typename Ty> class AtomicAddSubFPTest : public ::testing::Test {
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

    bool isDouble = std::is_same<typename Ty::DataTy, double>();
    bool isFloat = std::is_same<typename Ty::DataTy, float>();
    if (Ty::isOCL20) {
      buildOptions = "-cl-std=CL2.0";
      buildOptions += isDouble  ? " -D T=double -D AT=atomic_double"
                      : isFloat ? " -D T=float -D AT=atomic_float"
                                : " -D T=half -D AT=atomic_half";
    } else {
      buildOptions = "-cl-std=CL1.2";
      buildOptions += isDouble  ? " -D T=double"
                      : isFloat ? " -D T=float"
                                : " -D T=half";
    }
    buildOptions += " -D float_atomics_enable";
    std::string op =
        std::is_same<typename Ty::OpTy, std::plus<typename Ty::DataTy>>()
            ? "add"
            : "sub";
    buildOptions +=
        " -D atomic_op=atomic_" + op + " -D atomic_fetch_op=atomic_fetch_" +
        op + " -D atomic_fetch_op_explicit=atomic_fetch_" + op + "_explicit";
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
                                const char *kernelName);

  template <typename T>
  void checkAtomic_arifm(bool isOCL20, bool isLocal, const std::vector<T> &srcA,
                         const std::vector<T> &srcB, std::vector<T> &resOld,
                         std::vector<T> &resSum);
  template <typename T>
  void checkAtomic_atomicity(bool isOCL20, bool isLocal, size_t globalSizes,
                             size_t localSizes, T augend, T addend, T *resSum);

protected:
  cl_platform_id platform;
  cl_device_id device;
  cl_context context = nullptr;
  cl_command_queue queue = nullptr;
  std::string buildOptions;
  cl_program program = nullptr;
  cl_kernel kernel = nullptr;
};

template <typename T, template <typename> class Op, bool OCL20>
struct TestType {
  using DataTy = T;
  using OpTy = Op<T>;
  static constexpr bool isOCL20 = OCL20;
};

namespace std {
template <> struct minus<cl_half> {
  cl_half operator()(const cl_half &a, const cl_half &b) const {
    float c = cl_half_to_float(a) - cl_half_to_float(b);
    return cl_half_from_float(c, CL_HALF_RTE);
  }
};
template <> struct plus<cl_half> {
  cl_half operator()(const cl_half &a, const cl_half &b) const {
    float c = cl_half_to_float(a) + cl_half_to_float(b);
    return cl_half_from_float(c, CL_HALF_RTE);
  }
};
} // namespace std

using Implementations = ::testing::Types<
    TestType<float, std::plus, true>, TestType<float, std::plus, false>,
    TestType<double, std::plus, true>, TestType<double, std::plus, false>,
    TestType<float, std::minus, true>, TestType<float, std::minus, false>,
    TestType<double, std::minus, true>, TestType<double, std::minus, false>,
    TestType<cl_half, std::minus, true>, TestType<cl_half, std::plus, true>>;

TYPED_TEST_SUITE(AtomicAddSubFPTest, Implementations, );

template <typename Ty>
void AtomicAddSubFPTest<Ty>::buildProgramCreateKernel(const char *kernelString,
                                                      const char *kernelName) {
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

template <typename Ty>
template <typename T>
void AtomicAddSubFPTest<Ty>::checkAtomic_arifm(bool isOCL20, bool isLocal,
                                               const std::vector<T> &srcA,
                                               const std::vector<T> &srcB,
                                               std::vector<T> &resOld,
                                               std::vector<T> &resSum) {
  cl_int err;
  const size_t num = srcA.size();

  const char *kernelString =
      isOCL20 ? (isLocal ? OCL20_KERNEL_LOCAL_ADDRSPACE_ARIFM_TEST_CODE_STR
                         : OCL20_KERNEL_ARIFM_TEST_CODE_STR)
              : OCL12_KERNEL_ARIFM_TEST_CODE_STR;
  ASSERT_NO_FATAL_FAILURE(
      buildProgramCreateKernel(kernelString, "test_atomic_f_arifm"));

  cl_mem kA =
      clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(T) * num, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer src a");
  cl_mem kB =
      clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(T) * num, nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer src b");
  cl_mem kO = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(T) * num,
                             nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer res old");
  cl_mem kS = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(T) * num,
                             nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer res sum");

  err = clEnqueueWriteBuffer(queue, kA, CL_TRUE, 0, sizeof(T) * num, &srcA[0],
                             0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer src a");
  err = clEnqueueWriteBuffer(queue, kB, CL_TRUE, 0, sizeof(T) * num, &srcB[0],
                             0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer src b");

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &kA);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg src a");
  err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &kB);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg src b");
  err = clSetKernelArg(kernel, 2, sizeof(cl_mem), &kO);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg res old");
  err = clSetKernelArg(kernel, 3, sizeof(cl_mem), &kS);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg res sum");

  size_t global = num;
  err = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &global, nullptr, 0,
                               nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");

  err = clEnqueueReadBuffer(queue, kO, CL_TRUE, 0, sizeof(T) * num, &resOld[0],
                            0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer res old");
  err = clEnqueueReadBuffer(queue, kS, CL_TRUE, 0, sizeof(T) * num, &resSum[0],
                            0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer res sum");

  err = clReleaseMemObject(kA);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(kB);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(kO);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(kS);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");
  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");
}

template <typename Op, typename T>
static bool
checkArifm_results(const std::vector<T> &srcA, const std::vector<T> &srcB,
                   const std::vector<T> &resOld, const std::vector<T> &resSum) {
  Op op;
  for (size_t i = 0; i < srcA.size(); i++) {
    if (srcA[i] != resOld[i] &&
        !(std::isnan(srcA[i]) && std::isnan(resOld[i]))) {
      printf("Old value error at %zu: got %f, expected %f\n", i, resOld[i],
             srcA[i]);
      return false;
    }

    T expSum = op(srcA[i], srcB[i]);
    if (expSum != resSum[i] && !(std::isnan(expSum) && std::isnan(resSum[i]))) {
      printf("Addition error at %zu: got %f, expected %f\n", i, resSum[i],
             expSum);
      return false;
    }
  }
  return true;
}

template <typename Op>
static bool checkArifm_results(const std::vector<cl_half> &srcA,
                               const std::vector<cl_half> &srcB,
                               const std::vector<cl_half> &resOld,
                               const std::vector<cl_half> &resSum) {
  Op op;
  for (size_t i = 0; i < srcA.size(); i++) {
    if (srcA[i] != resOld[i] &&
        !((srcA[i] & 0x7fff) > 0x7c00 && (resOld[i] & 0x7fff) > 0x7c00)) {
      printf("Old value error at %zu: got 0x%04x, expected 0x%04x\n", i,
             resOld[i], srcA[i]);
      return false;
    }

    cl_half expSum = op(srcA[i], srcB[i]);

    if (expSum != resSum[i] &&
        !((expSum & 0x7fff) > 0x7c00 && (resSum[i] & 0x7fff) > 0x7c00)) {
      printf("Addition error at %zu: got 0x%04x, expected 0x%04x\n", i,
             resSum[i], expSum);
      return false;
    }
  }
  return true;
}

template <typename T>
static void initSrc(std::vector<T> &src_a, std::vector<T> &src_b) {
  src_a = {1.23f,
           0.00023f,
           213455444.3452f,
           -23.12213f,
           0.f,
           -0.f,
           std::numeric_limits<T>::max(),
           std::numeric_limits<T>::min(),
           std::numeric_limits<T>::infinity(),
           std::numeric_limits<T>::quiet_NaN()};
  src_b = {56.23f, 0.00621f, 0.0000023f, 245.345f,
           10.f,   10.f,     1.f,        -std::numeric_limits<T>::min(),
           1.f,    1.f};
}

static void initSrc(std::vector<cl_half> &src_a, std::vector<cl_half> &src_b) {
  const std::vector<float> src_a_f = {1.23f,      0.00023f, 213.3452f,
                                      -23.12213f, 0.f,      -0.f};
  const std::vector<float> src_b_f = {
      56.23f, 0.00621f, 0.0000023f, 245.345f, 10.f, 10.f, 1.f, 1.f, 1.f};
  for (size_t i = 0; i < src_a_f.size(); i++)
    src_a.push_back(cl_half_from_float(src_a_f[i], CL_HALF_RTE));
  for (size_t i = 0; i < src_b_f.size(); i++)
    src_b.push_back(cl_half_from_float(src_b_f[i], CL_HALF_RTE));

  std::vector<cl_half> limits_a = {0x7BFF, 0x0001, 0x7C00, 0x7C01};
  src_a.insert(src_a.end(), limits_a.begin(), limits_a.end());
  auto it = src_b.begin() + 7;
  src_b.insert(it, 0x8001);
}

TYPED_TEST(AtomicAddSubFPTest, Arifm) {
  using T = typename TypeParam::DataTy;
  bool isOCL20 = TypeParam::isOCL20;

  for (int i = 0; i < 2; i++) {
    std::vector<T> srcA;
    std::vector<T> srcB;
    initSrc(srcA, srcB);

    std::vector<T> resOld(srcA.size());
    std::vector<T> resSum(srcA.size());

    ASSERT_NO_FATAL_FAILURE(
        this->checkAtomic_arifm(isOCL20, i != 0, srcA, srcB, resOld, resSum));

    ASSERT_TRUE(checkArifm_results<typename TypeParam::OpTy>(srcA, srcB, resOld,
                                                             resSum))
        << "Results differ from expected";
  }
}

template <typename Ty>
template <typename T>
void AtomicAddSubFPTest<Ty>::checkAtomic_atomicity(bool isOCL20, bool isLocal,
                                                   size_t globalSizes,
                                                   size_t localSizes, T augend,
                                                   T addend, T *resSum) {
  cl_int err = 0;

  const char *kernelString =
      isOCL20 ? (isLocal ? OCL20_KERNEL_LOCAL_ADDRSPACE_ATOM_TEST_CODE_STR
                         : OCL20_KERNEL_ATOM_TEST_CODE_STR)
              : OCL12_KERNEL_ATOM_TEST_CODE_STR;
  ASSERT_NO_FATAL_FAILURE(
      buildProgramCreateKernel(kernelString, "test_atomic_f_atomicity"));

  cl_mem kA =
      clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(T), nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer addend");
  cl_mem kS =
      clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(T), nullptr, &err);
  ASSERT_OCL_SUCCESS(err, "clCreateBuffer res");

  err = clEnqueueWriteBuffer(queue, kA, CL_TRUE, 0, sizeof(T), &addend, 0,
                             nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer addend");
  err = clEnqueueWriteBuffer(queue, kS, CL_TRUE, 0, sizeof(T), &augend, 0,
                             nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueWriteBuffer augend");

  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &kA);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg addend");
  err = clSetKernelArg(kernel, 1, sizeof(cl_mem), &kS);
  ASSERT_OCL_SUCCESS(err, "clSetKernelArg res sum");

  err = clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &globalSizes,
                               &localSizes, 0, nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueNDRangeKernel");

  err = clEnqueueReadBuffer(queue, kS, CL_TRUE, 0, sizeof(T), resSum, 0,
                            nullptr, nullptr);
  ASSERT_OCL_SUCCESS(err, "clEnqueueReadBuffer res sum");

  err = clReleaseMemObject(kA);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");
  err = clReleaseMemObject(kS);
  ASSERT_OCL_SUCCESS(err, "clReleaseMemObject");

  err = clReleaseKernel(kernel);
  ASSERT_OCL_SUCCESS(err, "clReleaseKernel");
  err = clReleaseProgram(program);
  ASSERT_OCL_SUCCESS(err, "clReleaseProgram");
}

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

template <typename Op, typename T>
static bool checkAtomicity_results_with_ocl20_local_subrspace(
    size_t globalSizes, size_t localSizes, T augend, T addend, T resSum) {
  Op op;
  T expSum = augend;
  for (size_t i = 0; i < globalSizes / localSizes; i++) {
    T sum = 0.0;
    for (size_t j = 0; j < localSizes; j++)
      for (size_t k = 0; k < 11; k++)
        sum = op(sum, addend);
    expSum = op(expSum, sum);
  }

  size_t remainder = globalSizes % localSizes;
  if (remainder != 0) {
    T sum = 0.0;
    for (size_t j = 0; j < remainder; j++)
      for (size_t k = 0; k < 11; k++)
        sum = op(sum, addend);
    expSum = op(expSum, sum);
  }

  return isEqual(expSum, resSum);
}

template <typename Op, typename T>
static bool checkAtomicity_results(size_t globalSizes, T augend, T addend,
                                   T resSum) {
  Op op;
  T expSum = augend;
  for (size_t i = 0; i < globalSizes; i++)
    for (size_t j = 0; j < 11; j++)
      expSum = op(expSum, addend);

  return isEqual(expSum, resSum);
}

template <typename T> static void initSrc(T *augend, T *addend) {
  *augend = 12345.6789f;
  *addend = 0.98765f;
}

static void initSrc(cl_half *augend, cl_half *addend) {
  *augend = cl_half_from_float(12345.6789f, CL_HALF_RTE);
  *addend = cl_half_from_float(0.98765f, CL_HALF_RTE);
}

TYPED_TEST(AtomicAddSubFPTest, Atomicity) {
  using T = typename TypeParam::DataTy;
  bool isOCL20 = TypeParam::isOCL20;

  for (int i = 0; i < 2; i++) {
    size_t globalSizes = 64;
    size_t localSizes = 8;
    T augend;
    T addend;
    initSrc(&augend, &addend);
    T resSum{};

    ASSERT_NO_FATAL_FAILURE(this->checkAtomic_atomicity(
        isOCL20, i != 0, globalSizes, localSizes, augend, addend, &resSum));
    // Check results by 2 different functions since the calculation patterns
    // with global and local address space are not same and the results with
    // float point type may be slightly different.
    if (i == 0 || !isOCL20)
      ASSERT_TRUE(checkAtomicity_results<typename TypeParam::OpTy>(
          globalSizes, augend, addend, resSum))
          << "Results differ from expected";
    else
      ASSERT_TRUE(checkAtomicity_results_with_ocl20_local_subrspace<
                  typename TypeParam::OpTy>(globalSizes, localSizes, augend,
                                            addend, resSum))
          << "Results differ from expected";
  }
}
