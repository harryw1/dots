#!/usr/bin/env bash
# tui.sh - Terminal User Interface functions
# Part of the modular dotfiles installation system
# Provides box drawing, progress bars, and formatted output

# Requires: colors.sh to be sourced first

# Get terminal width (fallback to 80 if tput fails)
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

#############################################################################
# UTILITY FUNCTIONS
#############################################################################

# Strip ANSI color codes from a string for accurate length calculation
#
# Arguments:
#   $1 - String with ANSI codes
#
# Returns:
#   String with ANSI codes removed (printed to stdout)
#
# Example:
#   visible_text=$(strip_ansi "$colored_text")
strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

#############################################################################
# BOX DRAWING FUNCTIONS
#############################################################################

# Draw the top border of a box with optional title
#
# Creates a box using Unicode box-drawing characters in Catppuccin Frappe
# Lavender color. If a title is provided, it's centered with a separator line.
#
# Arguments:
#   $1 - Optional title text (can include ANSI color codes)
#   $2 - Box width in characters (default: 60)
#
# Example:
#   draw_box "Installation Progress" 70
#   draw_box "" 50  # No title
draw_box() {
    local title="$1"
    local width=${2:-60}

    # Top border
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╔"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo -e "╗${NC}"

    # Title (if provided)
    if [ -n "$title" ]; then
        # Strip ANSI codes to calculate visible length
        local visible_title=$(strip_ansi "$title")
        local title_len=${#visible_title}
        # Account for: ║ (1) + title + ║ (1) = title_len + 2
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$(( width - title_len - padding - 2 ))

        echo -en "${FRAPPE_LAVENDER}║${NC}"
        printf ' %.0s' $(seq 1 $padding)
        echo -en "${BOLD}${FRAPPE_MAUVE}${title}${NC}"
        printf ' %.0s' $(seq 1 $right_padding)
        echo -e "${FRAPPE_LAVENDER}║${NC}"

        # Separator
        echo -en "${FRAPPE_LAVENDER}"
        echo -n "╠"
        printf '═%.0s' $(seq 1 $((width - 2)))
        echo -e "╣${NC}"
    fi
}

# Draw a content line inside a box
#
# Draws a line of text inside a box with proper borders and padding.
# Automatically calculates padding to fill the box width.
#
# Arguments:
#   $1 - Text to display (can include ANSI color codes)
#   $2 - Box width in characters (default: 60)
#   $3 - Text color (optional, default: FRAPPE_TEXT)
#
# Example:
#   draw_box_line "  Installing packages..." 70
#   draw_box_line "" 70  # Empty line
draw_box_line() {
    local text="$1"
    local width=${2:-60}
    local color=${3:-$FRAPPE_TEXT}

    # Strip ANSI codes to get actual visible text length
    local visible_text=$(strip_ansi "$text")
    local text_length=${#visible_text}

    # Calculate padding: width - text_length - 4 (for "║ " and " ║" = 4 chars total)
    local padding=$((width - text_length - 4))

    # Print the line
    echo -en "${FRAPPE_LAVENDER}║${NC} "
    echo -en "${text}"
    if [ $padding -gt 0 ]; then
        printf ' %.0s' $(seq 1 $padding)
    fi
    echo -e " ${FRAPPE_LAVENDER}║${NC}"
}

# Draw the bottom border of a box
#
# Arguments:
#   $1 - Box width in characters (default: 60)
#
# Example:
#   draw_box_bottom 70
draw_box_bottom() {
    local width=${1:-60}
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╚"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo -e "╝${NC}"
}

# Draw a progress bar with percentage
#
# Creates a visual progress bar in Catppuccin Frappe colors.
#
# Arguments:
#   $1 - Current progress value
#   $2 - Total/maximum value
#
# Example:
#   draw_progress_bar 7 10  # Shows 70% progress
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    echo -en "${FRAPPE_LAVENDER}["
    echo -en "${FRAPPE_GREEN}"
    printf '█%.0s' $(seq 1 $filled)
    echo -en "${FRAPPE_BASE}"
    printf '░%.0s' $(seq 1 $empty)
    echo -en "${FRAPPE_LAVENDER}]${NC} ${FRAPPE_YELLOW}${percent}%%${NC}"
}

#############################################################################
# OUTPUT FUNCTIONS
#############################################################################

# Print a step header with number and total
#
# Displays a formatted step message with progress indication.
#
# Arguments:
#   $1 - Current step number
#   $2 - Total number of steps
#   $3 - Step description
#
# Example:
#   print_step 3 10 "Installing packages"
print_step() {
    local step_num=$1
    local total_steps=$2
    local description="$3"

    echo ""
    echo -e "${FRAPPE_SAPPHIRE}╭─${NC} ${BOLD}${FRAPPE_MAUVE}Step ${step_num}/${total_steps}${NC} ${FRAPPE_LAVENDER}─${NC}"
    echo -e "${FRAPPE_SAPPHIRE}│${NC}  ${FRAPPE_TEXT}${description}${NC}"
    echo -e "${FRAPPE_SAPPHIRE}╰─${NC}"
    echo ""
}

# Show welcome screen with ASCII art
show_welcome() {
    clear

    # Calculate box width based on ASCII art (longest line is ~69 chars)
    local ascii_width=69
    local box_width=$((ascii_width + 17))  # Add padding for margins

    echo ""
    draw_box "Hyprland Dotfiles Installer" $box_width
    draw_box_line "" $box_width

    # HYPRLAND ASCII art - colors handled by draw_box_line
    draw_box_line "${FRAPPE_MAUVE}  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗${NC}" $box_width
    draw_box_line "${FRAPPE_MAUVE}  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗${NC}" $box_width
    draw_box_line "${FRAPPE_BLUE}  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║${NC}" $box_width
    draw_box_line "${FRAPPE_BLUE}  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║${NC}" $box_width
    draw_box_line "${FRAPPE_SAPPHIRE}  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝${NC}" $box_width
    draw_box_line "${FRAPPE_SAPPHIRE}  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝${NC}" $box_width
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
}

# Print functions for formatted output
print_info() {
    echo -e "${FRAPPE_BLUE}●${NC} $1"
}

print_success() {
    echo -e "${FRAPPE_GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${FRAPPE_YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${FRAPPE_RED}✗${NC} $1"
}
