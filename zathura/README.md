# Zathura PDF Viewer Configuration

This directory contains configuration for [Zathura](https://pwmt.org/projects/zathura/), a minimal and highly customizable PDF viewer.

## Features

- **Catppuccin Frappe** color theme
- Recolor mode for dark theme reading
- Smooth scrolling
- Clipboard integration
- Optimized for comfortable reading

## Configuration Files

- `zathurarc` - Main configuration file

## Usage

### Opening PDFs
```bash
zathura document.pdf
```

### From File Manager
Zathura can be set as the default PDF viewer. Right-click a PDF → Properties → Open With → Zathura

## Keybindings

Zathura uses Vim-style keybindings:

### Navigation
- `j/k` or Arrow keys - Scroll down/up
- `h/l` - Scroll left/right
- `Space/Backspace` - Page down/up
- `gg` - Go to first page
- `G` - Go to last page
- `nG` - Go to page n (e.g., `42G` goes to page 42)

### Zoom
- `+/-` or `=/-` - Zoom in/out
- `a` - Adjust to page width
- `s` - Adjust to page height
- `d` - Toggle dual-page mode

### View
- `r` - Toggle recolor (dark mode)
- `i` - Toggle index/table of contents
- `f` - Toggle fullscreen
- `F5` - Start presentation mode

### Search
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

### Other
- `y` - Copy selected text to clipboard
- `:` - Command mode
- `q` - Quit

## Customization

### Font Size
Edit in `zathurarc`:
```conf
set font "FiraCode Nerd Font Mono 11"
```

### Disable Recolor by Default
Edit in `zathurarc`:
```conf
set recolor false
```

### Change Zoom Behavior
```conf
set adjust-open "best-fit"  # Options: width, height, best-fit
```

### Scroll Speed
```conf
set scroll-step 100  # Pixels per scroll
```

## Integration with Hyprland

Add keybinding to open PDFs quickly in `~/.config/hypr/conf/keybinds.conf`:
```conf
bind = $mod, Z, exec, zathura
```

## Resources

- [Zathura Documentation](https://pwmt.org/projects/zathura/documentation/)
- [Zathura GitHub](https://github.com/pwmt/zathura)
- [Catppuccin Zathura](https://github.com/catppuccin/zathura)
