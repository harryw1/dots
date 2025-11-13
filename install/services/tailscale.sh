#!/usr/bin/env bash
# tailscale.sh - Tailscale VPN service configuration
# Part of the modular dotfiles installation system
# Enables Tailscale service and installs tsui TUI

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

setup_tailscale_service() {
    local phase_name="services/tailscale"
    local phase_was_complete=false

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        phase_was_complete=true
        print_info "Tailscale service already configured (checking tsui installation...)"
    else
        log_phase_start "$phase_name"
        print_step 3 3 "Setting up Tailscale VPN"
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup Tailscale service"
        if [ "$phase_was_complete" = false ]; then
            log_phase_skip "$phase_name" "Dry run"
        fi
        return 0
    fi

    # Check if Tailscale is installed
    if ! command -v tailscale &> /dev/null; then
        print_info "Tailscale not installed - skipping configuration"
        if [ "$phase_was_complete" = false ]; then
            log_phase_skip "$phase_name" "Tailscale not installed"
            state_mark_phase_complete "$phase_name"
        fi
        return 0
    fi

    # Always check and install tsui, even if phase was already completed
    # This ensures tsui gets installed even if the phase was marked complete before tsui support was added
    if [ "$phase_was_complete" = false ]; then
        print_info "Setting up Tailscale..."
    fi

    # Enable tailscaled service (only if phase wasn't complete)
    if [ "$phase_was_complete" = false ]; then
        if sudo systemctl enable tailscaled 2>/dev/null; then
            print_success "Tailscale service enabled"
            log_success "Tailscale service enabled"
        else
            print_warning "Failed to enable Tailscale service"
            log_warning "Failed to enable Tailscale service"
        fi
    fi

    # Install tsui if not present (Tailscale TUI - essential for headless management)
    # Always check, even if phase was already marked complete
    if ! command -v tsui &> /dev/null; then
        print_info "Installing tsui (Tailscale TUI)..."
        
        # Detect architecture
        local arch=$(uname -m)
        local tsui_arch=""
        
        case "$arch" in
            x86_64)
                tsui_arch="amd64"
                ;;
            aarch64|arm64)
                tsui_arch="arm64"
                ;;
            armv7l|armv6l)
                tsui_arch="arm"
                ;;
            *)
                print_warning "Unsupported architecture for tsui: $arch"
                print_info "tsui may not be available for this architecture"
                log_warning "Unsupported architecture for tsui: $arch"
                tsui_arch="amd64"  # Fallback to amd64, may fail
                ;;
        esac
        
        local tsui_url="https://github.com/neuralinkcorp/tsui/releases/latest/download/tsui-linux-${tsui_arch}"
        local tsui_tmp="/tmp/tsui-linux-${tsui_arch}"

        print_info "Downloading tsui for architecture: $tsui_arch"
        if curl -fsSL "$tsui_url" -o "$tsui_tmp" 2>/dev/null; then
            chmod +x "$tsui_tmp"
            if sudo mv "$tsui_tmp" /usr/local/bin/tsui 2>/dev/null; then
                print_success "tsui installed successfully"
                log_success "tsui installed to /usr/local/bin/tsui (architecture: $tsui_arch)"
            else
                print_warning "Failed to install tsui to /usr/local/bin"
                log_warning "Failed to install tsui to /usr/local/bin"
                rm -f "$tsui_tmp"
            fi
        else
            print_warning "Failed to download tsui from GitHub releases"
            print_info "You can install tsui manually later if needed"
            log_warning "Failed to download tsui from $tsui_url"
        fi
    else
        print_info "tsui already installed"
    fi

    # Only show completion messages and mark phase complete if this was a new setup
    if [ "$phase_was_complete" = false ]; then
        print_success "Tailscale configuration complete"
        print_info "Connect to Tailscale with: sudo tailscale up"
        print_info "Manage with TUI: tsui"
        
        # Mark phase complete
        state_mark_phase_complete "$phase_name"
        log_phase_end "$phase_name" "success"
    else
        # Phase was already complete, just ensure tsui is installed
        if command -v tsui &> /dev/null; then
            print_success "tsui installation verified"
        fi
    fi

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
