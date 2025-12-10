# ResNet 基准测试

本项目用于在 RK3588 设备上进行 ResNet 模型的性能测试。

## 测试模型

- **模型类型**: ResNet（残差神经网络）
- **模型格式**: RKNN 格式（`.rknn`）
- **部署平台**: RK3588 设备

## 测试方法

### 前置条件

1. 在 PC 主机上编译可执行程序
2. 将编译好的程序和模型文件传输到 RK3588 设备

### 使用步骤

1. 修改 `run-benchmark.sh` 中的配置参数：
   ```bash
   EXECUTABLE="./your_executable_name"      # 可执行程序路径
   MODEL="./model/your_model_name.rknn"     # RKNN 模型文件路径
   ITERATIONS=10                            # 测试次数
   ```

2. 运行测试脚本：
   ```bash
   bash run-benchmark.sh
   ```

3. 查看测试结果：
   - 控制台实时输出各次执行的时间和 FPS
   - 详细结果保存在 `benchmark_results.txt`

## 结果说明

脚本将生成以下统计数据：

- **总时间**: 推理的总耗时（秒）
- **FPS**: 每秒帧数
- **统计指标**: 平均值、最小值、最大值

所有结果同时输出到控制台和结果文件中，便于后续分析。