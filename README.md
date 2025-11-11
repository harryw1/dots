# Hyprland Dotfiles

A modular, robust installation system for Arch Linux with Hyprland window manager and Catppuccin Frappe theming.

## Features

- **Modular Architecture**: Phase-based installation with state tracking and resume capability
- **Catppuccin Frappe Theme**: Beautiful, consistent theming across all components
- **State Management**: Resume installations after failures, track progress
- **Remote Installation**: Bootstrap from a single curl command
- **Configuration System**: Customize installation behavior with config files
- **Comprehensive Logging**: Detailed logs for debugging and troubleshooting

## Installation

### TUI-First Philosophy

**This installer defaults to TUI-only mode** (headless compatible). GUI components are optional.

- **Default**: Terminal applications only (yazi, lazygit, btop, pulsemixer, etc.)
- **Optional**: Hyprland GUI via `--gui` or `--full` flags

### Quick Start (Recommended)

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

The bootstrap script will:
- Clone the repository to `~/.local/share/dots`
- Install core system + TUI applications (default)
- Optionally install GUI components (if --gui or --full used)
- Deploy all configurations with Catppuccin Frappe theming

### Advanced Usage

```bash
# Preview what will be installed (dry-run, no sudo needed)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  bash -s -- --dry-run

# With custom configuration
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  CONFIG_URL=https://example.com/my-config.conf bash

# Skip packages, only deploy configs
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  bash -s -- --skip-packages

# From a specific branch (for testing)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  REPO_BRANCH=develop bash
```

### Local Installation (Alternative Method)

For local development or if you prefer not to use curl | bash:

```bash
# Clone repository
git clone https://github.com/harryw1/dots.git ~/.local/share/dots
cd ~/.local/share/dots

# Complete installation (packages + configs)
./install.sh

# Config-only installation (skip packages)
./install.sh --skip-packages
```

### Installation Options

```bash
./install.sh [OPTIONS]

Installation Modes:
  --gui                   Prompt for GUI components (interactive)
  --minimal               TUI-only install (default, headless compatible)
  --full                  Install everything (all GUI components)
  --headless              Same as --minimal (alias)

Other Options:
  -h, --help              Show help message
  -f, --force             Skip confirmation prompts (for automation)
  --skip-packages         Skip package installation (configs only)
  --no-tui                Disable TUI welcome screen
  --dry-run               Show what would be done without doing it
  --resume                Resume from last failed phase
  --reset                 Reset state and start fresh
  --config FILE           Use custom configuration file

Examples:
  ./install.sh                    # TUI-only installation (default)
  ./install.sh --gui              # Interactive GUI selection
  ./install.sh --full             # Install everything
  ./install.sh --skip-packages    # Only deploy configurations
  ./install.sh --dry-run          # Preview what will be installed
  ./install.sh --force --full     # Automated full installation
  ./install.sh --resume           # Continue after a failure
```

### What Gets Installed

The installation process handles everything automatically:

1. **System Preparation**:
   - Repository configuration and mirrorlist optimization
   - Package database sync
   - Conflict resolution (PulseAudio → PipeWire, NetworkManager → iwd)
   - Migration system for updates

2. **Package Installation**:
   - **Always installed** (TUI-first): Core system, TUI applications, development tools, theming
   - **Optional GUI** (--gui or --full): Hyprland, Waybar, Firefox, LibreOffice, Discord/Slack
   - **Default behavior**: TUI-only (headless compatible, no GUI components)
   - Automatic yay installation for AUR packages

3. **Configuration Deployment**:
   - Backup existing configs to `~/.config-backup-TIMESTAMP/`
   - Symlink configs from repository to `~/.config/`
   - LazyVim setup with Catppuccin Frappe theme
   - Bash aliases and shell configuration
   - SDDM login manager theme

4. **Service Configuration**:
   - iwd for WiFi management (replaces NetworkManager)
   - fprintd for fingerprint authentication
   - Tailscale VPN service

5. **Post-Installation**:
   - Catppuccin Frappe wallpaper collection (~50-200 wallpapers)
   - Final system checks and validation

See [packages/README.md](packages/README.md) for package details.

### Customizing Installation

Create a custom configuration file to control installation behavior:

```bash
# Copy example config
cp install.conf.example install.conf

# Edit configuration
nano install.conf

# Run installation with custom config
./install.sh --config install.conf
# Or if named 'install.conf', it's loaded automatically
./install.sh
```

See [install.conf.example](install.conf.example) for all available options.

### Post-Installation Setup

After running `./install.sh`, complete these essential steps:

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

### State Management and Resume

The installer tracks progress and can resume after failures:

```bash
# If installation fails, resume from last successful phase
./install.sh --resume

# Reset state and start fresh
./install.sh --reset

# Check state
cat ~/.local/state/dots/install-state.json

# View logs
ls ~/.local/state/dots/logs/
```

