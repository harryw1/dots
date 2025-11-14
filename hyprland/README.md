# Hyprland Configuration

A modular, aesthetic Hyprland configuration with **Catppuccin Frappe** theming.

## Features

- **Modular structure**: Easy to customize and maintain
- **Catppuccin Frappe theme**: Beautiful pastel color palette
- **Smooth animations**: Custom bezier curves for fluid window movements
- **Beautiful blur effects**: Dynamic blur on panels and windows
- **Responsive design**: Optimized for both keyboard and touchpad
- **Comprehensive keybindings**: Vim-style navigation + arrow keys

## Structure

```
hyprland/
├── hyprland.conf          # Main entry point
└── conf/
    ├── theme.conf         # Catppuccin Frappe colors
    ├── general.conf       # General settings (gaps, borders, layout)
    ├── decorations.conf   # Visual effects (blur, shadows, rounding)
    ├── animations.conf    # Animations and bezier curves
    ├── keybinds.conf      # Keyboard shortcuts
    ├── windowrules.conf   # Window-specific rules
    ├── monitors.conf      # Monitor configuration
    ├── input.conf         # Input device settings
    └── autostart.conf     # Startup applications
```

## Installation

1. **Backup existing configuration** (if any):
   ```bash
   mv ~/.config/hypr ~/.config/hypr.backup
   ```

2. **Create symlink** from this directory:
   ```bash
   ln -s ~/path/to/dots/hyprland ~/.config/hypr
   ```

3. **Install required dependencies**:
   ```bash
   # Core
   sudo pacman -S hyprland waybar mako rofi kitty thunar firefox

   # Utilities
   sudo pacman -S grim slurp wl-clipboard cliphist brightnessctl playerctl

   # Theming
   sudo pacman -S papirus-icon-theme bibata-cursor-theme

   # Optional Hypr ecosystem
   sudo pacman -S hyprpaper hypridle hyprlock hyprpicker
   ```

4. **Reload Hyprland**:
   - Press `SUPER + SHIFT + Q` to exit and restart, or
   - Run `hyprctl reload` to reload config without restarting

## Customization

### Changing Theme Colors

Edit `conf/theme.conf` to modify colors. The Catppuccin palette provides 14 accent colors to choose from.

### Adjusting Monitors

Edit `conf/monitors.conf`:
```bash
# List your monitors
hyprctl monitors all

# Then configure them
monitor = DP-1, 1920x1080@144, 0x0, 1
```

### Modifying Keybindings

Edit `conf/keybinds.conf`. The default modifier is `SUPER` (Windows/Command key).

Key bindings:
- `SUPER + RETURN`: Terminal
- `SUPER + SPACE`: App launcher
- `SUPER + E`: File manager
- `SUPER + B`: Browser
- `SUPER + I`: Package manager (pacseek)
- `SUPER + Q`: Close window
- `SUPER + F`: Fullscreen
- `SUPER + V`: Toggle floating
- `SUPER + [1-9]`: Switch workspace
- `SUPER + SHIFT + [1-9]`: Move window to workspace

### Adjusting Animations

Edit `conf/animations.conf` to change animation speeds and bezier curves.

### Window Rules

Edit `conf/windowrules.conf` to add application-specific rules (opacity, floating, workspace assignments).

## Dependencies

### Required
- `hyprland` - The compositor
- `waybar` - Status bar
- `mako` - Notification daemon
- `rofi` or `wofi` - Application launcher
- Terminal emulator (`kitty`, `alacritty`, etc.)

### Recommended
- `hyprpaper` - Wallpaper daemon
- `hypridle` - Idle management
- `hyprlock` - Screen locker
- `hyprpicker` - Color picker
- `grim` + `slurp` - Screenshots
- `wl-clipboard` - Clipboard support
- `cliphist` - Clipboard history
- `brightnessctl` - Brightness control
- `playerctl` - Media controls
- `pacseek` - TUI package manager (press SUPER+I)

### Theming
- `papirus-icon-theme` - Icon theme
- `bibata-cursor-theme` - Cursor theme
- `qt6ct` - Qt theme configuration

## Troubleshooting

### Monitors not working
Run `hyprctl monitors all` and update `conf/monitors.conf` with your monitor names.

### Applications not starting
Check `conf/autostart.conf` and ensure all applications are installed.

### Blur not working
Check if your GPU supports the required OpenGL features. You can disable blur in `conf/decorations.conf`.

### Keybindings not working
Verify that `xkb-switch` or similar tools aren't conflicting. Check your keyboard layout in `conf/input.conf`.

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Catppuccin for Hyprland](https://github.com/catppuccin/hyprland)
