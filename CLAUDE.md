# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a dotfiles repository for Arch Linux and Hyprland window manager configuration. It serves as a staging area for configuration files before deployment via symlinks to the system.

**Repository Location**: `~/dots` (canonical location)
- System symlinks may reference files via `~/.local/share/dots/` depending on installation history
- Always work from `~/dots` for git operations and configuration edits

## Architecture Overview

### Symlink-Based Deployment Model

This repository uses a **symlink-based architecture** where configuration files live in the repository and are symlinked to `~/.config/`:

- Repository files remain editable via git while being actively used by the system
- Changes to files in this repo immediately affect the running system
- `install.sh` creates symlinks: `~/.config/hypr` → `./hyprland/`, etc.
- Backups are created before symlinking: `~/.config-backup-TIMESTAMP/`
- `uninstall.sh` removes symlinks (backups are preserved)

### Modular Installation System

**The installer itself** uses a modular, phase-based architecture:

```
install/
├── lib/           # Shared libraries (colors, TUI, logging, state, utils)
├── preflight/     # System preparation (checks, repos, conflicts, migrations)
├── packages/      # Package installation (core, hypr-ecosystem, theming, dev, etc.)
├── config/        # Configuration deployment (hyprland, waybar, neovim, etc.)
├── services/      # Service management (iwd, fprintd, tailscale)
└── post-install/  # Final tasks (wallpapers, finalization)
```

**Key features:**
- **State tracking**: Progress saved to `~/.local/state/dots/install-state.json`
- **Resume capability**: `--resume` flag continues from last successful phase
- **Comprehensive logging**: All output saved to `~/.local/state/dots/logs/`
- **Error recovery**: Clear error messages with recovery instructions
- **Configuration files**: `install.conf` for customization
- **Remote bootstrap**: Single-command installation via curl
- **Non-interactive mode**: Auto-detects piped input (e.g., `curl | bash`) and disables prompts

**Hyprland configuration** also uses a modular approach (hyprland/conf/):
- `hyprland.conf` is the main entry point that sources all modular configs
- Each `.conf` file handles a specific concern (theme, keybinds, animations, etc.)
- Modifications should be made to individual modular files, not the main file
- Location: `hyprland/conf/*.conf`

**All configurations** follow the Catppuccin Frappe color scheme:
- Theme colors defined in: `hyprland/conf/theme.conf`
- Waybar styling: `waybar/style.css`
- Terminal: `kitty/kitty.conf`
- Shell prompt: `starship/starship.toml`
- See component README.md files for color references

### Package Management Strategy

Packages are organized by category in `packages/*.txt`:

**Core/TUI Packages (always installed):**
- `core.txt` - Essential system packages
- `network-tools.txt` - Network utilities (curl, wget, rsync, httpie, mosh, openssh)
- `documentation.txt` - Documentation tools (tldr/tealdeer, man pages)
- `tui.txt` - TUI applications (yazi, lazygit, btop, taskwarrior, etc.)
- `development.txt` - Python, C++, Node.js, Neovim, LazyVim, build tools, markdown/spell check
- `data-processing.txt` - Data format processors (yq, miller, sd, choose)
- `languages.txt` - Optional language toolchains (Rust, Go)

**GUI Packages (optional, conditional):**
- `theming-fonts.txt` - Fonts (Nerd Fonts) - headless safe, always installed
- `theming-gui.txt` - Qt/GTK theming (only with GUI)
- `hypr-ecosystem.txt` - Hypr-specific tools (hyprpaper, hypridle, etc.)
- `gui-essential.txt` - Hyprland, Waybar, Kitty, Rofi, Mako, etc.
- `gui-browsers.txt` - Firefox
- `gui-productivity.txt` - LibreOffice, Zathura
- `gui-communication.txt` - Discord, Slack

**AUR Packages:**
- `aur-tui.txt` - TUI tools (pacseek, bluetuith-bin, quickwall)
- `aur-gui-themes.txt` - GUI themes (Catppuccin GTK/SDDM/cursors)
- `gui-essential-aur.txt` - GUI AUR packages (waypaper, etc.)

