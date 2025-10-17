#!/usr/bin/env bash

# DEBUG VERSION of Dotfiles Installation Script
# This version includes extensive logging to diagnose issues

# Enable debugging
set -x  # Print each command before execution
exec 2> >(tee -a "install-debug.log" >&2)  # Log stderr to file

echo "=== DEBUG MODE STARTED ===" | tee -a install-debug.log
echo "Time: $(date)" | tee -a install-debug.log
echo "Terminal: $TERM" | tee -a install-debug.log
echo "Columns: $(tput cols 2>/dev/null || echo 'UNKNOWN')" | tee -a install-debug.log
echo "Lines: $(tput lines 2>/dev/null || echo 'UNKNOWN')" | tee -a install-debug.log

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Catppuccin Frappe colors for TUI
FRAPPE_ROSEWATER='\033[38;2;242;213;207m'
FRAPPE_FLAMINGO='\033[38;2;238;190;190m'
FRAPPE_PINK='\033[38;2;244;184;228m'
FRAPPE_MAUVE='\033[38;2;202;158;230m'
FRAPPE_RED='\033[38;2;231;130;132m'
FRAPPE_MAROON='\033[38;2;234;153;156m'
FRAPPE_PEACH='\033[38;2;239;159;118m'
FRAPPE_YELLOW='\033[38;2;229;200;144m'
FRAPPE_GREEN='\033[38;2;166;209;137m'
FRAPPE_TEAL='\033[38;2;129;200;190m'
FRAPPE_SKY='\033[38;2;153;209;219m'
FRAPPE_SAPPHIRE='\033[38;2;133;193;220m'
FRAPPE_BLUE='\033[38;2;140;170;238m'
FRAPPE_LAVENDER='\033[38;2;186;187;241m'
FRAPPE_TEXT='\033[38;2;198;208;245m'
FRAPPE_SUBTEXT1='\033[38;2;181;191;226m'
FRAPPE_BASE='\033[38;2;48;52;70m'

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

# Terminal width for formatting
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

echo "DOTFILES_DIR=$DOTFILES_DIR" | tee -a install-debug.log
echo "TERM_WIDTH=$TERM_WIDTH" | tee -a install-debug.log

# Function to strip ANSI codes for length calculation
strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# TUI Helper Functions (DEBUG versions with logging)
draw_box() {
    echo "[DEBUG] draw_box called: title='$1', width='${2:-60}'" | tee -a install-debug.log
    local title="$1"
    local width=${2:-60}

    # Top border
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╔"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo "╗"

    # Title (if provided)
    if [ -n "$title" ]; then
        # Strip ANSI codes to calculate visible length
        local visible_title=$(strip_ansi "$title")
        local title_len=${#visible_title}
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$(( width - title_len - padding - 2 ))

        echo "[DEBUG] title_len=$title_len, padding=$padding, right_padding=$right_padding" | tee -a install-debug.log

        echo -n "║"
        printf ' %.0s' $(seq 1 $padding)
        echo -n "${BOLD}${FRAPPE_MAUVE}${title}${NC}${FRAPPE_LAVENDER}"
        printf ' %.0s' $(seq 1 $right_padding)
        echo "║"

        # Separator
        echo -n "╠"
        printf '═%.0s' $(seq 1 $((width - 2)))
        echo "╣"
    fi
    echo -en "${NC}"
}

draw_box_line() {
    local text="$1"
    local width=${2:-60}
    local color=${3:-$FRAPPE_TEXT}

    echo "[DEBUG] draw_box_line: text='$text', width=$width" | tee -a install-debug.log

    # Strip ANSI codes to get actual visible text length
    local visible_text=$(strip_ansi "$text")
    local text_length=${#visible_text}

    echo "[DEBUG] visible_text='$visible_text', text_length=$text_length" | tee -a install-debug.log

    # Calculate padding: width - text_length - 3 (for "║ " and " ║")
    local padding=$((width - text_length - 3))

    echo "[DEBUG] padding=$padding" | tee -a install-debug.log

    # Print the line
    echo -en "${FRAPPE_LAVENDER}║${NC} "
    echo -en "${text}"
    if [ $padding -gt 0 ]; then
        printf ' %.0s' $(seq 1 $padding)
    fi
    echo -e " ${FRAPPE_LAVENDER}║${NC}"
}

draw_box_bottom() {
    echo "[DEBUG] draw_box_bottom: width=${1:-60}" | tee -a install-debug.log
    local width=${1:-60}
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╚"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo "╝"
    echo -en "${NC}"
}

show_welcome() {
    echo "[DEBUG] show_welcome called" | tee -a install-debug.log
    clear

    # Calculate box width based on ASCII art
    # The HYPRLAND ASCII art is approximately 82 characters wide
    local ascii_width=82
    local box_width=$((ascii_width + 4))  # Add padding

    echo "[DEBUG] ascii_width=$ascii_width, box_width=$box_width" | tee -a install-debug.log

    echo ""
    draw_box "Hyprland Dotfiles Installer" $box_width
    draw_box_line "" $box_width

    # HYPRLAND ASCII art (plain text, colors applied via draw_box_line)
    draw_box_line "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗" $box_width
    draw_box_line "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗" $box_width
    draw_box_line "  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║" $box_width
    draw_box_line "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║" $box_width
    draw_box_line "  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝" $box_width
    draw_box_line "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝" $box_width
    draw_box_line "" $box_width
    draw_box_line "Catppuccin Frappe Theme • Modular Configuration" $box_width
    draw_box_line "" $box_width
    draw_box_line "${FRAPPE_PEACH}This installer will:${NC}" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Install all required packages" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Set up Hyprland, Waybar, Kitty, and more" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Configure Neovim with LazyVim" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Install Catppuccin wallpaper collection" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Create backups of existing configs" $box_width
    draw_box_line "" $box_width
    draw_box_line "${FRAPPE_YELLOW}⚠  ${FRAPPE_TEXT}Requires Arch Linux${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""

    echo "[DEBUG] About to prompt for Enter key" | tee -a install-debug.log
}

# Minimal main for testing TUI only
main() {
    echo "[DEBUG] main() started" | tee -a install-debug.log

    show_welcome

    echo "[DEBUG] After show_welcome, before read prompt" | tee -a install-debug.log
    echo -n "Press Enter to continue or Ctrl+C to cancel..."

    echo "[DEBUG] Waiting for read..." | tee -a install-debug.log
    read -r response
    echo "[DEBUG] Read returned: response='$response'" | tee -a install-debug.log

    echo ""
    echo "DEBUG: You pressed Enter! The script works."
    echo ""

    echo "[DEBUG] Test complete" | tee -a install-debug.log
    echo ""
    echo "=== DEBUG LOG SAVED TO: install-debug.log ==="
    echo ""
}

# Run the test
echo "[DEBUG] Starting main()" | tee -a install-debug.log
main
echo "[DEBUG] main() completed" | tee -a install-debug.log
