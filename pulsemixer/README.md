# Pulsemixer Configuration

Pulsemixer is a CLI/TUI mixer for PulseAudio/PipeWire, providing volume control and audio device management from the terminal.

## Installation

Pulsemixer is in the official repositories. Add to `packages/productivity.txt`:

```bash
sudo pacman -S pulsemixer
```

## Usage

### Launch Pulsemixer

**TUI Mode** (interactive):
```bash
pulsemixer
```

**CLI Mode** (scripting):
```bash
pulsemixer --get-volume      # Get current volume
pulsemixer --set-volume 50   # Set volume to 50%
pulsemixer --change-volume +5  # Increase by 5%
pulsemixer --change-volume -5  # Decrease by 5%
pulsemixer --toggle-mute     # Toggle mute
```

### TUI Keybindings

**Navigation**:
- `↑`/`↓` or `k`/`j` - Move up/down
- `h`/`l` or `←`/`→` - Decrease/increase volume
- `H`/`L` - Change volume by 10%
- `Tab` - Cycle through sections (playback/recording/cards)

**Actions**:
- `Space` - Mute/unmute
- `Enter` - Context menu (set as default, etc.)
- `m` - Mute/unmute
- `e` - Toggle showing all sinks/sources
- `s` - Select default sink
- `i` - Show device info
- `q` - Quit

**Sections**:
- Tab 1: Playback (output devices and applications)
- Tab 2: Recording (input devices and applications)
- Tab 3: Cards (sound cards)

## Integration

### Waybar Volume Module

Use pulsemixer in Waybar's volume module:

```json
"pulseaudio": {
    "format": "{icon} {volume}%",
    "format-muted": " {volume}%",
    "on-click": "kitty -e pulsemixer",
    "on-click-right": "pulsemixer --toggle-mute",
    "scroll-step": 5
}
```

### Hyprland Keybinds

Add volume control keybinds:

```conf
# Volume controls with pulsemixer
bind = , XF86AudioRaiseVolume, exec, pulsemixer --change-volume +5
bind = , XF86AudioLowerVolume, exec, pulsemixer --change-volume -5
bind = , XF86AudioMute, exec, pulsemixer --toggle-mute

# Open pulsemixer TUI
bind = $mainMod, V, exec, kitty -e pulsemixer
```

### SwayOSD Integration

For visual volume feedback, use with SwayOSD (already in your AUR packages):

```conf
bind = , XF86AudioRaiseVolume, exec, pulsemixer --change-volume +5 && swayosd-client --output-volume raise
bind = , XF86AudioLowerVolume, exec, pulsemixer --change-volume -5 && swayosd-client --output-volume lower
bind = , XF86AudioMute, exec, pulsemixer --toggle-mute && swayosd-client --output-volume mute-toggle
```

## Common Tasks

### Switch Audio Output

1. Launch pulsemixer: `pulsemixer`
2. Navigate to the output device (speakers, headphones, Bluetooth, etc.)
3. Press `Enter` → "Set as default"
4. Press `q` to quit

### Route Application Audio

1. Open pulsemixer
2. Find the application in the Playback section
3. Navigate to it and press `Enter`
4. Select "Move to..." and choose the output device

### Bluetooth Audio

After connecting a Bluetooth device with `bluetuith`:

1. Open pulsemixer
2. The Bluetooth device should appear in the Playback section
3. Navigate to it and set as default with `Enter`

### Check Audio Levels

Use pulsemixer to:
- Monitor which applications are playing audio
- Check microphone input levels (Recording tab)
- Adjust per-application volume
- Mute specific applications

## CLI Examples

```bash
# Get current volume
pulsemixer --get-volume

# Set volume to 60%
pulsemixer --set-volume 60

# Increase by 10%
pulsemixer --change-volume +10

# Toggle mute
pulsemixer --toggle-mute

# List all sinks (output devices)
pulsemixer --list-sinks

# Set specific sink as default (by ID)
pulsemixer --id 1 --set-default-sink

# Get mute status
pulsemixer --get-mute
```

## Scripting

Create volume control scripts:

```bash
#!/bin/bash
# vol-up.sh
pulsemixer --change-volume +5
VOLUME=$(pulsemixer --get-volume | awk '{print $1}')
notify-send "Volume: ${VOLUME}%"
```

## Theme

Pulsemixer uses terminal colors, so it automatically inherits the Catppuccin Frappe theme from Kitty.

Color indicators:
- **Green bars**: Active volume level
- **White/gray text**: Device names
- **Highlighted**: Selected device

## Comparison to Alternatives

**vs. pavucontrol (GUI)**:
- ✅ Much lighter weight
- ✅ Keyboard-driven
- ✅ Faster to launch
- ✅ Scriptable CLI
- ⚠️ Less visual

**vs. amixer (CLI only)**:
- ✅ Interactive TUI mode
- ✅ Easier to use
- ✅ Better for PipeWire
- ✅ More intuitive

**vs. pactl (PulseAudio CLI)**:
- ✅ Interactive interface
- ✅ Visual feedback
- ✅ Simpler syntax
- ✅ Works with both PulseAudio and PipeWire

## Troubleshooting

### No audio devices shown

1. Check if PipeWire/PulseAudio is running:
   ```bash
   systemctl --user status pipewire pipewire-pulse
   ```

2. Restart audio services:
   ```bash
   systemctl --user restart pipewire pipewire-pulse
   ```

### Bluetooth audio not showing

1. Ensure Bluetooth device is connected (use `bluetuith`)
2. Wait a few seconds for PipeWire to detect it
3. Restart pulsemixer or press `e` to refresh

### Volume changes not taking effect

1. Check if application is muted in pulsemixer
2. Ensure correct output device is selected
3. Try setting volume through the application directly

## Related

- **PipeWire** - Modern audio server
- **bluetuith** - Bluetooth device management
- **SwayOSD** - On-screen volume/brightness display
- **Waybar** - Status bar with volume module
