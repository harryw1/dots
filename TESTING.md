# Hyprland Dotfiles Testing Checklist

Run through these tests to verify your Hyprland setup is working correctly.

## Recent Fixes Applied

The following issues have been addressed in the latest update:

✅ **Animation Speed** - Window closing and workspace switching animations have been optimized for smoother, faster transitions
✅ **Scrolling Direction** - Natural scrolling disabled (traditional scrolling enabled)
✅ **Wallpaper Support** - hyprpaper configuration added (see hyprland/wallpapers/README.md)
✅ **Dark Theme** - GTK theme settings corrected for better dark mode support
✅ **OSD Feedback** - SwayOSD added for visual volume/brightness feedback
✅ **Keybind Documentation** - Corrected keybinds in testing checklist

### First Time Setup

After pulling the latest changes:
1. Install SwayOSD: `yay -S swayosd-git`
2. Reload Hyprland: `hyprctl reload` or log out and back in
3. Set up a wallpaper (see hyprland/wallpapers/README.md)
4. Configure Firefox dark mode: `about:preferences` → General → Website appearance → Dark

---

## 1. Display & Scaling Tests

### Monitor Configuration
- [ ] Check current monitor settings: `hyprctl monitors`
- [ ] Verify scale is 1.566667 and resolution is 2256x1504@60
- [ ] Verify logical resolution is 1440x960
- [ ] Text should be comfortably readable (not too small, not too large)
- [ ] UI elements should be appropriately sized
- [ ] No "invalid scale" notifications appear

### Visual Quality
- [ ] No pixelation or blurriness in applications
- [ ] Cursor size is appropriate (not tiny)
- [ ] Icons and fonts are crisp and clear
- [ ] Check both native Wayland apps (Kitty) and XWayland apps (if any)

---

## 2. Theme & Appearance Tests

### Catppuccin Frappe Theme
- [ ] **Hyprland borders**: Should be purple/mauve (check window borders)
- [ ] **Waybar**: Dark background with Frappe colors
- [ ] **Kitty terminal**: Dark purple/blue background, proper syntax highlighting
- [ ] **Rofi launcher**: Catppuccin Frappe colors when opened
- [ ] **Mako notifications**: Purple/mauve themed (test with `notify-send "Test" "Message"`)
- [ ] **GTK apps** (Thunar, Firefox): Should respect dark theme

### Visual Effects
- [ ] Window rounding (corners should be rounded)
- [ ] Window shadows visible
- [ ] Blur effect on Waybar and notifications
- [ ] Window opacity (terminal should have slight transparency)
- [ ] Smooth animations when opening/closing windows

---

## 3. Keyboard Shortcuts Tests

Open Kitty terminal (`SUPER + Q` or find it in Rofi) and test these keybinds:

### Essential Keybinds (Corrected)
- [ ] `SUPER + ENTER` - Launch Kitty terminal
- [ ] `SUPER + SPACE` - Launch Rofi (application launcher)
- [ ] `SUPER + Q` - Close active window
- [ ] `SUPER + SHIFT + Q` - Exit Hyprland
- [ ] `SUPER + V` - Toggle floating mode
- [ ] `SUPER + P` - Toggle pseudo-tiling
- [ ] `SUPER + F` - Toggle fullscreen
- [ ] `SUPER + E` - Open Thunar (file manager)
- [ ] `SUPER + B` - Open Firefox (web browser)

### Window Navigation
- [ ] `SUPER + Left/Right/Up/Down` - Move focus between windows
- [ ] `SUPER + H/J/K/L` - Vim-style window navigation
- [ ] `SUPER + mouse drag` - Move window (click and drag window)
- [ ] `SUPER + right-click drag` - Resize window

### Workspace Management
- [ ] `SUPER + 1-9` - Switch to workspace 1-9
- [ ] `SUPER + SHIFT + 1-9` - Move window to workspace 1-9
- [ ] `SUPER + mouse wheel` - Cycle through workspaces
- [ ] `SUPER + S` - Toggle special workspace (scratchpad)

### System Controls
- [ ] `SUPER + SHIFT + R` - Reload Hyprland config
- [ ] `Print Screen` - Take full screenshot (with grim)
- [ ] `SUPER + Print Screen` - Take area screenshot (with slurp)

---

## 4. Touchpad & Gestures Tests

### Touchpad Basics
- [ ] Natural scrolling works (two-finger scroll)
- [ ] Tap-to-click works
- [ ] Two-finger right-click works
- [ ] Three-finger middle-click works
- [ ] Typing disables touchpad temporarily

### Gestures
- [ ] Three-finger horizontal swipe left - Switch to previous workspace
- [ ] Three-finger horizontal swipe right - Switch to next workspace

---

## 5. Application Launch Tests

Test launching these applications (use Rofi: `SUPER + D`):

