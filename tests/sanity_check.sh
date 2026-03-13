#!/bin/bash

set -e

echo "Running basic sanity checks..."

# Test that build scripts exist
if [ ! -f "build.sh" ] || [ ! -f "buildall.sh" ]; then
    echo "Error: Build scripts not found."
    exit 1
fi

echo "Checking if makefiles exist..."
if [ ! -f "aircast/Makefile" ] || [ ! -f "airupnp/Makefile" ]; then
    echo "Error: Makefiles not found."
    exit 1
fi

echo "Checking for essential configuration scripts..."
if [ ! -f "scripts/proxmox-pve.sh" ] || [ ! -f "scripts/install-proxmox.sh" ]; then
    echo "Error: Essential scripts not found."
    exit 1
fi

echo "Compiling and running test_util.c..."
gcc tests/test_util.c common/crosstools/src/cross_util.c -I common/crosstools/src/ -I common -o tests/test_util
./tests/test_util

echo "Sanity check passed!"
exit 0
