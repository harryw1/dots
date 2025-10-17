# wlogout Configuration

This directory contains wlogout (Wayland logout menu) configuration styled with the Catppuccin Frappe theme.

## What is wlogout?

wlogout is a logout menu for Wayland compositors like Hyprland. It provides a graphical menu with options to lock, logout, suspend, hibernate, shutdown, or reboot your system.

## Files

- `layout` - Defines the buttons and their actions
- `style.css` - Catppuccin Frappe themed styling

## Installation

The `install.sh` script will:
1. Install `wlogout` from AUR
2. Symlink configuration files to `~/.config/wlogout/`

Manual installation:
```bash
# Install wlogout
yay -S wlogout

# Create config directory and symlink files
mkdir -p ~/.config/wlogout
ln -sf ~/dots/wlogout/layout ~/.config/wlogout/layout
ln -sf ~/dots/wlogout/style.css ~/.config/wlogout/style.css
```

## Usage

### Launch wlogout

```bash
# From command line
wlogout

# Or click the power button in Waybar (configured in waybar/config)
```

### Keyboard Shortcuts

When wlogout is open, use these keys:
- **L** - Lock screen (hyprlock)
- **E** - Logout (exit Hyprland)
- **U** - Suspend
- **H** - Hibernate
- **S** - Shutdown
- **R** - Reboot
- **Esc** - Cancel and close wlogout

## Customization

### Change Button Layout

Edit `layout` to modify buttons, their order, actions, or keybinds. Each button is defined as a JSON object.

### Change Actions

By default, the configuration uses:
- Lock: `hyprlock` (Hyprland's lock screen)
- Logout: `hyprctl dispatch exit`
- Power actions: `systemctl` commands

You can change these to use different tools (e.g., `swaylock` instead of `hyprlock`).

### Styling

The `style.css` uses Catppuccin Frappe colors:
- Background: base (#303446) with 90% opacity
- Buttons: surface0 (#414559)
- Hover: surface1 (#51576d) with lavender glow
- Focus: surface2 (#626880) with stronger lavender glow

Icons use the default wlogout icons from `/usr/share/wlogout/icons/`.

## Theming with Catppuccin Icons (Optional)

For full Catppuccin-themed icons, you can:
1. Clone https://github.com/catppuccin/wlogout
2. Copy the Frappe icons to `~/.config/wlogout/icons/`
3. Update `style.css` icon paths to use local icons

## Integration with Hyprland

The power button in Waybar (`waybar/config`) is configured to launch wlogout:
```json
"custom/power": {
    "format": "󰐥",
    "tooltip": false,
    "on-click": "wlogout"
}
```

## Dependencies

- `wlogout` - The logout menu application
- `hyprlock` - For screen locking (optional, can use alternatives)
- `systemctl` - For power management (included in systemd)

## Troubleshooting

**wlogout doesn't start:**
```bash
# Check if wlogout is installed
which wlogout

# Test configuration
wlogout --help
```

**Buttons don't work:**
- Ensure systemd commands are available: `systemctl --version`
- For lock, ensure hyprlock is installed: `which hyprlock`
- Check Hyprland logs: `tail -f ~/.local/share/hyprland/hyprland.log`
