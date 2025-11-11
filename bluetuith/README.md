# Bluetuith Configuration

Bluetuith is a TUI-based Bluetooth manager for Linux, providing an alternative to GUI tools like blueman.

## Installation

Bluetuith is installed via AUR (already in `packages/aur.txt`):

```bash
yay -S bluetuith-bin
```

The install script automatically symlinks this directory:
- `bluetuith/` → `~/.config/bluetuith/`

## Usage

### Launch Bluetuith

```bash
bluetuith
```

Or use a keybind in Waybar/Hyprland to launch it in a terminal.

### Basic Operations

**Navigation**:
- `j` / `k` - Move down/up
- `h` / `l` - Move left/right (between panels)
- `Enter` - Select/confirm
- `Esc` / `q` - Back/quit
- `?` - Show help

**Bluetooth Operations**:
- `s` - Scan for devices
- `p` - Pair with device
- `Enter` - Connect to paired device
- `d` - Disconnect from device
- `r` - Remove (unpair) device
- `t` - Trust device
- `b` - Block device

**Adapter Control**:
- `a` - Toggle adapter on/off
- `P` - Toggle pairable
- `D` - Toggle discoverable

## Features

- **No D-Bus complexity** - Simple TUI interface
- **Fast navigation** - Vim-style keybindings
- **Full functionality** - Pair, connect, disconnect, trust, block
- **Adapter management** - Turn Bluetooth on/off, set discoverable
- **Device info** - View device details and connection status
- **Lightweight** - Terminal-based, no GUI overhead

## Integration

### Waybar Module

Add a Bluetooth module to Waybar that launches bluetuith:

```json
"bluetooth": {
    "format": " {status}",
    "format-disabled": "",
    "format-connected": " {num_connections}",
    "tooltip-format": "{device_enumerate}",
    "tooltip-format-enumerate-connected": "{device_alias}",
    "on-click": "kitty -e bluetuith"
}
```

### Hyprland Keybind

Add a keybind to launch bluetuith:

```conf
bind = $mainMod, B, exec, kitty -e bluetuith
```

## Theme

Bluetuith uses terminal colors, so it automatically inherits the Catppuccin Frappe theme from Kitty.

## Troubleshooting

### Bluetooth adapter not found

1. Check if Bluetooth service is running:
   ```bash
   systemctl status bluetooth
   ```

2. Start/enable if needed:
   ```bash
   sudo systemctl enable --now bluetooth
   ```

3. Check for rfkill blocks:
   ```bash
   rfkill list bluetooth
   ```

4. Unblock if necessary:
   ```bash
   rfkill unblock bluetooth
   ```

### Can't pair devices

1. Ensure adapter is powered on (press `a` in bluetuith)
2. Ensure adapter is discoverable (press `D`)
3. Make sure device is in pairing mode
4. Try scanning again (press `s`)

### Device connects but no audio

Audio routing is handled by PipeWire. Use `pulsemixer` to select the correct audio output:

```bash
pulsemixer
```

## Comparison to GUI Alternatives

**vs. blueman (GUI)**:
- ✅ Lighter weight (no GUI overhead)
- ✅ Faster to launch
- ✅ Keyboard-driven workflow
- ✅ No systray daemon needed
- ⚠️ Less visual (TUI interface)

**vs. bluetoothctl (CLI)**:
- ✅ More user-friendly than raw CLI
- ✅ Visual device list
- ✅ Easier device management
- ✅ Better for interactive use

## Related

- **rfkill** - Hardware radio control
- **bluetoothctl** - Lower-level Bluetooth CLI
- **pulsemixer** - TUI audio control for routing Bluetooth audio
