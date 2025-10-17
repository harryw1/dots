# Starship Shell Prompt

This directory contains the Starship prompt configuration with the Catppuccin Frappe theme, matching the rest of the dotfiles aesthetic.

## What is Starship?

Starship is a minimal, blazing-fast, and infinitely customizable prompt for any shell. It shows you relevant information about your current directory, git status, programming languages, and more.

## Features

- **Catppuccin Frappe Theme**: Matches the color scheme used throughout these dotfiles
- **Powerline Style**: Clean, modern look with smooth color transitions
- **Language Detection**: Automatically shows versions for detected languages (Node.js, Python, Rust, Go, etc.)
- **Git Integration**: Displays current branch and repository status
- **Performance Metrics**: Shows command execution time for long-running commands
- **OS Detection**: Shows your operating system icon

## Installation

The `install.sh` script automatically:
- Symlinks the starship configuration:
  - Source: `./starship/starship.toml`
  - Target: `~/.config/starship.toml`
- Adds Starship initialization to your shell configuration (bash/zsh)

## Shell Setup

### Automatic Setup (Bash/Zsh)

The install script automatically adds the Starship initialization to `~/.bashrc` and/or `~/.zshrc` if those files exist. After installation, simply reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc, depending on your shell
```

Or open a new terminal window.

### Manual Setup (Other Shells)

For Fish, add to `~/.config/fish/config.fish`:
```fish
starship init fish | source
```

For other shells (Ion, Elvish, Tcsh, Nushell, Xonsh, PowerShell), see the [official Starship documentation](https://starship.rs/guide/#%F0%9F%9A%80-installation).

## Requirements

- **Nerd Font**: Starship uses Nerd Font icons. Make sure you have a Nerd Font installed and configured in your terminal.
  - The `packages/theming.txt` includes several Nerd Fonts (ttf-jetbrains-mono-nerd, ttf-firacode-nerd, ttf-hack-nerd)
  - Configure your terminal (Kitty) to use one of these fonts

## Customization

The configuration file is located at `./starship/starship.toml`. You can customize:
- Which modules to display
- Module order and appearance
- Color scheme (though this is set to Catppuccin Frappe to match the theme)
- Time format, truncation length, symbols, and more

See the [Starship configuration documentation](https://starship.rs/config/) for all available options.

## Color Palette

The Catppuccin Frappe palette is defined in the configuration with these colors:
- **Red** (#e78284): OS/Username segment
- **Peach** (#ef9f76): Directory segment
- **Yellow** (#e5c890): Git segment
- **Green** (#a6d189): Language/tool segments
- **Sapphire** (#85c1dc): Environment segments
- **Lavender** (#babbf1): Time/duration segments

## Troubleshooting

### Icons not showing
Make sure you have a Nerd Font installed and configured in your terminal. Check `kitty/kitty.conf` to verify the font setting.

### Starship command not found
Ensure starship is installed:
```bash
pacman -Q starship
```

If not installed, run:
```bash
sudo pacman -S starship
# or
./install.sh --packages
```

### Configuration not loading
Verify the symlink exists:
```bash
ls -l ~/.config/starship.toml
```

Should point to: `/path/to/dotfiles/starship/starship.toml`

### Testing the configuration
You can test the Starship configuration without modifying your shell:
```bash
starship prompt
```

## References

- [Starship Official Website](https://starship.rs/)
- [Starship Configuration Documentation](https://starship.rs/config/)
- [Catppuccin for Starship](https://github.com/catppuccin/starship)
