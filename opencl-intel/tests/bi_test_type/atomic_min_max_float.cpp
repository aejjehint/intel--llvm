#include "CL/cl.h"
#include "CL/cl_half.h"
#include "bi_tests.h"
#include "cl_types.h"
#include "test_utils.h"

#include <atomic>
#include <cmath>
#include <limits>

/*******************************************************************************
 * Test checks that atomic_min/atomic_max in kernel code compares float/double
 * values correctly.
 ******************************************************************************/

extern cl_device_type gDeviceType;

namespace {
const char *OCL12_KERNEL_TEST_CODE_STR =
    "#ifdef FUNC_MIN                                                 \n\
    #define atomic_FUNC atomic_min                                   \n\
    #elif defined(FUNC_MAX)                                          \n\
    #define atomic_FUNC atomic_max                                   \n\
    #else                                                            \n\
    #error \"atomic_FUNC is not defined\"                            \n\
    #endif                                                           \n\
    #pragma OPENCL EXTENSION cl_khr_fp16 : enable                    \n\
    half __attribute__((overloadable))                               \n\
    atomic_min(volatile __global half *p, half val);                 \n\
    half __attribute__((overloadable))                               \n\
    atomic_max(volatile __global half *p, half val);                 \n\
    __kernel void test_atomics(__global T *src_a,                    \n\
    __global T *src_b,                                               \n\
    __global T *r_old,                                               \n\
    __global T *r_cmp) {                                             \n\
    int tid = get_global_id(0);                                      \n\
    r_cmp[tid] = src_a[tid];                                         \n\
    r_old[tid] = atomic_FUNC(&(r_cmp[tid]), src_b[tid]);             \n\
    }";

const char *OCL20_KERNEL_TEST_CODE_STR =
    "#ifdef FUNC_MIN                                                 \n\
    #define atomic_fetch_FUNC_explicit atomic_fetch_min_explicit     \n\
    #elif defined(FUNC_MAX)                                          \n\
    #define atomic_fetch_FUNC_explicit atomic_fetch_max_explicit     \n\
    #else                                                            \n\
    #error \"FUNC is not defined\"                                   \n\
    #endif                                                           \n\
    #pragma OPENCL EXTENSION cl_khr_fp16 : enable                    \n\
    __kernel void test_atomics(__global T *src_a,                    \n\
    __global T *src_b,                                               \n\
    __global T *r_old,                                               \n\
    __global AT *r_cmp) {                                            \n\
    int tid = get_global_id(0);                                      \n\
    atomic_store_explicit(&(r_cmp[tid]), src_a[tid],                 \n\
                          ORDER, SCOPE);                             \n\
    r_old[tid] = atomic_fetch_FUNC_explicit(&(r_cmp[tid]),           \n\
	                       src_b[tid], ORDER, SCOPE);            \n\
    }";

const std::vector<int> orders = {__ATOMIC_RELAXED, __ATOMIC_ACQUIRE,
                                 __ATOMIC_RELEASE, __ATOMIC_ACQ_REL,
                                 __ATOMIC_SEQ_CST};
const std::vector<int> scopes = {
    __OPENCL_MEMORY_SCOPE_WORK_ITEM,       __OPENCL_MEMORY_SCOPE_SUB_GROUP,
    __OPENCL_MEMORY_SCOPE_WORK_GROUP,      __OPENCL_MEMORY_SCOPE_DEVICE,
    __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES,
};
} // namespace

