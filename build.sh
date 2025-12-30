#!/bin/bash

# Build script for UI Builder

echo "Building UI Builder..."

# Check if V compiler is installed
if ! command -v v &> /dev/null; then
    echo "Error: V compiler not found. Please install V from https://vlang.io"
    exit 1
fi

# Build the application
v -o ui-builder main.v

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can run the application with: ./ui-builder"
else
    echo "Build failed!"
    exit 1
fi
