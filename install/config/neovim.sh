#!/usr/bin/env bash
# neovim.sh - Neovim/LazyVim configuration deployment
# Part of the modular dotfiles installation system
# Sets up LazyVim with custom Catppuccin Frappe theme configuration

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_neovim_config() {
    local phase_name="config/neovim"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Neovim/LazyVim config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 4 8 "Setting up LazyVim"

    # Check if Neovim is installed
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim not installed - skipping LazyVim setup"
        log_phase_skip "$phase_name" "Neovim not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install LazyVim"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    print_info "Setting up LazyVim..."
    log_info "Setting up LazyVim"

    local nvim_config="$HOME/.config/nvim"

    # Backup existing config if present
    if [ -d "$nvim_config" ]; then
        backup_if_exists "$nvim_config" "Neovim configuration"
    fi

    # Clone LazyVim starter
    print_info "Cloning LazyVim starter template..."
    if ! git clone https://github.com/LazyVim/starter "$nvim_config"; then
        print_error "Failed to clone LazyVim starter"
        log_error "Failed to clone LazyVim starter"
        log_phase_end "$phase_name" "failed"
        return 1
    fi

    # Remove .git directory so it becomes part of your dotfiles
    rm -rf "$nvim_config/.git"

    # Symlink custom configuration files from dotfiles
    print_info "Symlinking custom LazyVim configurations..."
    local nvim_custom_dir="$DOTFILES_DIR/nvim/lua"
    if [ -d "$nvim_custom_dir" ]; then
        # Create necessary directories
        mkdir -p "$nvim_config/lua/config"
        mkdir -p "$nvim_config/lua/plugins"

        # Symlink individual files from nvim/lua/config
        if [ -d "$nvim_custom_dir/config" ]; then
            for file in "$nvim_custom_dir/config"/*; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file")
                    create_symlink "$file" "$nvim_config/lua/config/$filename" "Neovim config: $filename"
                fi
            done
        fi

        # Symlink individual files from nvim/lua/plugins
        if [ -d "$nvim_custom_dir/plugins" ]; then
            for file in "$nvim_custom_dir/plugins"/*; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file")
                    create_symlink "$file" "$nvim_config/lua/plugins/$filename" "Neovim plugin: $filename"
                fi
            done
        fi
    fi

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