template <typename T>
cl_int check_atomic_min_max(bool isOCL20, const std::vector<T> &src_a,
                            const std::vector<T> &src_b, std::vector<T> &r_old,
                            std::vector<T> &r_cmp, const std::string &options) {
  cl_int iRet = 0;
  cl_device_id device = NULL;
  cl_context context;
  cl_platform_id platform = 0;
  const size_t num = src_a.size();

  iRet = clGetPlatformIDs(1, &platform, NULL);
  CheckException("clGetPlatformIDs", CL_SUCCESS, iRet);

  cl_context_properties prop[3] = {CL_CONTEXT_PLATFORM,
                                   (cl_context_properties)platform, 0};

  iRet = clGetDeviceIDs(platform, gDeviceType, 1, &device, NULL);
  CheckException("clGetDeviceIDs", CL_SUCCESS, iRet);

  context = clCreateContext(prop, 1, &device, NULL, NULL, &iRet);
  CheckException("clCreateContext", CL_SUCCESS, iRet);

  cl_command_queue queue =
      clCreateCommandQueueWithProperties(context, device, NULL, &iRet);
  CheckException("clCreateCommandQueueWithProperties", CL_SUCCESS, iRet);

  const char *kernelString =
      isOCL20 ? OCL20_KERNEL_TEST_CODE_STR : OCL12_KERNEL_TEST_CODE_STR;
  cl_program prog = clCreateProgramWithSource(
      context, 1, (const char **)&kernelString, NULL, &iRet);
  CheckException("clCreateProgramWithSource", CL_SUCCESS, iRet);

  printf("Building program with options %s\n", options.c_str());
  iRet = clBuildProgram(prog, 1, &device, options.c_str(), NULL, NULL);
  if (iRet != CL_SUCCESS) {
    char buildLog[2048];
    clGetProgramBuildInfo(prog, device, CL_PROGRAM_BUILD_LOG, sizeof(buildLog),
                          buildLog, NULL);
    printf("Build Failed, log:\n %s\n", buildLog);
  }
  CheckException("clBuildProgram", CL_SUCCESS, iRet);

  cl_kernel kernel = clCreateKernel(prog, "test_atomics", &iRet);
  CheckException("clCreateKernel", CL_SUCCESS, iRet);

  cl_mem k_a =
      clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(T) * num, NULL, &iRet);
  CheckException("clCreateBuffer src a", CL_SUCCESS, iRet);
  cl_mem k_b =
      clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(T) * num, NULL, &iRet);
  CheckException("clCreateBuffer src b", CL_SUCCESS, iRet);
  cl_mem k_o =
      clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(T) * num, NULL, &iRet);
  CheckException("clCreateBuffer res old", CL_SUCCESS, iRet);
  cl_mem k_s =
      clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(T) * num, NULL, &iRet);
  CheckException("clCreateBuffer res cmp", CL_SUCCESS, iRet);

  iRet = clEnqueueWriteBuffer(queue, k_a, CL_TRUE, 0, sizeof(T) * num,
                              &src_a[0], 0, NULL, NULL);
  CheckException("clEnqueueWriteBuffer src a", CL_SUCCESS, iRet);
  iRet = clEnqueueWriteBuffer(queue, k_b, CL_TRUE, 0, sizeof(T) * num,
                              &src_b[0], 0, NULL, NULL);
  CheckException("clEnqueueWriteBuffer src b", CL_SUCCESS, iRet);

  iRet = clSetKernelArg(kernel, 0, sizeof(cl_mem), &k_a);
  CheckException("clSetKernelArg src a", CL_SUCCESS, iRet);
  iRet = clSetKernelArg(kernel, 1, sizeof(cl_mem), &k_b);
  CheckException("clSetKernelArg src b", CL_SUCCESS, iRet);
  iRet = clSetKernelArg(kernel, 2, sizeof(cl_mem), &k_o);
  CheckException("clSetKernelArg res old", CL_SUCCESS, iRet);
  iRet = clSetKernelArg(kernel, 3, sizeof(cl_mem), &k_s);
  CheckException("clSetKernelArg res cmp", CL_SUCCESS, iRet);

  size_t global = num;
  iRet = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global, NULL, 0, NULL,
                                NULL);
  CheckException("clEnqueueNDRangeKernel", CL_SUCCESS, iRet);

  iRet = clEnqueueReadBuffer(queue, k_o, CL_TRUE, 0, sizeof(T) * num, &r_old[0],
                             0, NULL, NULL);
  CheckException("clEnqueueReadBuffer res old", CL_SUCCESS, iRet);
  iRet = clEnqueueReadBuffer(queue, k_s, CL_TRUE, 0, sizeof(T) * num, &r_cmp[0],
                             0, NULL, NULL);
  CheckException("clEnqueueReadBuffer res cmp", CL_SUCCESS, iRet);

  clReleaseMemObject(k_a);
  clReleaseMemObject(k_b);
  clReleaseMemObject(k_o);
  clReleaseMemObject(k_s);
  clReleaseCommandQueue(queue);
  clReleaseKernel(kernel);
  clReleaseProgram(prog);
  clReleaseContext(context);

  return iRet;
}

bool isLess(float a, float b) { return a < b; }

bool isGreater(float a, float b) { return a > b; }

bool isLess(double a, double b) { return a < b; }

bool isGreater(double a, double b) { return a > b; }

bool isLess(cl_half a, cl_half b) {
  return cl_half_to_float(a) < cl_half_to_float(b);
}

bool isGreater(cl_half a, cl_half b) {
  return cl_half_to_float(a) > cl_half_to_float(b);
}

template <typename T>
bool check_min_max_results(const std::vector<T> &src_a,
                           const std::vector<T> &src_b,
                           const std::vector<T> &r_old,
                           const std::vector<T> &r_cmp,
                           bool (*compFunc)(T, T)) {
  for (size_t i = 0; i < src_a.size(); i++) {
    if (src_a[i] != r_old[i] &&
        !(std::isnan(src_a[i]) && std::isnan(r_old[i]))) {
      printf("Old value error at %zu: got %f, expected %f\n", i, r_old[i],
             src_a[i]);
      return false;
    }

    T exp_cmp = compFunc(src_a[i], src_b[i]) ? src_a[i] : src_b[i];
    if (exp_cmp != r_cmp[i] && !(std::isnan(exp_cmp) && std::isnan(r_cmp[i]))) {
      printf("Comparison error at %zu: got %f, expected %f\n", i, r_cmp[i],
             exp_cmp);
      return false;
    }
  }
  return true;
}

