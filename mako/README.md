# Mako Notification Configuration

This directory contains configuration for [Mako](https://github.com/emersion/mako), a lightweight notification daemon for Wayland.

## Features

- **Catppuccin Frappe** color theme
- Smart notification grouping by app
- Urgency-based styling (low, normal, critical)
- App-specific customization
- Icon support with Papirus theme
- Configurable timeouts

## Configuration Files

- `config` - Main configuration file

## Starting Mako

Mako should be started automatically by Hyprland. Add to `~/.config/hypr/conf/autostart.conf`:

```conf
# Notification daemon
exec-once = mako
```

## Controlling Mako

### Reload Configuration
After making changes to the config:
```bash
makoctl reload
```

### Dismiss Notifications
```bash
makoctl dismiss        # Dismiss oldest notification
makoctl dismiss -a     # Dismiss all notifications
```

### View History
```bash
makoctl history        # Show notification history
makoctl restore        # Restore last dismissed notification
```

## Testing Notifications

Send a test notification:
```bash
notify-send "Test Title" "This is a test notification"
```

Test different urgency levels:
```bash
notify-send -u low "Low Priority" "This is a low priority notification"
notify-send -u normal "Normal Priority" "This is a normal notification"
notify-send -u critical "Critical!" "This is an urgent notification"
```

Test with icons:
```bash
notify-send -i dialog-information "Info" "Information message"
notify-send -i dialog-warning "Warning" "Warning message"
notify-send -i dialog-error "Error" "Error message"
```

## Urgency Level Colors

- **Low** - Green border (#a6d189) - 3 second timeout
- **Normal** - Mauve border (#ca9ee6) - 5 second timeout
- **Critical** - Red border (#e78284) - No timeout (stays until dismissed)

## Customization

### Change Position
Edit anchor setting:
```ini
anchor=top-right
# Options: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
```

### Notification Size
```ini
width=350
height=150
```

### Default Timeout
```ini
default-timeout=5000  # milliseconds (5 seconds)
```

### Font Size
```ini
font=FiraCode Nerd Font Mono 10
```

## App-Specific Settings

You can customize notifications for specific apps by adding sections:

```ini
[app-name="YourApp"]
border-color=#yourcolor
default-timeout=3000
```

## Integration with Scripts

### Volume Change Notifications
For volume change notifications, you can use:
```bash
notify-send -a "volume" "Volume: 50%" -h int:value:50
```

### Brightness Notifications
```bash
notify-send -a "brightness" "Brightness: 75%" -h int:value:75
```

## Resources

- [Mako GitHub](https://github.com/emersion/mako)
- [Mako Wiki](https://github.com/emersion/mako/wiki)
- [FreeDesktop Notifications Spec](https://specifications.freedesktop.org/notification-spec/)
