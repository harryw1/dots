#!/usr/bin/env bash
# tailscale.sh - Tailscale VPN service configuration
# Part of the modular dotfiles installation system
# Enables Tailscale service and installs tsui TUI

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

setup_tailscale_service() {
    local phase_name="services/tailscale"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Tailscale service already configured"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 3 3 "Setting up Tailscale VPN"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup Tailscale service"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Check if Tailscale is installed
    if ! command -v tailscale &> /dev/null; then
        print_info "Tailscale not installed - skipping configuration"
        log_phase_skip "$phase_name" "Tailscale not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi

    print_info "Setting up Tailscale..."

    # Enable tailscaled service
    if sudo systemctl enable tailscaled 2>/dev/null; then
        print_success "Tailscale service enabled"
        log_success "Tailscale service enabled"
    else
        print_warning "Failed to enable Tailscale service"
        log_warning "Failed to enable Tailscale service"
    fi

    # Install tsui if not present
    if ! command -v tsui &> /dev/null; then
        print_info "Installing tsui (Tailscale TUI)..."
        local tsui_url="https://github.com/neuralinkcorp/tsui/releases/latest/download/tsui-linux-amd64"
        local tsui_tmp="/tmp/tsui-linux-amd64"

        if curl -sL "$tsui_url" -o "$tsui_tmp" 2>/dev/null; then
            chmod +x "$tsui_tmp"
            if sudo mv "$tsui_tmp" /usr/local/bin/tsui 2>/dev/null; then
                print_success "tsui installed"
                log_success "tsui installed to /usr/local/bin/tsui"
            else
                print_warning "Failed to install tsui"
                log_warning "Failed to install tsui"
                rm -f "$tsui_tmp"
            fi
        else
            print_warning "Failed to download tsui"
            log_warning "Failed to download tsui from $tsui_url"
        fi
    else
        print_info "tsui already installed"
    fi

    print_success "Tailscale configuration complete"
    print_info "Connect to Tailscale with: sudo tailscale up"
    print_info "Manage with TUI: tsui"

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
