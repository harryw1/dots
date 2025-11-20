#!/usr/bin/env bash
# zsh.sh - Zsh configuration deployment
# Part of the modular dotfiles installation system
# Deploys zsh configuration with menu selection, Catppuccin colors, and fzf integration

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

deploy_zsh_config() {
    local phase_name="config/zsh"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Zsh config already deployed"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 6 8 "Setting up zsh configuration"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy zsh config"
        state_mark_phase_complete "$phase_name"
        log_phase_end "$phase_name" "success (dry-run)"
        return 0
    fi

    # Check if zsh is installed, install if missing
    if ! command -v zsh &> /dev/null; then
        print_warning "zsh is not installed"
        print_info "Installing zsh..."
        log_info "zsh not found, installing..."
        
        if [ "$DRY_RUN" = true ]; then
            print_info "[DRY RUN] Would install zsh"
        else
            if ! sudo pacman -S --needed --noconfirm zsh; then
                print_error "Failed to install zsh"
                print_info "Install manually with: sudo pacman -S zsh"
                log_error "Failed to install zsh"
                return 1
            fi
            print_success "Installed zsh"
            log_success "Installed zsh"
        fi
    fi

    # Set zsh as default shell if not already
    setup_default_shell_zsh

    # Create .zprofile for login shells (TTY)
    setup_zprofile

    # Deploy zsh configuration files
    setup_zsh_completion
    setup_zsh_colors
    setup_fzf_zsh

    # Deploy aliases (compatible with bash aliases)
    setup_zsh_aliases

    # Create/update .zshrc
    setup_zshrc

    print_success "Zsh configuration complete"

    # Mark phase complete
    state_mark_phase_complete "$phase_name"
    log_phase_end "$phase_name" "success"

    return 0
}

# Set zsh as default shell (optional)
setup_default_shell_zsh() {
    print_info "Checking default shell..."

    local current_shell="${SHELL:-$(getent passwd "$USER" | cut -d: -f7)}"
    local zsh_path="$(which zsh 2>/dev/null || command -v zsh)"

    if [ -z "$zsh_path" ]; then
        print_warning "zsh not found in PATH, skipping shell change"
        log_warning "zsh not found in PATH"
        return 0
    fi

    # Check if already using zsh
    if echo "$current_shell" | grep -q "zsh$"; then
        print_success "zsh is already the default shell"
        log_info "zsh is already default shell: $current_shell"
        return 0
    fi

    print_info "Current shell: $current_shell"
    print_info "zsh path: $zsh_path"

    # Try to change shell
    # Note: chsh requires the user's password (not sudo), so it may prompt
    print_info "Attempting to change default shell to zsh..."
    
    # In non-interactive mode (piped input), we can't prompt for password
    if [ ! -t 0 ]; then
        print_warning "Cannot change shell in non-interactive mode (password required)"
        print_info "After installation, run manually:"
        print_info "  chsh -s $zsh_path"
        log_warning "Skipping shell change (non-interactive mode)"
        return 0
    fi
    
    # Try to change shell (will prompt for password if needed)
    if chsh -s "$zsh_path" 2>/dev/null; then
        print_success "Changed default shell to zsh"
        print_info "New shell will take effect after you log out and back in"
        log_info "Changed default shell to: $zsh_path"
    else
        print_warning "Could not change default shell automatically"
        print_info "This requires your password. Please run manually:"
        print_info "  chsh -s $zsh_path"
        print_info "The new shell will take effect after you log out and back in."
        log_warning "Could not change default shell (password required or failed)"
    fi
}

# Create .zprofile for login shells (TTY)
setup_zprofile() {
    print_info "Setting up .zprofile for login shells..."

    local zprofile="$HOME/.zprofile"

    # Check if .zprofile already exists and has our content
    if [ -f "$zprofile" ]; then
        if grep -q "# Dotfiles: zprofile" "$zprofile" 2>/dev/null; then
            print_info ".zprofile already configured"
            return 0
        fi
        # Backup existing .zprofile
        backup_if_exists "$zprofile" "Zsh profile"
    fi

    # Build .zprofile content
    cat > "$zprofile" <<'ZPROFILE_EOF'
# Dotfiles: zprofile
# This file is sourced by login shells (e.g., TTY logins)
# It sources .zshrc for interactive shells and handles kitty auto-launch

# Source .zshrc for interactive shells
if [ -f ~/.zshrc ]; then
    . ~/.zshrc
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
ZPROFILE_EOF

    print_success "Created .zprofile for login shells"
    log_info "Created .zprofile with kitty auto-launch logic"
}