The `install.sh` script is an **orchestrator** that sources and executes modular phase scripts:
- **Preflight**: Repository config, mirrorlist optimization, conflict resolution, migrations
- **Packages**: Install all package categories (core, hypr-ecosystem, theming, dev, productivity, AUR)
- **Configuration**: Deploy all configs via symlinks with timestamped backups
- **Services**: Enable and configure system services (iwd, fprintd, tailscale)
- **Post-install**: Wallpaper collection, LazyVim setup, final checks

The modular design makes the codebase:
- **Maintainable**: Small, focused scripts instead of one 1000+ line file
- **Testable**: Each phase can be tested independently
- **Recoverable**: State tracking enables resume after failures
- **Extensible**: Easy to add new phases or modify existing ones

The `update.sh` script provides system-wide updates:
- Updates all official repository packages (pacman)
- Updates all AUR packages (yay/paru)
- Optional mirrorlist optimization for faster downloads
- Optional package cache cleanup to free disk space
- Optional orphaned package removal
- Detection of .pacnew configuration files needing review
- Branded with matching Catppuccin Frappe TUI design

## Common Development Commands

### Installation and Deployment

```bash
# DEFAULT: TUI-only installation (headless compatible, no GUI)
./install.sh

# Interactive GUI selection (prompts for which GUI components to install)
./install.sh --gui

# Minimal/headless (same as default - explicit)
./install.sh --minimal

# Full installation (all GUI components + TUI)
./install.sh --full

# Config-only installation (skip packages)
./install.sh --skip-packages

# Force mode (skip prompts, for automation)
./install.sh --force

# Dry run (show what would happen)
./install.sh --dry-run

# Resume from failure
./install.sh --resume

# Reset state and start fresh
./install.sh --reset

# Use custom config file
./install.sh --config my-install.conf

# Remote bootstrap (TUI-only by default)
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

# Remote bootstrap with GUI
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --full

# Remove symlinks
./uninstall.sh

# Show installation options
./install.sh --help
```

### System Updates

```bash
# Full system update (official + AUR packages)
./update.sh

# Auto-yes all prompts (unattended update)
./update.sh -y

# Update only AUR packages
./update.sh --aur-only

# Update only official repository packages
./update.sh --official-only

# Skip optional maintenance prompts
./update.sh --skip-clean --skip-orphans

# Show update options
./update.sh --help
```

### Configuration Management

```bash
# Reload Hyprland configuration (test changes)
hyprctl reload

# Check for configuration errors
hyprctl configerrors

# Validate Hyprland config and collect diagnostics
./collect-errors.sh

# View current monitor settings
hyprctl monitors

# View active windows
hyprctl clients
```

### Network Management (iwd)

```bash
# Launch impala TUI for WiFi management
impala

# Interactive iwctl session (alternative)
iwctl

# Common iwctl commands
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "SSID"

# Check iwd service status
systemctl status iwd

# Enable/disable iwd service
sudo systemctl enable --now iwd
sudo systemctl disable iwd
```

### Wallpaper Management

```bash
# Launch waypaper GUI to browse wallpapers
waypaper

# Download new wallpaper from Unsplash
quickwall
quickwall --search "landscape"

# Manual hyprctl commands
hyprctl hyprpaper preload ~/path/to/wallpaper.png
hyprctl hyprpaper wallpaper ",~/path/to/wallpaper.png"
hyprctl hyprpaper listloaded

# Wallpaper collection location
ls ~/.local/share/catppuccin-wallpapers/frappe/
```

### Testing and Debugging

```bash
# Run through testing checklist
cat TESTING.md

# Comprehensive system diagnostic (RECOMMENDED - checks everything)
./system-check.sh

# Specific diagnostics:
./collect-errors.sh    # Hyprland config validation and logs only
./debug-packages.sh    # Package installation issues only

# Check service status
pgrep waybar
pgrep mako
systemctl --user status pipewire

# View Hyprland logs
tail -f ~/.local/share/hyprland/hyprland.log

# Test notifications
notify-send "Test" "This is a test notification"

# Reload Waybar
pkill -USR2 waybar
```

### Manual Package Management

