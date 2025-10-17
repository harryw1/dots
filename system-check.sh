#!/usr/bin/env bash

# Comprehensive System Diagnostic Script
# Checks all components, services, configurations, and logs for issues

set +e  # Don't exit on errors - we want to collect all diagnostics

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/system-check-output.txt"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Initialize output file
cat > "$OUTPUT_FILE" << EOF
╔════════════════════════════════════════════════════════════════════════════╗
║                     COMPREHENSIVE SYSTEM DIAGNOSTIC                        ║
║                          Generated: $TIMESTAMP                             ║
╚════════════════════════════════════════════════════════════════════════════╝

EOF

# Function to add section to output
add_section() {
    local title="$1"
    local command="$2"
    local show_in_terminal="${3:-false}"

    echo "" >> "$OUTPUT_FILE"
    echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
    echo "$title" >> "$OUTPUT_FILE"
    echo "═══════════════════════════════════════════════════════════════════════════════" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    if [ "$show_in_terminal" = "true" ]; then
        eval "$command" 2>&1 | tee -a "$OUTPUT_FILE"
    else
        eval "$command" >> "$OUTPUT_FILE" 2>&1
    fi

    echo "" >> "$OUTPUT_FILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check process status
check_process() {
    local process_name="$1"
    if pgrep -x "$process_name" > /dev/null; then
        print_success "$process_name is running (PID: $(pgrep -x "$process_name"))"
        echo "$process_name: RUNNING (PID: $(pgrep -x "$process_name"))" >> "$OUTPUT_FILE"
        return 0
    else
        print_error "$process_name is NOT running"
        echo "$process_name: NOT RUNNING" >> "$OUTPUT_FILE"
        return 1
    fi
}

# Function to validate JSON/config file
validate_config() {
    local file="$1"
    local validator="$2"

    if [ ! -f "$file" ]; then
        print_warning "Config not found: $file"
        return 1
    fi

    if [ -n "$validator" ]; then
        if eval "$validator" 2>&1 | grep -qi "error\|failed\|invalid"; then
            print_error "Config has errors: $file"
            return 1
        else
            print_success "Config valid: $file"
            return 0
        fi
    else
        print_success "Config exists: $file"
        return 0
    fi
}

################################################################################
# SYSTEM INFORMATION
################################################################################

print_header "SYSTEM INFORMATION"
print_info "Collecting system information..."

add_section "Hostname" "hostname"
add_section "Kernel and OS" "uname -a"
add_section "OS Release" "cat /etc/os-release"
add_section "Current User" "whoami"
add_section "Display Server" "echo \$XDG_SESSION_TYPE"
add_section "Current Desktop" "echo \$XDG_CURRENT_DESKTOP"

################################################################################
# PACKAGE INSTALLATION STATUS
################################################################################

print_header "PACKAGE INSTALLATION STATUS"
print_info "Checking installed packages..."

# Core packages
CORE_PACKAGES=(
    "hyprland"
    "waybar"
    "kitty"
    "rofi"
    "mako"
    "hyprpaper"
    "hypridle"
    "hyprlock"
    "pipewire"
    "wireplumber"
    "polkit-gnome"
    "thunar"
    "firefox"
    "neovim"
)

{
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "INSTALLED PACKAGE VERSIONS"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""

    for pkg in "${CORE_PACKAGES[@]}"; do
        if pacman -Q "$pkg" &> /dev/null; then
            version=$(pacman -Q "$pkg" 2>/dev/null)
            echo "✓ $version"
            print_success "$version"
        else
            echo "✗ $pkg: NOT INSTALLED"
            print_error "$pkg: NOT INSTALLED"
        fi
    done
} >> "$OUTPUT_FILE"

# Check AUR packages
print_info "Checking AUR packages..."
{
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "AUR PACKAGES"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""

    AUR_PACKAGES=("waypaper" "quickwall" "swayosd-git" "visual-studio-code-bin")
    for pkg in "${AUR_PACKAGES[@]}"; do
        if pacman -Q "$pkg" &> /dev/null; then
            version=$(pacman -Q "$pkg" 2>/dev/null)
            echo "✓ $version"
        else
            echo "✗ $pkg: NOT INSTALLED"
        fi
    done
} >> "$OUTPUT_FILE"

################################################################################
# SERVICE AND PROCESS STATUS
################################################################################

print_header "SERVICE AND PROCESS STATUS"
print_info "Checking running services and processes..."

{
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "PROCESS STATUS"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
} >> "$OUTPUT_FILE"

# Check critical processes
PROCESSES=("Hyprland" "waybar" "mako" "hyprpaper" "hypridle" "pipewire" "wireplumber" "polkit-gnome-authentication-agent-1")
for process in "${PROCESSES[@]}"; do
    check_process "$process"
done

# PipeWire status
if command_exists systemctl; then
    print_info "Checking PipeWire systemd services..."
    add_section "PipeWire Service Status" "systemctl --user status pipewire 2>&1 | head -20"
    add_section "PipeWire Pulse Service Status" "systemctl --user status pipewire-pulse 2>&1 | head -20"
    add_section "WirePlumber Service Status" "systemctl --user status wireplumber 2>&1 | head -20"
fi

################################################################################
# CONFIGURATION VALIDATION
################################################################################

print_header "CONFIGURATION VALIDATION"
print_info "Validating configuration files..."

# Hyprland
print_info "Checking Hyprland configuration..."
if command_exists hyprctl; then
    add_section "Hyprland Config Validation" "hyprctl reload" true
    add_section "Hyprland Monitors" "hyprctl monitors"
    add_section "Hyprland Active Windows" "hyprctl clients | head -50"
else
    print_error "hyprctl not found - Hyprland may not be installed"
fi

# Waybar
print_info "Checking Waybar configuration..."
if [ -f "$HOME/.config/waybar/config" ]; then
    # Try to validate JSON if it's JSON
    if file "$HOME/.config/waybar/config" | grep -q "JSON"; then
        if command_exists jq; then
            validate_config "$HOME/.config/waybar/config" "jq empty ~/.config/waybar/config"
        else
            print_warning "jq not installed - cannot validate Waybar JSON config"
        fi
    else
        print_success "Waybar config exists: ~/.config/waybar/config"
    fi
    add_section "Waybar Config Content" "cat ~/.config/waybar/config"
else
    print_error "Waybar config not found: ~/.config/waybar/config"
fi

if [ -f "$HOME/.config/waybar/style.css" ]; then
    print_success "Waybar style exists: ~/.config/waybar/style.css"
    add_section "Waybar Style Content" "head -50 ~/.config/waybar/style.css"
else
    print_error "Waybar style not found: ~/.config/waybar/style.css"
fi

# Mako
print_info "Checking Mako configuration..."
if [ -f "$HOME/.config/mako/config" ]; then
    print_success "Mako config exists: ~/.config/mako/config"
    add_section "Mako Config Content" "cat ~/.config/mako/config"
else
    print_warning "Mako config not found: ~/.config/mako/config"
fi

# Hyprpaper
print_info "Checking Hyprpaper configuration..."
if [ -f "$HOME/.config/hypr/hyprpaper.conf" ]; then
    print_success "Hyprpaper config exists"
    add_section "Hyprpaper Config Content" "cat ~/.config/hypr/hyprpaper.conf"
    add_section "Hyprpaper Loaded Wallpapers" "hyprctl hyprpaper listloaded 2>&1 || echo 'hyprpaper not responding'"
else
    print_warning "Hyprpaper config not found: ~/.config/hypr/hyprpaper.conf"
fi

# Check symlinks
print_info "Verifying configuration symlinks..."
{
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "CONFIGURATION SYMLINKS"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""

    CONFIGS=("hypr" "waybar" "kitty" "rofi" "mako" "zathura")
    for config in "${CONFIGS[@]}"; do
        if [ -L "$HOME/.config/$config" ]; then
            target=$(readlink "$HOME/.config/$config")
            echo "✓ $config -> $target"
        elif [ -d "$HOME/.config/$config" ]; then
            echo "⚠ $config exists but is NOT a symlink (may be standalone)"
        else
            echo "✗ $config: NOT FOUND"
        fi
    done
} >> "$OUTPUT_FILE"

################################################################################
# LOG FILES AND ERRORS
################################################################################

print_header "LOG FILES AND RECENT ERRORS"
print_info "Collecting log files..."

# Hyprland log
if [ -f "$HOME/.local/share/hyprland/hyprland.log" ]; then
    print_success "Found Hyprland log"
    add_section "Hyprland Log (last 100 lines)" "tail -n 100 ~/.local/share/hyprland/hyprland.log"
    add_section "Hyprland Errors (last 50)" "grep -i 'error\|warn\|failed' ~/.local/share/hyprland/hyprland.log | tail -50 || echo 'No errors found'"
else
    print_warning "Hyprland log not found"
fi

# Journal logs
if command_exists journalctl; then
    print_info "Collecting journal logs..."
    add_section "User Journal Errors (last 100)" "journalctl --user --priority=err -n 100 --no-pager || echo 'No errors found'"
    add_section "System Journal Errors (last 100)" "sudo journalctl --priority=err -n 100 --no-pager 2>/dev/null || echo 'Cannot access system journal'"
fi

# Waybar specific logs
add_section "Waybar Output (if running)" "pkill -USR2 waybar 2>&1 && sleep 1 && journalctl --user -u waybar -n 50 --no-pager 2>/dev/null || echo 'No waybar journal logs available'"

################################################################################
# ENVIRONMENT VARIABLES
################################################################################

print_header "ENVIRONMENT VARIABLES"
print_info "Collecting environment variables..."

add_section "Wayland Environment" "env | grep -E '(WAYLAND|XDG|DISPLAY|QT_QPA|GDK|XCURSOR)' | sort"
add_section "Path" "echo \$PATH"

################################################################################
# FILE PERMISSIONS
################################################################################

print_header "FILE PERMISSIONS"
print_info "Checking file permissions..."

add_section "Config Directory Permissions" "ls -la ~/.config/ | head -20"
add_section "Hyprland Config Permissions" "ls -laR ~/.config/hypr/ 2>/dev/null | head -50 || echo 'Cannot access hypr config'"

################################################################################
# DISPLAY AND GRAPHICS
################################################################################

print_header "DISPLAY AND GRAPHICS"
print_info "Checking display and graphics information..."

add_section "Monitors (Hyprctl)" "hyprctl monitors"
add_section "Graphics Info (lspci)" "lspci | grep -i 'vga\|3d\|display'"
add_section "Loaded DRI Modules" "ls /dev/dri/ 2>/dev/null || echo 'No DRI devices found'"

################################################################################
# NETWORK AND CONNECTIVITY
################################################################################

print_header "NETWORK STATUS"
print_info "Checking network connectivity..."

add_section "Network Interfaces" "ip addr show"
add_section "DNS Configuration" "cat /etc/resolv.conf"
add_section "Connectivity Test" "ping -c 2 8.8.8.8 2>&1 || echo 'Ping failed'"

################################################################################
# COMMON ISSUES CHECK
################################################################################

print_header "COMMON ISSUES CHECK"
print_info "Checking for common issues..."

{
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "COMMON ISSUES CHECKLIST"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""

    # Check if Wayland is running
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        echo "✓ Running on Wayland"
    else
        echo "✗ NOT running on Wayland (current: $XDG_SESSION_TYPE)"
    fi

    # Check if Hyprland is current desktop
    if echo "$XDG_CURRENT_DESKTOP" | grep -qi "hyprland"; then
        echo "✓ Hyprland is current desktop"
    else
        echo "✗ Hyprland is NOT current desktop (current: $XDG_CURRENT_DESKTOP)"
    fi

    # Check for config directory
    if [ -d "$HOME/.config/hypr" ]; then
        echo "✓ Hyprland config directory exists"
    else
        echo "✗ Hyprland config directory NOT FOUND"
    fi

    # Check for required binaries
    REQUIRED_BINS=("hyprctl" "waybar" "mako" "rofi")
    for bin in "${REQUIRED_BINS[@]}"; do
        if command_exists "$bin"; then
            echo "✓ $bin found in PATH"
        else
            echo "✗ $bin NOT FOUND in PATH"
        fi
    done

    # Check XDG portal
    if pgrep -x "xdg-desktop-portal" > /dev/null; then
        echo "✓ xdg-desktop-portal is running"
    else
        echo "⚠ xdg-desktop-portal is not running (may affect some apps)"
    fi

} >> "$OUTPUT_FILE"

################################################################################
# SUMMARY
################################################################################

{
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                            END OF DIAGNOSTIC                               ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""
} >> "$OUTPUT_FILE"

print_header "DIAGNOSTIC COMPLETE"
print_success "Full diagnostic report saved to: $OUTPUT_FILE"
echo ""
print_info "Review the output:"
echo "  ${CYAN}less $OUTPUT_FILE${NC}"
echo ""
print_info "To share for troubleshooting:"
echo "  ${CYAN}git add system-check-output.txt${NC}"
echo "  ${CYAN}git commit -m 'Add system diagnostic output'${NC}"
echo "  ${CYAN}git push origin main${NC}"
echo ""
print_info "Or do it all at once:"
echo "  ${CYAN}git add system-check-output.txt && git commit -m 'Add system diagnostic' && git push${NC}"
echo ""
