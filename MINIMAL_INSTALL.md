# Minimal Installation Guide

This guide covers installing a minimal, TUI-focused configuration ideal for:
- Headless servers
- Low-resource machines
- Remote development boxes
- Users who prefer terminal-only workflows
- Testing environments

## What is Included

### Core System
- **Hyprland** - Wayland compositor (minimal GUI layer) - *Optional, only with --gui flag*
- **Waybar** - Status bar for system information - *Optional, only with --gui flag*
- **Kitty** - Terminal emulator (GPU-accelerated, requires display server)
- **Rofi** - Application launcher - *Optional, only with --gui flag*
- **PipeWire** - Audio server
- **iwd** - Network management (lightweight)
- **Tailscale** - Mesh VPN for secure device connections (includes tsui TUI)
- **Hyprland ecosystem** - hyprpaper, hypridle, hyprlock - *Optional, only with --gui flag*

### TUI Applications (from `packages/tui.txt`)
- **System monitoring**: btop, ncdu, bandwhich, iotop
- **File management**: yazi, fd, ripgrep, fzf, bat, eza, zoxide
- **Git**: lazygit, git-delta
- **Audio**: pulsemixer
- **Bluetooth**: bluetuith
- **Network**: impala (manual install)
- **Terminal multiplexer**: tmux or zellij
- **Productivity**: taskwarrior, newsboat
- **Modern CLI tools**: dust, procs, ouch

### Development Tools
- **Neovim** with LazyVim
- **Python** development tools
- **C++** development tools
- **Build essentials** (gcc, cmake, etc.)
- **Starship** prompt

### Theming
- **Catppuccin Frappe** theme across all components
- **Nerd Fonts** (JetBrainsMono)
- **Papirus** icons
- **GTK themes** for consistency

## What is Excluded

- **LibreOffice** and office suite
- **GUI image viewers** (use image.nvim instead)
- **GUI file managers** (use yazi)
- **PDF arrangers** (keep zathura for viewing)
- **Discord/Slack** (optional, install separately if needed)
- **GUI system utilities** (all replaced with TUI equivalents)

## Installation Methods

### Method 1: Remote Bootstrap (Recommended)

For a fresh machine or remote server:

```bash
# DEFAULT: TUI-only installation (headless compatible)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

# Explicit minimal (same as default)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --minimal

# With GUI prompts (interactive)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --gui

# Full installation (all GUI components)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --full
```

### Method 2: Local Installation

If you've already cloned the repository:

```bash
cd ~/dots

# DEFAULT: TUI-only (headless compatible)
./install.sh

# Explicit minimal (same as default)
./install.sh --minimal

# Interactive GUI selection
./install.sh --gui

# Full installation (all GUI components)
./install.sh --full

# With force flag (skip prompts)
./install.sh --full --force
```

### Method 3: Custom Package Selection

Install only specific package categories:

```bash
cd ~/dots

# Core + TUI + Development only
sudo pacman -S --needed - < packages/core.txt
sudo pacman -S --needed - < packages/hypr-ecosystem.txt
sudo pacman -S --needed - < packages/tui.txt
sudo pacman -S --needed - < packages/development.txt
sudo pacman -S --needed - < packages/theming.txt

# AUR packages
yay -S --needed - < packages/aur-tui.txt

# Then deploy configs
./install.sh --skip-packages
```

## Post-Installation

### 1. Configure Git

Edit your git config:

```bash
nvim ~/.gitconfig
```

Update user information:
```gitconfig
[user]
    email = your.email@example.com
    name = Your Name
```

### 2. Learn Essential TUI Applications

**File Management** - yazi:
```bash
yazi              # Launch file manager
?                 # Show help
```

**Git Operations** - lazygit:
```bash
lazygit           # Launch in any git repo
?                 # Show help
```

**System Monitor** - btop:
```bash
btop              # Full system monitoring
```

**Audio Control** - pulsemixer:
```bash
pulsemixer        # TUI audio control
```

**Bluetooth** - bluetuith:
```bash
bluetuith         # Bluetooth management
```

**WiFi** - impala:
```bash
impala            # WiFi management TUI
```

**Tailscale VPN** - tailscale and tsui:
```bash
sudo tailscale up    # Connect to Tailscale
tsui                 # Manage Tailscale with TUI
```

### 3. Terminal Multiplexer

Choose between tmux (classic) or zellij (modern):

**tmux**:
```bash
tmux              # Start session
Ctrl-b ?          # Show help
Ctrl-b d          # Detach
tmux attach       # Re-attach
```

