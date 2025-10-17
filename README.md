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

### Comprehensive System Check (Recommended)

For a complete diagnostic of all components, services, and configurations:

```bash
./system-check.sh
```

This comprehensive script checks:
- System information and environment
- All package installation status (core + AUR)
- Service and process status (Waybar, Mako, Hyprpaper, PipeWire, etc.)
- Configuration validation (Hyprland, Waybar, Mako, etc.)
- Log files and recent errors
- File permissions and symlinks
- Display and graphics info
- Network connectivity
- Common issues checklist

Output saved to `system-check-output.txt` with detailed diagnostics.

### Specific Diagnostic Scripts

**Configuration errors only:**
```bash
./collect-errors.sh  # Hyprland config validation and logs
```

**Package installation issues:**
```bash
./debug-packages.sh  # Repository and package availability checks
```

### Sharing Diagnostics

To share diagnostic output for troubleshooting:

```bash
# Run the comprehensive check
./system-check.sh

# Commit and push
git add system-check-output.txt
git commit -m "Add system diagnostic from target machine"
git push origin main

# On your development machine
git pull origin main
cat system-check-output.txt
```

### Quick Checks

**Check Hyprland configuration:**
```bash
hyprctl reload  # Shows config errors if any
```

**Check Waybar status:**
```bash
pgrep waybar && echo "Running" || echo "Not running"
pkill -USR2 waybar  # Reload waybar
```

**View recent Hyprland errors:**
```bash
grep -i error ~/.local/share/hyprland/hyprland.log | tail -20
```

## Goals

- Python development tools
- C++ development tools
- Office productivity tools
- WiFi management (GUI or TUI)
- Bluetooth management (GUI or TUI)
- Catppuccin Frappe aesthetic throughout
