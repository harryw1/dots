# Waybar Configuration

A beautiful, responsive Waybar configuration themed with **Catppuccin Frappe** colors, designed for Hyprland.

## Features

- **Catppuccin Frappe theme**: Consistent with Hyprland theme
- **Hyprland integration**: Native workspace and window management
- **Rounded corners**: Modern aesthetic with smooth transitions
- **Interactive modules**: Click and scroll functionality
- **Hover effects**: Visual feedback with glowing effects
- **Icon support**: Nerd Font icons throughout
- **Responsive design**: Adapts to different screen sizes

## Structure

```
waybar/
├── config.jsonc       # Main configuration
├── style.css          # Catppuccin Frappe styling
└── README.md          # This file
```

## Modules

### Left Side
- **Workspaces**: Shows workspaces 1-5 with custom icons
  - Click to switch workspaces
  - Scroll to navigate between workspaces
- **Window**: Displays current window title with app-specific icons

### Center
- **Clock**: Time and date
  - Click to see full date
  - Right-click to show calendar
  - Scroll to navigate calendar

### Right Side
- **Tray**: System tray icons
- **Idle Inhibitor**: Toggle screen sleep (󰅶/󰾪)
- **Audio**: Volume control
  - Click: Open pavucontrol
  - Right-click: Mute/unmute
  - Scroll: Adjust volume
- **Network**: Connection status
  - Click: Open network settings (GUI)
  - Right-click: Open nmtui (TUI)
- **CPU**: CPU usage
  - Click: Open btop
- **Memory**: RAM usage
  - Click: Open btop
- **Battery**: Battery status (if applicable)
- **Power**: Power menu
  - Click: Open wlogout

## Dependencies

### Required
- `waybar` - The status bar
- `font-awesome` - Icons
- `ttf-firacode-nerd` - Primary font with icons

### Optional (for full functionality)
- `pavucontrol` - Audio control GUI
- `nm-connection-editor` - Network settings GUI
- `networkmanager` - Network management
- `btop` - System monitor
- `wlogout` - Logout menu

## Installation

The installation script will automatically symlink this configuration:

```bash
./install.sh --packages
```

Or manually:
```bash
ln -s ~/path/to/dots/waybar ~/.config/waybar
```

## Customization

### Changing Colors

All colors are defined at the top of `style.css` using CSS variables. To change the theme, modify these `@define-color` values.

### Adding/Removing Modules

Edit `config.jsonc`:
1. Add module name to `modules-left`, `modules-center`, or `modules-right`
2. Add module configuration in the configuration section
3. Add styling in `style.css` if needed

### Module Order

Rearrange modules by changing their order in the `modules-*` arrays in `config.jsonc`.

### Font

Change the font in `style.css`:
```css
* {
    font-family: "YourFont", sans-serif;
}
```

### Height and Spacing

Adjust in `config.jsonc`:
```jsonc
{
    "height": 40,
    "spacing": 8,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12
}
```

## Styling

The style uses Catppuccin Frappe color palette:

| Element | Color | Use |
|---------|-------|-----|
| Workspaces (active) | Lavender | Active workspace highlight |
| Clock | Mauve | Center module emphasis |
| Audio | Blue | Volume indicator |
| Network | Teal | Connection status |
| CPU | Green | System usage |
| Memory | Yellow | RAM usage |
| Battery | Green/Blue/Red | Status-dependent |
| Power | Red | Warning color |

### Custom Animations

The battery module includes a blinking animation when critically low:
```css
@keyframes blink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
}
```

## Troubleshooting

### Waybar not starting
Check if Waybar is running:
```bash
killall waybar
waybar
```

Check for configuration errors:
```bash
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

### Icons not showing
Install Nerd Fonts:
```bash
sudo pacman -S ttf-firacode-nerd ttf-font-awesome
```

### Modules not working
Ensure dependencies are installed. Check individual module requirements in the Dependencies section.

### Hyprland workspaces not updating
Restart Waybar:
```bash
killall waybar && waybar &
```

### Height issues
If the bar appears too tall or short, adjust `height` in `config.jsonc`.

## Reloading Configuration

After making changes:
```bash
killall waybar && waybar &
```

Or bind a key in Hyprland to reload Waybar (add to `hyprland/conf/keybinds.conf`):
```conf
bind = $mod, R, exec, killall waybar && waybar &
```

## Resources

- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [Nerd Fonts](https://www.nerdfonts.com/)
