# Wallpapers Directory

This directory is for your wallpaper images used by hyprpaper.

## Quick Setup

1. **Add your own wallpaper:**
   ```bash
   # Copy your wallpaper here
   cp ~/Downloads/my-wallpaper.jpg ~/.config/hypr/wallpapers/

   # Update hyprpaper.conf to use it
   vim ~/.config/hypr/hyprpaper.conf
   ```

2. **Use a Catppuccin Frappe themed wallpaper:**

   Download from these sources:
   - **Official Catppuccin wallpapers**: https://github.com/catppuccin/wallpapers
   - **Recommended**: Use any wallpaper from the Frappe folder

   ```bash
   # Example: Download a Catppuccin wallpaper
   cd ~/.config/hypr/wallpapers/
   wget https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic/cat-sound.png

   # Update hyprpaper.conf
   # Change the preload and wallpaper lines to:
   # preload = ~/.config/hypr/wallpapers/cat-sound.png
   # wallpaper = , ~/.config/hypr/wallpapers/cat-sound.png
   ```

3. **Create a solid color background (temporary solution):**

   If you don't have a wallpaper yet, create a simple solid color:
   ```bash
   # Create a 1920x1080 image with Catppuccin Frappe base color (#303446)
   convert -size 1920x1080 xc:'#303446' ~/.config/hypr/wallpapers/catppuccin-frappe.png
   ```

   Note: Requires `imagemagick` package: `sudo pacman -S imagemagick`

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
