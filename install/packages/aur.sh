#!/usr/bin/env bash
# aur.sh - AUR package installation
# Part of the modular dotfiles installation system
# Installs AUR packages (waypaper, quickwall, SwayOSD, VS Code, Catppuccin GTK themes)

# This script is sourced by install.sh, not executed directly
# Requires: packages/utils.sh, tui.sh, logging.sh, state.sh

install_aur_packages() {
    local phase_name="packages/aur"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "AUR packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 6 6 "Installing AUR packages"

    # Always install TUI AUR packages (headless-safe)
    local tui_package_file="$PACKAGES_DIR/aur-tui.txt"
    if ! install_aur_package_file "$tui_package_file" "AUR TUI packages"; then
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Install GUI theme AUR packages only if GUI mode enabled
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        local gui_theme_file="$PACKAGES_DIR/aur-gui-themes.txt"
        if ! install_aur_package_file "$gui_theme_file" "AUR GUI theme packages"; then
            log_phase_end "$phase_name" "failed"
            return 1
        fi
    else
        print_info "Skipping AUR GUI theme packages (TUI-only mode)"
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
