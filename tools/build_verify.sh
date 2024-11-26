#!/bin/bash

PROJECT_ROOT=~/mips-dev/mips-projects/mips-vuln-scanner

echo "Verifying build setup..."

# Check if memory_manager.s exists and has correct structure
MM_FILE="${PROJECT_ROOT}/src/core/memory_manager.s"
if [ -f "$MM_FILE" ]; then
    echo "✅ Found memory_manager.s"
    if grep -q ".globl initialize_memory_manager" "$MM_FILE"; then
        echo "✅ Found global declarations in memory_manager.s"
    else
        echo "❌ Missing global declarations in memory_manager.s"
    fi
else
    echo "❌ memory_manager.s not found"
fi

# Check if test file exists and has correct structure
TEST_FILE="${PROJECT_ROOT}/tests/unit/memory_manager_test.s"
if [ -f "$TEST_FILE" ]; then
    echo "✅ Found memory_manager_test.s"
    if grep -q ".include.*memory_manager.s" "$TEST_FILE"; then
        echo "✅ Found include directive in test file"
    else
        echo "❌ Missing include directive in test file"
    fi
else
    echo "❌ memory_manager_test.s not found"
fi

# Try to compile files
echo -e "\nAttempting to compile..."
~/mips-dev/tools/mars nc "$MM_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ memory_manager.s compiles successfully"
else
    echo "❌ memory_manager.s compilation failed"
fi

~/mips-dev/tools/mars nc "$TEST_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ memory_manager_test.s compiles successfully"
else
    echo "❌ memory_manager_test.s compilation failed"
fi