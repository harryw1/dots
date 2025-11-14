# Waybar Configuration

A beautiful, modern Waybar configuration using the **official Catppuccin Frappe theme** for Hyprland, with TUI integrations for system management.

## Features

- **Official Catppuccin Frappe theme**: Uses official color palette from catppuccin/waybar
- **Dynamic DPI scaling**: Automatically adjusts sizes based on monitor scale factor
- **Multi-monitor support**: Per-monitor CSS rules for consistent appearance
- **Modern rounded design**: Clean, transparent aesthetic with grouped modules
- **Hyprland integration**: Native workspace and window management
- **TUI integrations**: All modules launch terminal interfaces (btop, impala, bluetuith)
- **Interactive modules**: Click and scroll functionality
- **Smart styling**: Status-aware colors (connected, disconnected, charging, etc.)

## Structure

```
waybar/
├── config                      # Main configuration
├── style.css                   # Custom styling with Catppuccin integration
├── frappe.css                  # Official Catppuccin Frappe color palette
├── scaling.css                 # Auto-generated per-monitor scaling (DO NOT EDIT)
├── generate-waybar-css.sh      # Script to generate scaling.css
└── README.md                   # This file
```

## Modules

### Left Side
- **Workspaces**: Shows workspaces 1-5 with colored dots
  - **Default** dots (●): Muted gray (@overlay0) for inactive workspaces
  - **Active** dot (●): Bright sky blue (@sky) with glow effect, larger size
  - **Urgent** dot (●): Red (@red) with pulsing animation to draw attention
  - Click to switch workspaces
  - Scroll to navigate between workspaces
  - Smooth transitions and hover effects
- **Window**: Displays current window title with app-specific icons
  - Hidden when workspace is empty

### Center
- **Clock**: Time and date
  - Click to toggle full date format
  - Right-click to change calendar mode
  - Scroll to navigate calendar
  - Interactive calendar tooltip

### Right Side
- **Tray**: System tray icons
- **Bluetooth**: Connection status
  - Click: Open bluetuith (TUI manager)
  - Right-click: Open blueman-manager (GUI)
  - Shows connected device name and battery
- **Audio**: Volume control
  - Click: Open pavucontrol
  - Right-click: Mute/unmute
  - Scroll: Adjust volume
- **Network**: Connection status
  - Click: Open impala (WiFi TUI)
  - Right-click: Open iwctl (CLI)
- **CPU**: CPU usage
  - Click: Open btop
- **Battery**: Battery status (if applicable)
  - Shows charge level with icons
  - Warning at 30%, critical at 15%
- **Power**: Power menu
  - Click: Open wlogout

## Dependencies

### Required
- `waybar` - The status bar
- `font-awesome` - Icons
- `ttf-firacode-nerd` - Primary font with icons
- `jq` - JSON processor (for scaling script)
- `bc` - Calculator (for scaling script)

### Required TUI Tools
- `btop` - System monitor (for CPU module)
- `impala` - WiFi management TUI (for network module)
- `bluetuith-bin` (AUR) - Bluetooth TUI manager (for bluetooth module)

### Required GUI Tools
- `pavucontrol` - Audio control GUI
- `blueman` - Bluetooth GUI manager (fallback)
- `wlogout` - Logout menu

### Optional
- `iwctl` - Alternative network management CLI

## Installation

The installation script will automatically install all dependencies and symlink this configuration:

```bash
./install.sh --packages-all
```

Or config-only:
```bash
./install.sh
```

Or manually:
```bash
ln -s ~/path/to/dots/waybar ~/.config/waybar
```

## Dynamic DPI Scaling

This Waybar configuration includes **automatic DPI scaling** that adapts to your monitor's scale factor, ensuring consistent visual sizing across different displays.

### How It Works

1. **Detection**: The `generate-waybar-css.sh` script reads your monitor configuration from Hyprland
2. **Calculation**: Calculates scaled sizes based on each monitor's scale factor
   - Base sizes are defined for scale=1.0 (standard 1080p displays)
   - Formula: `scaled_size = base_size × scale_factor`
3. **Generation**: Creates per-monitor CSS rules in `scaling.css`
4. **Application**: Waybar automatically uses the correct sizes for each monitor