# Setup zsh completion
setup_zsh_completion() {
    print_info "Setting up zsh completion with menu selection..."

    local completion_file="$DOTFILES_DIR/zsh/zsh_completion.zsh"
    local target_file="$HOME/.config/zsh/zsh_completion.zsh"

    if [ -f "$completion_file" ]; then
        # Ensure target directory exists
        mkdir -p "$HOME/.config/zsh"

        # Copy the completion file
        if [ -L "$target_file" ] || [ -f "$target_file" ]; then
            print_info "Zsh completion already configured"
        else
            cp "$completion_file" "$target_file"
            chmod +x "$target_file"
            print_success "Installed zsh completion configuration"
        fi
    else
        print_info "Zsh completion file not found, skipping"
        log_info "Zsh completion file not found: $completion_file"
    fi
}

# Setup zsh colors
setup_zsh_colors() {
    print_info "Setting up Catppuccin Frappe colors for zsh..."

    local colors_file="$DOTFILES_DIR/zsh/zsh_colors.zsh"
    local target_file="$HOME/.config/zsh/zsh_colors.zsh"

    if [ -f "$colors_file" ]; then
        # Ensure target directory exists
        mkdir -p "$HOME/.config/zsh"

        # Copy the colors file
        if [ -L "$target_file" ] || [ -f "$target_file" ]; then
            print_info "Catppuccin colors already configured"
        else
            cp "$colors_file" "$target_file"
            chmod +x "$target_file"
            print_success "Installed Catppuccin Frappe colors"
        fi
    else
        print_info "Zsh colors file not found, skipping"
        log_info "Zsh colors file not found: $colors_file"
    fi
}

# Setup fzf for zsh
setup_fzf_zsh() {
    print_info "Setting up fzf integration for zsh..."

    local fzf_file="$DOTFILES_DIR/zsh/fzf_integration.zsh"
    local target_file="$HOME/.config/zsh/fzf_integration.zsh"

    if [ -f "$fzf_file" ]; then
        # Ensure target directory exists
        mkdir -p "$HOME/.config/zsh"

        # Copy the fzf file
        if [ -L "$target_file" ] || [ -f "$target_file" ]; then
            print_info "fzf integration already configured"
        else
            cp "$fzf_file" "$target_file"
            chmod +x "$target_file"
            print_success "Installed fzf integration for zsh"
        fi
    else
        print_info "fzf integration file not found, skipping"
        log_info "fzf integration file not found: $fzf_file"
    fi
}

# Setup zsh aliases (can use bash aliases)
setup_zsh_aliases() {
    print_info "Setting up aliases for zsh..."

    # Try to use .zsh_aliases first, fallback to .bash_aliases
    if [ -f "$DOTFILES_DIR/zsh/.zsh_aliases" ]; then
        create_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases" "Zsh aliases"
    elif [ -f "$DOTFILES_DIR/bash/.bash_aliases" ]; then
        # Use bash aliases (they're compatible)
        create_symlink "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.zsh_aliases" "Zsh aliases (from bash)"
        print_info "Using bash aliases (compatible with zsh)"
    else
        print_info "No aliases file found, skipping"
    fi
}

# Create/update .zshrc
setup_zshrc() {
    print_info "Setting up .zshrc..."

    local zshrc="$HOME/.zshrc"

    # Create .zshrc if it doesn't exist
    if [ ! -f "$zshrc" ]; then
        touch "$zshrc"
        echo "# Zsh configuration" >> "$zshrc"
    fi

    # Check if already configured
    if grep -q "# Dotfiles: zshrc" "$zshrc" 2>/dev/null; then
        print_info ".zshrc already configured"
        return 0
    fi

    # Backup existing .zshrc
    backup_if_exists "$zshrc" "Zsh rc"

    # Add our configuration to .zshrc
    cat >> "$zshrc" <<'ZSHRC_EOF'

# Dotfiles: zshrc
# Zsh configuration with menu selection, Catppuccin colors, and fzf integration

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Load Catppuccin Frappe colors for ls and terminal
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load aliases (try zsh first, fallback to bash)
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
elif [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load zsh completion (menu selection!)
if [ -f ~/.config/zsh/zsh_completion.zsh ]; then
    . ~/.config/zsh/zsh_completion.zsh
fi

# Load fzf integration
if [ -f ~/.config/zsh/fzf_integration.zsh ]; then
    . ~/.config/zsh/fzf_integration.zsh
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
ZSHRC_EOF

    print_success "Created/updated .zshrc"
    log_info "Created .zshrc with zsh configuration"
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

