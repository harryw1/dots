# SDDM Configuration

This directory contains SDDM (Simple Desktop Display Manager) configuration for the Catppuccin Frappe theme.

## Theme

The SDDM theme uses **Catppuccin Frappe Lavender** to match the accent color used throughout the rest of the dotfiles (Hyprland, Waybar, Kitty, etc.).

## Installation

The `install.sh` script will:
1. Install `catppuccin-sddm-theme-frappe` from AUR (includes all 14 color variants)
2. Create `/etc/sddm.conf.d/` directory if it doesn't exist
3. Symlink `theme.conf` to `/etc/sddm.conf.d/theme.conf`

Manual installation:
```bash
# Install the theme from AUR
yay -S catppuccin-sddm-theme-frappe

# Create config directory and symlink
sudo mkdir -p /etc/sddm.conf.d
sudo ln -sf ~/dots/sddm/theme.conf /etc/sddm.conf.d/theme.conf
```

## Available Color Variants

The package includes 14 color variants:
- `catppuccin-frappe-blue`
- `catppuccin-frappe-flamingo`
- `catppuccin-frappe-green`
- `catppuccin-frappe-lavender` (default)
- `catppuccin-frappe-maroon`
- `catppuccin-frappe-mauve`
- `catppuccin-frappe-peach`
- `catppuccin-frappe-pink`
- `catppuccin-frappe-red`
- `catppuccin-frappe-rosewater`
- `catppuccin-frappe-sapphire`
- `catppuccin-frappe-sky`
- `catppuccin-frappe-teal`
- `catppuccin-frappe-yellow`

To change the accent color, edit `theme.conf` and change `Current=catppuccin-frappe-lavender` to your preferred variant.

## Testing

After installation, you can test the SDDM theme without logging out:
```bash
# Preview the theme (opens a test window)
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/catppuccin-frappe-lavender
```

Or simply log out to see the actual login screen.

## Package Information

- **AUR Package**: `catppuccin-sddm-theme-frappe`
- **Theme Location**: `/usr/share/sddm/themes/catppuccin-frappe-*`
- **Config Location**: `/etc/sddm.conf.d/theme.conf` (symlink)
- **Repository**: https://github.com/catppuccin/sddm
