#!/usr/bin/env bash
# development.sh - Development tools package installation
# Part of the modular dotfiles installation system
# Installs Python, C++, Neovim, LazyVim, Node.js, Starship, and build tools

# This script is sourced by install.sh, not executed directly
# Requires: packages/utils.sh, tui.sh, logging.sh, state.sh

install_development_packages() {
    local phase_name="packages/development"

    # Check if should skip all packages
    if should_skip_packages; then
        log_phase_skip "$phase_name" "Package installation skipped"
        return 0
    fi

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Development packages already installed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 4 6 "Installing development packages"

    # Install core development tools (Python, C++, Node, Neovim, etc.)
    local package_file="$PACKAGES_DIR/development.txt"
    if ! install_package_file "$package_file" "development packages"; then
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Install data processing tools (jq, yq, miller, sd, choose)
    local data_processing_file="$PACKAGES_DIR/data-processing.txt"
    if ! install_package_file "$data_processing_file" "data processing tools"; then
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Install additional language toolchains if file exists (Rust, Go)
    local languages_file="$PACKAGES_DIR/languages.txt"
    if [ -f "$languages_file" ]; then
        print_info "Installing additional language toolchains (Rust, Go)..."
        if ! install_package_file "$languages_file" "language toolchains"; then
            print_warning "Failed to install some language toolchains (non-critical)"
            # Don't fail the whole installation
        fi
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
