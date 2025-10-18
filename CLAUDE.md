# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a dotfiles repository for Arch Linux and Hyprland window manager configuration. It serves as a staging area for configuration files before deployment via symlinks to the system.

## Architecture Overview

### Symlink-Based Deployment Model

This repository uses a **symlink-based architecture** where configuration files live in the repository and are symlinked to `~/.config/`:

- Repository files remain editable via git while being actively used by the system
- Changes to files in this repo immediately affect the running system
- `install.sh` creates symlinks: `~/.config/hypr` → `./hyprland/`, etc.
- Backups are created before symlinking: `~/.config-backup-TIMESTAMP/`
- `uninstall.sh` removes symlinks (backups are preserved)

### Modular Configuration System

**Hyprland** uses a modular approach (hyprland/conf/):
- `hyprland.conf` is the main entry point that sources all modular configs
- Each `.conf` file handles a specific concern (theme, keybinds, animations, etc.)
- Modifications should be made to individual modular files, not the main file
- Location: `hyprland/conf/*.conf`

**All configurations** follow the Catppuccin Frappe color scheme:
- Theme colors defined in: `hyprland/conf/theme.conf`
- Waybar styling: `waybar/style.css`
- Terminal: `kitty/kitty.conf`
- Shell prompt: `starship/starship.toml`
- See component README.md files for color references

### Package Management Strategy

Packages are organized by category in `packages/*.txt`:
- `core.txt` - Essential Hyprland system packages
- `hypr-ecosystem.txt` - Hypr-specific tools (hyprpaper, hypridle, etc.)
- `theming.txt` - Fonts (Nerd Fonts required), icons, cursors, GTK themes
- `development.txt` - Python, C++, Neovim, LazyVim, Node.js, Starship, build tools
- `productivity.txt` - LibreOffice, PDF viewer, file manager, Discord
- `aur.txt` - AUR packages (waypaper, quickwall, SwayOSD, VS Code, Catppuccin GTK themes)

The `install.sh` script handles:
- Repository configuration and mirrorlist optimization
- Conflict resolution (e.g., PulseAudio → PipeWire, NetworkManager → iwd migration)
- Automatic yay installation for AUR packages
- LazyVim setup with Catppuccin theme integration
- Wallpaper collection setup (clones ~50-200 Catppuccin Frappe wallpapers)
- Service management (enables iwd service for network connectivity)

## Common Development Commands

### Installation and Deployment

```bash
# Fresh installation with all packages (recommended for new systems)
./install.sh --packages-all

# Interactive package selection
./install.sh --packages

# Config-only installation (no packages)
./install.sh

# Remove symlinks
./uninstall.sh

# Show installation options
./install.sh --help
```

### Configuration Management

```bash
# Reload Hyprland configuration (test changes)
hyprctl reload

# Check for configuration errors
hyprctl configerrors

# Validate Hyprland config and collect diagnostics
./collect-errors.sh

# View current monitor settings
hyprctl monitors

# View active windows
hyprctl clients
```

### Network Management (iwd)

```bash
# Launch impala TUI for WiFi management
impala

# Interactive iwctl session (alternative)
iwctl

# Common iwctl commands
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "SSID"

# Check iwd service status
systemctl status iwd

# Enable/disable iwd service
sudo systemctl enable --now iwd
sudo systemctl disable iwd
```

### Wallpaper Management

```bash
# Launch waypaper GUI to browse wallpapers
waypaper

# Download new wallpaper from Unsplash
quickwall
quickwall --search "landscape"

# Manual hyprctl commands
hyprctl hyprpaper preload ~/path/to/wallpaper.png
hyprctl hyprpaper wallpaper ",~/path/to/wallpaper.png"
hyprctl hyprpaper listloaded

# Wallpaper collection location
ls ~/.local/share/catppuccin-wallpapers/frappe/
```

### Testing and Debugging

```bash
# Run through testing checklist
cat TESTING.md

# Comprehensive system diagnostic (RECOMMENDED - checks everything)
./system-check.sh

# Specific diagnostics:
./collect-errors.sh    # Hyprland config validation and logs only
./debug-packages.sh    # Package installation issues only

# Check service status
pgrep waybar
pgrep mako
systemctl --user status pipewire

# View Hyprland logs
tail -f ~/.local/share/hyprland/hyprland.log

# Test notifications
notify-send "Test" "This is a test notification"

# Reload Waybar
pkill -USR2 waybar
```

### Manual Package Management

