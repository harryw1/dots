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
            state_mark_phase_complete "$phase_name"
            log_phase_end "$phase_name" "success (dry-run)"
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

    # Install tsui if not present or if it's corrupted (Tailscale TUI - essential for headless management)
    # Always check, even if phase was already marked complete
    local tsui_needs_install=false
    local tsui_path=""
    
    # Check if tsui exists and is valid
    if command -v tsui &> /dev/null; then
        tsui_path=$(command -v tsui)
        # Verify it's actually a valid binary
        if [ -f "$tsui_path" ]; then
            local file_type=$(file -b "$tsui_path" 2>/dev/null || echo "unknown")
            # Check if it's a binary executable
            if ! echo "$file_type" | grep -qE "(ELF|executable|binary|Mach-O)"; then
                # File exists but is not a valid binary (likely corrupted HTML)
                print_warning "Found corrupted tsui at $tsui_path (type: $file_type)"
                print_info "Removing corrupted file and reinstalling..."
                sudo rm -f "$tsui_path" 2>/dev/null
                tsui_needs_install=true
            else
                print_info "tsui already installed and valid at $tsui_path"
            fi
        else
            # Command exists but file doesn't (broken symlink?)
            tsui_needs_install=true
        fi
    else
        tsui_needs_install=true
    fi
    
    if [ "$tsui_needs_install" = true ]; then
        print_info "Installing tsui (Tailscale TUI)..."
        print_info "Using official install script from neuralink.com"
        
        # Use the official install script as recommended by tsui
        local install_script_url="https://neuralink.com/tsui/install.sh"
        local install_script_tmp="/tmp/tsui-install.sh"
        
        # Download the install script
        if curl -fsSL "$install_script_url" -o "$install_script_tmp" 2>/dev/null; then
            # Make it executable
            chmod +x "$install_script_tmp"
            
            # Run the install script (it handles architecture detection and installation)
            print_info "Running tsui install script..."
            if bash "$install_script_tmp" 2>&1; then
                # Verify installation was successful
                if command -v tsui &> /dev/null; then
                    local installed_path=$(command -v tsui)
                    print_success "tsui installed successfully at $installed_path"
                    log_success "tsui installed successfully using official install script"
                else
                    print_warning "tsui install script ran but tsui command not found"
                    log_warning "tsui install script completed but command not available"
                    print_info "You may need to add tsui to your PATH or install manually"
                fi
            else
                print_warning "tsui install script failed"
                log_warning "tsui install script execution failed"
                print_info "You may need to install tsui manually:"
                print_info "  curl -fsSL https://neuralink.com/tsui/install.sh | bash"
            fi
            
            # Clean up install script
            rm -f "$install_script_tmp"
        else
            print_warning "Failed to download tsui install script"
            log_warning "Failed to download tsui install script from $install_script_url"
            print_info "You can install tsui manually with:"
            print_info "  curl -fsSL https://neuralink.com/tsui/install.sh | bash"
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
