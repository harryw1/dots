# GTK Configuration

GTK 3.0 and GTK 4.0 configuration for consistent Catppuccin Frappe theming.

## Files

- `gtk-3.0/settings.ini` - GTK 3 theme settings
- `gtk-4.0/settings.ini` - GTK 4 theme settings

## Installation

The install script automatically symlinks these directories:
- `gtk-3.0/` → `~/.config/gtk-3.0/`
- `gtk-4.0/` → `~/.config/gtk-4.0/`

## Theme

Uses the **Catppuccin Frappe** GTK theme with matching components:

- **GTK Theme**: `catppuccin-frappe-mauve-standard+default`
- **Icon Theme**: `Papirus-Dark`
- **Cursor Theme**: `catppuccin-frappe-mauve-cursors`
- **Dark Mode**: Enabled

## Required Packages

### Official Repositories

```bash
sudo pacman -S papirus-icon-theme
```

### AUR

```bash
yay -S catppuccin-gtk-theme-frappe catppuccin-cursors-frappe
```

These are included in the `packages/aur-gui-themes.txt` and installed automatically by the install script.

## Customization

### Changing Accent Color

The Catppuccin GTK theme supports different accent colors. To change from mauve to another color, edit `settings.ini`:

Available accents: `mauve`, `blue`, `green`, `pink`, `red`, `peach`, `yellow`, `teal`, `sky`, `sapphire`, `lavender`, `rosewater`, `flamingo`, `maroon`

```ini
gtk-theme-name=catppuccin-frappe-<accent>-standard+default
gtk-cursor-theme-name=catppuccin-frappe-<accent>-cursors
```

### Font Configuration

Update the font in both `gtk-3.0/settings.ini` and `gtk-4.0/settings.ini`:

```ini
gtk-font-name=YourFont 10
```

### Cursor Size

Adjust cursor size if needed:

```ini
gtk-cursor-theme-size=24  # Default, can be 16, 24, 32, 48
```

## Testing

After installation or changes:

1. Reload GTK applications to see changes
2. Check settings in GTK apps like Thunar, LibreOffice, etc.
3. Verify cursor theme: `echo $XCURSOR_THEME`

## Troubleshooting

### Theme not applying

1. Ensure packages are installed: `pacman -Q catppuccin-gtk-theme-frappe`
2. Check theme location: `ls /usr/share/themes/ | grep catppuccin`
3. Log out and back in
4. For some apps, may need to manually set in app preferences

### Cursor theme not working

Cursor theme is also set in Hyprland config (`hyprland/conf/theme.conf`). Ensure both locations match.