bool check_min_max_results(const std::vector<cl_half> &src_a,
                           const std::vector<cl_half> &src_b,
                           const std::vector<cl_half> &r_old,
                           const std::vector<cl_half> &r_cmp,
                           bool (*compFunc)(cl_half, cl_half)) {
  for (size_t i = 0; i < src_a.size(); i++) {
    if (src_a[i] != r_old[i] &&
        !((src_a[i] & 0x7fff) > 0x7c00 && (r_old[i] & 0x7fff) > 0x7c00)) {
      printf("Old value error at %zu: got 0x%04x, expected 0x%04x\n", i,
             r_old[i], src_a[i]);
      return false;
    }

    cl_half exp_cmp = compFunc(src_a[i], src_b[i]) ? src_a[i] : src_b[i];

    if (exp_cmp != r_cmp[i] &&
        !((src_a[i] & 0x7fff) > 0x7c00 && (r_old[i] & 0x7fff) > 0x7c00)) {
      printf("Comparison error at %zu: got 0x%04x, expected 0x%04x\n", i,
             r_cmp[i], exp_cmp);
      return false;
    }
  }
  return true;
}

template <typename T>
void initSrc(std::vector<T> &src_a, std::vector<T> &src_b) {
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

void initSrc(std::vector<cl_half> &src_a, std::vector<cl_half> &src_b) {
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

template <typename T> bool atomic_float_min_max_test(bool isOCL20, bool isMin) {
  printf("---------------------------------------\n");
  printf("atomic_float_min_max_test\n");
  printf("---------------------------------------\n");

  cl_int iRet = 0;
  std::vector<T> src_a;
  std::vector<T> src_b;

  initSrc(src_a, src_b);

  std::vector<T> r_old(src_a.size());
  std::vector<T> r_cmp(src_a.size());

  std::string options = " -D float_atomics_enable";
  if (isOCL20) {
    options += " -cl-std=CL2.0";
    options +=
        (std::is_same<T, double>::value)  ? " -D T=double -D AT=atomic_double"
        : (std::is_same<T, float>::value) ? " -D T=float -D AT=atomic_float"
                                          : " -D T=half -D AT=atomic_half";
  } else {
    options += " -cl-std=CL1.2";
    options += (std::is_same<T, double>::value)  ? " -D T=double"
               : (std::is_same<T, float>::value) ? " -D T=float"
                                                 : " -D T=half";
  }
  options += isMin ? " -D FUNC_MIN" : " -D FUNC_MAX";

  // Check atomic_min or atomic_max.
  if (!isOCL20) {
    iRet = check_atomic_min_max(isOCL20, src_a, src_b, r_old, r_cmp, options);
    CheckException("check_atomic_min_max", CL_SUCCESS, iRet);

    if ((isMin && !check_min_max_results(src_a, src_b, r_old, r_cmp, isLess)) ||
        (!isMin &&
         !check_min_max_results(src_a, src_b, r_old, r_cmp, isGreater))) {
      printf("Results differ from expected in check_atomic_min_max\n");
      return false;
    }
    return true;
  }
  // Check atomic_fetch_min or atomic_fetch_max.
  for (auto scope : scopes) {
    for (auto order : orders) {
      iRet =
          check_atomic_min_max(isOCL20, src_a, src_b, r_old, r_cmp,
                               options + " -DSCOPE=" + std::to_string(scope) +
                                   " -DORDER=" + std::to_string(order));
      CheckException("check_atomic_min_max", CL_SUCCESS, iRet);
      if ((isMin &&
           !check_min_max_results(src_a, src_b, r_old, r_cmp, isLess)) ||
          (!isMin &&
           !check_min_max_results(src_a, src_b, r_old, r_cmp, isGreater))) {
        printf("Results differ from expected in check_atomic_min_max\n");
        return false;
      }
    }
  }
  return true;
}

bool atomic_min_max_float_test() {
  return (
      atomic_float_min_max_test<float>(false /*isOCL20*/, false /*isMin*/) &&
      atomic_float_min_max_test<float>(false, true) &&
      atomic_float_min_max_test<float>(true, true) &&
      atomic_float_min_max_test<float>(true, false) &&
      atomic_float_min_max_test<double>(false, false) &&
      atomic_float_min_max_test<double>(false, true) &&
      atomic_float_min_max_test<double>(true, false) &&
      atomic_float_min_max_test<double>(true, true) &&
      atomic_float_min_max_test<cl_half>(false, false) &&
      atomic_float_min_max_test<cl_half>(false, true) &&
      atomic_float_min_max_test<cl_half>(true, true) &&
      atomic_float_min_max_test<cl_half>(true, false));
}
