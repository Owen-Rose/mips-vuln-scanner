# Edit tools/build.sh
cat > tools/build.sh << 'EOF'
#!/bin/bash

# Set project root directory
PROJECT_ROOT=~/mips-dev/mips-projects/mips-vuln-scanner

# Compile all source files
for file in ${PROJECT_ROOT}/src/**/*.asm; do
    echo "Compiling $file..."
    ~/mips-dev/tools/mars nc "$file"
done
EOF