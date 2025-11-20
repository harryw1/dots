#!/usr/bin/env bash
# network.sh - Network service configuration
# Part of the modular dotfiles installation system
# Sets up iwd network management and disables NetworkManager

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

setup_network_service() {
    local phase_name="services/network"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Network service already configured"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 1 3 "Setting up iwd network management"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup iwd network service"
        state_mark_phase_complete "$phase_name"
        log_phase_end "$phase_name" "success (dry-run)"
        return 0
    fi

    # Check if iwd is installed
    if ! command -v iwctl &> /dev/null; then
        print_info "iwd not installed - skipping network configuration"
        log_phase_skip "$phase_name" "iwd not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi

    print_info "Setting up iwd network management..."

    # Disable NetworkManager if running
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        print_info "Disabling NetworkManager in favor of iwd..."
        if sudo systemctl disable --now NetworkManager 2>/dev/null; then
            print_success "NetworkManager disabled"
            log_success "NetworkManager disabled"
        else
            print_warning "Failed to disable NetworkManager"
            log_warning "Failed to disable NetworkManager"
        fi
    fi

    # Enable iwd
    if sudo systemctl enable --now iwd 2>/dev/null; then
        print_success "iwd service enabled"
        log_success "iwd service enabled"
    else
        print_warning "Failed to enable iwd service"
        log_warning "Failed to enable iwd service"
    fi

    print_success "Network configuration complete"

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
