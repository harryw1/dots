# Waypaper Configuration

Waypaper is a GUI wallpaper manager for Wayland that works with hyprpaper backend.

## Files

- `config.ini` - Waypaper settings and preferences
- `style.css` - Catppuccin Frappe themed GTK stylesheet

## Installation

The install script automatically symlinks this directory:
- `waypaper/` → `~/.config/waypaper/`

## Usage

### Launch Waypaper

```bash
waypaper
```

Or use the Waybar wallpaper module click action (if configured).

### Features

- **Visual wallpaper browser** - Preview and select wallpapers
- **Multiple monitor support** - Set different wallpapers per monitor or same on all
- **Catppuccin wallpapers** - Pre-configured to use the curated Catppuccin collection
- **hyprpaper integration** - Automatically updates hyprpaper configuration
- **Themed interface** - Custom Catppuccin Frappe GTK stylesheet

### Default Wallpaper Location

```
~/.local/share/catppuccin-wallpapers/
```

This collection is automatically installed by the install script and contains curated Frappe-themed wallpapers.

## Configuration

### Change Default Wallpaper Folder

Edit `config.ini`:

```ini
folder = /path/to/your/wallpapers
```

### Fill Modes

Available fill modes in the GUI:
- `fill` - Scale to fill (may crop)
- `fit` - Scale to fit (may have bars)
- `center` - Center without scaling
- `tile` - Tile the image
- `stretch` - Stretch to fill (may distort)

### Backend

This configuration uses `hyprpaper` as the backend, which is the recommended backend for Hyprland.

```ini
backend = hyprpaper
```

## Theme Customization

The `style.css` file applies Catppuccin Frappe theming to waypaper's GTK interface. To modify:

1. Edit `style.css` with custom GTK CSS
2. Colors are defined at the top using `@define-color`
3. Reload waypaper to see changes

## Integration

### Waybar Integration

The Waybar configuration (if enabled) includes a wallpaper module that launches waypaper on click:

```json
"custom/wallpaper": {
    "format": "",
    "on-click": "waypaper",
    "tooltip-format": "Change wallpaper"
}
```

### hyprpaper Integration

Waypaper automatically updates `~/.config/hypr/hyprpaper.conf` when you select a wallpaper. No manual configuration needed.

## Troubleshooting

### Wallpaper not changing

1. Ensure hyprpaper is running: `pgrep hyprpaper`
2. Check hyprpaper config: `cat ~/.config/hypr/hyprpaper.conf`
3. Restart hyprpaper: `pkill hyprpaper && hyprpaper &`

### Theme not applying

1. Verify stylesheet path in `config.ini` points to the symlinked location
2. Restart waypaper
3. Check GTK theme is properly set in `~/.config/gtk-3.0/settings.ini`

## Related

- **hyprpaper** - Wallpaper daemon for Hyprland
- **quickwall** - CLI tool for downloading new wallpapers from Unsplash
- Catppuccin wallpaper collection - Pre-installed themed wallpapers