```bash
# Install specific package category
sudo pacman -S --needed - < packages/core.txt
sudo pacman -S --needed - < packages/development.txt

# Install AUR packages (requires yay or paru)
yay -S --needed - < packages/aur-tui.txt

# Check installed package versions
hyprctl version
waybar --version
```

## Configuration File Locations

When editing configurations, files are in this repository but active via symlinks:

### Core Configurations

| Component | Repository Path | System Symlink Target |
|-----------|----------------|----------------------|
| Hyprland | `./hyprland/` | `~/.config/hypr/` |
| Hyprlock | `./hyprland/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| Waybar | `./waybar/` | `~/.config/waybar/` |
| Kitty | `./kitty/` | `~/.config/kitty/` |
| Rofi | `./rofi/` | `~/.config/rofi/` |
| Mako | `./mako/` | `~/.config/mako/` |
| Zathura | `./zathura/` | `~/.config/zathura/` |
| wlogout | `./wlogout/` | `~/.config/wlogout/` |
| btop | `./btop/` | `~/.config/btop/` |
| SDDM | `./sddm/theme.conf` | `/etc/sddm.conf.d/theme.conf` |
| Starship | `./starship/starship.toml` | `~/.config/starship.toml` |
| Neovim | `./nvim/lua/` | `~/.config/nvim/lua/` (files symlinked into LazyVim) |

### System Configurations

| Component | Repository Path | System Symlink Target |
|-----------|----------------|----------------------|
| Git | `./git/.gitconfig` | `~/.gitconfig` |
| Git Ignore | `./git/.gitignore_global` | `~/.gitignore_global` |
| GTK 3.0 | `./gtk-3.0/` | `~/.config/gtk-3.0/` |
| GTK 4.0 | `./gtk-4.0/` | `~/.config/gtk-4.0/` |
| Waypaper | `./waypaper/` | `~/.config/waypaper/` |

### TUI Application Configurations

| Component | Repository Path | System Symlink Target |
|-----------|----------------|----------------------|
| Bluetuith | `./bluetuith/` | `~/.config/bluetuith/` |
| Lazygit | `./lazygit/` | `~/.config/lazygit/` |
| Yazi | `./yazi/` | `~/.config/yazi/` |
| Pulsemixer | N/A (no config) | Uses terminal colors |
| Tmux | `./tmux/` (optional) | `~/.config/tmux/` |
| Zellij | `./zellij/` (optional) | `~/.config/zellij/` |

### Optional Configurations (Not Tracked)

These configurations exist on your system but are intentionally not tracked in the repository. They may contain machine-specific or sensitive information:

- **Discord** (`~/.config/discord/`) - Contains session tokens and cache
- **Obsidian** (`~/.config/obsidian/`) - Note-taking app with personal vaults
- **Bluetooth** (`~/.config/bluetuith/`) - Bluetooth TUI settings (minimal config)
- **dconf** (`~/.config/dconf/`) - GNOME settings database (auto-generated)
- **GitHub CLI** (`~/.config/gh/`) - Contains authentication tokens
- **Application cache/state** - Various apps store temporary data

If you want to track any of these, create a directory in the repository and add the configuration files.

## Key Design Decisions

1. **Catppuccin Frappe Everywhere**: All theming must use the Catppuccin Frappe palette. Color definitions are in `hyprland/conf/theme.conf`.

2. **LazyVim Integration**: The install script clones LazyVim starter and then symlinks custom configurations from `./nvim/lua/`. Changes to the dots repo immediately affect the active Neovim config. This allows upstream LazyVim updates while preserving customizations.

   **Critical Catppuccin Fix**: The minimal colorscheme config overrides `NormalFloat` background to match `base` color instead of the default darker `mantle`. This fixes color mismatches in Snacks.explorer, completion menus, and all floating windows. Additional highlight overrides ensure consistent Frappe colors across all UI elements.

3. **Conflict Resolution**: The install script automatically resolves package conflicts (e.g., PulseAudio → PipeWire, NetworkManager → iwd) using `pacman --ask=4`.

4. **Repository Management**: The install script checks and fixes repository configuration, optimizes mirrorlist with reflector, and syncs databases before installation.

5. **XDG Base Directory Compliance**: All configurations follow XDG standards and are placed in `~/.config/`.

6. **Network Management**: Uses iwd (modern wireless daemon) with impala (TUI frontend). This replaces NetworkManager for a lighter, more efficient WiFi management solution. Waybar network module opens impala on click for interactive WiFi management. Use `impala` for the friendly TUI or `iwctl` for command-line control.

7. **Wallpaper Management**: Uses waypaper (GUI) + hyprpaper (backend) + Catppuccin wallpaper collection. The install script automatically clones a curated collection of ~50-200 Frappe wallpapers to `~/.local/share/catppuccin-wallpapers/`. ImageMagick is excluded to avoid package conflicts; waypaper provides a better user experience for wallpaper selection.

8. **Non-Interactive Mode Handling**: The installer auto-detects when stdin is not a terminal (e.g., `curl | bash`) and automatically enables `--no-tui --force` flags to disable interactive prompts. All `read` commands are protected with `|| true` to prevent failures on EOF. This ensures seamless remote bootstrap installation while maintaining interactive prompts when run locally.

   **Auto-Update Behavior**: When running via `curl | bash` and the installation directory (`~/.local/share/dots`) already exists, the bootstrap script automatically pulls the latest changes from GitHub. Local changes are stashed before updating. This ensures repeated bootstrap runs always use the latest version without manual intervention.

9. **TUI-First Philosophy**: This configuration prioritizes terminal user interfaces (TUI) over GUI applications wherever practical. System management, file browsing, git operations, audio control, and network/Bluetooth configuration are all handled through fast, keyboard-driven TUI applications. This approach reduces resource usage, increases efficiency, and ensures full functionality over SSH.

## TUI-First Workflow

This configuration embraces a **terminal-first, keyboard-driven** workflow that minimizes GUI application usage while maintaining full system functionality.

### Philosophy

- **Keyboard > Mouse**: All primary workflows should be achievable without touching the mouse
- **Terminal > GUI**: Prefer TUI applications for better performance and SSH compatibility
- **Minimal > Bloated**: Install only what's needed, avoid feature-heavy GUI applications
- **Fast > Pretty**: Prioritize responsiveness and efficiency over visual complexity

### Core TUI Applications

**System Management**:
- **btop** - Real-time system monitor (CPU, RAM, disk, network)
- **ncdu** - Disk usage analyzer
- **bandwhich** - Network bandwidth monitor per process

**File Management**:
- **yazi** - Modern file manager with image preview
- **fd** - Fast find alternative
- **ripgrep** (rg) - Fast grep for content search
- **fzf** - Fuzzy finder (essential for shell productivity)

**Git Operations**:
- **lazygit** - Full-featured git TUI
- **delta** - Syntax-highlighted diffs

**System Control**:
- **pulsemixer** - Audio control (volume, device switching)
- **bluetuith** - Bluetooth device management
- **impala** - WiFi network management (iwd frontend)

**Development**:
- **neovim/lazyvim** - Text editing, coding, document editing
- **image.nvim** - Image viewing in Neovim
- **curl/wget/rsync** - Network transfers, API testing
- **httpie** - User-friendly HTTP client
- **uv** - Fast Python package manager
- **yarn/pnpm** - Node.js package managers

**Note-Taking & Documentation**:
- **obsidian.nvim** - Obsidian-compatible wiki links, daily notes, backlinks, tags
- **render-markdown.nvim** - Beautiful in-editor markdown rendering
- **marksman** - LSP for markdown (auto-completion, goto definition)
- **img-clip.nvim** - Paste images from clipboard into markdown
- **image.nvim** - Display images inline in terminal (Kitty graphics protocol)
- **glow** - Terminal markdown renderer
- **pandoc** - Universal document converter
- **aspell/hunspell** - Spell checking
- **tldr/tealdeer** - Quick command examples

**Data Processing**:
- **yq** - YAML processor (jq for YAML)
- **miller** - CSV/TSV processing
- **sd** - Modern sed replacement
- **choose** - Modern cut replacement

**Terminal Enhancement**:
- **tmux** or **zellij** - Terminal multiplexer for session management
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls with colors and icons
- **zoxide** - Smart cd that learns your habits
- **dust** - Modern du for disk usage
- **procs** - Modern ps for process viewing

**Productivity**:
- **taskwarrior** + **taskwarrior-tui** - Task management
- **newsboat** - RSS feed reader

### Integration Points

**Hyprland Keybindings**: All TUI apps can be launched with Super+key combinations:
```conf
bind = $mainMod, E, exec, kitty -e yazi          # File manager
bind = $mainMod, G, exec, kitty -e lazygit       # Git
bind = $mainMod, V, exec, kitty -e pulsemixer    # Audio
bind = $mainMod, B, exec, kitty -e bluetuith     # Bluetooth
bind = $mainMod, W, exec, kitty -e impala        # WiFi
```

**Waybar Modules**: Status bar elements open relevant TUI apps on click:
- Network module → impala
- Volume module → pulsemixer
- Bluetooth module → bluetuith

### Minimal GUI Applications

The configuration includes minimal GUI applications only where TUI alternatives are impractical:

**Essential GUI**:
- **Hyprland** - Wayland compositor (necessary for graphics)
- **Waybar** - Status bar (visual system information)
- **Kitty** - Terminal emulator (GPU-accelerated, essential for TUI apps)
- **Rofi** - Application launcher (fast, minimal)
- **Zathura** - PDF viewer (minimal, vim-like)

**Optional GUI** (productivity-focused):
- **LibreOffice** - Document editing (when terminal editors won't suffice)
- **Firefox** - Web browsing (no TUI alternative)
- **Discord/Slack** - Communication (if needed)

### Minimal Installation Mode

**Default installation is now TUI-only (headless compatible)**:

```bash
# TUI-only (default - no flags needed)
./install.sh

