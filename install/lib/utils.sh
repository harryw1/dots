#!/usr/bin/env bash
# utils.sh - Utility functions for dotfiles installation
# Part of the modular dotfiles installation system
# Provides backup, symlink, and system detection functions

# Requires: tui.sh to be sourced first (for print_* functions)

# Directory setup - these are globals used throughout the installation
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export DOTFILES_DIR
CONFIG_DIR="$HOME/.config"
export CONFIG_DIR
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
export BACKUP_DIR
PACKAGES_DIR="$DOTFILES_DIR/packages"
export PACKAGES_DIR

# Check if running Arch Linux
is_arch_linux() {
    [ -f /etc/arch-release ]
}

# Create backup of existing config
# Usage: backup_if_exists "/path/to/config" "config_name"
# Returns: 0 if backup was created, 1 if no backup needed
backup_if_exists() {
    local target="$1"
    local name="$2"

    if [ -e "$target" ]; then
        print_warning "Existing $name configuration found"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        print_info "Backed up to: $BACKUP_DIR/$(basename "$target")"
        return 0
    fi
    return 1
}

# Create symlink with backup of existing files
# Usage: create_symlink "/path/to/source" "/path/to/target" "description"
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -L "$target" ]; then
        local current_source
        current_source="$(readlink "$target")"
        if [ "$current_source" = "$source" ]; then
            print_info "$name already linked correctly"
            return 0
        else
            print_warning "$name symlink exists but points to different location"
            backup_if_exists "$target" "$name"
        fi
    elif [ -e "$target" ]; then
        backup_if_exists "$target" "$name"
    fi

    ln -sf "$source" "$target"
    print_success "Linked $name: $target -> $source"
}
