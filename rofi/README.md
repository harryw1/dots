# Rofi Configuration

This directory contains configuration for [Rofi](https://github.com/davatorium/rofi), a window switcher, application launcher, and dmenu replacement for Wayland.

## Features

- **Catppuccin Frappe** color theme
- Application launcher (drun mode)
- Window switcher
- Command runner
- Fuzzy matching search
- Icon support with Papirus theme

## Configuration Files

- `config.rasi` - Main configuration with behavior settings
- `catppuccin-frappe.rasi` - Catppuccin Frappe color theme

## Usage

### Launch Application Launcher
```bash
rofi -show drun
```

### Window Switcher
```bash
rofi -show window
```

### Run Commands
```bash
rofi -show run
```

## Keybindings

Rofi should be bound to a key combination in your Hyprland config. Add to `~/.config/hypr/conf/keybinds.conf`:

```conf
# Application Launcher
bind = SUPER, D, exec, rofi -show drun

# Window Switcher
bind = SUPER, TAB, exec, rofi -show window

# Command Runner
bind = SUPER, R, exec, rofi -show run
```

## Default Rofi Keybindings

While Rofi is open:
- `Enter` - Select item
- `Esc` - Close Rofi
- `Ctrl+J/K` or Arrow keys - Navigate
- `Shift+Delete` - Delete entry from history (run mode)
- `Ctrl+Space` - Switch between modes

## Customization

### Change Window Size
Edit in `catppuccin-frappe.rasi`:
```rasi
* {
    width: 600;  // Change width
}

window {
    height: 450px;  // Change height
}
```

### Change Number of Results
Edit in `catppuccin-frappe.rasi`:
```rasi
listview {
    lines: 8;  // Number of visible results
}
```

### Font Size
Edit in `catppuccin-frappe.rasi`:
```rasi
* {
    font: "FiraCode Nerd Font Mono 10";  // Change size
}
```

## Testing

Test your configuration:
```bash
rofi -show drun -config ~/.config/rofi/config.rasi
```

## Resources

- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Rofi Themes](https://github.com/davatorium/rofi-themes)
- [Catppuccin Rofi](https://github.com/catppuccin/rofi)