### Core Applications
- [ ] **Kitty** - Terminal emulator opens with Catppuccin theme
- [ ] **Firefox** - Web browser launches
- [ ] **Thunar** - File manager opens
- [ ] **Rofi** - Application launcher works (`SUPER + D`)

### System Utilities
- [ ] **pavucontrol** - Audio control (should float in center)
- [ ] **nm-connection-editor** - Network settings (should float)
- [ ] **blueman-manager** - Bluetooth manager

### Productivity Tools (if installed)
- [ ] **LibreOffice** - Opens with system theme
- [ ] **Zathura** - PDF viewer with Catppuccin Frappe theme
- [ ] **Obsidian** - Note-taking app

### Communication (if installed)
- [ ] **Discord**
- [ ] **Slack**
- [ ] **Thunderbird**

---

## 6. Waybar Status Bar Tests

Check the top bar (Waybar):

### Modules Working
- [ ] Workspace indicators show (1-9)
- [ ] Active workspace is highlighted
- [ ] Window title shows in center
- [ ] System tray icons appear (network, bluetooth, audio)
- [ ] Clock shows correct time
- [ ] CPU/Memory usage displays (if enabled)
- [ ] Battery indicator shows (laptop)

### Interactions
- [ ] Click workspace number - Switch to that workspace
- [ ] Click system tray icons - Open respective settings
- [ ] Hover over modules - Tooltips appear

---

## 7. Notification System Tests

Test Mako notification daemon:

```bash
# Send a test notification
notify-send "Test Notification" "This is a test message"

# Send with urgency levels
notify-send -u low "Low Priority" "This is low priority"
notify-send -u normal "Normal Priority" "This is normal priority"
notify-send -u critical "Critical Priority" "This is critical!"
```

- [ ] Notifications appear in top-right corner
- [ ] Notifications have Catppuccin Frappe colors
- [ ] Notifications have blur effect
- [ ] Click notification to dismiss
- [ ] Notifications auto-dismiss after timeout

---

## 8. Window Management Tests

### Tiling Behavior
- [ ] Open 2 windows - They tile side by side
- [ ] Open 3 windows - They tile appropriately
- [ ] Open 4 windows - Proper tiling layout
- [ ] Resize window by dragging borders
- [ ] Gaps between windows are visible

### Floating Windows
- [ ] `SUPER + V` toggles floating mode
- [ ] Floating window can be moved freely
- [ ] Floating window can be resized
- [ ] Pavucontrol opens as floating by default
- [ ] Floating windows are centered

### Window Rules
- [ ] Kitty has slight transparency
- [ ] Firefox opens on workspace 2 (if configured)
- [ ] VS Code opens on workspace 3 (if configured)
- [ ] Discord opens on workspace 4 (if configured)

---

## 9. Multi-Monitor Tests (if applicable)

If you have an external monitor:

- [ ] External monitor is detected
- [ ] Resolution is correct on both displays
- [ ] Workspaces can be moved between monitors
- [ ] Windows can be moved between monitors
- [ ] Waybar appears on primary monitor
- [ ] Scaling is correct on both displays

---

## 10. Terminal & Font Tests

Open Kitty and test:

### Font Rendering
- [ ] JetBrains Mono Nerd Font is used
- [ ] Nerd Font icons render correctly (try: `ls` in a git repo)
- [ ] Font size is readable
- [ ] No font rendering issues or artifacts

### Terminal Features
- [ ] Colors are vibrant (Catppuccin Frappe)
- [ ] Transparency works (slight see-through)
- [ ] Copy/paste works (`CTRL+SHIFT+C/V`)
- [ ] Multiple tabs work (`CTRL+SHIFT+T`)
- [ ] Window swallowing works (run `nvim` - terminal should hide)

---

## 11. LazyVim / Neovim Tests

Open Neovim and test:

```bash
nvim
```

### LazyVim Setup
- [ ] LazyVim loads without errors
- [ ] Catppuccin Frappe theme is active
- [ ] Plugins are installed (first launch may take time)
- [ ] JetBrains Mono font is used
- [ ] Syntax highlighting works
- [ ] LSP features work (if configured)

### Test File Editing
```bash
# Create a test file
nvim ~/test.py
```

- [ ] Python syntax highlighting works
- [ ] Line numbers are visible
- [ ] Relative line numbers work
- [ ] Theme colors are consistent

---

## 12. Performance Tests

### System Responsiveness
- [ ] Window animations are smooth (not laggy)
- [ ] Switching workspaces is instant
- [ ] Opening applications is fast
- [ ] No stuttering or frame drops
- [ ] CPU usage is reasonable when idle

### Check System Resources
```bash
# Check Hyprland process
ps aux | grep hyprland

# Check overall system
htop
```

