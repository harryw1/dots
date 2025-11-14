# Dotfiles Configuration

A comprehensive collection of Linux dotfiles for a modern Wayland-based desktop environment, featuring **Catppuccin Frappe** theming throughout.

## Overview

This repository contains configuration files for a complete Linux desktop setup, including:

- **Window Manager**: Hyprland (Wayland compositor)
- **Status Bar**: Waybar
- **Application Launcher**: Rofi
- **Notifications**: Mako
- **Terminal**: Kitty
- **Shell Prompt**: Starship
- **Editor**: Neovim (LazyVim)
- **File Manager**: Thunar
- **And more...**

All configurations use the **Catppuccin Frappe** color scheme for a cohesive, beautiful aesthetic.

## Repository Structure

```
.config/
├── hypr/              # Hyprland window manager configuration
├── waybar/            # Waybar status bar configuration
├── rofi/              # Rofi application launcher
├── mako/              # Mako notification daemon
├── kitty/             # Kitty terminal emulator
├── nvim/              # Neovim editor (LazyVim)
├── starship.toml      # Starship shell prompt
├── yazi/              # Yazi file manager
├── zathura/           # Zathura PDF viewer
├── wlogout/           # Wlogout logout menu
├── waypaper/          # Waypaper wallpaper daemon
├── pacseek/           # Pacseek package manager TUI
├── lazygit/           # LazyGit Git TUI
├── btop/              # Btop system monitor
├── bluetuith/         # Bluetuith Bluetooth TUI
├── Thunar/            # Thunar file manager
├── xfce4/             # XFCE4 settings
├── gtk-3.0/           # GTK3 theme configuration
├── gtk-4.0/           # GTK4 theme configuration
├── rofi/              # Rofi launcher
└── README.md          # This file
```

## Quick Start

### Prerequisites

- **Arch Linux** (or Arch-based distribution)
- **Hyprland** window manager
- **Git** for cloning/syncing

### Installation

1. **Clone or sync this repository**:
   ```bash
   # If setting up on a new machine:
   git clone git@github.com:harryweiss/dots.git ~/.config
   
   # If already have ~/.config, sync with remote:
   cd ~/.config
   git remote add origin git@github.com:harryweiss/dots.git
   git pull origin main  # or master, depending on your default branch
   ```

2. **Install core dependencies**:
   ```bash
   sudo pacman -S hyprland waybar mako rofi kitty thunar firefox
   sudo pacman -S grim slurp wl-clipboard cliphist brightnessctl playerctl
   sudo pacman -S papirus-icon-theme bibata-cursor-theme
   sudo pacman -S hyprpaper hypridle hyprlock hyprpicker
   ```

3. **Install TUI tools**:
   ```bash
   sudo pacman -S btop starship lazygit yazi zathura
   yay -S bluetuith-bin impala pacseek
   ```

4. **Install Neovim dependencies**:
   ```bash
   sudo pacman -S neovim
   # LazyVim will auto-install on first launch
   ```

5. **Start Hyprland**:
   ```bash
   # From a TTY or display manager
   Hyprland
   ```

## Configuration Details

### Hyprland (`hypr/`)

Modular window manager configuration with:
- Catppuccin Frappe theming
- Smooth animations and blur effects
- Vim-style keybindings
- Comprehensive workspace management

See [hypr/README.md](hypr/README.md) for detailed documentation.

### Waybar (`waybar/`)

Modern status bar with:
- Dynamic DPI scaling
- Multi-monitor support
- TUI integrations (btop, impala, bluetuith)
- Interactive modules

See [waybar/README.md](waybar/README.md) for detailed documentation.

### Neovim (`nvim/`)

LazyVim-based editor configuration with:
- Catppuccin Frappe colorscheme
- LSP support
- Tree-sitter syntax highlighting
- Comprehensive plugin ecosystem

See [nvim/README.md](nvim/README.md) for detailed documentation.

### Kitty (`kitty/`)

Terminal emulator with:
- Catppuccin Frappe theme
- JetBrains Mono Nerd Font
- Optimized performance settings

See [kitty/README.md](kitty/README.md) for detailed documentation.

