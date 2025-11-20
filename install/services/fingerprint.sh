#!/usr/bin/env bash
# fingerprint.sh - Fingerprint authentication configuration
# Part of the modular dotfiles installation system
# Sets up fprintd with PAM configurations for sudo, login, and polkit

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

setup_fingerprint_service() {
    local phase_name="services/fingerprint"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Fingerprint authentication already configured"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 2 3 "Setting up fingerprint authentication"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup fingerprint authentication"
        state_mark_phase_complete "$phase_name"
        log_phase_end "$phase_name" "success (dry-run)"
        return 0
    fi

    # Check if fprintd is installed
    if ! command -v fprintd-enroll &> /dev/null; then
        print_info "fprintd not installed - skipping fingerprint configuration"
        log_phase_skip "$phase_name" "fprintd not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi

    print_info "Setting up fingerprint authentication..."

    # Backup and install PAM configs
    for pam_file in sudo system-local-login polkit-1; do
        if [ -f "/etc/pam.d/$pam_file" ]; then
            if [ ! -f "/etc/pam.d/${pam_file}.backup-pre-fprintd" ]; then
                if sudo cp "/etc/pam.d/$pam_file" "/etc/pam.d/${pam_file}.backup-pre-fprintd" 2>/dev/null; then
                    print_info "Backed up /etc/pam.d/$pam_file"
                    log_info "Backed up /etc/pam.d/$pam_file"
                fi
            fi
        fi
    done

    # Install custom PAM configs from dotfiles
    if [ -d "$DOTFILES_DIR/fprintd/pam-configs" ]; then
        for pam_file in sudo system-local-login polkit-1; do
            if [ -f "$DOTFILES_DIR/fprintd/pam-configs/$pam_file" ]; then
                if sudo cp "$DOTFILES_DIR/fprintd/pam-configs/$pam_file" "/etc/pam.d/$pam_file" 2>/dev/null; then
                    print_success "Installed fingerprint auth for $pam_file"
                    log_success "Installed fingerprint auth for $pam_file"
                else
                    print_warning "Failed to install fingerprint auth for $pam_file"
                    log_warning "Failed to install fingerprint auth for $pam_file"
                fi
            fi
        done
    else
        print_warning "Fingerprint PAM configs not found in dotfiles"
        log_warning "Fingerprint PAM configs not found: $DOTFILES_DIR/fprintd/pam-configs"
    fi

    print_success "Fingerprint authentication configured"
    print_info "Enroll your fingerprint with: fprintd-enroll"

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
