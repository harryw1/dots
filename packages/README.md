# Package Lists

This directory contains package lists organized by category for easy installation on Arch Linux.

## Package Files

### Core Packages (Always Installed)

- **`core.txt`** - Core system packages (headless compatible)
  - Network management (iwd, tailscale)
  - Bluetooth (bluez)
  - Audio (PipeWire)
  - Version control (git)
  - System utilities (btop, jq, bc, fprintd)
  - Archive utilities (unzip, zip)
  - File utilities (tree, less)
  - Note: tsui (Tailscale TUI) is automatically installed during service configuration

- **`theming.txt`** - Visual theming packages
  - GTK and Qt themes
  - Icon themes (Papirus)
  - Cursor themes
  - Fonts (Nerd Fonts, Noto, Font Awesome)

- **`development.txt`** - Development tools
  - Python (pip, virtualenv, ipython)
  - C++ (gcc, clang, cmake, gdb, lldb)
  - Build essentials
  - Neovim with LazyVim
  - Lua and LuaRocks (required for Neovim plugins with native dependencies)

- **`tui.txt`** - Terminal User Interface applications (DEFAULT)
  - System monitoring (btop, ncdu, bandwhich)
  - File management (yazi, fd, ripgrep, fzf)
  - Git tools (lazygit, delta)
  - Audio control (pulsemixer)
  - Terminal multiplexer (tmux/zellij)
  - Productivity (taskwarrior, newsboat)
  - Modern CLI replacements (bat, eza, zoxide, dust, procs)

- **`aur.txt`** - Core AUR packages
  - Catppuccin themes
  - TUI tools (pacseek, bluetuith)
  - CLI utilities (quickwall)

### GUI Packages (Optional - Install with --gui or --full)

- **`gui-essential.txt`** - Essential Hyprland GUI
  - Hyprland compositor
  - Waybar, Mako, Rofi
  - Kitty terminal
  - File manager (Thunar)
  - Screenshot tools, utilities
  - Zathura (PDF), imv (images)

- **`gui-essential-aur.txt`** - Essential GUI AUR packages
  - SwayOSD, wlogout, waypaper

- **`gui-browsers.txt`** - Web browsers
  - Firefox

- **`gui-productivity.txt`** - Office and productivity
  - LibreOffice suite
  - Thunderbird email
  - Document tools (pandoc, LaTeX)
  - Calculator, note-taking (Obsidian)

- **`gui-communication.txt`** - Communication apps (AUR)
  - Discord, Slack, Zoom

## Installation

### TUI-First Default

**By default, the installer installs only TUI applications** (headless compatible).

GUI components are optional and require explicit flags or interactive selection.

### Using the install script (recommended)

```bash
# Default: TUI-only installation (headless compatible)
./install.sh

# Interactive GUI selection (prompts for which GUI components to install)
./install.sh --gui

# Minimal/headless (same as default - explicit)
./install.sh --minimal

# Full installation (all GUI components)
./install.sh --full
```

### Manual installation

```bash
# Install core packages
sudo pacman -S --needed - < packages/core.txt

# Install specific category
sudo pacman -S --needed - < packages/theming.txt

# Install an AUR helper first (if you don't have one)
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Then install AUR packages
yay -S --needed - < packages/aur.txt
# or with paru
paru -S --needed - < packages/aur.txt
```

### Using pacseek for package management

After installation, you can use `pacseek` for a visual TUI interface to search, install, and manage packages:

```bash
pacseek
```

### Individual packages

You can also install packages individually:

```bash
sudo pacman -S hyprland waybar kitty
```

## Adding Packages

To add new packages:

1. Open the appropriate `.txt` file
2. Add the package name on a new line
3. Add a comment (starting with `#`) to describe the package if needed
4. Commit the changes

Example:
```
# My favorite text editor
neovim
```

## Package Organization

Packages are organized to allow flexibility:
- Install only what you need
- Skip categories that don't apply to your use case
- Easy to maintain and update

## Dependencies

All package files are designed to work with `pacman -S --needed`, which:
- Only installs packages that aren't already installed
- Safely handles dependencies
- Can be run multiple times without issues
