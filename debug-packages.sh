#!/usr/bin/env bash

# Package Installation Debug Script
# Run this on your target machine to diagnose package installation issues

echo "=== Package Installation Debug ==="
echo ""

echo "1. Checking if extra repository is enabled..."
if grep -q "^\[extra\]" /etc/pacman.conf; then
    echo "✓ [extra] repository is enabled"
    grep -A2 "^\[extra\]" /etc/pacman.conf
else
    echo "✗ [extra] repository NOT found enabled"
    if grep -q "^#\[extra\]" /etc/pacman.conf; then
        echo "  Found commented out - needs uncommenting"
    else
        echo "  Not found at all in pacman.conf"
    fi
fi
echo ""

echo "2. Checking mirrorlist..."
mirror_count=$(grep -c "^Server" /etc/pacman.d/mirrorlist 2>/dev/null || echo "0")
echo "Active mirrors: $mirror_count"
if [ "$mirror_count" -lt 3 ]; then
    echo "⚠ Warning: Only $mirror_count mirrors - may cause issues"
fi
echo ""

echo "3. Checking package database sync status..."
if [ -d /var/lib/pacman/sync/ ]; then
    ls -lh /var/lib/pacman/sync/ | grep "extra.db"
else
    echo "✗ Sync directory not found"
fi
echo ""

echo "4. Testing package search for problematic packages..."
echo ""
echo "Searching for 'ttf-nerd-fonts-symbols':"
pacman -Ss ttf-nerd-fonts-symbols || echo "✗ Package not found in search"
echo ""
echo "Searching for 'imagemagick':"
pacman -Ss imagemagick || echo "✗ Package not found in search"
echo ""

echo "5. Checking pacman cache..."
ls -lh /var/cache/pacman/pkg/ | head -5
echo ""

echo "6. Testing manual install of ttf-nerd-fonts-symbols..."
echo "Running: sudo pacman -S --noconfirm ttf-nerd-fonts-symbols"
sudo pacman -S --noconfirm ttf-nerd-fonts-symbols 2>&1 | tee /tmp/package-install-test.log
echo ""

echo "7. Full pacman.conf:"
cat /etc/pacman.conf
echo ""

echo "=== Debug Complete ==="
echo "If package install failed above, check /tmp/package-install-test.log"
