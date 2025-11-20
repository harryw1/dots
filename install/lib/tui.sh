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

# Function to check for gum
has_gum() {
    command -v gum &> /dev/null
}

#############################################################################
# UTILITY FUNCTIONS
#############################################################################

strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

#############################################################################
# BOX DRAWING FUNCTIONS (GUM ADAPTERS)
#############################################################################

draw_box() {
    local title="$1"
    local width=${2:-60}

    if [ -n "$title" ]; then
        if has_gum; then
            gum style \
                --border-foreground "$COLOR_LAVENDER" \
                --border double \
                --align center \
                --width "$width" \
                --padding "0 1" \
                "$title"
        else
            echo "== $title =="
        fi
    fi
}

draw_box_line() {
    local text="$1"
    local width=${2:-60}

    # Strip ANSI for calculations (gum handles some ansi but we want to be safe)
    local visible_text=$(strip_ansi "$text")
    local text_length=${#visible_text}
    local padding=$((width - text_length - 4))

    # Use simple echo with colors to match the expected output format of the old script
    # since the old script built the box line by line.
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

    if has_gum; then
        gum style --foreground "$COLOR_GREEN" "Progress: $percent%"
    else
        echo "Progress: $percent%"
    fi
}

#############################################################################
# OUTPUT FUNCTIONS (GUM ENHANCED)
#############################################################################

print_step() {
    local step_num=$1
    local total_steps=$2
    local description="$3"

    echo ""
    if has_gum; then
        gum style \
            --foreground "$COLOR_MAUVE" --border-foreground "$COLOR_SAPPHIRE" --border rounded --padding "0 1" \
            "Step $step_num/$total_steps: $description"
    else
        echo ">> Step $step_num/$total_steps: $description"
    fi
    echo ""
}

show_welcome() {
    clear

    if has_gum; then
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
    else
        echo "Hyprland Dotfiles Installer (TUI disabled or gum missing)"
    fi
}

print_info() {
    if has_gum; then
        gum style --foreground "$COLOR_BLUE" "● $1"
    else
        echo -e "\033[0;34m●\033[0m $1"
    fi
}

print_success() {
    if has_gum; then
        gum style --foreground "$COLOR_GREEN" "✓ $1"
    else
        echo -e "\033[0;32m✓\033[0m $1"
    fi
}

print_warning() {
    if has_gum; then
        gum style --foreground "$COLOR_YELLOW" "⚠ $1"
    else
        echo -e "\033[1;33m⚠\033[0m $1"
    fi
}

print_error() {
    if has_gum; then
        gum style --foreground "$COLOR_RED" "✗ $1"
    else
        echo -e "\033[0;31m✗\033[0m $1"
    fi
}
