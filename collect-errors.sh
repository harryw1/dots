#!/usr/bin/env bash

# Debug/Error Collection Script
# Collects configuration errors and diagnostics for troubleshooting

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/debug-output.txt"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Initialize output file
cat > "$OUTPUT_FILE" << EOF
================================================================================
DOTFILES DEBUG OUTPUT
Generated: $TIMESTAMP
================================================================================

EOF

# Function to add section to output
add_section() {
    local title="$1"
    local command="$2"

    echo "" >> "$OUTPUT_FILE"
    echo "--------------------------------------------------------------------------------" >> "$OUTPUT_FILE"
    echo "$title" >> "$OUTPUT_FILE"
    echo "--------------------------------------------------------------------------------" >> "$OUTPUT_FILE"

    if eval "$command" >> "$OUTPUT_FILE" 2>&1; then
        echo "[Command completed successfully]" >> "$OUTPUT_FILE"
    else
        echo "[Command failed or returned errors - see output above]" >> "$OUTPUT_FILE"
    fi
}

print_info "Collecting system and configuration diagnostics..."
echo ""

# System Information
print_info "Collecting system information..."
add_section "SYSTEM INFORMATION" "uname -a"
add_section "KERNEL VERSION" "uname -r"
add_section "OS RELEASE" "cat /etc/os-release"

# Package versions
print_info "Collecting package versions..."
add_section "HYPRLAND VERSION" "hyprctl version"
add_section "WAYBAR VERSION" "waybar --version"
add_section "KITTY VERSION" "kitty --version"
add_section "ROFI VERSION" "rofi -version"

# Hyprland Configuration Check
print_info "Checking Hyprland configuration..."
add_section "HYPRLAND CONFIG VALIDATION" "hyprctl reload"

# Check if configs exist
print_info "Verifying configuration files..."
add_section "HYPRLAND CONFIG FILES" "ls -la ~/.config/hypr/"
add_section "HYPRLAND MODULAR CONFIGS" "ls -la ~/.config/hypr/conf/"

# Recent Hyprland logs
print_info "Collecting Hyprland logs..."
if [ -f "$HOME/.local/share/hyprland/hyprland.log" ]; then
    add_section "HYPRLAND LOG (last 100 lines)" "tail -n 100 ~/.local/share/hyprland/hyprland.log"
else
    echo "" >> "$OUTPUT_FILE"
    echo "Hyprland log file not found at ~/.local/share/hyprland/hyprland.log" >> "$OUTPUT_FILE"
fi

# System journal errors (if available)
print_info "Collecting system logs..."
if command -v journalctl &> /dev/null; then
    add_section "HYPRLAND JOURNAL ERRORS (last 50)" "journalctl --user -u hyprland -n 50 --no-pager 2>/dev/null || echo 'No Hyprland systemd unit found'"
    add_section "WAYBAR JOURNAL ERRORS (last 20)" "journalctl --user -u waybar -n 20 --no-pager 2>/dev/null || echo 'No Waybar systemd unit found'"
fi

# Check for common issues
print_info "Checking for common configuration issues..."
add_section "MONITOR CONFIGURATION" "hyprctl monitors"
add_section "ACTIVE WINDOWS" "hyprctl clients"
add_section "HYPRLAND ERRORS" "hyprctl getoption"

# Environment variables
add_section "WAYLAND ENVIRONMENT" "env | grep -E '(WAYLAND|XDG|QT_QPA)'"

echo "" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"
echo "END OF DEBUG OUTPUT" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"

print_success "Debug information collected: $OUTPUT_FILE"
echo ""
print_info "Next steps:"
echo "  1. Review the output: cat debug-output.txt"
echo "  2. Commit to git: git add debug-output.txt && git commit -m 'Add debug output'"
echo "  3. Push to remote: git push origin main"
echo ""
print_info "Or do it all at once:"
echo "  git add debug-output.txt && git commit -m 'Add debug output from target machine' && git push origin main"
echo ""
