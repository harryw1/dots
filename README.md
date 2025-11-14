# Dotfiles Configuration

A comprehensive collection of Linux dotfiles for a modern Wayland-based desktop environment, featuring **Catppuccin Frappe** theming throughout.

## Overview

This repository contains configuration files for a complete Linux desktop setup, including:

- **Window Manager**: Hyprland (Wayland compositor)
- **Status Bar**: Waybar
- **Application Launcher**: Rofi
- **Notifications**: Mako
- **Terminal**: Kitty
- **Shell**: zsh with menu selection (bash also supported)
- **Shell Prompt**: Starship
- **Editor**: Neovim (LazyVim)
- **File Manager**: Thunar
- **And more...**

All configurations use the **Catppuccin Frappe** color scheme for a cohesive, beautiful aesthetic.

## Installation

### Quick Start (Recommended)

The easiest way to install is using the bootstrap installer. It handles everything automatically:

**TUI-only installation** (default - headless compatible):
```bash
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash
```

**Interactive GUI selection**:
```bash
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --gui
```

**Full installation** (all GUI components):
```bash
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --full
```

### What the Bootstrap Installer Does

The bootstrap script will:
1. Clone the repository to `~/.local/share/dots`
2. Check prerequisites (Arch Linux, git, sudo, jq)
3. Run the full installer which handles:
   - System preparation (repositories, mirrorlist optimization)
   - Package installation (TUI-first by default, GUI optional)
   - Configuration deployment (symlinks to `~/.config/`)
   - Service configuration (iwd, fprintd, Tailscale)
   - Post-installation setup (wallpapers, final checks)

### Advanced Bootstrap Options

```bash
# Preview what will be installed (dry-run, no sudo needed)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  bash -s -- --dry-run

# Skip packages, only deploy configs
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  bash -s -- --skip-packages

# With custom configuration
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  CONFIG_URL=https://example.com/my-config.conf bash

# From a specific branch
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  REPO_BRANCH=develop bash
```

### Local Installation (Alternative)

For local development or if you prefer not to use curl | bash:

```bash
# Clone repository
git clone https://github.com/harryw1/dots.git ~/.local/share/dots
cd ~/.local/share/dots

# Run installer
./install.sh                    # TUI-only (default)
./install.sh --gui              # Interactive GUI selection
./install.sh --full             # Install everything
./install.sh --skip-packages    # Only deploy configurations
./install.sh --dry-run          # Preview what will be installed
./install.sh --resume           # Continue after a failure
```

### Installation Modes

- **Default (TUI-only)**: Terminal applications only (yazi, lazygit, btop, pulsemixer, etc.) - headless compatible
- **--gui**: Interactive prompt to select GUI components
- **--full**: Install all GUI components (Hyprland, Waybar, Firefox, etc.)

## Post-Installation

After installation, complete these steps:

1. **Select a wallpaper** (required for transparency effects):
   ```bash
   waypaper  # Browse Catppuccin Frappe wallpaper collection
   ```

2. **Apply theme changes**: Log out and log back in for GTK themes to apply

3. **Configure Firefox dark mode**: Open Firefox → `about:preferences` → General → Website appearance → Choose "Dark"

## Keybindings

### Hyprland (SUPER key = Windows/Command key)

- `SUPER + RETURN` - Open terminal (Kitty)
- `SUPER + SPACE` - Application launcher (Rofi)
- `SUPER + E` - File manager (Thunar)
- `SUPER + B` - Browser (Firefox)
- `SUPER + Q` - Close window
- `SUPER + F` - Toggle fullscreen
- `SUPER + [1-9]` - Switch workspace
- `SUPER + SHIFT + [1-9]` - Move window to workspace
- `SUPER + H/J/K/L` - Move focus (vim-style)
- `Print` - Screenshot (Grim + Slurp)

See `hypr/conf/keybinds.conf` for complete keybinding reference.

## Customization

Each configuration directory contains its own README with customization instructions. Key files to modify:

- **Hyprland**: `hypr/conf/theme.conf` for colors, `hypr/conf/keybinds.conf` for keybindings
- **Waybar**: `waybar/config.jsonc` for modules, `waybar/style.css` for styling
- **Neovim**: `nvim/lua/plugins/` for plugin configuration
- **Kitty**: `kitty/kitty.conf` for terminal settings
- **Starship**: `starship.toml` for prompt customization

## Troubleshooting

### Quick Checks

```bash
# Check Hyprland configuration
hyprctl reload

# Check Waybar status
pgrep waybar && echo "Running" || echo "Not running"

# Comprehensive system check
./system-check.sh

# View installation logs
ls ~/.local/state/dots/logs/
```

### Resume Installation

If installation fails, resume from the last successful phase:

```bash
cd ~/.local/share/dots
./install.sh --resume
```

## System Updates

Keep your system up-to-date:

```bash
cd ~/.local/share/dots
./update.sh              # Full system update
./update.sh --aur-only   # Update only AUR packages
```

## Architecture

This repository uses a **modular, phase-based architecture**:

- **Phase 1**: System preparation (repositories, mirrorlist, conflicts)
- **Phase 2**: Package installation (core, TUI, optional GUI)
- **Phase 3**: Configuration deployment (symlinks to `~/.config/`)
- **Phase 4**: Service management (iwd, fprintd, Tailscale)
- **Phase 5**: Post-installation (wallpapers, final checks)

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [LazyVim Documentation](https://lazyvim.github.io)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

**Note**: This repository is designed for Arch Linux. The installer defaults to TUI-only mode (headless compatible), with GUI components available via `--gui` or `--full` flags.