```bash
# Install specific package category
sudo pacman -S --needed - < packages/core.txt
sudo pacman -S --needed - < packages/development.txt

# Install AUR packages (requires yay or paru)
yay -S --needed - < packages/aur.txt

# Check installed package versions
hyprctl version
waybar --version
```

## Configuration File Locations

When editing configurations, files are in this repository but active via symlinks:

| Component | Repository Path | System Symlink Target |
|-----------|----------------|----------------------|
| Hyprland | `./hyprland/` | `~/.config/hypr/` |
| Waybar | `./waybar/` | `~/.config/waybar/` |
| Kitty | `./kitty/` | `~/.config/kitty/` |
| Rofi | `./rofi/` | `~/.config/rofi/` |
| Mako | `./mako/` | `~/.config/mako/` |
| Zathura | `./zathura/` | `~/.config/zathura/` |
| wlogout | `./wlogout/` | `~/.config/wlogout/` |
| SDDM | `./sddm/theme.conf` | `/etc/sddm.conf.d/theme.conf` |
| Starship | `./starship/starship.toml` | `~/.config/starship.toml` |
| Neovim | `./nvim/lua/` | `~/.config/nvim/lua/` (files symlinked into LazyVim) |

## Key Design Decisions

1. **Catppuccin Frappe Everywhere**: All theming must use the Catppuccin Frappe palette. Color definitions are in `hyprland/conf/theme.conf`.

2. **LazyVim Integration**: The install script clones LazyVim starter and then symlinks custom configurations from `./nvim/lua/`. Changes to the dots repo immediately affect the active Neovim config. This allows upstream LazyVim updates while preserving customizations.

   **Critical Catppuccin Fix**: The minimal colorscheme config overrides `NormalFloat` background to match `base` color instead of the default darker `mantle`. This fixes color mismatches in Snacks.explorer, completion menus, and all floating windows. Additional highlight overrides ensure consistent Frappe colors across all UI elements.

3. **Conflict Resolution**: The install script automatically resolves package conflicts (e.g., PulseAudio → PipeWire, NetworkManager → iwd) using `pacman --ask=4`.

4. **Repository Management**: The install script checks and fixes repository configuration, optimizes mirrorlist with reflector, and syncs databases before installation.

5. **XDG Base Directory Compliance**: All configurations follow XDG standards and are placed in `~/.config/`.

6. **Network Management**: Uses iwd (modern wireless daemon) with impala (TUI frontend). This replaces NetworkManager for a lighter, more efficient WiFi management solution. Waybar network module opens impala on click for interactive WiFi management. Use `impala` for the friendly TUI or `iwctl` for command-line control.

7. **Wallpaper Management**: Uses waypaper (GUI) + hyprpaper (backend) + Catppuccin wallpaper collection. The install script automatically clones a curated collection of ~50-200 Frappe wallpapers to `~/.local/share/catppuccin-wallpapers/`. ImageMagick is excluded to avoid package conflicts; waypaper provides a better user experience for wallpaper selection.

## Troubleshooting Workflow

When configuration or system issues arise:

1. **Run comprehensive diagnostic** (recommended):
   ```bash
   ./system-check.sh
   ```
   This checks ALL components: packages, services, configs, logs, permissions, etc.
   Output saved to `system-check-output.txt`

2. **Or use specific diagnostics**:
   - `./collect-errors.sh` - Hyprland config validation and logs only
   - `./debug-packages.sh` - Package installation issues only

3. **Review the output**:
   ```bash
   less system-check-output.txt
   # or
   cat debug-output.txt
   ```

4. **If on a remote machine**, commit and push the diagnostic output:
   ```bash
   git add system-check-output.txt
   git commit -m "Add system diagnostic from target machine"
   git push origin main
   ```

5. **Pull on development machine and analyze**:
   ```bash
   git pull && less system-check-output.txt
   ```

## Component Documentation

Each major component has its own README.md with detailed configuration information:
- `hyprland/README.md` - Hyprland settings, keybinds, window rules
- `waybar/README.md` - Waybar modules, styling, icons
- `wlogout/README.md` - Wayland logout menu with Catppuccin Frappe theme
- `sddm/README.md` - SDDM login manager theme configuration with Catppuccin Frappe
- `tailscale/README.md` - Tailscale mesh VPN and tsui terminal interface setup
- `fprintd/README.md` - Fingerprint authentication setup and PAM configuration
- `starship/README.md` - Starship shell prompt configuration with Catppuccin Frappe theme
- `packages/README.md` - Package organization and installation details
- `hyprland/wallpapers/README.md` - Wallpaper setup with hyprpaper

Refer to component READMEs for specific customization guidance.
