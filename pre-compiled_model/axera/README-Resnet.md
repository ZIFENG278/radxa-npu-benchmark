# ResNet50 Benchmark on AX650N

简要说明：该模型使用 `pulsar2` 工具链编译为可在 AX650N 上运行的 `.axmodel`。本文档记录示例编译配置、运行/测试说明与简要性能结果。

## 概要

基准使用 ResNet-50 v2 的 ONNX 模型（`resnet50-v2-7-sim.onnx`）进行量化与编译，目标设备为 AX650N。输出文件 `resnet.axmodel` 位于 `resnet-benchmark/output`。

## 先决条件

- 主机已安装并配置好 `pulsar2` 工具链。
- 源模型：`resnet-benchmark/resnet50-v2-7-sim.onnx`
- 校准数据（用于量化）：`resnet-benchmark/imagenet-32-images.tar`（示例，按需替换）

## 编译配置（示例）

下面为用于量化/编译的 JSON 配置示例（已格式化）：

```json
{
  "input": "resnet-benchmark/resnet50-v2-7-sim.onnx",
  "output_dir": "resnet-benchmark/output",
  "output_name": "resnet.axmodel",
  "model_type": "ONNX",
  "target_hardware": "AX650N",
  "npu_mode": "NPU3",
  "input_shapes": "input:1x3x224x224",
  "quant": {
    "input_configs": [
      {
        "tensor_name": "DEFAULT",
        "calibration_dataset": "resnet-benchmark/imagenet-32-images.tar",
        "calibration_size": 32,
        "calibration_mean": [123.675, 116.28, 103.53],
        "calibration_std": [58.82, 58.82, 58.82]
      }
    ],
    "calibration_method": "MinMax",
    "precision_analysis": false
  },
  "input_processors": [
    {
      "tensor_name": "DEFAULT",
      "tensor_format": "BGR",
      "src_format": "BGR",
      "src_dtype": "U8",
      "src_layout": "NHWC",
      "csc_mode": "NoCSC"
    }
  ],
  "compiler": {"check": 0}
}
```

编译命令示例：

```bash
pulsar2 build --config ./resnet-benchmark/config.json
```

说明：根据实际需求调整配置参数与路径。

## 运行与测试

将生成的 `resnet.axmodel` 推送到搭载 AX650N 的开发板后，可使用 axcl-cli 的 `axcl_run_model` 进行推理测试：

```bash
axcl_run_model -m resnet.axmodel -w 1 -l 1000
```

## 测试结果（示例）

- 平均: 578 FPS  
- 峰值: 585 FPS

（结果受模型、量化配置、硬件与运行环境影响，实际值可能不同。）
