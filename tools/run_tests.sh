#!/bin/bash

# Set project root directory
PROJECT_ROOT=~/mips-dev/mips-projects/mips-vuln-scanner

# Run unit tests
echo "Running unit tests..."
for test in ${PROJECT_ROOT}/tests/unit/*.{s,asm}; do
    if [ -f "$test" ]; then
        echo -e "\nRunning test: $test"
        ~/mips-dev/tools/mars nc "$test"
        
        # Check exit status
        if [ $? -eq 0 ]; then
            echo "✅ Test passed: $test"
        else
            echo "❌ Test failed: $test"
        fi
    fi
done

# Run integration tests
echo -e "\nRunning integration tests..."
for test in ${PROJECT_ROOT}/tests/integration/*.{s,asm}; do
    if [ -f "$test" ]; then
        echo -e "\nRunning test: $test"
        ~/mips-dev/tools/mars nc "$test"
        
        # Check exit status
        if [ $? -eq 0 ]; then
            echo "✅ Test passed: $test"
        else
            echo "❌ Test failed: $test"
        fi
    fi
done