#!/usr/bin/env bash
# kitty.sh - Kitty terminal configuration deployment
# Part of the modular dotfiles installation system
# Deploys Kitty terminal configuration via symlink

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_kitty_config() {
    local phase_name="config/kitty"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Kitty config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 3 8 "Deploying Kitty configuration"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy Kitty config"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    # Deploy Kitty configuration
    if [ -d "$DOTFILES_DIR/kitty" ]; then
        create_symlink "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty" "Kitty"
        print_success "Kitty configuration deployed"
    else
        print_warning "Kitty directory not found in dotfiles"
        log_warning "Kitty directory not found: $DOTFILES_DIR/kitty"
    fi

    # Note: Default terminal is typically set by the window manager/compositor
    # (e.g., Hyprland keybinds) or desktop environment, not via xdg-settings
    # Rofi and other launchers will use kitty if configured in their configs

    # Verify font is available
    if [ "$DRY_RUN" != true ] && command -v fc-list &> /dev/null; then
        if fc-list | grep -qi "jetbrains.*nerd" 2>/dev/null; then
            print_success "JetBrainsMono Nerd Font is available"
            log_info "JetBrainsMono Nerd Font verified"
        else
            print_warning "JetBrainsMono Nerd Font not found in font cache"
            print_info "Try running: fc-cache -fv"
            log_warning "JetBrainsMono Nerd Font not found in font cache"
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
