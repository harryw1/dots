#!/usr/bin/env bash
# finalize.sh - Post-installation finalization
# Part of the modular dotfiles installation system
# Performs final checks and displays completion summary

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

finalize_installation() {
    local phase_name="post-install/finalize"

    log_phase_start "$phase_name"
    print_step 2 2 "Finalizing installation"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would finalize installation"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    print_info "Running final checks..."

    # Verify critical components
    local warnings=0

    # Check if Hyprland config exists
    if [ ! -L "$HOME/.config/hypr" ] && [ ! -d "$HOME/.config/hypr" ]; then
        print_warning "Hyprland config not found at ~/.config/hypr"
        log_warning "Hyprland config not found"
        ((warnings++))
    fi

    # Check if Waybar config exists
    if [ ! -L "$HOME/.config/waybar" ] && [ ! -d "$HOME/.config/waybar" ]; then
        print_warning "Waybar config not found at ~/.config/waybar"
        log_warning "Waybar config not found"
        ((warnings++))
    fi

    # Check if wallpapers were downloaded
    if [ ! -d "$HOME/.local/share/catppuccin-wallpapers" ]; then
        print_warning "Wallpaper collection not found"
        log_warning "Wallpaper collection not found"
        ((warnings++))
    fi

    if [ $warnings -eq 0 ]; then
        print_success "All checks passed"
        log_success "All finalization checks passed"
    else
        print_warning "Completed with $warnings warning(s)"
        log_warning "Finalization completed with $warnings warning(s)"
    fi

    # Mark phase complete
    state_mark_phase_complete "$phase_name"
    log_phase_end "$phase_name" "success"

    return 0
}

# Auto-execute if not in dry-run planning mode
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Being sourced, define function only
    :
else
    # Being executed directly (shouldn't happen, but handle gracefully)
    echo "This script should be sourced by install.sh, not executed directly"
    exit 1
fi
