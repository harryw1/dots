# Kitty Terminal Configuration

This directory contains configuration for the [Kitty](https://sw.kovidgoyal.net/kitty/) terminal emulator.

## Features

- **Catppuccin Frappe** color theme
- **FiraCode Nerd Font** for programming ligatures and icons
- Optimized performance settings
- Powerline-style tab bar
- Comfortable window padding

## Configuration Files

- `kitty.conf` - Main configuration file

## Customization

### Font Size
Adjust the font size by modifying:
```conf
font_size 11.0
```

### Window Padding
Change padding around terminal content:
```conf
window_padding_width 8
```

### Cursor Style
Available cursor shapes: `block`, `beam`, `underline`
```conf
cursor_shape block
```

### Tab Bar
Change tab bar position:
```conf
tab_bar_edge bottom  # Options: top, bottom
```

## Keybindings

Kitty uses default keybindings. Some useful ones:

- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+W` - Close tab
- `Ctrl+Shift+Right` - Next tab
- `Ctrl+Shift+Left` - Previous tab
- `Ctrl+Shift+Enter` - New window
- `Ctrl+Shift+]` - Next window
- `Ctrl+Shift+[` - Previous window

## Testing

Test your configuration:
```bash
kitty --config ~/.config/kitty/kitty.conf
```

## Resources

- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
