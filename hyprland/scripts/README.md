# Hyprland Helper Scripts

Utility scripts used by Hyprland components, primarily for hyprlock.

## Scripts

### capslock-status.sh

Shows Caps Lock status indicator for hyprlock.

**Used by**: `hyprlock.conf` - Displays warning when Caps Lock is active

**Output**:
- ` CAPS LOCK` when active
- Empty string when inactive

### battery-status.sh

Shows battery status and charge level for hyprlock (laptops only).

**Used by**: `hyprlock.conf` - Displays battery icon and percentage

**Output**:
- ` 85%` (charging icon + percentage) when charging
- Battery level icon + percentage when on battery
- Empty string when no battery detected

**Battery Icons**:
-  - Charging
-  - Full (90-100%)
-  - Good (60-89%)
-  - Medium (40-59%)
-  - Low (20-39%)
-  - Critical (0-19%)

## Usage

These scripts are called automatically by hyprlock based on the configuration in `hyprlock.conf`. They don't need to be executed manually.

## Permissions

Scripts are automatically made executable during installation. If needed, you can make them executable manually:

```bash
chmod +x ~/.config/hypr/scripts/*.sh
```

## Customization

### Adding New Scripts

1. Create a new `.sh` file in this directory
2. Make it executable: `chmod +x scriptname.sh`
3. Reference it in `hyprlock.conf` using:
   ```
   text = cmd[update:MILLISECONDS] ~/.config/hypr/scripts/scriptname.sh
   ```

### Modifying Existing Scripts

Edit the scripts directly. Since the hyprland directory is symlinked, changes take effect immediately without needing to reinstall.

## Dependencies

### capslock-status.sh
- **xset** - X11 keyboard settings utility
- Installed as part of the core system packages

### battery-status.sh
- **sysfs** - Linux filesystem for hardware information
- No additional packages required (uses `/sys/class/power_supply/`)

## Troubleshooting

### Caps Lock status not showing

Ensure xset is installed:
```bash
pacman -Q xorg-xset
```

### Battery status not showing

Check if battery device exists:
```bash
ls /sys/class/power_supply/
```

Should show `BAT0` or `BAT1` on laptops.

### Scripts not executing

1. Verify scripts are executable: `ls -la ~/.config/hypr/scripts/`
2. Test script manually: `~/.config/hypr/scripts/battery-status.sh`
3. Check hyprlock logs for errors
