# Wallpapers Directory

This directory is for your wallpaper images used by hyprpaper.

## Quick Setup with Waypaper (Recommended)

If you ran `./install.sh --packages-all`, you already have access to a curated collection of Catppuccin Frappe wallpapers!

1. **Browse and select wallpapers with the GUI:**
   ```bash
   # Launch waypaper to browse the collection
   waypaper
   ```
   - The collection is located at: `~/.local/share/catppuccin-wallpapers/frappe/`
   - Contains 50-200 curated Catppuccin Frappe wallpapers
   - Click any wallpaper to set it instantly via hyprpaper

2. **Set wallpaper to restore on startup (optional):**
   ```bash
   # Add to hyprland autostart to restore last wallpaper
   echo "exec-once = waypaper --restore" >> ~/.config/hypr/conf/autostart.conf
   ```

## Download New Wallpapers from Unsplash

Use QuickWall to download wallpapers directly from Unsplash:

```bash
# Download a random wallpaper
quickwall

# Download with specific search term
quickwall --search "landscape"

# Save to specific directory
quickwall --dir ~/.config/hypr/wallpapers/
```

## Manual Wallpaper Management

### Add Your Own Wallpaper

```bash
# Copy your wallpaper here
cp ~/Downloads/my-wallpaper.jpg ~/.config/hypr/wallpapers/

# Set it using hyprctl
hyprctl hyprpaper preload ~/.config/hypr/wallpapers/my-wallpaper.jpg
hyprctl hyprpaper wallpaper ",~/.config/hypr/wallpapers/my-wallpaper.jpg"
```

### Use hyprctl for Direct Control

```bash
# Preload a wallpaper
hyprctl hyprpaper preload ~/path/to/wallpaper.png

# Set wallpaper for all monitors
hyprctl hyprpaper wallpaper ",~/path/to/wallpaper.png"

# Set wallpaper for specific monitor
hyprctl hyprpaper wallpaper "DP-1,~/path/to/wallpaper.png"

# List loaded wallpapers
hyprctl hyprpaper listloaded
```

### Create Random Wallpaper Script

Create `~/.config/hypr/scripts/random-wallpaper.sh`:
```bash
#!/bin/bash
WALLPAPER_DIR="$HOME/.local/share/catppuccin-wallpapers/frappe"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
```

Then make it executable:
```bash
chmod +x ~/.config/hypr/scripts/random-wallpaper.sh
```

## Alternative: Download from GitHub

### Official Catppuccin Wallpapers

```bash
cd ~/.config/hypr/wallpapers/
wget https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic/cat-sound.png
```

More options at: https://github.com/catppuccin/wallpapers

## Fallback: Solid Color Background (Optional)

If you want a simple solid color background for testing:

```bash
# Requires imagemagick (install manually if needed)
sudo pacman -S imagemagick

# Create solid color background
convert -size 2560x1600 xc:'#303446' ~/.config/hypr/wallpapers/catppuccin-frappe.png
```

Note: This is only recommended for testing transparency effects.

## Apply Wallpaper Changes

After adding/changing wallpapers:
```bash
# Reload hyprpaper
pkill hyprpaper && hyprpaper &

# Or reload Hyprland entirely
hyprctl reload
```

## Multiple Monitors

If you have multiple monitors, you can set different wallpapers:

```conf
# In hyprpaper.conf:
preload = ~/wallpapers/laptop.png
preload = ~/wallpapers/external.png

wallpaper = eDP-1, ~/wallpapers/laptop.png
wallpaper = HDMI-A-1, ~/wallpapers/external.png
```

## Recommended Wallpapers

For the Catppuccin Frappe aesthetic:
- Use wallpapers with purple/mauve/pink accents
- Dark or muted backgrounds work best
- Check https://github.com/catppuccin/wallpapers for themed options
