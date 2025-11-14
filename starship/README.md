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
- Installs the official Starship Catppuccin Powerline preset using:
  ```bash
  starship preset catppuccin-powerline -o ~/.config/starship.toml
  ```
- Configures it to use the Frappe variant (matching the theme)
- Adds Starship initialization to your shell configuration (bash/zsh)

**Note:** The preset is installed directly from Starship's official presets, not from the `starship.toml` file in this repository. The repository file serves as a reference/fallback.

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

### Manual Installation

If you want to manually install or reinstall the preset:

```bash
# Install the Catppuccin Powerline preset
starship preset catppuccin-powerline -o ~/.config/starship.toml

# Then change the palette to Frappe (line 32)
# Edit ~/.config/starship.toml and change:
# palette = 'catppuccin_mocha'
# to:
# palette = 'catppuccin_frappe'
```

Or use sed to make the change automatically:
```bash
sed -i "s/palette = 'catppuccin_mocha'/palette = 'catppuccin_frappe'/" ~/.config/starship.toml
```

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
