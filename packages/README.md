# Package Lists

This directory contains package lists organized by category for easy installation on Arch Linux.

## Package Files

- **`core.txt`** - Essential packages required for Hyprland to function
  - Compositor, Wayland support, display utilities
  - Terminal, file manager, launcher
  - Network and Bluetooth management
  - Audio (PipeWire)
  - Basic utilities

- **`hypr-ecosystem.txt`** - Optional Hyprland ecosystem tools
  - hyprpaper (wallpaper daemon)
  - hypridle (idle management)
  - hyprlock (screen locker)
  - hyprpicker (color picker)

- **`theming.txt`** - Visual theming packages
  - GTK and Qt themes
  - Icon themes (Papirus, Adwaita)
  - Cursor themes (Bibata)
  - Fonts (Nerd Fonts, Noto, Font Awesome)

- **`development.txt`** - Development tools
  - Python (pip, virtualenv, ipython)
  - C++ (gcc, clang, cmake, gdb, lldb)
  - Build essentials
  - Text editors (neovim)

- **`productivity.txt`** - Office and productivity applications
  - LibreOffice
  - PDF viewer (Zathura)
  - Image viewer (imv)
  - Document conversion (Pandoc)

- **`aur.txt`** - Arch User Repository packages
  - Catppuccin themes
  - Additional community packages
  - Requires an AUR helper (yay or paru)
  - See file header for AUR helper installation instructions

## Installation

### Using the install script (recommended)

```bash
# Interactive package selection
./install.sh --packages

# Install all packages non-interactively
./install.sh --packages-all
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
