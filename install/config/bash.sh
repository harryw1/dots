#!/usr/bin/env bash
# bash.sh - Bash aliases and configuration deployment
# Part of the modular dotfiles installation system
# Deploys bash aliases and integrates with .bashrc and .zshrc

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_bash_config() {
    local phase_name="config/bash"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Bash config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 6 8 "Setting up bash aliases"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy bash config"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Deploy Bash aliases
    if [ -f "$DOTFILES_DIR/bash/.bash_aliases" ]; then
        print_info "Setting up bash aliases..."
        create_symlink "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases" "Bash aliases"

        # Add source command to .bashrc if needed
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q '\.bash_aliases' "$HOME/.bashrc"; then
                echo '' >> "$HOME/.bashrc"
                echo '# Load custom bash aliases' >> "$HOME/.bashrc"
                echo 'if [ -f ~/.bash_aliases ]; then' >> "$HOME/.bashrc"
                echo '    . ~/.bash_aliases' >> "$HOME/.bashrc"
                echo 'fi' >> "$HOME/.bashrc"
                print_success "Added bash aliases to .bashrc"
            else
                print_info "Bash aliases already sourced in .bashrc"
            fi
        fi

        # Do the same for .zshrc
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q '\.bash_aliases' "$HOME/.zshrc"; then
                echo '' >> "$HOME/.zshrc"
                echo '# Load custom bash aliases' >> "$HOME/.zshrc"
                echo 'if [ -f ~/.bash_aliases ]; then' >> "$HOME/.zshrc"
                echo '    . ~/.bash_aliases' >> "$HOME/.zshrc"
                echo 'fi' >> "$HOME/.zshrc"
                print_success "Added bash aliases to .zshrc"
            else
                print_info "Bash aliases already sourced in .zshrc"
            fi
        fi

        print_success "Bash configuration complete"
    else
        print_info "No bash aliases file found, skipping"
        log_info "Bash aliases file not found: $DOTFILES_DIR/bash/.bash_aliases"
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
