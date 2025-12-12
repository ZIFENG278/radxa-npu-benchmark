# YOLOv5s Benchmark on AX650N

简要说明：该模型使用 `pulsar2` 工具链编译为可在 AX650N 上运行的 `.axmodel`。本文档记录示例编译配置、运行/测试说明与简要性能结果。

## 概要

基准使用 YOLOv5s 的 ONNX 模型（`yolov5s-sim.onnx`）进行量化与编译，目标设备为 AX650N。输出文件 `yolov5s.axmodel` 位于 `yolo-benchmark/output`。

## 先决条件

- 主机已安装并配置好 `pulsar2` 工具链。
- 源模型：`yolo-benchmark/yolov5s-sim.onnx`
- 校准数据（用于量化）：`yolo-benchmark/coco_4.tar`（示例，按需替换）

## 编译配置（示例）

下面为用于量化/编译的 JSON 配置示例：

```json
{
  "input": "yolo-benchmark/yolov5s-sim.onnx",
  "output_dir": "yolo-benchmark/output",
  "output_name": "yolov5s.axmodel",
  "model_type": "ONNX",
  "target_hardware": "AX650N",
  "npu_mode": "NPU3",
  "input_shapes": "input:1x3x640x640",
  "quant": {
    "input_configs": [
      {
        "tensor_name": "DEFAULT",
        "calibration_dataset": "./yolo-benchmark/coco_4.tar",
        "calibration_size": 4,
        "calibration_mean": [0, 0, 0],
        "calibration_std": [255.0, 255.0, 255.0]
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
      "src_layout": "NHWC"
    }
  ],
  "output_processors": [
    {
      "tensor_name": "DEFAULT",
      "dst_perm": [0, 2, 3, 1]
    }
  ],
  "compiler": {
    "check": 0
  }
}
```

编译命令示例：

```bash
pulsar2 build --config ./yolo-benchmark/config.json
```

说明：根据实际需求调整配置参数与路径。

## 运行与测试

将生成的 `yolov5s.axmodel` 推送到搭载 AX650N 的开发板后，可使用 axcl-cli 的 `axcl_run_model` 进行推理测试：

```bash
axcl_run_model -m yolov5s.axmodel -w 1 -l 1000
```

## 测试结果（示例）

- 平均: 303 FPS  
- 峰值: 304 FPS

（结果受模型、量化配置、硬件与运行环境影响，实际值可能不同。）
