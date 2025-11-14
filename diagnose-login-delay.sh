#!/usr/bin/env bash
# Diagnostic script to identify slow login issues from lock screen

set -e

echo "=========================================="
echo "Login Delay Diagnostic Tool"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_section() {
    echo ""
    echo -e "${GREEN}=== $1 ===${NC}"
    echo ""
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_ok() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 1. Check fingerprint authentication configuration
print_section "1. Fingerprint Authentication (fprintd)"
if systemctl is-active --quiet fprintd.service; then
    print_ok "fprintd service is running"
else
    print_warning "fprintd service is not running (may cause delays if waiting for fingerprint)"
fi

if command -v fprintd-list &> /dev/null; then
    ENROLLED=$(fprintd-list "$USER" 2>/dev/null | wc -l)
    if [ "$ENROLLED" -gt 0 ]; then
        print_ok "Fingerprints enrolled: $ENROLLED"
    else
        print_warning "No fingerprints enrolled - authentication will always fall back to password"
    fi
else
    print_warning "fprintd-list not found"
fi

# Check PAM configuration
if [ -f /etc/pam.d/system-local-login ]; then
    if grep -q "pam_fprintd.so" /etc/pam.d/system-local-login; then
        print_ok "Fingerprint PAM module configured in system-local-login"
        TIMEOUT=$(grep -oP "timeout=\K[0-9]+" /etc/pam.d/system-local-login || echo "default (30s)")
        echo "  Timeout: ${TIMEOUT}s"
    fi
fi

# 2. Check SDDM configuration
print_section "2. SDDM Configuration"
if [ -f /etc/sddm.conf.d/theme.conf ]; then
    THEME=$(grep "^Current=" /etc/sddm.conf.d/theme.conf | cut -d'=' -f2)
    print_ok "SDDM theme: $THEME"
else
    print_warning "SDDM theme config not found at /etc/sddm.conf.d/theme.conf"
fi

# Check for slow SDDM settings
if [ -f /etc/sddm.conf ]; then
    if grep -q "SessionCommand=" /etc/sddm.conf; then
        print_warning "Custom SessionCommand found - may add delay"
    fi
fi

# 3. Check Hyprland autostart applications
print_section "3. Hyprland Autostart Applications"
AUTOSTART_FILE="$HOME/.config/hyprland/conf/autostart.conf"
if [ -f "$AUTOSTART_FILE" ]; then
    EXEC_COUNT=$(grep -c "^exec-once" "$AUTOSTART_FILE" || echo "0")
    print_ok "Autostart commands found: $EXEC_COUNT"
    
    # Check for potentially slow commands
    if grep -q "waypaper --restore" "$AUTOSTART_FILE"; then
        print_warning "waypaper --restore may be slow (checking filesystem/network)"
    fi
    
    if grep -q "generate-waybar-css.sh" "$AUTOSTART_FILE"; then
        SCRIPT_PATH=$(grep "generate-waybar-css.sh" "$AUTOSTART_FILE" | grep -oP "exec-once = \K[^ ]+")
        if [ -f "$SCRIPT_PATH" ]; then
            print_ok "Waybar CSS generation script exists"
        else
            print_error "Waybar CSS generation script not found: $SCRIPT_PATH"
        fi
    fi
    
    # Count gsettings commands (multiple can be slow)
    GSETTINGS_COUNT=$(grep -c "gsettings set" "$AUTOSTART_FILE" || echo "0")
    if [ "$GSETTINGS_COUNT" -gt 5 ]; then
        print_warning "Many gsettings commands ($GSETTINGS_COUNT) - consider batching"
    fi
else
    print_error "Autostart config not found: $AUTOSTART_FILE"
fi

# 4. Check systemd user services
print_section "4. Systemd User Services"
ENABLED_SERVICES=$(systemctl --user list-unit-files --type=service --state=enabled 2>/dev/null | tail -n +2 | wc -l)
print_ok "Enabled user services: $ENABLED_SERVICES"

# Check for slow-starting services
if systemctl --user is-enabled wireplumber.service &> /dev/null; then
    print_ok "wireplumber.service is enabled (normal)"
fi

# 5. Check PAM for network lookups
print_section "5. PAM Network Lookups"
if [ -f /etc/nsswitch.conf ]; then
    if grep -qE "^(passwd|group|shadow):.*ldap|nis|winbind" /etc/nsswitch.conf; then
        print_warning "Network-based user lookups configured (may cause delays)"
    else
        print_ok "No network-based user lookups configured"
    fi
fi

# 6. Check for slow filesystem mounts
print_section "6. Filesystem Mounts"
# Check for actual network filesystems (exclude normal FUSE mounts like fusectl, portal)
NETWORK_FS=$(mount | grep -E "type nfs|type cifs" || true)
FUSE_NETWORK=$(mount | grep -E "type fuse" | grep -vE "fusectl|portal|gvfsd" || true)
if [ -n "$NETWORK_FS" ] || [ -n "$FUSE_NETWORK" ]; then
    print_warning "Network filesystems mounted - may cause delays"
    [ -n "$NETWORK_FS" ] && echo "$NETWORK_FS"
    [ -n "$FUSE_NETWORK" ] && echo "$FUSE_NETWORK"
else
    print_ok "No network filesystems detected (fusectl/portal are normal)"
fi

# 7. Check journal logs for recent login delays
print_section "7. Recent Login/Session Issues"
echo "Checking systemd journal for recent errors..."
RECENT_ERRORS=$(journalctl --since "1 hour ago" -p err --no-pager 2>/dev/null | grep -iE "sddm|login|session|pam" | tail -5 || echo "None")
if [ "$RECENT_ERRORS" != "None" ] && [ -n "$RECENT_ERRORS" ]; then
    print_warning "Recent errors found:"
    echo "$RECENT_ERRORS"
else
    print_ok "No recent login-related errors in journal"
fi

# 8. Check for blocking processes
print_section "8. Potential Blocking Processes"
if command -v systemd-analyze &> /dev/null; then
    echo "User session startup time:"
    systemd-analyze --user blame 2>/dev/null | head -10 || echo "Unable to analyze user services"
fi

# 9. Recommendations
print_section "9. Recommendations"
echo "Based on the checks above, consider:"
echo ""
echo "1. If fingerprint auth is slow:"
echo "   - Check if fprintd is waiting for input: journalctl -u fprintd -f"
echo "   - Consider disabling fingerprint on lock screen if not needed"
echo "   - Use password directly if fingerprint times out"
echo ""
echo "2. If autostart is slow:"
echo "   - Check if waypaper --restore is slow: time waypaper --restore"
echo "   - Verify waybar CSS script exists and is fast"
echo "   - Consider batching gsettings commands"
echo ""
echo "3. To measure actual login time:"
echo "   - Add timing to Hyprland autostart: exec-once = date +%s > /tmp/login_start"
echo "   - Check time difference in your shell startup"
echo ""
echo "4. Check SDDM logs:"
echo "   - journalctl -u sddm -f"
echo "   - journalctl -u sddm --since '10 minutes ago'"
echo ""

echo "=========================================="
echo "Diagnostic complete"
echo "=========================================="