# Or explicit
./install.sh --minimal
```

This installs:
- Core system packages (network, audio, Bluetooth)
- All TUI applications (`packages/tui.txt`)
- Development tools (Neovim, compilers)
- Theming (fonts, icons)
- NO GUI components (no Hyprland, no Firefox, etc.)
- Development tools
- System theming (for consistency)

Skip:
- LibreOffice and office suite
- GUI image viewers
- Optional GUI applications

### Remote/Headless Usage

The TUI-first approach ensures full system management over SSH:

```bash
# SSH into machine
ssh user@machine

# All system management available via TUI
btop                    # Monitor system
yazi                    # Browse files
lazygit                 # Manage git repos
pulsemixer              # Control audio
bluetuith               # Manage Bluetooth
impala                  # Connect to WiFi
nvim                    # Edit files/code/notes
```

### Note-Taking in TUI Mode

The Neovim configuration provides **Obsidian-like note-taking capabilities** entirely in TUI mode, perfect for developers who want to maintain notes, documentation, and meeting notes alongside their code.

**Features (90% of Obsidian functionality):**
- ✅ **Wiki links**: `[[note name]]` with auto-completion
- ✅ **Daily notes**: Quick access to daily journal entries
- ✅ **Backlinks**: See which notes reference the current note
- ✅ **Tags**: Organize with `#tag` syntax
- ✅ **Beautiful rendering**: Headings, lists, code blocks styled in-editor
- ✅ **Image support**: Display images inline (Kitty terminal)
- ✅ **Clipboard paste**: Paste images directly from clipboard
- ✅ **Spell checking**: Automatic spell check in markdown files
- ✅ **LSP completion**: Auto-complete for wiki links and references
- ✅ **Plain text + Git**: All notes are plain markdown files, version controlled

