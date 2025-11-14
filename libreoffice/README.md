# LibreOffice Theme Configuration

LibreOffice automatically uses the system GTK theme, which means it will inherit the Catppuccin Frappe theme we've configured.

## Automatic Theming

The Catppuccin GTK theme is applied automatically via `~/.config/hypr/conf/autostart.conf`:

```conf
exec-once = gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Frappe-Standard-Mauve-Dark'
```

LibreOffice will automatically detect and use this theme on startup.

## Additional Theme Customization

### Dark Mode
LibreOffice respects the system dark mode preference, which is already set:
```conf
exec-once = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

### Icon Theme
To change LibreOffice's icon theme within the application:
1. Open LibreOffice
2. Go to **Tools** → **Options** → **View**
3. Under **Icon Theme**, select your preferred style:
   - **Breeze Dark** - Clean, modern icons that work well with dark themes
   - **Elementary** - Minimalist design
   - **Sifr Dark** - Flat, modern design

### Application Colors
If you want to customize LibreOffice colors further:
1. **Tools** → **Options** → **LibreOffice** → **Application Colors**
2. Choose **Automatic** to use system colors
3. Or customize individual elements

### Font Rendering
For better font rendering:
1. **Tools** → **Options** → **LibreOffice** → **View**
2. Enable **Use hardware acceleration** (if available)
3. **Tools** → **Options** → **LibreOffice** → **Fonts**
4. Set default fonts:
   - Western: Liberation Sans or Carlito
   - Code: FiraCode Nerd Font Mono

## Office Fonts

The following Microsoft-compatible fonts are installed via the productivity packages:
- **Liberation Sans/Serif/Mono** - Drop-in replacements for Arial, Times New Roman, Courier
- **Carlito** - Compatible with Calibri
- **Caladea** - Compatible with Cambria

## Recommended Settings

### Performance
1. **Tools** → **Options** → **Memory**
   - Graphics cache: 128 MB
   - Objects: 20-40

2. **Tools** → **Options** → **LibreOffice** → **View**
   - Enable hardware acceleration
   - Enable OpenGL for rendering

### UI Customization
1. **View** → **User Interface**
   - **Tabbed** - Modern ribbon-like interface
   - **Tabbed Compact** - Condensed version
   - **Standard Toolbar** - Classic interface

## Troubleshooting

### Theme Not Applied
If LibreOffice doesn't use the dark theme:
1. Close all LibreOffice windows
2. Run: `gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Frappe-Standard-Mauve-Dark'`
3. Restart LibreOffice

### Icons Look Wrong
1. Ensure you have icon themes installed: `papirus-icon-theme`
2. Set icons in LibreOffice: **Tools** → **Options** → **View** → **Icon Theme**

### Fonts Not Available
1. Verify fonts are installed: `fc-list | grep -i liberation`
2. Rebuild font cache: `fc-cache -fv`

## Resources

- [LibreOffice Documentation](https://documentation.libreoffice.org/)
- [GTK Theme Integration](https://wiki.archlinux.org/title/GTK)
- [Catppuccin GTK Theme](https://github.com/catppuccin/gtk)
