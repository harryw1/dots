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
        print_info "URL: $tsui_url"
        
        # Download with explicit error checking (don't use -f flag so we can check HTTP code)
        local http_code=$(curl -w "%{http_code}" -sSL "$tsui_url" -o "$tsui_tmp" 2>/dev/null)
        local curl_exit=$?
        
        # Check if download was successful (HTTP 200) and file exists
        if [ "$curl_exit" -eq 0 ] && [ "$http_code" = "200" ] && [ -f "$tsui_tmp" ] && [ -s "$tsui_tmp" ]; then
            # Verify it's actually a binary, not HTML/text
            local file_type=$(file -b "$tsui_tmp" 2>/dev/null || echo "unknown")
            
            # Check if it's a binary executable (ELF, Mach-O, or similar)
            if echo "$file_type" | grep -qE "(ELF|executable|binary|Mach-O)" || [ "$(head -c 4 "$tsui_tmp" 2>/dev/null | od -An -tx1 | tr -d ' \n')" = "7f454c46" ]; then
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
                # File is not a binary - likely HTML error page
                print_warning "Downloaded file is not a valid binary (type: $file_type)"
                print_info "This may indicate the release URL is incorrect or the file doesn't exist"
                log_warning "Downloaded file is not a binary: $file_type"
                
                # Show first few lines to help debug
                if [ -f "$tsui_tmp" ] && [ -s "$tsui_tmp" ]; then
                    print_info "Downloaded content preview:"
                    head -3 "$tsui_tmp" | while read -r line; do
                        print_info "  $line"
                    done
                fi
                
                rm -f "$tsui_tmp"
                print_warning "tsui installation failed - please install manually"
                print_info "Check releases at: https://github.com/neuralinkcorp/tsui/releases"
            fi
        else
            # Download failed or got non-200 response
            print_warning "Failed to download tsui (HTTP code: ${http_code:-unknown})"
            print_info "URL may be incorrect or the release may not be available for this architecture"
            log_warning "Failed to download tsui from $tsui_url (HTTP: ${http_code:-unknown})"
            rm -f "$tsui_tmp"
            print_info "Check releases at: https://github.com/neuralinkcorp/tsui/releases"
            print_info "You may need to install tsui manually"
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
