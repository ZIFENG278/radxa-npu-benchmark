# vpm_run 测试说明

概述
- 本目录包含针对 Allwinner T527TOPS 芯片（2 TOPS）上使用 vpm_run 接口的简单性能测试说明与脚本示例。
- 测试模型：resnet50-v2-7-sim.onnx、yolov5s-sim.onnx（可从仓库下载或根据说明转换得到）。
- SDK 版本：1.8.11
- 转换工具：ACUITY Toolkit（请参考官方文档获取转换方法和参数）。

依赖与准备
- 可执行文件：vpm_run（需放在与脚本同一目录且具有可执行权限）
- 测试描述文件：resnet.txt、yolo.txt（示例输入配置，放在同一目录）

脚本说明
- resnet.sh 与 yolo.sh 均为相同结构的测试脚本，功能为：
  1. 接收一个参数：循环次数（loop_count）
  2. 重复调用 `./vpm_run -s ./<xx>.txt -l 1`
  3. 从 vpm_run 输出中提取 "profile inference time=XXXus" 的数值（单位：微秒）
  4. 统计平均推理时间、最小推理时间，并换算为毫秒和 FPS（FPS = 1000ms / 推理时间ms）

使用方法（示例）
1. 赋予脚本执行权限（若尚未设置）：
   chmod +x resnet.sh yolo.sh
2. 运行示例（执行 10 次推理）：
   ./resnet.sh 10
   ./yolo.sh 10

输出说明
- 脚本在每次迭代会显示当前进度和本次推理耗时（微秒）。
- 最终会打印：
  - Average inference time: <avg_ms>ms
  - Minimum inference time: <min_ms>ms
  - Average FPS: <avg_fps>
  - Maximum FPS: <max_fps>
- 其中平均/最小耗时由脚本从 vpm_run 输出的 microsecond 值换算得到；FPS 按 1000 / ms 计算。

示例 vpm_run 输出解析
- 期望 vpm_run 的输出包含像如下的字段（脚本基于此解析）：
  profile inference time=12345us
- 脚本通过 grep + awk 提取等号后的数字并去掉 "us" 单位，要求为纯数字（微秒）。

常见问题排查
- 若脚本报错提示找不到 vpm_run：
  - 检查当前目录是否存在可执行文件 `vpm_run`，并确保权限可执行（chmod +x vpm_run）。
- 若报错找不到 resnet.txt / yolo.txt：
  - 确认对应的描述文件存在且路径正确。
- 若无法解析推理时间（脚本提示 `Failed to get inference time`）：
  - 检查 vpm_run 的输出格式是否包含 `profile inference time=`，或输出是否被重定向/改变；
  - 可手动运行 `./vpm_run -s ./resnet.txt -l 1` 并观察输出内容，确认包含时间字段。

测试结果（示例）
- 使用本仓库提供的模型和配置进行测试，得到的示例结果（参考）：
  - resnet50-v2-7-sim: 65.18 FPS
  - yolov5s-sim: 19.29 FPS
- 注：具体结果受硬件、系统负载、驱动和模型转换参数影响，实际测试中可能有所不同。

参考
- ACUITY Toolkit 官方文档（用于模型转换）
- 本目录下的 benchmark.sh 脚本（用于了解调用与解析细节）
