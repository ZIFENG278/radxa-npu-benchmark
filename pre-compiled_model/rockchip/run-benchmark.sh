#!/bin/bash

# Configuration
ITERATIONS=10
EXECUTABLE="./your_executable_name"
MODEL="./model/your_model_name.rknn"
RESULTS_FILE="benchmark_results.txt"

> "$RESULTS_FILE"

echo "Running performance test $ITERATIONS times..."
echo "================================"

# Store results
declare -a times
declare -a fps

for ((i=1; i<=ITERATIONS; i++))
do
    echo "Execution $i..."
    
    # Execute C++ program and capture output
    output=$("$EXECUTABLE" "$MODEL" 2>&1)
    
    # Extract time
    time_val=$(echo "$output" | grep -oP 'total time taken: \K[0-9.]+')
    # Extract FPS
    fps_val=$(echo "$output" | grep -oP 'FPS: \K[0-9.]+')
    
    if [ -n "$time_val" ] && [ -n "$fps_val" ]; then
        times+=("$time_val")
        fps+=("$fps_val")
        echo "  Time: ${time_val}s, FPS: ${fps_val}"
        echo "Execution $i: time=${time_val}s, FPS=${fps_val}" >> "$RESULTS_FILE"
    else
        echo "  Warning: Failed to extract data"
    fi
done

echo "================================"

# Calculate statistics
if [ ${#times[@]} -gt 0 ]; then
    # Initialize
    time_sum=0; fps_sum=0
    time_min=${times[0]}; time_max=${times[0]}
    fps_min=${fps[0]}; fps_max=${fps[0]}
    
    # Calculate
    for i in "${!times[@]}"; do
        # Time
        time_sum=$(echo "$time_sum + ${times[i]}" | bc -l)
        if (( $(echo "${times[i]} < $time_min" | bc -l) )); then
            time_min=${times[i]}
        fi
        if (( $(echo "${times[i]} > $time_max" | bc -l) )); then
            time_max=${times[i]}
        fi
        
        # FPS
        fps_sum=$(echo "$fps_sum + ${fps[i]}" | bc -l)
        if (( $(echo "${fps[i]} < $fps_min" | bc -l) )); then
            fps_min=${fps[i]}
        fi
        if (( $(echo "${fps[i]} > $fps_max" | bc -l) )); then
            fps_max=${fps[i]}
        fi
    done
    
    # Calculate average
    count=${#times[@]}
    time_avg=$(echo "scale=3; $time_sum / $count" | bc -l)
    fps_avg=$(echo "scale=3; $fps_sum / $count" | bc -l)
    
    # Output results
    echo "" | tee -a "$RESULTS_FILE"
    echo "========== Statistics ==========" | tee -a "$RESULTS_FILE"
    echo "Number of executions: $count" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"
    echo "Time statistics (total time taken):" | tee -a "$RESULTS_FILE"
    echo "  Average: ${time_avg}s" | tee -a "$RESULTS_FILE"
    echo "  Minimum: ${time_min}s (best)" | tee -a "$RESULTS_FILE"
    echo "  Maximum: ${time_max}s" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"
    echo "FPS statistics:" | tee -a "$RESULTS_FILE"
    echo "  Average: ${fps_avg}" | tee -a "$RESULTS_FILE"
    echo "  Maximum: ${fps_max} (best)" | tee -a "$RESULTS_FILE"
    echo "  Minimum: ${fps_min}" | tee -a "$RESULTS_FILE"
    
    echo "Results saved to: $RESULTS_FILE"
else
    echo "Error: No valid data" | tee -a "$RESULTS_FILE"
fi
