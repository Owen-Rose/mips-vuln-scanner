#!/bin/bash

# Setup verification script
# Save this as ~/mips-dev/mips-projects/mips-vuln-scanner/tools/verify_setup.sh

echo "Verifying MIPS development environment setup..."

# Check MARS executable
if [ -x ~/mips-dev/tools/mars ]; then
    echo "✅ MARS executable found"
else
    echo "❌ MARS executable not found or not executable"
    exit 1
fi

# Create test file
TEST_FILE=$(mktemp)
cat > "$TEST_FILE" << 'EOF'
.data
    msg: .asciiz "MARS Setup Verified Successfully!\n"
.text
main:
    li $v0, 4
    la $a0, msg
    syscall
    
    li $v0, 10
    syscall
EOF

echo "Running test MIPS program..."
~/mips-dev/tools/mars nc "$TEST_FILE"

if [ $? -eq 0 ]; then
    echo "✅ MARS execution test passed"
else
    echo "❌ MARS execution test failed"
fi

# Clean up
rm "$TEST_FILE"

# Verify project structure
PROJECT_DIR=~/mips-dev/mips-projects/mips-vuln-scanner

for dir in src/{core,scanner,exploit,common} tests/{unit,integration} examples tools; do
    if [ -d "$PROJECT_DIR/$dir" ]; then
        echo "✅ Directory exists: $dir"
    else
        echo "❌ Missing directory: $dir"
        mkdir -p "$PROJECT_DIR/$dir"
        echo "  └─ Created directory: $dir"
    fi
done

echo -e "\nVerification complete!"