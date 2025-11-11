#!/usr/bin/env bash
# productivity.sh - Productivity tools package installation
# Part of the modular dotfiles installation system
# Installs LibreOffice, PDF viewer, file manager, Discord

# This script is sourced by install.sh, not executed directly
# Requires: packages/utils.sh, tui.sh, logging.sh, state.sh

install_productivity_packages() {
    local phase_name="packages/productivity"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Productivity packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 5 6 "Installing productivity packages"

    local package_file="$PACKAGES_DIR/productivity.txt"

    if ! install_package_file "$package_file" "productivity packages"; then
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
