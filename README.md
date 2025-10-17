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

**Install with package selection (recommended for first-time setup):**
```bash
./install.sh --packages
```
This will:
1. Show an interactive menu to select which packages to install
2. Install selected packages (Arch Linux only)
3. Backup any existing configurations to `~/.config-backup-TIMESTAMP/`
4. Create symlinks from this repository to `~/.config/`

**Install all packages non-interactively:**
```bash
./install.sh --packages-all
```

**Skip package installation:**
```bash
./install.sh
```

**Show all options:**
```bash
./install.sh --help
```

### Package Management

Packages are organized in the `packages/` directory:
- `core.txt` - Essential Hyprland packages (required)
- `hypr-ecosystem.txt` - Optional Hypr tools (hyprpaper, hypridle, etc.)
- `theming.txt` - Fonts, icons, cursors
- `development.txt` - Python, C++, build tools
- `productivity.txt` - LibreOffice, PDF viewer, etc.
- `aur.txt` - AUR packages (requires yay or paru)

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

## Goals

- Python development tools
- C++ development tools
- Office productivity tools
- WiFi management (GUI or TUI)
- Bluetooth management (GUI or TUI)
- Catppuccin Frappe aesthetic throughout