**zellij** (alternative):
```bash
zellij            # Start session
Ctrl-p ?          # Show help
```

### 4. Shell Configuration

The installer automatically sets up both **bash** and **zsh** configurations:

**Bash:**
- **`.bash_profile`**: Created for login shells (TTY logins), sources `.bashrc` and handles kitty auto-launch
- **`.bashrc`**: Enhanced with TTY optimizations, starship integration, and aliases
- **Completion**: bash-completion with colored completions

**Zsh (Recommended):**
- **`.zprofile`**: Created for login shells (TTY logins), sources `.zshrc` and handles kitty auto-launch
- **`.zshrc`**: Enhanced with menu selection (scrollable completion lists!), starship integration, and aliases
- **Completion**: Built-in zsh completion with menu selection (use arrow keys to scroll through completions)
- **Default shell**: Can be set to zsh (in force mode) or manually with `chsh -s /usr/bin/zsh`

**Key Feature - Zsh Menu Selection:**
```zsh
# Press Tab to see completions, then use arrow keys to scroll!
git <TAB>
> add          # ← cursor, use ↑↓ to scroll
  branch
  checkout
  ...
```

**Manual Shell Enhancements** (optional):

Add to `~/.bashrc`:

```bash
# Yazi - cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Modern CLI replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat='bat --theme=Catppuccin-frappe'
alias find='fd'
alias grep='rg'
alias du='dust'
alias ps='procs'

# TUI application shortcuts
alias fm='yazi'
alias lg='lazygit'
alias mon='btop'
```

Then reload:
```bash
source ~/.bashrc
```

### 5. Zoxide Setup

Initialize zoxide for smart directory jumping:

**For bash:**
```bash
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
source ~/.bashrc
```

**For zsh:**
```zsh
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Usage:**
```bash
# Now use 'z' instead of 'cd'
z ~/dots          # Jump to frequently used directory
z -               # Jump back
```

## Essential Keybindings

### Hyprland

Add TUI app launcher keybinds to `~/.config/hypr/conf/keybinds.conf`:

```conf
# TUI Applications
bind = $mainMod, E, exec, kitty -e yazi          # File manager
bind = $mainMod, G, exec, kitty -e lazygit       # Git
bind = $mainMod, V, exec, kitty -e pulsemixer    # Audio
bind = $mainMod, B, exec, kitty -e bluetuith     # Bluetooth
bind = $mainMod, W, exec, kitty -e impala        # WiFi
bind = $mainMod, T, exec, kitty -e btop          # System monitor
```

## Resource Usage

Minimal installation typical RAM usage (idle):

- **Hyprland compositor**: ~80-120MB
- **Waybar**: ~30-50MB
- **Kitty (3 instances)**: ~150-200MB
- **PipeWire**: ~20-30MB
- **System services**: ~100-150MB

**Total idle**: ~400-600MB RAM

Compare to full desktop environment (GNOME/KDE): 1.5-2.5GB RAM idle

## Adding GUI Applications Later

If you need specific GUI applications after minimal install:

```bash
# LibreOffice
sudo pacman -S libreoffice-fresh

# Firefox
sudo pacman -S firefox

# Discord
yay -S discord

# Image viewer
sudo pacman -S imv
```

## Remote Access

The minimal installation is fully functional over SSH:

```bash
# Connect to remote machine
ssh user@machine

# Attach to existing tmux session
tmux attach

# Or start new session
tmux

# All TUI apps work identically over SSH
yazi              # File management
lazygit           # Git operations
btop              # System monitoring
pulsemixer        # Audio control
nvim              # Code editing
```

## TTY vs Terminal Emulator Strategy

### Understanding the Setup

This installation uses a **dual-strategy approach** for terminal access:

1. **Enhanced TTY (Text Console)**: Works everywhere (headless, SSH, local console)
   - Configured with starship prompt, 256-color support, and optimized settings
   - Always available as fallback
   - Limited to basic terminal features (no true color, ligatures, or images)

2. **Kitty Terminal Emulator**: Superior experience when display server is available
   - Requires X11 or Wayland display server
   - Full features: true color, font ligatures, images, GPU acceleration
   - Auto-launches when logging in via TTY if display server is detected
   - Falls back to enhanced TTY if no display server

### How It Works

**On TTY Login (Local Console)**:
- If display server (X11/Wayland) is running → automatically launches kitty
- If no display server → uses enhanced TTY with starship and optimized colors
- Both provide starship prompt and all TUI applications

**On SSH**:
- Always uses enhanced TTY (kitty auto-launch is disabled for SSH)
- Full TUI application support
- Starship prompt works perfectly

**In GUI Environment**:
- Kitty is available as the terminal emulator
- All features enabled (true color, ligatures, etc.)

### Starting a Display Server

If you want to use kitty on a laptop with a display but no display server running:

**For X11**:
```bash
startx
# Or with a window manager:
startx /usr/bin/i3  # or your preferred WM
```

**For Wayland (Hyprland)**:
```bash
# If Hyprland is installed:
Hyprland
# Or via display manager (SDDM, GDM, etc.)
```

Once the display server starts, logging in via TTY will automatically launch kitty.

## Headless Mode (No Hyprland)

For true headless servers, skip Hyprland entirely:

```bash
# Install only TUI packages + development tools
sudo pacman -S --needed - < packages/tui.txt
sudo pacman -S --needed - < packages/development.txt

