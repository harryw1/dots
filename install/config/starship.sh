#!/usr/bin/env bash
# starship.sh - Starship prompt configuration deployment
# Part of the modular dotfiles installation system
# Installs Starship Catppuccin Frappe preset and shell integration

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_starship_config() {
    local phase_name="config/starship"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Starship config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 5 8 "Installing Starship configuration"

    # Check dry-run mode first
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy Starship config"
        state_mark_phase_complete "$phase_name"
        log_phase_end "$phase_name" "success (dry-run)"
        return 0
    fi

    # Check if Starship is installed
    if ! command -v starship &> /dev/null; then
        print_warning "Starship not installed - skipping configuration"
        log_phase_skip "$phase_name" "Starship not installed"
        state_mark_phase_complete "$phase_name"
        return 0
    fi

    print_info "Installing Starship Catppuccin Frappe preset..."

    # Backup existing config if present
    if [ -f "$CONFIG_DIR/starship.toml" ]; then
        backup_if_exists "$CONFIG_DIR/starship.toml" "Starship configuration"
    fi

    # Install the official Catppuccin Powerline preset
    if starship preset catppuccin-powerline -o "$CONFIG_DIR/starship.toml"; then
        print_success "Installed Starship preset"

        # Update the palette to use Frappe variant
        if [ -f "$CONFIG_DIR/starship.toml" ]; then
            if grep -q "palette = 'catppuccin_mocha'" "$CONFIG_DIR/starship.toml" 2>/dev/null; then
                sed -i "s/palette = 'catppuccin_mocha'/palette = 'catppuccin_frappe'/" "$CONFIG_DIR/starship.toml"
                print_success "Configured Catppuccin Frappe theme"
            fi
        fi
    else
        print_warning "Failed to install Starship preset, trying manual symlink..."
        if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
            create_symlink "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml" "Starship"
        fi
    fi

    # Configure Starship in shell RC files
    print_info "Setting up Starship shell integration..."

    # Setup for bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
            echo '' >> "$HOME/.bashrc"
            echo '# Starship prompt' >> "$HOME/.bashrc"
            echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
            print_success "Added Starship initialization to .bashrc"
        else
            print_info "Starship already configured in .bashrc"
        fi
    fi

    # Setup for zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Starship prompt' >> "$HOME/.zshrc"
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
            print_success "Added Starship initialization to .zshrc"
        else
            print_info "Starship already configured in .zshrc"
        fi
    fi

    print_success "Starship configuration complete"

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