### Base Sizes (scale=1.0)

| Element | Base Size |
|---------|-----------|
| Font | 14px |
| Workspace icon | 18px |
| Active workspace | 22px |
| Bar height | 40px |
| Padding/margin | 5px |

### Example Scaling

On a Framework 13 (1.57x scale):
- Font: 14px → 22px
- Workspace icon: 18px → 28px
- Active workspace: 22px → 35px
- Bar height: 40px → 63px

### Regenerating Scaling CSS

The script runs automatically on login via Hyprland autostart. To manually regenerate:

```bash
# From any directory
~/.config/waybar/generate-waybar-css.sh

# Or from waybar directory
cd ~/.config/waybar
./generate-waybar-css.sh
```

The script will:
- Detect all connected monitors
- Generate per-monitor CSS rules
- Automatically reload Waybar

### When to Regenerate

You should regenerate the scaling CSS when:
- Connecting/disconnecting external monitors
- Changing monitor scale factors in Hyprland
- Adjusting base sizes in the script

### Multi-Monitor Setup

The script generates separate CSS rules for each monitor:

```css
/* Monitor: eDP-1 (scale: 1.57) */
window.eDP-1 * {
    font-size: 22px;
}

/* Monitor: HDMI-A-1 (scale: 1.0) */
window.HDMI-A-1 * {
    font-size: 14px;
}
```

### Customizing Base Sizes

Edit `generate-waybar-css.sh` and modify these variables:

```bash
BASE_FONT_SIZE=14      # Font size at scale=1.0
BASE_ICON_SIZE=18      # Workspace icon size
BASE_ICON_ACTIVE=22    # Active workspace size
BASE_HEIGHT=40         # Bar height
BASE_PADDING=5         # Module padding
BASE_MARGIN=5          # Module margin
```

After editing, regenerate the CSS with `./generate-waybar-css.sh`.

## Official Catppuccin Theme

