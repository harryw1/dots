#!/bin/bash
# Battery status indicator for hyprlock

# Check if battery exists
if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
    # Try BAT0 first, then BAT1
    if [ -d /sys/class/power_supply/BAT0 ]; then
        BATTERY="BAT0"
    else
        BATTERY="BAT1"
    fi

    CAPACITY=$(cat /sys/class/power_supply/$BATTERY/capacity)
    STATUS=$(cat /sys/class/power_supply/$BATTERY/status)

    # Choose icon based on status
    if [ "$STATUS" = "Charging" ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 90 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 40 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 20 ]; then
        ICON=""
    else
        ICON=""
    fi

    echo "$ICON $CAPACITY%"
else
    # No battery detected
    echo ""
fi
