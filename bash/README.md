# Bash Configuration

This directory contains bash shell configuration including useful aliases and customizations.

## What's Included

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
2. Adds source command to `~/.bashrc` to load aliases automatically

## Usage

After installation and reloading your shell:

```bash
# Reload shell to apply aliases
source ~/.bashrc
# or
rebash

# Use the aliases
ll                    # List files in long format
pacup                 # Update system
gs                    # Git status
hyprreload           # Reload Hyprland config
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
- Some aliases require specific packages:
  - `tree` - for tree aliases
  - `inxi` - for system info
  - `netstat` - for port listing
  - `curl` - for IP and weather

## Notes

- The `ls` aliases use GNU coreutils flags (`--color=auto`, `--group-directories-first`)
- These work on Linux but may need adjustment for macOS/BSD
- Git aliases assume you have git installed
- Docker and Node.js aliases are only useful if those tools are installed
