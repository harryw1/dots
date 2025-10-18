# btop Configuration

A beautiful system monitor configuration for btop with **Catppuccin Frappe** theming to match your entire Hyprland setup.

## Features

- **Catppuccin Frappe theme**: Consistent with your system-wide color scheme
- **Performance monitoring**: CPU, memory, network, and process monitoring
- **Optimized settings**: Preconfigured for a great out-of-the-box experience
- **Native integration**: Launched from Waybar CPU module

## Structure

```
btop/
├── btop.conf                           # Main configuration
├── themes/
│   └── catppuccin_frappe.theme        # Catppuccin Frappe color theme
└── README.md                           # This file
```

## Installation

The installation script will automatically symlink this configuration:

```bash
./install.sh
```

Or manually:
```bash
ln -s ~/path/to/dots/btop ~/.config/btop
```

## Usage

### Launch btop

btop is integrated with Waybar - simply **click the CPU module** in your status bar to launch it.

Alternatively, launch from terminal:
```bash
btop
```

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `q` | Quit |
| `Esc` | Show/hide menu |
| `m` | Cycle through main boxes |
| `f` | Toggle filtering |
| `/` | Filter processes |
| `t` | Toggle process tree |
| `s` | Change process sorting |
| `r` | Reverse sort order |
| `e` | Toggle process grouping |
| `c` | Toggle command/name |
| `k` | Kill selected process |

### Menu Navigation

Press `Esc` to open the menu, then:
- **Options**: Configure btop settings
- **Help**: View all keyboard shortcuts
- **Quit**: Exit btop

## Configuration Options

The main configuration file (`btop.conf`) includes:

- **Theme**: `color_theme = "catppuccin_frappe"`
- **Update rate**: 2000ms (2 seconds)
- **Boxes shown**: CPU, Memory, Network, Processes
- **Process sorting**: CPU usage (lazy)
- **Temperature monitoring**: Enabled (requires lm-sensors)
- **Network graphs**: Auto-detect interfaces

## Color Theme

The Catppuccin Frappe theme uses these color mappings:

| Element | Color | Hex |
|---------|-------|-----|
| Main background | Base | `#303446` |
| Main text | Text | `#c6d0f5` |
| CPU box | Mauve | `#ca9ee6` |
| Memory box | Green | `#a6d189` |
| Network box | Maroon | `#ea999c` |
| Process box | Blue | `#8caaee` |
| Selected items | Surface1 | `#51576d` |
| Highlights | Blue | `#8caaee` |

### Temperature Gradients

- **Cool to hot**: Green → Yellow → Red
- **CPU usage**: Teal → Sapphire → Lavender
- **Memory usage**: Green → Teal → Sky
- **Network**: Peach → Maroon → Red

## Customization

### Change Theme

1. Press `Esc` to open menu
2. Select "Options"
3. Navigate to "color_theme"
4. Choose a different theme

Or edit `btop.conf`:
```conf
color_theme = "Default"  # Use built-in theme
color_theme = "TTY"      # Use TTY theme
```

### Adjust Update Rate

Faster updates (more CPU usage):
```conf
update_ms = 1000  # Update every 1 second
```

Slower updates (less CPU usage):
```conf
update_ms = 5000  # Update every 5 seconds
```

### Show Different Boxes

Edit `btop.conf`:
```conf
# Show only CPU and memory
shown_boxes = "cpu mem"

# Show all boxes
shown_boxes = "cpu mem net proc"
```

### Process Tree View

Enable process tree by default:
```conf
proc_tree = True
```

## Temperature Monitoring

btop can display CPU temperatures if `lm-sensors` is installed:

```bash
# Install lm-sensors
sudo pacman -S lm-sensors

# Detect sensors
sudo sensors-detect

# Test sensor output
sensors
```

Enable in `btop.conf`:
```conf
check_temp = True
```

## Performance Tips

### Reduce CPU Usage

1. **Increase update interval**: Set `update_ms = 3000` or higher
2. **Disable unused boxes**: Remove from `shown_boxes`
3. **Disable background updates**: Set `background_update = False`

### Improve Responsiveness

1. **Decrease update interval**: Set `update_ms = 1000`
2. **Enable lazy sorting**: Use `proc_sorting = "cpu lazy"`

## Troubleshooting

### btop not starting

Check if btop is installed:
```bash
which btop
# Should output: /usr/bin/btop
```

Install if missing:
```bash
sudo pacman -S btop
```

### Theme not loading

Verify theme file exists:
```bash
ls ~/.config/btop/themes/catppuccin_frappe.theme
```

Check theme setting in config:
```bash
grep color_theme ~/.config/btop/btop.conf
```

### Temperature not showing

Install and configure lm-sensors:
```bash
sudo pacman -S lm-sensors
sudo sensors-detect  # Answer YES to all
sensors              # Verify output
```

### Waybar integration not working

Verify the CPU module configuration in `~/.config/waybar/config`:
```json
"cpu": {
    "on-click": "kitty --class btop -e btop"
}
```

## Resources

- [btop GitHub](https://github.com/aristocratos/btop)
- [Catppuccin btop Theme](https://github.com/catppuccin/btop)
- [btop Documentation](https://github.com/aristocratos/btop#usage)
