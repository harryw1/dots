#!/bin/bash
# Caps Lock status indicator for hyprlock

# Check if Caps Lock is on
if xset q | grep "Caps Lock:   on" > /dev/null 2>&1; then
    echo " CAPS LOCK"
else
    echo ""
fi
