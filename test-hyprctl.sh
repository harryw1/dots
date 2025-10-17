#!/usr/bin/env bash

# Quick test to see if hyprctl check is blocking

echo "=== Testing hyprctl availability ==="
echo ""

if command -v hyprctl &> /dev/null; then
    echo "✓ hyprctl IS installed"
    echo "  Location: $(command -v hyprctl)"
else
    echo "✗ hyprctl NOT found"
    echo ""
    echo "This means the installer will prompt:"
    echo '  "hyprctl not found - Hyprland may not be installed"'
    echo '  "Continue anyway? (y/N) "'
    echo ""
    echo "The script is likely waiting for you to type 'y' or 'n'"
fi

echo ""
echo "=== SOLUTION ==="
echo "Run the installer with -f flag to skip this check:"
echo "  ./install.sh -f"
echo ""
