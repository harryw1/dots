#!/usr/bin/env bash

# Dotfiles Uninstallation Script
# Removes symlinks created by install.sh

set -e  # Exit on error

# Source theme configuration if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh" ]; then
    # Fallback for installed location
    source "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh"
fi

# Use the shared TUI functions if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/install/lib/tui.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/install/lib/tui.sh"
else
    # Basic Fallback if TUI lib not found (should not happen in repo)
    print_info() { echo "● $1"; }
    print_success() { echo "✓ $1"; }
    print_warning() { echo "⚠ $1"; }
    print_error() { echo "✗ $1"; }
fi

CONFIG_DIR="$HOME/.config"

# Remove symlink if it exists
remove_symlink() {
    local target="$1"
    local name="$2"

    if [ -L "$target" ]; then
        rm "$target"
        print_success "Removed $name symlink: $target"
        return 0
    elif [ -e "$target" ]; then
        print_warning "$name exists but is not a symlink, skipping"
        return 1
    else
        print_info "$name not found, skipping"
        return 1
    fi
}

# Main uninstallation
main() {
    print_info "Starting dotfiles uninstallation"
    echo ""

    # Confirmation
    print_warning "This will remove symlinks created by install.sh"
    if ! gum confirm "Continue with uninstallation?"; then
        print_info "Uninstallation cancelled"
        exit 0
    fi

    echo ""

    # Remove Hyprland configuration
    remove_symlink "$CONFIG_DIR/hypr" "Hyprland"

    # Remove Waybar configuration
    remove_symlink "$CONFIG_DIR/waybar" "Waybar"

    # Future configurations
    # remove_symlink "$CONFIG_DIR/kitty" "Kitty"

    echo ""
    print_success "Uninstallation complete!"
    echo ""
    print_info "Your backup files (if any) are still in ~/.config-backup-*/"
    print_info "To restore a backup, copy files from backup directory to ~/.config/"
    echo ""
}

# Show help
show_help() {
    cat << EOF
Dotfiles Uninstallation Script

Usage: ./uninstall.sh [OPTIONS]

Options:
    -h, --help      Show this help message
    -f, --force     Skip confirmation prompts

This script will:
    1. Remove symlinks created by install.sh
    2. Leave backup files intact

To restore a backup:
    cp -r ~/.config-backup-TIMESTAMP/* ~/.config/
EOF
}

# Parse arguments
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run uninstallation
if [ "$FORCE" = false ]; then
    main
else
    # Skip confirmation if force flag is set
    print_info "Starting dotfiles uninstallation (forced)"
    echo ""
    remove_symlink "$CONFIG_DIR/hypr" "Hyprland"
    remove_symlink "$CONFIG_DIR/waybar" "Waybar"
    echo ""
    print_success "Uninstallation complete!"
fi