**Keybindings (obsidian.nvim):**
```vim
<leader>on  - New note
<leader>os  - Search notes
<leader>oq  - Quick switch between notes
<leader>ob  - Show backlinks
<leader>ot  - Search tags
<leader>od  - Open today's daily note
<leader>ol  - Show all links in current note
<leader>of  - Follow link under cursor
<leader>p   - Paste image from clipboard
<leader>ss  - Toggle spell check
<leader>mp  - Markdown preview in browser (optional)
```

**Workflow Example:**
```bash
# Create notes directory
mkdir -p ~/notes/daily ~/notes/templates

# Start Neovim
nvim

# In Neovim:
# - Press <leader>od to open today's daily note
# - Type [[meeting notes]] to create a link
# - Press <leader>of on the link to create/open that note
# - Paste screenshots with <leader>p
# - See beautiful rendering automatically
# - All files are plain markdown in ~/notes/
```

**vs. Obsidian GUI:**
- ✅ **Faster**: No Electron overhead, instant startup
- ✅ **SSH-friendly**: Full functionality over SSH
- ✅ **Keyboard-driven**: No mouse required
- ✅ **Git-native**: Easy version control and sync
- ❌ **No graph view**: Cannot visualize note connections (GUI only)
- ❌ **No canvas**: Cannot create visual whiteboards
- ✅ **Mobile sync**: Use Obsidian mobile app with same ~/notes/ directory

