#include "TaskExecutorTester.h"
#include "common_utils.h"
#include "gtest_wrapper.h"
#include "tbb/global_control.h"
#include "tbb/info.h"
#include "gtest/gtest.h"
#include <iostream>
#include <type_traits>

using namespace Intel::OpenCL::TaskExecutor;

ITaskExecutor *TaskExecutorTester::m_pTaskExecutor = nullptr;

struct DeviceAuto {
  SharedPtr<ITEDevice> deviceHandle;

  // root device constructor
  DeviceAuto(TaskExecutorTester &taskExecutorTester, bool useNuma = false) {
    ITaskExecutor *taskExecutor = taskExecutorTester.GetTaskExecutor();
    RootDeviceCreationParam param(TE_AUTO_THREADS, TE_ENABLE_MASTERS_JOIN, 1);
    if (useNuma && taskExecutor->IsTBBNumaEnabled())
      param.uiNumOfLevels = TE_MAX_LEVELS_COUNT;
    deviceHandle =
        taskExecutor->CreateRootDevice(param, nullptr, &taskExecutorTester);
  };

  // sub device constructor
  DeviceAuto(const SharedPtr<ITEDevice> root, unsigned int units) {
    deviceHandle = root->CreateSubDevice(units);
  }

  ~DeviceAuto() {
    if (nullptr != deviceHandle.GetPtr()) {
      deviceHandle->ShutDown();
    }
  }
};

template <typename TesterTaskSetType = TesterTaskSet,
          typename = std::enable_if_t<
              std::is_base_of_v<TesterTaskSet, TesterTaskSetType>>>
static bool RunSomeTasks(const SharedPtr<ITEDevice> &pSubdevData,
                         bool bOutOfOrder, bool bIsFullDevice,
                         std::atomic<long> *pUncompletedTasks) {
  SharedPtr<ITaskList> pTaskList = pSubdevData->CreateTaskList(
      bOutOfOrder ? TE_CMD_LIST_OUT_OF_ORDER : TE_CMD_LIST_IN_ORDER);
  if (nullptr == pTaskList.GetPtr()) {
    std::cerr << "TaskExecutor::CreateTaskList returned NULL" << std::endl;
    return false;
  }
  const bool bWaitShouldBeSupported = bIsFullDevice;
  for (unsigned int uiNumDims = 1; uiNumDims <= 3; uiNumDims++) {
    std::vector<SharedPtr<TesterTaskSet>> tasks(1000);
    for (size_t i = 0; i < tasks.size(); i++) {
      SharedPtr<TesterTaskSet> pTaskSet =
          TesterTaskSetType::Allocate(uiNumDims, pUncompletedTasks);
      if (nullptr != pUncompletedTasks) {
        (*pUncompletedTasks)++;
      }
      pTaskList->Enqueue(pTaskSet);
      tasks[i] = pTaskSet;
    }
    if (!pTaskList->Flush()) {
      std::cerr << "Flush failed failed" << std::endl;
      return false;
    }

    for (size_t i = 0; i < tasks.size(); i++) {
      const te_wait_result res = pTaskList->WaitForCompletion(tasks[i]);

      if ((!bWaitShouldBeSupported && res != TE_WAIT_NOT_SUPPORTED) ||
          (bWaitShouldBeSupported && res != TE_WAIT_COMPLETED)) {
        std::cerr << "WaitForCompletion doesn't return result as expected"
                  << std::endl;
        return false;
      }
    }

    const te_wait_result res = pTaskList->WaitForCompletion(nullptr);
    if ((!bWaitShouldBeSupported && res != TE_WAIT_NOT_SUPPORTED) ||
        (bWaitShouldBeSupported && res != TE_WAIT_COMPLETED)) {
      std::cerr << "WaitForCompletion doesn't return result as expected"
                << std::endl;
      return false;
    }
  }
  return true;
}

// a value of 0 in uiSubdevSize designates running on the root device

