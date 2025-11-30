#!/usr/bin/env bash

# tests/verify-installation.sh
#
# This script verifies that the dotfiles installer has run correctly in a "real"
# installation scenario. It checks for the presence of key symlinks, installed
# packages, and the final state of the installation.

set -e

# Helper function for logging
log() {
  echo "✔ $*"
}

# Verification functions
verify_symlinks() {
  log "Verifying symlinks..."
  local dotfiles_dir
  dotfiles_dir=$(pwd) # Assuming the script is run from the repo root

  # Check a few key symlinks
  if [[ ! -L "$HOME/.config/hypr" || "$(readlink "$HOME/.config/hypr")" != "$dotfiles_dir/hyprland" ]]; then
    echo "Hyprland symlink is incorrect."
    exit 1
  fi

  if [[ ! -L "$HOME/.config/kitty" || "$(readlink "$HOME/.config/kitty")" != "$dotfiles_dir/kitty" ]]; then
    echo "Kitty symlink is incorrect."
    exit 1
  fi

  # Neovim config is copied (not symlinked) to avoid path resolution issues with LazyVim
  if [[ ! -d "$HOME/.config/nvim" ]]; then
    echo "Neovim config directory not found."
    exit 1
  fi
  # Verify key files exist (they should be regular files, not symlinks)
  if [[ ! -f "$HOME/.config/nvim/init.lua" ]]; then
    echo "Neovim init.lua not found."
    exit 1
  fi
  log "All symlinks verified."
}

verify_packages() {
  log "Verifying packages..."
  # Check for a core package
  if ! pacman -Qi neovim >/dev/null; then
    echo "Neovim is not installed."
    exit 1
  fi

  # Check for a GUI package
  if ! pacman -Qi kitty >/dev/null; then
    echo "Kitty is not installed."
    exit 1
  fi

  # Check for an AUR package (also tests yay)
  if ! pacman -Qi catppuccin-gtk-theme-frappe >/dev/null; then
    echo "catppuccin-gtk-theme-frappe is not installed."
    exit 1
  fi
  log "All packages verified."
}

verify_state() {
  log "Verifying state file..."
  local state_file="$HOME/.local/state/dots/install-state.json"

  if [[ ! -f "$state_file" ]]; then
    echo "State file not found."
    exit 1
  fi

  local status
  status=$(jq -r '.status' "$state_file")

  if [[ "$status" != "completed" ]]; then
    echo "Installation status is '$status', not 'completed'."
    exit 1
  fi
  log "State file verified."
}

# Main execution
main() {
  log "Starting installation verification..."
  verify_symlinks
  verify_packages
  verify_state
  log "Installation verified successfully!"
}

main
