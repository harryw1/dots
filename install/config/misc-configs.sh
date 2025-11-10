#!/usr/bin/env bash
# misc-configs.sh - Miscellaneous configuration deployment
# Part of the modular dotfiles installation system
# Deploys Rofi, Mako, Zathura, wlogout, btop, and SDDM configurations

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_misc_configs() {
    local phase_name="config/misc"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Miscellaneous configs already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 7 8 "Deploying miscellaneous configurations"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy miscellaneous configs"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    # Install Rofi configuration
    if [ -d "$DOTFILES_DIR/rofi" ]; then
        create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "Rofi"
    fi

    # Install Mako configuration
    if [ -d "$DOTFILES_DIR/mako" ]; then
        create_symlink "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" "Mako"
    fi

    # Install Zathura configuration
    if [ -d "$DOTFILES_DIR/zathura" ]; then
        create_symlink "$DOTFILES_DIR/zathura" "$CONFIG_DIR/zathura" "Zathura"
    fi

    # Install wlogout configuration
    if [ -d "$DOTFILES_DIR/wlogout" ]; then
        create_symlink "$DOTFILES_DIR/wlogout" "$CONFIG_DIR/wlogout" "wlogout"
    fi

    # Install btop configuration
    if [ -d "$DOTFILES_DIR/btop" ]; then
        create_symlink "$DOTFILES_DIR/btop" "$CONFIG_DIR/btop" "btop"
    fi

    # Install SDDM configuration (requires sudo)
    if [ -f "$DOTFILES_DIR/sddm/theme.conf" ]; then
        print_info "Setting up SDDM theme configuration..."
        if sudo mkdir -p /etc/sddm.conf.d 2>/dev/null; then
            if sudo ln -sf "$DOTFILES_DIR/sddm/theme.conf" /etc/sddm.conf.d/theme.conf 2>/dev/null; then
                print_success "Linked SDDM theme configuration"
            else
                print_warning "Failed to create SDDM config symlink (may need sudo)"
            fi
        fi
    fi

    print_success "Miscellaneous configurations deployed"

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
