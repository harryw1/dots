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
    print_step 6 8 "Setting up bash configuration"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy bash config"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    # Set bash as default shell if not already
    setup_default_shell

    # Create .bash_profile for login shells (TTY)
    setup_bash_profile

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
    else
        print_info "No bash aliases file found, skipping"
        log_info "Bash aliases file not found: $DOTFILES_DIR/bash/.bash_aliases"
    fi

    # Optimize TTY experience
    optimize_tty_config

    print_success "Bash configuration complete"

    # Mark phase complete
    state_mark_phase_complete "$phase_name"
    log_phase_end "$phase_name" "success"

    return 0
}

# Set bash as default shell
setup_default_shell() {
    print_info "Checking default shell..."

    local current_shell="${SHELL:-$(getent passwd "$USER" | cut -d: -f7)}"
    local bash_path="$(which bash 2>/dev/null || command -v bash)"

    if [ -z "$bash_path" ]; then
        print_warning "Bash not found in PATH, skipping shell change"
        log_warning "Bash not found in PATH"
        return 0
    fi

    # Check if already using bash
    if echo "$current_shell" | grep -q "bash$"; then
        print_success "Bash is already the default shell"
        log_info "Bash is already default shell: $current_shell"
        return 0
    fi

    print_info "Current shell: $current_shell"
    print_info "Bash path: $bash_path"

    # Try to change shell
    if [ "$FORCE" = true ]; then
        print_info "Attempting to change default shell to bash (force mode)..."
        if chsh -s "$bash_path" 2>/dev/null; then
            print_success "Changed default shell to bash"
            log_info "Changed default shell to: $bash_path"
        else
            print_warning "Failed to change default shell (may require password)"
            print_info "You can change it manually with: chsh -s $bash_path"
            log_warning "Failed to change default shell automatically"
        fi
    else
        print_info "To change default shell to bash, run: chsh -s $bash_path"
        log_info "Shell change skipped (not in force mode)"
    fi
}

# Create .bash_profile for login shells (TTY)
setup_bash_profile() {
    print_info "Setting up .bash_profile for login shells..."

    local bash_profile="$HOME/.bash_profile"
    local bash_profile_content=""

    # Check if .bash_profile already exists and has our content
    if [ -f "$bash_profile" ]; then
        if grep -q "# Dotfiles: bash_profile" "$bash_profile" 2>/dev/null; then
            print_info ".bash_profile already configured"
            return 0
        fi
        # Backup existing .bash_profile
        backup_if_exists "$bash_profile" "Bash profile"
    fi

    # Build .bash_profile content
    cat > "$bash_profile" <<'BASHPROFILE_EOF'
# Dotfiles: bash_profile
# This file is sourced by login shells (e.g., TTY logins)
# It sources .bashrc for interactive shells and handles kitty auto-launch

# Source .bashrc for interactive shells
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# TTY Optimization: Set TERM for better color support if in TTY
if [ "$TERM" = "linux" ] && [ -z "$SSH_CONNECTION" ]; then
    # Try to use 256-color terminal if supported
    if [ -e /usr/share/terminfo/x/xterm-256color ] || [ -e /lib/terminfo/x/xterm-256color ]; then
        export TERM=xterm-256color
    fi
fi

# Auto-launch kitty on TTY login if display server is available
# Enhanced TTY (starship, colors) works as fallback when no display server
if [ -z "$SSH_CONNECTION" ] && [ -t 0 ] && ([ "$TERM" = "linux" ] || [ "$TERM" = "xterm-256color" ]); then
    if command -v kitty &> /dev/null; then
        # Check for display server (X11 or Wayland)
        if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] || [ -S "/tmp/.X11-unix/X0" ] 2>/dev/null; then
            # Display server detected, launch kitty
            exec kitty
        fi
    fi
fi
BASHPROFILE_EOF

    print_success "Created .bash_profile for login shells"
    log_info "Created .bash_profile with kitty auto-launch logic"
}

# Optimize TTY experience
optimize_tty_config() {
    print_info "Optimizing TTY configuration..."

    # Ensure .bashrc exists before we try to modify it
    if [ ! -f "$HOME/.bashrc" ]; then
        # Create a basic .bashrc if it doesn't exist
        touch "$HOME/.bashrc"
        echo "# Bash configuration" >> "$HOME/.bashrc"
    fi

    # Add TTY optimization to .bashrc if not already present
    if ! grep -q "# Dotfiles: TTY optimization" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<'BASHRC_EOF'

# Dotfiles: TTY optimization
# Improve TTY experience with better colors and terminal detection
if [ "$TERM" = "linux" ] && [ -z "$SSH_CONNECTION" ]; then
    # Try to use 256-color terminal if supported
    if [ -e /usr/share/terminfo/x/xterm-256color ] || [ -e /lib/terminfo/x/xterm-256color ]; then
        export TERM=xterm-256color
    fi
fi

# Terminal multiplexer aliases for session management
if command -v tmux &> /dev/null; then
    alias tmux-attach='tmux attach -t'
    alias tmux-new='tmux new -s'
    alias tmux-list='tmux list-sessions'
fi

if command -v zellij &> /dev/null; then
    alias zj='zellij'
    alias zj-attach='zellij attach'
    alias zj-list='zellij list-sessions'
fi
BASHRC_EOF
        print_success "Added TTY optimization to .bashrc"
        log_info "Added TTY optimization configuration"
    else
        print_info "TTY optimization already configured in .bashrc"
    fi
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