### Rofi (`rofi/`)

Application launcher with:
- Catppuccin Frappe theme
- Fuzzy matching
- Icon support

See [rofi/README.md](rofi/README.md) for detailed documentation.

### Mako (`mako/`)

Notification daemon with:
- Catppuccin Frappe theme
- Urgency-based styling
- Smart grouping

See [mako/README.md](mako/README.md) for detailed documentation.

## Keybindings

### Hyprland (SUPER key = Windows/Command key)

- `SUPER + RETURN` - Open terminal (Kitty)
- `SUPER + SPACE` - Application launcher (Rofi)
- `SUPER + E` - File manager (Thunar)
- `SUPER + B` - Browser (Firefox)
- `SUPER + I` - Package manager (Pacseek)
- `SUPER + Q` - Close window
- `SUPER + F` - Toggle fullscreen
- `SUPER + V` - Toggle floating
- `SUPER + [1-9]` - Switch workspace
- `SUPER + SHIFT + [1-9]` - Move window to workspace
- `SUPER + H/J/K/L` - Move focus (vim-style)
- `SUPER + SHIFT + H/J/K/L` - Move window
- `SUPER + C` - Color picker (Hyprpicker)
- `Print` - Screenshot (Grim + Slurp)

See `hypr/conf/keybinds.conf` for complete keybinding reference.

## Theming

All configurations use **Catppuccin Frappe** color scheme:

- **Base**: `#303446`
- **Mantle**: `#292c3c`
- **Crust**: `#232634`
- **Text**: `#c6d0f5`

Accent colors available:
- Rosewater, Flamingo, Pink, Mauve
- Red, Maroon, Peach, Yellow
- Green, Teal, Sky, Sapphire
- Blue, Lavender

## Synchronization

This repository is configured to sync with GitHub:

```bash
# Pull latest changes
git pull origin main

# Push local changes
git add .
git commit -m "Update configs"
git push origin main
```

## Customization

Each configuration directory contains its own README with customization instructions. Key files to modify:

- **Hyprland**: `hypr/conf/theme.conf` for colors, `hypr/conf/keybinds.conf` for keybindings
- **Waybar**: `waybar/waybar.jsonc` for modules, `waybar/style.css` for styling
- **Neovim**: `nvim/lua/plugins/` for plugin configuration
- **Kitty**: `kitty/kitty.conf` for terminal settings
- **Starship**: `starship.toml` for prompt customization

## Troubleshooting

### Waybar not starting
```bash
killall waybar
waybar
```

### Hyprland config errors
```bash
hyprctl reload
# Check for errors in output
```

### Neovim plugins not loading
```bash
# Open Neovim and run
:Lazy sync
```

### Monitor configuration
```bash
# List monitors
hyprctl monitors all

# Update hypr/conf/monitors.conf with your monitor names
```

## Dependencies Summary

### Core
- `hyprland` - Window manager
- `waybar` - Status bar
- `mako` - Notifications
- `rofi` - Application launcher
- `kitty` - Terminal

### Utilities
- `grim` + `slurp` - Screenshots
- `wl-clipboard` - Clipboard
- `brightnessctl` - Brightness control
- `playerctl` - Media controls
- `hyprpaper` - Wallpapers
- `hypridle` + `hyprlock` - Idle/lock

### TUI Tools
- `btop` - System monitor
- `starship` - Shell prompt
- `lazygit` - Git TUI
- `yazi` - File manager
- `bluetuith` - Bluetooth manager
- `impala` - WiFi manager
- `pacseek` - Package manager

### Theming
- `papirus-icon-theme` - Icons
- `bibata-cursor-theme` - Cursors
- `ttf-jetbrains-mono-nerd` - Font
- `ttf-firacode-nerd` - Font

## Contributing

This is a personal dotfiles repository. Feel free to fork and adapt for your own use!

## License

Individual configurations may have their own licenses. See respective directories for details.

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [LazyVim Documentation](https://lazyvim.github.io)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)

---

**Note**: This repository is designed for Arch Linux with Hyprland. Adaptations may be needed for other distributions or window managers.

