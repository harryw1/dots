This repository serves as a staging area for dotfiles and configuration for Arch Linux with Hyprland window manager.

## Installation

### Quick Start

```bash
# Install configs and packages (interactive)
./install.sh --packages

# Or just install configs (skip packages)
./install.sh
```

### Installation Options

**Complete installation (recommended for fresh systems):**
```bash
./install.sh --packages-all
```
This will automatically:
1. Sync package databases to ensure latest versions
2. Resolve package conflicts (e.g., PulseAudio → PipeWire)
3. Install ALL packages from all categories:
   - Core Hyprland packages (Waybar, Mako, etc.)
   - Hypr ecosystem tools (hyprpaper, hypridle, hyprlock)
   - Theming (Catppuccin themes, Nerd Fonts, icons)
   - Development tools (Python, C++, Neovim, LazyVim)
   - Productivity (LibreOffice, PDF tools, Discord, etc.)
   - **AUR packages** (waypaper, quickwall, SwayOSD, VS Code, etc.)
4. Install yay AUR helper if not present
5. Clone Catppuccin Frappe wallpaper collection (~50-200 wallpapers)
6. Backup existing configs to `~/.config-backup-TIMESTAMP/`
7. Create symlinks from this repository to `~/.config/`
8. Set up LazyVim with Catppuccin Frappe theme

**Interactive installation (choose which package groups to install):**
```bash
./install.sh --packages
```
Shows a menu to selectively install package groups.

**Config-only installation (skip package installation):**
```bash
./install.sh
```
Only creates symlinks, doesn't install any packages.

**Show all options:**
```bash
./install.sh --help
```

### Post-Installation Setup

After running `./install.sh --packages-all`, complete these essential steps:

1. **Browse and select a wallpaper** (required for transparency effects):
   ```bash
   # Launch waypaper GUI to browse the Catppuccin Frappe collection
   waypaper
   ```
   - The install script automatically cloned 50-200 curated Catppuccin Frappe wallpapers
   - Collection location: `~/.local/share/catppuccin-wallpapers/frappe/`
   - Click any wallpaper to set it via hyprpaper
   - See `~/.config/hypr/wallpapers/README.md` for more options

2. **Apply theme changes**: Log out and log back in to Hyprland for GTK themes to apply (enables dark mode for Thunar, LibreOffice, etc.)

3. **Configure Firefox dark mode**: Open Firefox → `about:preferences` → General → Website appearance → Choose "Dark"

4. **Optional**: Customize monitor scaling, keybinds, or animations (see Configuration section below)

### Package Management

Packages are organized in the `packages/` directory:
- `core.txt` - Essential Hyprland packages (Waybar, Mako, Kitty, etc.)
- `hypr-ecosystem.txt` - Hypr tools (hyprpaper, hypridle, hyprlock, hyprpicker)
- `theming.txt` - Fonts, icons, cursors, themes
- `development.txt` - Python, C++, Neovim, build tools
- `productivity.txt` - LibreOffice, PDF viewer, Discord, etc.
- `aur.txt` - AUR packages (SwayOSD, VS Code, Catppuccin themes, etc.)

**All packages are automatically installed** when you run `./install.sh --packages-all`, including:
- Automatic yay installation for AUR packages
- SwayOSD for volume/brightness OSD
- All Nerd Fonts for Waybar icons
- Waypaper GUI wallpaper manager + Catppuccin wallpaper collection
- QuickWall for downloading wallpapers from Unsplash
- Complete Catppuccin Frappe theming

See [packages/README.md](packages/README.md) for details.

### Uninstall

To remove the symlinks:
```bash
./uninstall.sh
```

Backups are preserved in `~/.config-backup-TIMESTAMP/`

## Configuration

- **Hyprland**: Modular configuration with Catppuccin Frappe theme
  - See [hyprland/README.md](hyprland/README.md) for details
- **Waybar**: Status bar with Catppuccin Frappe theme
  - See [waybar/README.md](waybar/README.md) for details

## Testing

After installation, verify everything works correctly:

```bash
# View the testing checklist
cat TESTING.md
```

See [TESTING.md](TESTING.md) for a comprehensive checklist covering:
- Display scaling and visual quality
- Keyboard shortcuts and window management
- Touchpad gestures
- Application launching and theming
- Waybar, Mako, and system utilities
- Performance and troubleshooting

## Troubleshooting

If you encounter configuration errors or issues, use the error collection script:

```bash
./collect-errors.sh
```

This will:
1. Validate Hyprland configuration
2. Collect system logs and version information
3. Check for common configuration issues
4. Save everything to `debug-output.txt`

**To share errors for troubleshooting:**
```bash
# On your target machine
./collect-errors.sh
git add debug-output.txt
git commit -m "Add debug output from target machine"
git push origin main

# Then on your development machine
git pull origin main
cat debug-output.txt
```

**Quick check for Hyprland errors only:**
```bash
hyprctl reload  # Shows config errors if any
```

## Goals

- Python development tools
- C++ development tools
- Office productivity tools
- WiFi management (GUI or TUI)
- Bluetooth management (GUI or TUI)
- Catppuccin Frappe aesthetic throughout
