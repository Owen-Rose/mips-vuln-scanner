#!/bin/bash

PROJECT_ROOT=~/mips-dev/mips-projects/mips-vuln-scanner

echo "Verifying test setup..."

# Check memory manager source file
MM_SOURCE="${PROJECT_ROOT}/src/core/memory_manager.s"
if [ -f "$MM_SOURCE" ]; then
    echo "✅ Memory manager source found: $MM_SOURCE"
    # Check for global declarations
    if grep -q "\.globl.*initialize_memory_manager" "$MM_SOURCE"; then
        echo "  ✓ Found .globl initialize_memory_manager"
    else
        echo "  ⚠️  Missing .globl initialize_memory_manager declaration"
    fi
else
    echo "❌ Memory manager source not found at: $MM_SOURCE"
    echo "   Please ensure memory_manager.s exists in src/core/"
fi

# Check test file
TEST_FILE="${PROJECT_ROOT}/tests/unit/memory_manager_test.s"
if [ -f "$TEST_FILE" ]; then
    echo "✅ Test file found: $TEST_FILE"
    # Check for includes
    if grep -q "\.include.*memory_manager.s" "$TEST_FILE"; then
        echo "  ✓ Found include directive for memory_manager.s"
    else
        echo "  ⚠️  Missing include directive for memory_manager.s"
        echo "      Add '.include \"../../src/core/memory_manager.s\"' at the top"
    fi
    # Check for main label
    if grep -q "^main:" "$TEST_FILE"; then
        echo "  ✓ Found main label definition"
    else
        echo "  ⚠️  Missing main label definition"
    fi
    # Check for potentially problematic .globl main
    if grep -q "\.globl.*main" "$TEST_FILE"; then
        echo "  ⚠️  Found .globl main declaration - this might cause issues"
        echo "      Remove the .globl main line, it's not needed"
    fi
else
    echo "❌ Test file not found at: $TEST_FILE"
    echo "   Please ensure memory_manager_test.s exists in tests/unit/"
fi

# Check constants file
CONST_FILE="${PROJECT_ROOT}/src/common/constants.s"
if [ -f "$CONST_FILE" ]; then
    echo "✅ Constants file found: $CONST_FILE"
else
    echo "❌ Constants file not found at: $CONST_FILE"
fi

# Check file permissions
if [ -x "${PROJECT_ROOT}/tools/run_tests.sh" ]; then
    echo "✅ run_tests.sh is executable"
else
    echo "❌ run_tests.sh is not executable"
    echo "   Run: chmod +x ${PROJECT_ROOT}/tools/run_tests.sh"
fi

# Try to compile the test file
echo -e "\nAttempting to compile test file..."
if [ -f "$TEST_FILE" ]; then
    # Capture both stdout and stderr
    OUTPUT=$(~/mips-dev/tools/mars nc "$TEST_FILE" 2>&1)
    if [ $? -eq 0 ]; then
        echo "✅ Test file compiles successfully"
    else
        echo "❌ Test file compilation failed"
        echo "Error output:"
        echo "$OUTPUT"
        
        # Specific error checking
        if echo "$OUTPUT" | grep -q "main.*declared.*global.*label.*but.*not.*defined"; then
            echo -e "\n🔍 Found 'main declared but not defined' error"
            echo "To fix this:"
            echo "1. Remove '.globl main' from the test file if present"
            echo "2. Ensure 'main:' label exists in the test file"
            echo "3. Make sure memory_manager.s is properly included"
        fi
    fi
fi

echo -e "\nVerification complete!"