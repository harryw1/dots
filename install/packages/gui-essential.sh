#!/usr/bin/env bash
# gui-essential.sh - Essential GUI package installation
# Part of the modular dotfiles installation system
# Installs essential Hyprland and GUI packages

# This script is sourced by install.sh, not executed directly
# Requires: packages/utils.sh, tui.sh, logging.sh, state.sh

install_gui_essential_packages() {
    local phase_name="packages/gui-essential"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Essential GUI packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 2 8 "Installing essential GUI packages (Hyprland)"

    local package_file="$PACKAGES_DIR/gui-essential.txt"

    if ! install_package_file "$package_file" "essential GUI packages"; then
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Mark phase complete
    state_mark_phase_complete "$phase_name"
    log_phase_end "$phase_name" "success"

    return 0
}

install_gui_essential_aur_packages() {
    local phase_name="packages/gui-essential-aur"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Essential GUI AUR packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 3 8 "Installing essential GUI AUR packages"

    local package_file="$PACKAGES_DIR/gui-essential-aur.txt"

    if ! install_aur_package_file "$package_file" "essential GUI AUR packages"; then
        log_phase_end "$phase_name" "failed"
        return 1
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
