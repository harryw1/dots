#!/usr/bin/env bash
# theming.sh - Theming package installation
# Part of the modular dotfiles installation system
# Installs fonts (Nerd Fonts), icons, cursors, and GTK themes

# This script is sourced by install.sh, not executed directly
# Requires: packages/utils.sh, tui.sh, logging.sh, state.sh

install_theming_packages() {
    local phase_name="packages/theming"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Theming packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 3 6 "Installing theming packages"

    # Always install fonts (headless-safe)
    local fonts_file="$PACKAGES_DIR/theming-fonts.txt"
    if ! install_package_file "$fonts_file" "fonts"; then
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Refresh font cache after font installation
    if [ "$DRY_RUN" != true ]; then
        print_info "Refreshing font cache..."
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv &> /dev/null || true
            print_success "Font cache refreshed"
            log_info "Font cache refreshed"
        else
            print_warning "fc-cache not found - fonts may not be immediately available"
            log_warning "fc-cache not found"
        fi
    fi

    # Install GUI theming only if GUI mode enabled
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        local gui_theming_file="$PACKAGES_DIR/theming-gui.txt"
        if ! install_package_file "$gui_theming_file" "GUI theming"; then
            log_phase_end "$phase_name" "failed"
            return 1
        fi
    else
        print_info "Skipping GUI theming packages (TUI-only mode)"
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
