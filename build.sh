#!/usr/bin/env bash
# this_file: build.sh

set -euo pipefail

# Quick build script for development
echo "Building macdefaultbrowser..."

# Use the comprehensive build script
./scripts/build-and-test.sh --release

echo "Build completed. Binary location: macdefaultbrowser/build/macdefaultbrowser"

# Test the binary
if [[ -f "macdefaultbrowser/build/macdefaultbrowser" ]]; then
    echo "Testing binary:"
    ./macdefaultbrowser/build/macdefaultbrowser --version
else
    echo "Error: Binary not found at expected location"
    exit 1
fi
