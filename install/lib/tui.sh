#!/usr/bin/env bash
# tui.sh - Terminal User Interface functions using gum
# Part of the modular dotfiles installation system

# Source theme configuration if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/gum_theme.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/gum_theme.sh"
fi

# Fallback ANSI colors for legacy compatibility (if colors.sh not sourced)
# These match Catppuccin Frappe Lavender
FRAPPE_LAVENDER="${FRAPPE_LAVENDER:-\033[38;2;186;187;241m}"
NC="${NC:-\033[0m}"

#############################################################################
# UTILITY FUNCTIONS
#############################################################################

strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

#############################################################################
# BOX DRAWING FUNCTIONS (GUM ADAPTERS)
#############################################################################

# Draw a box using gum style
# Note: The arguments are slightly different than the old implementation
# to better fit gum's API, but we keep the wrapper for compatibility
draw_box() {
    local title="$1"
    local width=${2:-60}

    if [ -n "$title" ]; then
        # If title is provided, we print it separately styled, then the box content would go below
        # Since the original draw_box was top border + title, this is a close approximation
        gum style \
            --border-foreground "$COLOR_LAVENDER" \
            --border double \
            --align center \
            --width "$width" \
            --padding "0 1" \
            "$title"
    fi
}

# Draw a line inside a box - in gum we usually just echo content or style it
# We'll adapt this to just print the text with side borders if needed,
# but gum style is block-based.
# For backward compatibility with the script's linear printing, we'll simulate it.
draw_box_line() {
    local text="$1"
    local width=${2:-60}

    # Strip ANSI for calculations (gum handles some ansi but we want to be safe)
    local visible_text=$(strip_ansi "$text")
    local text_length=${#visible_text}
    local padding=$((width - text_length - 4))

    # Use simple echo with colors to match the expected output format of the old script
    # since the old script built the box line by line.
    # Using gum style per line would create individual boxes.
    echo -en "${FRAPPE_LAVENDER}║${NC} "
    echo -en "${text}"
    if [ $padding -gt 0 ]; then
        printf ' %.0s' $(seq 1 $padding)
    fi
    echo -e " ${FRAPPE_LAVENDER}║${NC}"
}

draw_box_bottom() {
    local width=${1:-60}
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╚"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo -e "╝${NC}"
}

draw_progress_bar() {
    local current=$1
    local total=$2

    # Calculate percentage
    local percent=$((current * 100 / total))

    # Use gum format to display a progress-like indicator
    gum style --foreground "$COLOR_GREEN" "Progress: $percent%"
}

#############################################################################
# OUTPUT FUNCTIONS (GUM ENHANCED)
#############################################################################

print_step() {
    local step_num=$1
    local total_steps=$2
    local description="$3"

    echo ""
    gum style \
        --foreground "$COLOR_MAUVE" --border-foreground "$COLOR_SAPPHIRE" --border rounded --padding "0 1" \
        "Step $step_num/$total_steps: $description"
    echo ""
}

show_welcome() {
    clear

    # ASCII Art
    gum style \
        --foreground "$COLOR_MAUVE" --border double --border-foreground "$COLOR_LAVENDER" --padding "1 2" \
        "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗
  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝"

    echo ""
    gum style --foreground "$COLOR_TEXT" --align center "Catppuccin Frappe Theme • Modular Configuration"
    echo ""

    gum style --foreground "$COLOR_PEACH" "This installer will:"
    gum style --foreground "$COLOR_GREEN" "  ✓ Install all required packages"
    gum style --foreground "$COLOR_GREEN" "  ✓ Set up Hyprland, Waybar, Kitty, and more"
    gum style --foreground "$COLOR_GREEN" "  ✓ Configure Neovim with LazyVim"
    gum style --foreground "$COLOR_GREEN" "  ✓ Install Catppuccin wallpaper collection"
    gum style --foreground "$COLOR_GREEN" "  ✓ Create backups of existing configs"
    echo ""
    gum style --foreground "$COLOR_YELLOW" "⚠  Requires Arch Linux"
    echo ""
}

print_info() {
    gum style --foreground "$COLOR_BLUE" "● $1"
}

print_success() {
    gum style --foreground "$COLOR_GREEN" "✓ $1"
}

print_warning() {
    gum style --foreground "$COLOR_YELLOW" "⚠ $1"
}

print_error() {
    gum style --foreground "$COLOR_RED" "✗ $1"
}