**Spell Checking:**
- Automatic in markdown, text, and git commit files
- Keybindings: `]s` next error, `[s` previous error, `z=` suggestions, `zg` add to dictionary

**Image Handling:**
- Paste from clipboard: `<leader>p` (saves to `assets/images/`)
- View inline: Images render in terminal automatically (Kitty protocol)
- Alt text support: `![description](path/to/image.png)`

**Document Conversion:**
- **pandoc** included for converting markdown to PDF, HTML, DOCX, etc.
- Example: `pandoc note.md -o note.pdf`

### Performance Benefits

TUI-first workflow provides:
- **Lower RAM usage** - Terminal apps use 10-50MB vs 200-500MB for GUI equivalents
- **Faster startup** - TUI apps launch in <100ms vs 1-3s for GUI apps
- **Better SSH experience** - Full functionality remotely
- **Reduced battery usage** - No GPU rendering for most tasks
- **Snappier response** - Direct terminal rendering vs GUI framework overhead

### Learning Curve

TUI applications have a steeper initial learning curve but pay dividends in long-term efficiency:

1. **Week 1**: Learn basic navigation (j/k/h/l, common keybinds)
2. **Week 2**: Master your most-used tools (file manager, git, system monitor)
3. **Month 1**: Develop muscle memory, see productivity gains
4. **Month 3+**: Significantly faster than GUI equivalents, hate using the mouse

### Documentation

Each TUI application has a README in its config directory with:
- Installation instructions
- Essential keybindings
- Integration examples
- Tips and troubleshooting

Locations:
- `bluetuith/README.md`
- `lazygit/README.md`
- `yazi/README.md`
- `pulsemixer/README.md`

## Troubleshooting Workflow

When configuration or system issues arise:

1. **Run comprehensive diagnostic** (recommended):
   ```bash
   ./system-check.sh
   ```
   This checks ALL components: packages, services, configs, logs, permissions, etc.
   Output saved to `system-check-output.txt`

2. **Or use specific diagnostics**:
   - `./collect-errors.sh` - Hyprland config validation and logs only
   - `./debug-packages.sh` - Package installation issues only

3. **Review the output**:
   ```bash
   less system-check-output.txt
   # or
   cat debug-output.txt
   ```

4. **If on a remote machine**, commit and push the diagnostic output:
   ```bash
   git add system-check-output.txt
   git commit -m "Add system diagnostic from target machine"
   git push origin main
   ```

5. **Pull on development machine and analyze**:
   ```bash
   git pull && less system-check-output.txt
   ```

## Component Documentation

Each major component has its own README.md with detailed configuration information:
- `hyprland/README.md` - Hyprland settings, keybinds, window rules
- `waybar/README.md` - Waybar modules, styling, icons
- `btop/README.md` - System monitor with Catppuccin Frappe theme
- `wlogout/README.md` - Wayland logout menu with Catppuccin Frappe theme
- `sddm/README.md` - SDDM login manager theme configuration with Catppuccin Frappe
- `tailscale/README.md` - Tailscale mesh VPN and tsui terminal interface setup
- `fprintd/README.md` - Fingerprint authentication setup and PAM configuration
- `starship/README.md` - Starship shell prompt configuration with Catppuccin Frappe theme
- `packages/README.md` - Package organization and installation details
- `hyprland/wallpapers/README.md` - Wallpaper setup with hyprpaper

Refer to component READMEs for specific customization guidance.