- [ ] Hyprland CPU usage is low when idle
- [ ] Memory usage is reasonable
- [ ] No processes are stuck or consuming excessive resources

---

## 13. Audio & Media Tests

### Audio Control
- [ ] Volume up/down keys work (if configured)
- [ ] PipeWire is running: `systemctl --user status pipewire`
- [ ] Audio output works (play a video/song)
- [ ] Microphone input works (test in recording app)
- [ ] pavucontrol shows all audio devices

### Media Controls
- [ ] Play/pause media keys work (if configured)
- [ ] playerctl controls media playback (if installed)

---

## 14. Network & Bluetooth Tests

### Network Management
```bash
# Check NetworkManager
systemctl status NetworkManager
```

- [ ] NetworkManager is running
- [ ] WiFi connects successfully
- [ ] nm-applet icon appears in Waybar
- [ ] Can switch between networks via GUI

### Bluetooth
```bash
# Check Bluetooth
systemctl status bluetooth
```

- [ ] Bluetooth service is running
- [ ] blueman-manager opens
- [ ] Can scan for Bluetooth devices
- [ ] Can pair/connect devices

---

## 15. Screenshot & Screen Capture Tests

### Screenshot Tools
- [ ] `grim` is installed: `which grim`
- [ ] `slurp` is installed: `which slurp`
- [ ] Take full screenshot: `grim ~/screenshot.png`
- [ ] Take area screenshot: `grim -g "$(slurp)" ~/screenshot-area.png`
- [ ] Screenshots are saved correctly

### Check Screenshot
```bash
ls -lh ~/screenshot*.png
imv ~/screenshot.png  # View with imv
```

---

## 16. File Manager Tests

Open Thunar:

- [ ] Thunar opens with dark theme
- [ ] Can navigate directories
- [ ] Can open files
- [ ] Can create/delete files
- [ ] Archive plugin works (right-click → extract)
- [ ] Thumbnails show for images

---

## 17. Clipboard Tests

Test clipboard functionality:

```bash
# Check cliphist is running
pgrep wl-paste
```

- [ ] wl-clipboard is installed
- [ ] Copy text from one app, paste in another
- [ ] cliphist stores clipboard history (if configured)
- [ ] Clipboard persists after closing source app

---

## 18. Special Workspace (Scratchpad) Tests

Test the scratchpad/special workspace:

- [ ] `SUPER + S` toggles special workspace
- [ ] Can move window to special workspace
- [ ] Can bring window back from special workspace
- [ ] Special workspace is independent from regular workspaces

---

## 19. Error & Log Checks

### Check for Errors
```bash
# Check Hyprland log for errors
cat ~/.local/share/hyprland/hyprland.log | grep -i error

# Check journal for errors
journalctl --user -xe | grep -i hypr
```

- [ ] No critical errors in logs
- [ ] No repeated error messages
- [ ] No warnings about missing dependencies

### Config Validation
```bash
# Validate config loads without errors
hyprctl reload
# Should show "ok"
```

- [ ] Config reload returns "ok"
- [ ] No error notifications appear

---

## 20. Autostart Tests

These should start automatically when you log in:

- [ ] Waybar is running: `pgrep waybar`
- [ ] Mako is running: `pgrep mako`
- [ ] Network Manager applet is running
- [ ] Polkit agent is running
- [ ] Clipboard manager is running (wl-paste)

---

## Common Issues & Troubleshooting

### Waybar Not Showing

If Waybar doesn't appear on your screen:

1. **Check if Waybar is running:**
   ```bash
   pgrep waybar
   ```

2. **Try starting Waybar manually to see errors:**
   ```bash
   pkill waybar  # Kill any existing instance
   waybar        # Start in foreground to see errors
   ```

3. **Common causes:**
   - Missing Nerd Font: Install `ttf-jetbrains-mono-nerd`
   - Config syntax error: Check the output from manual start
   - Wrong monitor configuration: Waybar may be on wrong screen

4. **Fix:**
   ```bash
   # Ensure fonts are installed
   sudo pacman -S ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols

   # Restart Waybar
   pkill waybar && waybar &
   ```

### If something doesn't work:

1. **Check if the service is running:**
   ```bash
   pgrep <service-name>
   ```

2. **Check logs:**
   ```bash
   journalctl --user -xe
   ```

3. **Reload Hyprland:**
   ```bash
   hyprctl reload
   ```

4. **Check config errors:**
   ```bash
   hyprctl configerrors
   ```

5. **Re-run the error collection script:**
   ```bash
   ./collect-errors.sh
   ```

---

## Test Summary

After completing all tests, rate each category:
- ✅ **Working** - Everything works as expected
- ⚠️ **Partial** - Some features work, some don't
- ❌ **Broken** - Nothing works in this category

**Overall System Status:** _______________

**Issues Found:**
1.
2.
3.

**Notes:**
