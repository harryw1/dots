#!/usr/bin/env bash
# neovim.sh - Neovim/LazyVim configuration deployment
# Part of the modular dotfiles installation system
# Sets up LazyVim with custom Catppuccin Frappe theme configuration

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_neovim_config() {
    local phase_name="config/neovim"
    local nvim_config_src="$DOTFILES_DIR/nvim"
    local nvim_config_dest="$HOME/.config/nvim"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Neovim/LazyVim config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 4 8 "Setting up LazyVim"

    # Check dry-run mode first
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy Neovim configuration"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Check if Neovim is installed
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim not installed - skipping LazyVim setup"
        log_phase_skip "$phase_name" "Neovim not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi
    
    # Symlink the entire nvim directory
    create_symlink "$nvim_config_src" "$nvim_config_dest" "Neovim/LazyVim"

    print_success "LazyVim setup complete"
    log_success "LazyVim setup complete"
    print_info "Open Neovim and LazyVim will automatically install plugins"

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
