#!/usr/bin/env bash
# waybar.sh - Waybar configuration deployment
# Part of the modular dotfiles installation system
# Deploys Waybar configuration via symlink

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_waybar_config() {
    local phase_name="config/waybar"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Waybar config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 2 8 "Deploying Waybar configuration"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy Waybar config"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    # Deploy Waybar configuration
    if [ -d "$DOTFILES_DIR/waybar" ]; then
        create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "Waybar"
        print_success "Waybar configuration deployed"
    else
        print_warning "Waybar directory not found in dotfiles"
        log_warning "Waybar directory not found: $DOTFILES_DIR/waybar"
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
