# Bash Configuration

This directory contains bash shell configuration including useful aliases and customizations.

## What's Included

### `bash_completion.sh`

Enhanced bash tab completion configuration that provides:
- **System completion**: Automatically sources `/usr/share/bash-completion/bash_completion` for comprehensive command completion
- **Alias completion**: Enables tab completion to work with your custom aliases
- **Enhanced options**: 
  - Shows all completions immediately if ambiguous
  - Shows completions on first tab press
  - Menu completion for cycling through options

**Requirements**: Install `bash-completion` package:
```bash
sudo pacman -S bash-completion
```

### `catppuccin_colors.sh`

Catppuccin Frappe color scheme for terminal and `ls` output:
- **LS_COLORS**: Beautiful colorized file listings using Catppuccin Frappe palette
  - Directories: Blue (#8caaee)
  - Executables: Green (#a6d189)
  - Archives: Yellow (#e5c890)
  - Images: Teal (#81c8be)
  - Videos: Pink (#f4b8e4)
  - Audio: Peach (#ef9f76)
  - Code files: Sapphire (#85c1dc)
  - Documents: Sky (#99d1db)
  - And many more file type specific colors
- **Color variables**: Exports all Catppuccin Frappe color variables for use in scripts

### `.bash_aliases`

A comprehensive collection of bash aliases organized by category:

#### Directory Navigation & Listing
- `ls` - Colorized output with directories first, alphabetically sorted
- `ll` - Long listing format with all files
- `la` - List all files including hidden
- `..`, `...`, `....` - Quick parent directory navigation

#### File Operations
- Safety aliases for `cp`, `mv`, `rm` (confirms before overwriting)
- `mkdir` - Creates parent directories automatically

#### System & Package Management
- `pacup` - Update system packages
- `pacin` - Install package
- `pacrem` - Remove package with dependencies
- `pacsearch` - Search packages
- `yayup`, `yaysearch` - AUR helper shortcuts

#### Git Shortcuts
- `g`, `gs`, `ga`, `gc`, `gp` - Common git commands
- `gl` - Pretty git log with graph

#### Hyprland Specific
- `hyprreload` - Reload Hyprland configuration
- `hyprerrors` - View Hyprland errors
- `waybar-restart` - Restart Waybar

#### Development
- Python shortcuts (`py`, `venv`, `activate`)
- Node.js shortcuts (`ni`, `ns`, `nt`, `nb`)
- Docker shortcuts (if installed)

#### Utilities
- Colorized `grep`, `egrep`, `fgrep`
- `df`, `du` - Human-readable disk usage
- `myip` - Get external IP address
- `weather` - Check weather report

See the `.bash_aliases` file for the complete list.

## Installation

The `install.sh` script automatically:
1. Creates a symlink: `~/.bash_aliases` → `./bash/.bash_aliases`
2. Installs `bash_completion.sh` to `~/.config/bash/bash_completion.sh`
3. Installs `catppuccin_colors.sh` to `~/.config/bash/catppuccin_colors.sh`
4. Adds source commands to `~/.bashrc` to load all configurations automatically

**Manual Installation** (if not using install.sh):
```bash
# Copy configuration files
mkdir -p ~/.config/bash
cp bash/bash_completion.sh ~/.config/bash/
cp bash/catppuccin_colors.sh ~/.config/bash/

# Add to ~/.bashrc (if not already present)
echo '' >> ~/.bashrc
echo '# Load Catppuccin Frappe colors for ls and terminal' >> ~/.bashrc
echo 'if [ -f ~/.config/bash/catppuccin_colors.sh ]; then' >> ~/.bashrc
echo '    . ~/.config/bash/catppuccin_colors.sh' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '# Load enhanced bash completion' >> ~/.bashrc
echo 'if [ -f ~/.config/bash/bash_completion.sh ]; then' >> ~/.bashrc
echo '    . ~/.config/bash/bash_completion.sh' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
```

## Usage

After installation and reloading your shell:

```bash
# Reload shell to apply all configurations
source ~/.bashrc
# or
rebash

# Tab Completion Examples
git <TAB>             # Shows all git commands
pacman -S <TAB>       # Shows available packages
cd ~/<TAB>            # Shows directories in home
./script.sh <TAB>     # Completes file paths

# Use the aliases
ll                    # List files in long format (with Catppuccin colors!)
pacup                 # Update system
gs                    # Git status
hyprreload           # Reload Hyprland config

# See Catppuccin colors in action
ls                    # Beautiful colorized file listing
ls -la               # Long format with colors
```

## Customization

To add your own aliases:

1. Edit the aliases file:
   ```bash
   editalias
   # or
   nano ~/.bash_aliases
   ```

2. Reload bash configuration:
   ```bash
   rebash
   # or
   source ~/.bashrc
   ```

## Compatibility

- Designed for **Arch Linux** and **Bash**
- **Required packages**:
  - `bash-completion` - for tab completion features (install with `sudo pacman -S bash-completion`)
- **Optional packages** (for aliases):
  - `tree` - for tree aliases
  - `inxi` - for system info
  - `netstat` - for port listing
  - `curl` - for IP and weather

## Enhanced Completion Options

For a significantly better experience than basic bash-completion, see **[ENHANCED_COMPLETION.md](ENHANCED_COMPLETION.md)** for modern alternatives:

- **fzf** (Fuzzy Finder) - Interactive fuzzy search for files, history, git, and more
- **ble.sh** - Modern bash line editor with syntax highlighting and auto-suggestions
- **Alternative shells** - Fish or Zsh for a completely different experience

**Quick recommendation**: Install `fzf` for fuzzy search (already in your packages) + `bash-completion` for context-aware completions. This gives you 90% of the benefits of modern shells while staying in bash.

## Notes

- The `ls` aliases use GNU coreutils flags (`--color=auto`, `--group-directories-first`)
- These work on Linux but may need adjustment for macOS/BSD
- Git aliases assume you have git installed
- Docker and Node.js aliases are only useful if those tools are installed
- **Colors**: The Catppuccin Frappe color scheme matches your Starship prompt theme
- **Completion**: Tab completion works best with `bash-completion` package installed. Without it, basic completion still works but with fewer features
- **fzf Integration**: If `fzf` is installed, `fzf_integration.sh` provides fuzzy search for files, history, git branches, and more. Use `Ctrl+R` for history, `Ctrl+T` for files, `Alt+C` for directories
