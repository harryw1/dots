# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a dotfiles repository for Arch Linux and Hyprland window manager configuration. It serves as a staging area for configuration files before deployment to the system.

## Configuration Structure

- `hyprland/` - Hyprland window manager configuration files (modular setup)
  - `hyprland.conf` - Main entry point that sources all other configs
  - `conf/` - Modular configuration directory
    - `theme.conf` - Catppuccin Frappe color definitions
    - `general.conf` - General settings (gaps, borders, layout)
    - `decorations.conf` - Visual effects (blur, shadows, rounding)
    - `animations.conf` - Animation settings with custom bezier curves
    - `keybinds.conf` - Keyboard shortcuts
    - `windowrules.conf` - Window-specific rules and layer rules
    - `monitors.conf` - Monitor configuration
    - `input.conf` - Input device settings (keyboard, mouse, touchpad, gestures)
    - `autostart.conf` - Programs to launch on startup
  - `README.md` - Detailed documentation for Hyprland configuration

- `waybar/` - Waybar status bar configuration
  - `config.jsonc` - Main Waybar configuration with module settings
  - `style.css` - Catppuccin Frappe themed styling
  - `README.md` - Waybar documentation and customization guide

## Design Goals

Per README.md, this configuration aims to:
- Support Python and C++ development workflows
- Support office productivity tools
- Include WiFi and Bluetooth management (GUI or TUI)
- Follow Catppuccin Frappe color scheme aesthetic

## Working with Configuration Files

When adding or modifying configuration files:
1. Place configuration files in appropriately named subdirectories (e.g., `hyprland/`, `waybar/`, `kitty/`)
2. Maintain compatibility with Arch Linux package paths and conventions
3. Follow the Catppuccin Frappe color palette when adding theme-related settings
4. Consider both GUI and terminal-based alternatives for system management tools

## Installation/Deployment

Configuration files are deployed using the `install.sh` script, which:
1. Optionally installs packages from `packages/` directory (interactive or all at once)
2. Backs up existing configurations to `~/.config-backup-TIMESTAMP/`
3. Creates symlinks from this repository to `~/.config/` or other XDG Base Directory paths

### Package Management

Packages are tracked in the `packages/` directory:
- `core.txt` - Essential Hyprland packages
- `hypr-ecosystem.txt` - Optional Hypr tools
- `theming.txt` - Fonts, icons, cursors
- `development.txt` - Python, C++, build tools
- `productivity.txt` - Office and productivity tools
- `aur.txt` - AUR packages (requires yay or paru)

Install packages with: `./install.sh --packages` (interactive) or `./install.sh --packages-all` (non-interactive)

Manual installation: `sudo pacman -S --needed - < packages/core.txt`