State file location: `~/.local/state/dots/install-state.json`
Logs location: `~/.local/state/dots/logs/`

### Uninstall

To remove the symlinks:
```bash
./uninstall.sh
```

Backups are preserved in `~/.config-backup-TIMESTAMP/`

## Architecture

This repository uses a **modular, phase-based architecture**:

```
install/
├── lib/                    # Shared libraries (sourced first)
│   ├── colors.sh              # Color definitions and Catppuccin Frappe palette
│   ├── tui.sh                 # TUI helper functions (draw_box, progress bars)
│   ├── utils.sh               # Common utility functions
│   ├── logging.sh             # Logging system (file + console)
│   └── state.sh               # State management (tracking, resume)
│
├── preflight/              # Phase 1: System preparation
│   ├── trap-errors.sh         # Error handling and recovery
│   ├── check-system.sh        # Verify Arch Linux, dependencies
│   ├── repositories.sh        # Configure pacman repos
│   ├── mirrorlist.sh          # Optimize mirrorlist with reflector
│   ├── conflicts.sh           # Resolve package conflicts
│   └── migrations.sh          # Migration system for updates
│
├── packages/               # Phase 2: Package installation
│   ├── utils.sh               # Shared package utilities
│   ├── core.sh                # Core Hyprland packages
│   ├── hypr-ecosystem.sh      # Hypr-specific tools
│   ├── theming.sh             # Fonts, icons, themes
│   ├── development.sh         # Development tools
│   ├── productivity.sh        # Productivity apps
│   └── aur.sh                 # AUR packages (with yay auto-install)
│
├── config/                 # Phase 3: Configuration deployment
│   ├── hyprland.sh            # Hyprland window manager config
│   ├── waybar.sh              # Waybar status bar
│   ├── kitty.sh               # Kitty terminal
│   ├── neovim.sh              # LazyVim with Catppuccin
│   ├── starship.sh            # Starship shell prompt
│   ├── bash.sh                # Bash aliases and config
│   └── misc-configs.sh        # Rofi, Mako, Zathura, btop, etc.
│
├── services/               # Phase 4: Service management
│   ├── network.sh             # iwd WiFi management
│   ├── fingerprint.sh         # fprintd authentication
│   └── tailscale.sh           # Tailscale VPN
│
└── post-install/           # Phase 5: Final setup
    ├── wallpapers.sh          # Catppuccin wallpaper collection
    └── finalize.sh            # Final checks and summary
```

### Key Design Principles

1. **Symlink-Based Deployment**: Config files remain in the repo and are symlinked to `~/.config/`, so git changes immediately affect the system.

2. **Modular Organization**: Each phase is broken into small, focused scripts. Easy to understand, test, and modify.

3. **Idempotent Operations**: Safe to run multiple times. Scripts check state before making changes.

4. **State Tracking**: Installation progress is tracked in `~/.local/state/dots/install-state.json`. Enables resume functionality.

5. **Comprehensive Logging**: All output logged to `~/.local/state/dots/logs/` with timestamps. Valuable for debugging.

6. **Error Recovery**: Error traps provide clear messages and recovery instructions. --resume flag continues from failures.

7. **Catppuccin Frappe Everywhere**: Consistent theming across all components using the Frappe color palette.

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

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

## System Updates

Keep your system up-to-date with the included update script:

```bash
# Full system update (official + AUR packages)
./update.sh

# Auto-confirm all prompts (unattended update)
./update.sh -y

# Update only AUR packages
./update.sh --aur-only

# Update only official repository packages
./update.sh --official-only

# Skip optional maintenance
./update.sh --skip-clean --skip-orphans

# Show all options
./update.sh --help
```

The update script:
- Updates all official repository packages (pacman)
- Updates all AUR packages (yay/paru)
- Optionally optimizes mirrorlist for faster downloads
- Optionally cleans package cache to free disk space
- Optionally removes orphaned packages
- Detects .pacnew files needing manual review
- Matches Catppuccin Frappe TUI design

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Key points:
- Follow the modular architecture
- Maintain Catppuccin Frappe theming
- Ensure idempotent operations
- Add comprehensive logging
- Update documentation
- Test thoroughly before submitting PRs

## Migration from Previous Versions

If you're upgrading from the old monolithic `install.sh`, see [MIGRATION.md](MIGRATION.md) for details.

The new modular system is **backward compatible** - existing usage patterns still work.

## Goals

- Python development tools ✅
- C++ development tools ✅
- Office productivity tools ✅
- WiFi management (iwd + impala TUI) ✅
- Bluetooth management (blueman GUI) ✅
- Catppuccin Frappe aesthetic throughout ✅
- Modular, maintainable codebase ✅
- State tracking and resume capability ✅