static bool RunSubdeviceTest(unsigned int uiSubdevSize,
                             TaskExecutorTester &taskExecutorTester) {
  DeviceAuto rootDeviceHandle(taskExecutorTester);
  bool use_subdevice = (uiSubdevSize > 0);
  DeviceAuto subDevHandle(rootDeviceHandle.deviceHandle, uiSubdevSize);
  SharedPtr<ITEDevice> pSubdevData =
      use_subdevice ? subDevHandle.deviceHandle : rootDeviceHandle.deviceHandle;
  if (nullptr == pSubdevData.GetPtr() && use_subdevice) {
    std::cerr << "CreateSubdevice returned NULL" << std::endl;
    return false;
  }
  std::atomic<long> uncompletedTasks{0};
  const bool bResult =
      RunSomeTasks(pSubdevData, false, !use_subdevice, &uncompletedTasks);

  if (0 == uiSubdevSize) // subdevices don't support WaitForCompletion
  {
    SharedPtr<TesterTaskSet> pTaskSet =
        TesterTaskSet::Allocate(1, &uncompletedTasks);
    SharedPtr<ITaskList> pTaskList =
        pSubdevData->CreateTaskList(TE_CMD_LIST_IN_ORDER);

    pTaskList->Enqueue(pTaskSet);
    pTaskList->Flush();
    pTaskList->WaitForCompletion(pTaskSet.GetPtr());
    if (!pTaskSet->IsCompleted()) {
      std::cerr << "pTaskSet is not completed after taskExecutor.Execute"
                << std::endl;
      return false;
    }
  } else {
    while (uncompletedTasks > 0) {
      clSleep(1);
    }
  }
  return bResult;
}

bool SubdeviceTest() {
  TaskExecutorTester tester;
  return RunSubdeviceTest(
      tester.GetTaskExecutor()->GetMaxNumOfConcurrentThreads() / 2, tester);
}

bool SubdeviceSize1Test() {
  TaskExecutorTester tester;
  return RunSubdeviceTest(1, tester);
}

bool SubdeviceFullDevice() {
  TaskExecutorTester tester;
  return RunSubdeviceTest(
      tester.GetTaskExecutor()->GetMaxNumOfConcurrentThreads(), tester);
}

bool BasicTest() {
  TaskExecutorTester tester;

  DeviceAuto rootDeviceHandle(tester);
  const bool bResult = RunSubdeviceTest(0, tester);
  return bResult;
}

bool OOOTest() {
  TaskExecutorTester tester;

  DeviceAuto rootDeviceHandle(tester);
  const bool bResult =
      RunSomeTasks(rootDeviceHandle.deviceHandle, true, true, nullptr);
  return bResult;
}

bool NumaTest() {
  TaskExecutorTester tester;

  DeviceAuto rootDeviceHandle(tester, true);
  const bool bResult = RunSomeTasks<NumaTesterTaskSet>(
      rootDeviceHandle.deviceHandle, true, true, nullptr);
  return bResult;
}

TEST(TaskExecutorTestType, Test_Basic) { EXPECT_TRUE(BasicTest()); }

TEST(TaskExecutorTestType, Test_Subdevices) { EXPECT_TRUE(SubdeviceTest()); }

TEST(TaskExecutorTestType, Test_SubdeviceSize1) {
  EXPECT_TRUE(SubdeviceSize1Test());
}

TEST(TaskExecutorTestType, Test_SubdeviceFullDevice) {
  EXPECT_TRUE(SubdeviceFullDevice());
}

TEST(TaskExecutorTestType, Test_OOO) { EXPECT_TRUE(OOOTest()); }

TEST(TaskExecutorTestType, Test_Numa) {
  std::vector<int> tbbNumaNodes = tbb::info::numa_nodes();
  // Skip test if there is only a single NUMA node.
  if (tbbNumaNodes.size() < 2)
    GTEST_SKIP();

  ASSERT_TRUE(SETENV("SYCL_CPU_PLACES", "numa_domains"));
  EXPECT_TRUE(NumaTest());
}

TEST(TaskExecutorTestType, numaAPIEnabled) {
  std::vector<int> tbbNumaNodes = tbb::info::numa_nodes();
  // Skip test if there is only a single NUMA node.
  if (tbbNumaNodes.size() < 2)
    GTEST_SKIP();

  ASSERT_TRUE(SETENV("SYCL_CPU_PLACES", "numa_domains"));
  TaskExecutorTester tester;
  EXPECT_TRUE(tester.GetTaskExecutor()->IsTBBNumaEnabled())
      << "NUMA API should be enabled";
}

TEST(TaskExecutorTestType, numaAPIDisabledSingleThread) {
  std::vector<int> tbbNumaNodes = tbb::info::numa_nodes();
  // Skip test if there is only a single NUMA node.
  if (tbbNumaNodes.size() < 2)
    GTEST_SKIP();

  ASSERT_TRUE(SETENV("SYCL_CPU_PLACES", "numa_domains"));
  auto controller =
      tbb::global_control{tbb::global_control::max_allowed_parallelism, 1};
  TaskExecutorTester tester;
  EXPECT_FALSE(tester.GetTaskExecutor()->IsTBBNumaEnabled())
      << "NUMA API should be disabled if there is only single thread in TBB";
}

#ifdef _WIN32
bool AtExitTaskExecutor::EnableTaskExecutorFinalizing = true;
#endif

int main(int argc, char *argv[]) {
#ifdef _WIN32
  AtExitTaskExecutor guard;
#endif

  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