# Deploy only shell configs
ln -sf ~/dots/bash/.bashrc ~/.bashrc
ln -sf ~/dots/bash/.bash_aliases ~/.bash_aliases
ln -sf ~/dots/git/.gitconfig ~/.gitconfig
ln -sf ~/dots/starship/starship.toml ~/.config/starship.toml

# TUI app configs
ln -sf ~/dots/bluetuith ~/.config/bluetuith
ln -sf ~/dots/lazygit ~/.config/lazygit
ln -sf ~/dots/yazi ~/.config/yazi
```

**Note**: Even in headless mode, kitty is installed (it's a TUI tool). It simply won't launch automatically without a display server, and you'll use the enhanced TTY instead.

## Performance Tuning

For low-resource machines:

### Hyprland Config

Edit `~/.config/hypr/conf/animations.conf`:

```conf
# Disable animations
animations {
    enabled = false
}
```

Edit `~/.config/hypr/conf/decorations.conf`:

```conf
# Reduce blur and shadows
decoration {
    blur {
        enabled = false
    }
    drop_shadow = false
}
```

### Waybar Config

Edit `~/.config/waybar/config`:

```json
{
    "update-interval": 10  // Reduce from 1 to 10 seconds
}
```

## Troubleshooting

### TTY Login Issues

**Kitty not auto-launching on TTY login**:
- Check if display server is running: `echo $DISPLAY` or `echo $WAYLAND_DISPLAY`
- Verify kitty is installed: `command -v kitty`
- Check `.bash_profile` exists and has kitty auto-launch logic
- If no display server, enhanced TTY will be used (this is expected)

**Starship prompt not showing**:
- Ensure starship is installed: `pacman -Q starship`
- Check `.bashrc` sources starship: `grep starship ~/.bashrc`
- Reload shell: `source ~/.bashrc` or `source ~/.bash_profile`

**Default shell not bash**:
- Check current shell: `echo $SHELL`
- Change manually: `chsh -s $(which bash)` (requires password)
- Log out and back in for changes to take effect

### TUI apps not launching

Ensure packages are installed:
```bash
pacman -Q yazi lazygit btop pulsemixer bluetuith-bin
```

### Missing fonts/icons

Install theming packages:
```bash
sudo pacman -S --needed - < packages/theming.txt
```

### Network/Bluetooth not working

Enable services:
```bash
sudo systemctl enable --now iwd
sudo systemctl enable --now bluetooth
```

### Audio not working

Check PipeWire:
```bash
systemctl --user status pipewire pipewire-pulse
```

Restart if needed:
```bash
systemctl --user restart pipewire pipewire-pulse
```

## Further Reading

- [TUI Application Documentation](./CLAUDE.md#tui-first-workflow)
- [Individual app READMEs](./):
  - `bluetuith/README.md`
  - `lazygit/README.md`
  - `yazi/README.md`
  - `pulsemixer/README.md`
- [Package Organization](./packages/README.md)
- [Hyprland Configuration](./hyprland/README.md)

## Customization

The minimal install is a starting point. Customize by:

1. **Editing package lists**: Add/remove packages from `packages/tui.txt`
2. **Modifying configs**: All TUI app configs are in their respective directories
3. **Adding keybinds**: Edit `~/.config/hypr/conf/keybinds.conf`
4. **Installing additional tools**: Use `pacman` or `yay` as needed

## Philosophy

The minimal installation embodies:
- **Efficiency over features**: Only what you actually use
- **Keyboard over mouse**: Maximize productivity
- **Terminal over GUI**: Better performance, works anywhere
- **Simplicity over complexity**: Easy to understand and maintain

Perfect for developers, sysadmins, and power users who value speed and efficiency over visual flair.
