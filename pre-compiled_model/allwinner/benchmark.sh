#!/bin/bash

# 检查命令行参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <loop_count>"
    exit 1
fi

# 获取循环次数
LOOP_COUNT=$1
TOTAL_TIME=0
MIN_TIME=999999999

# 检查vpm_run程序是否存在
if [ ! -x "./vpm_run" ]; then
    echo "Error: vpm_run not found or not executable in current directory"
    exit 1
fi

# 检查resnet.txt文件是否存在
if [ ! -f "./target_model.txt" ]; then
    echo "Error: target_model.txt not found in current directory"
    exit 1
fi

echo "Running inference $LOOP_COUNT times..."

# 循环运行推理
for ((i=1; i<=$LOOP_COUNT; i++)); do
    # 运行vpm_run并捕获输出
    OUTPUT=$(./vpm_run -s ./target_model.txt -l 1 2>&1)

    # 提取推理时间 - 改进的提取方法
    INFERENCE_TIME=$(echo "$OUTPUT" | grep "profile inference time=" | awk -F'=' '{print $2}' | awk -F'us' '{print $1}')

    # 验证是否成功获取到时间
    if [ -z "$INFERENCE_TIME" ] || ! [[ "$INFERENCE_TIME" =~ ^[0-9]+$ ]]; then
        echo "Error: Failed to get inference time on iteration $i"
        echo "Raw output extract: $(echo "$OUTPUT" | grep "profile inference time=")"
        exit 1
    fi

    # 累加总时间
    TOTAL_TIME=$((TOTAL_TIME + INFERENCE_TIME))

    # 更新最短时间
    if [ $INFERENCE_TIME -lt $MIN_TIME ]; then
        MIN_TIME=$INFERENCE_TIME
    fi

    # 显示进度
    echo -ne "Progress: $i/$LOOP_COUNT (Current: ${INFERENCE_TIME}us)\r"
done

echo ""  # 换行

# 计算统计信息
AVG_TIME=$((TOTAL_TIME / LOOP_COUNT))

# 转换为毫秒并计算帧率
AVG_TIME_MS=$(echo "scale=2; $AVG_TIME / 1000" | bc)
MIN_TIME_MS=$(echo "scale=2; $MIN_TIME / 1000" | bc)

# 计算帧率（FPS = 1000ms / 推理时间ms）
if [ $(echo "$AVG_TIME_MS > 0" | bc) -eq 1 ]; then
    AVG_FPS=$(echo "scale=2; 1000 / $AVG_TIME_MS" | bc)
else
    AVG_FPS=0
fi

if [ $(echo "$MIN_TIME_MS > 0" | bc) -eq 1 ]; then
    MAX_FPS=$(echo "scale=2; 1000 / $MIN_TIME_MS" | bc)
else
    MAX_FPS=0
fi

# 输出结果
echo "Average inference time: ${AVG_TIME_MS}ms"
echo "Minimum inference time: ${MIN_TIME_MS}ms"
echo "Average FPS: $AVG_FPS"
echo "Maximum FPS: $MAX_FPS"