This configuration uses the **official Catppuccin Frappe theme** from [catppuccin/waybar](https://github.com/catppuccin/waybar).

The `frappe.css` file contains the official color palette, and `style.css` imports it:

```css
@import "frappe.css";
```

You can then use color variables throughout your styling:

```css
#workspaces button.active {
    color: @sky;
}

#bluetooth {
    color: @sapphire;
}
```

### Available Color Variables

All Catppuccin Frappe colors are available:

| Variable | Hex | Use |
|----------|-----|-----|
| `@rosewater` | `#f2d5cf` | Accent |
| `@flamingo` | `#eebebe` | Accent |
| `@pink` | `#f4b8e4` | Accent |
| `@mauve` | `#ca9ee6` | Accent |
| `@red` | `#e78284` | Errors/Power |
| `@maroon` | `#ea999c` | Accent |
| `@peach` | `#ef9f76` | Warnings |
| `@yellow` | `#e5c890` | Warnings |
| `@green` | `#a6d189` | Success/Battery |
| `@teal` | `#81c8be` | Network |
| `@sky` | `#99d1db` | Active elements |
| `@sapphire` | `#85c1dc` | Bluetooth |
| `@blue` | `#8caaee` | Clock/Info |
| `@lavender` | `#babbf1` | Workspaces |
| `@text` | `#c6d0f5` | Primary text |
| `@subtext1` | `#b5bfe2` | Secondary text |
| `@subtext0` | `#a5adce` | Tertiary text |
| `@overlay2` | `#949cbb` | Overlay |
| `@overlay1` | `#838ba7` | Overlay |
| `@overlay0` | `#737994` | Overlay |
| `@surface2` | `#626880` | Surface |
| `@surface1` | `#51576d` | Surface |
| `@surface0` | `#414559` | Module backgrounds |
| `@base` | `#303446` | Base background |
| `@mantle` | `#292c3c` | Mantle |
| `@crust` | `#232634` | Darkest |

## Module Colors

Current color assignments:

| Module | Color | Variable | States |
|--------|-------|----------|--------|
| Workspaces | Multiple | `@overlay0`, `@sky`, `@red`, `@lavender` | Default (gray), Active (sky blue + glow), Urgent (red), Hover (lavender) |
| Window | Lavender | `@lavender` | - |
| Clock | Blue | `@blue` | - |
| Bluetooth | Sapphire/Teal | `@sapphire`, `@teal`, `@overlay0` | Default (sapphire), Connected (teal), Off/Disabled (gray) |
| Audio | Maroon | `@maroon` | Default (maroon), Muted (gray) |
| Network | Teal | `@teal` | Connected (teal), Disconnected (red) |
| CPU | Mauve | `@mauve` | - |
| Battery | Yellow/Green | `@yellow`, `@green`, `@peach`, `@red` | Normal (yellow), Charging (green), Warning (peach), Critical (red + blink) |
| Power | Red | `@red` | - |

## Customization

### Switching Catppuccin Flavors

To use a different Catppuccin flavor (Latte, Macchiato, Mocha):

1. Download the flavor CSS from [catppuccin/waybar releases](https://github.com/catppuccin/waybar/releases)
2. Save as `~/.config/waybar/<flavor>.css`
3. Update `style.css` import:
   ```css
   @import "mocha.css";
   ```

### Adding/Removing Modules

Edit `config`:
1. Add module name to `modules-left`, `modules-center`, or `modules-right`
2. Add module configuration in the configuration section
3. Add styling in `style.css` using Catppuccin color variables

### Changing Module Order

Rearrange modules by changing their order in the `modules-*` arrays in `config`.

### Adjusting Transparency

The waybar background is transparent by default. To adjust:

```css
#waybar {
    background: @base;  /* Solid background */
    /* or */
    background: alpha(@base, 0.9);  /* 90% opacity */
}
```

### Module Border Radius

Modules use a grouped design with rounded outer corners. First and last modules in a group have rounded corners:

```css
#tray {
    border-radius: 1rem 0px 0px 1rem;  /* Left rounded */
}

#custom-power {
    border-radius: 0px 1rem 1rem 0px;  /* Right rounded */
}
```

### Height and Spacing

Adjust in `config`:
```json
{
    "height": 40,
    "spacing": 0,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12
}
```

## TUI Integration

### Bluetooth (bluetuith)

Click the bluetooth icon in Waybar to launch bluetuith TUI, or right-click for blueman GUI.

**Keyboard shortcuts in bluetuith:**
- `Tab` / `Shift+Tab` - Navigate between panels
- `Enter` - Select/Connect device
- `d` - Disconnect device
- `p` - Pair with device
- `t` - Trust device
- `r` - Remove (unpair) device
- `s` - Scan for new devices
- `Ctrl+R` - Rename device
- `q` - Quit bluetuith

**Bluetooth service management:**
```bash
# Check bluetooth service status
systemctl status bluetooth

# Enable bluetooth service
sudo systemctl enable --now bluetooth

# Restart bluetooth service
sudo systemctl restart bluetooth
```

### Network (impala)

Launch impala from waybar to manage WiFi connections with a beautiful TUI.

### System Monitor (btop)

Click CPU module to launch btop with Catppuccin Frappe theme.

## Troubleshooting

### Waybar not starting

```bash
killall waybar
waybar
```

Check for errors:
```bash
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css
```

### Colors not loading

Verify frappe.css exists:
```bash
ls ~/.config/waybar/frappe.css
```

Check import in style.css:
```bash
head -n 2 ~/.config/waybar/style.css
```

### Bluetooth module not working

Install bluetuith:
```bash
yay -S bluetuith-bin
```

Check bluetooth service:
```bash
systemctl status bluetooth
```

Enable bluetooth:
```bash
sudo systemctl enable --now bluetooth
```

### Icons not showing

Install Nerd Fonts:
```bash
sudo pacman -S ttf-firacode-nerd ttf-font-awesome
```

### Modules not working

Ensure all TUI tools are installed:
```bash
which btop impala bluetuith
```

## Reloading Configuration

After making changes:
```bash
killall waybar && waybar &
```

Or bind a key in Hyprland (add to `hyprland/conf/keybinds.conf`):
```conf
bind = $mod, R, exec, killall waybar && waybar &
```

## Resources

- [Official Catppuccin Waybar Theme](https://github.com/catppuccin/waybar)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [bluetuith](https://github.com/darkhz/bluetuith)
- [Nerd Fonts](https://www.nerdfonts.com/)
