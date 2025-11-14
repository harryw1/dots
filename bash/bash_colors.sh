#!/usr/bin/env bash
# bash_colors.sh - Catppuccin Frappe colors for bash completion
# Sets terminal colors for bash completion highlighting

# Source Catppuccin colors if available
if [ -f ~/.config/bash/catppuccin_colors.sh ]; then
    . ~/.config/bash/catppuccin_colors.sh
fi

# Set terminal colors for bash completion using Catppuccin Frappe
# These colors are used by colored-stats and colored-completion-prefix

# ANSI color codes for Catppuccin Frappe
# Using 256-color codes for better color accuracy

# Completion colors
# These are used when colored-stats and colored-completion-prefix are enabled

# Set terminal colors using tput (if available)
if command -v tput &> /dev/null; then
    # Catppuccin Frappe colors as ANSI 256-color codes
    # These will be used by bash's colored completion
    
    # Note: Bash uses standard ANSI colors for completion highlighting
    # The actual colors depend on your terminal's color scheme
    # For best results, configure your terminal to use Catppuccin Frappe theme
    
    # Export color variables for use in prompts/completions
    export CATPPUCCIN_COMPLETION_FG="\033[38;5;230m"      # Text (#c6d0f5)
    export CATPPUCCIN_COMPLETION_BG="\033[48;5;236m"      # Base (#303446)
    export CATPPUCCIN_COMPLETION_HL="\033[38;5;140m"      # Mauve (#ca9ee6) - for highlights
    export CATPPUCCIN_COMPLETION_PREFIX="\033[38;5;111m"  # Blue (#8caaee) - for common prefix
    export CATPPUCCIN_COMPLETION_MATCH="\033[38;5;150m"   # Green (#a6d189) - for matches
fi

# Note: Bash's colored-stats uses your terminal's color palette
# To get Catppuccin Frappe colors in completions:
# 1. Set your terminal emulator's color scheme to Catppuccin Frappe
# 2. Enable colored-stats and colored-completion-prefix (done in bash_completion.sh)
# 3. The terminal will use the colors from your terminal theme

