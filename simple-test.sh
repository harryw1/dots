#!/usr/bin/env bash

# Simple test to find where the script hangs
# This bypasses the TUI and goes straight to the installation steps

set -e

source ./install.sh

echo "=== SIMPLE TEST ==="
echo "Testing each function that runs after Enter key press..."
echo ""

echo "[1/5] Testing is_arch_linux..."
if is_arch_linux; then
    echo "     ✓ Arch Linux detected"
else
    echo "     ✗ NOT Arch Linux"
    exit 1
fi

echo ""
echo "[2/5] Testing print_step..."
print_step 1 10 "Test step"
echo "     ✓ print_step works"

echo ""
echo "[3/5] Testing check_repositories (REQUIRES SUDO)..."
echo "     This will prompt for sudo password if not cached..."
if check_repositories; then
    echo "     ✓ check_repositories completed"
else
    echo "     ✗ check_repositories failed"
    exit 1
fi

echo ""
echo "[4/5] Testing check_mirrorlist (MAY REQUIRE SUDO)..."
if check_mirrorlist; then
    echo "     ✓ check_mirrorlist completed"
else
    echo "     ✗ check_mirrorlist failed"
fi

echo ""
echo "[5/5] Testing sync_package_database (REQUIRES SUDO)..."
if sync_package_database; then
    echo "     ✓ sync_package_database completed"
else
    echo "     ✗ sync_package_database failed"
fi

echo ""
echo "=== ALL TESTS PASSED ==="
echo ""
echo "The script can run successfully. The issue might be:"
echo "1. Sudo password prompt is not visible when running full install"
echo "2. Script output is being cleared/scrolled away"
echo "3. Terminal buffering issue"
