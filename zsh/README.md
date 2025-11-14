# Zsh Configuration

This directory contains zsh shell configuration with menu selection (scrollable completion lists), Catppuccin Frappe colors, and enhanced features.

## What's Included

### `zsh_completion.zsh`

Enhanced zsh completion configuration with **menu selection** - the key feature that provides scrollable completion lists!

**Features:**
- **Menu selection**: Scrollable list of completions with arrow keys
- **Context-aware completions**: Git, pacman, ssh, and more
- **Colored completions**: Uses Catppuccin Frappe colors
- **Case-insensitive**: Smart matching
- **Completion cache**: Faster repeated completions

**Key Feature - Menu Selection:**
```zsh
# Press Tab to see completions, then use arrow keys to scroll!
git <TAB>
> add          # ← cursor, use ↑↓ to scroll
  branch
  checkout
  commit
  ...
```

### `fzf_integration.zsh`

fzf (fuzzy finder) integration for zsh:
- **Ctrl+R**: Fuzzy search command history
- **Ctrl+T**: Fuzzy search files and insert into command line
- **Alt+C**: Fuzzy change directory
- **Custom functions**: fzf-cd, fzf-file, fzf-git, etc.
- **Catppuccin Frappe colors**: All fzf menus styled

### `zsh_colors.zsh`

Catppuccin Frappe color scheme for zsh:
- **LS_COLORS**: Beautiful colorized file listings
- **Completion colors**: Colored completion matches
- **Color variables**: All Catppuccin Frappe colors exported

## Installation

The `install.sh` script automatically:
1. Detects if zsh is installed
2. Creates `~/.zshrc` with all configurations
3. Creates `~/.zprofile` for login shells
4. Sets up menu selection and completions
5. Integrates with Starship, fzf, and Catppuccin colors

**Manual Installation:**
```bash
# Copy zsh configs
mkdir -p ~/.config/zsh
cp zsh/*.zsh ~/.config/zsh/

# Create .zshrc
cat > ~/.zshrc <<'EOF'
# Starship prompt
eval "$(starship init zsh)"

# Load Catppuccin Frappe colors
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load aliases (compatible with bash aliases)
if [ -f ~/.zsh_aliases ] || [ -f ~/.bash_aliases ]; then
    [ -f ~/.zsh_aliases ] && . ~/.zsh_aliases
    [ -f ~/.bash_aliases ] && . ~/.bash_aliases
fi

# Load zsh completion (menu selection!)
if [ -f ~/.config/zsh/zsh_completion.zsh ]; then
    . ~/.config/zsh/zsh_completion.zsh
fi

# Load fzf integration
if [ -f ~/.config/zsh/fzf_integration.zsh ]; then
    . ~/.config/zsh/fzf_integration.zsh
fi
EOF
```

## Usage

### Menu Selection (Scrollable Completions)

This is the main feature that makes zsh better than bash for completions:

```zsh
# Press Tab to see completions
git <TAB>

# Use arrow keys to scroll through the list
# ↑ ↓ to navigate
# Enter to select
# Escape to cancel
```

### fzf Features

```zsh
Ctrl+R              # Fuzzy search history
Ctrl+T              # Fuzzy search files
Alt+C               # Fuzzy change directory
**<TAB>             # Fuzzy file completion
```

### Custom Functions

```zsh
fzf-cd              # Fuzzy cd into directory
fzf-file            # Fuzzy find and edit file
fzf-git             # Fuzzy find in git files
fzf-kill            # Fuzzy kill process
fzf-git-branch      # Fuzzy checkout git branch
fzf-git-log         # Fuzzy search git commits
```

## Key Differences from Bash

| Feature | Bash | Zsh |
|---------|------|-----|
| **Show completion list** | ✅ Yes | ✅ Yes |
| **Scroll with arrow keys** | ❌ No | ✅ Yes |
| **Menu selection** | ❌ No | ✅ Yes |
| **Cycle with Tab** | ✅ Yes | ✅ Yes |

## Requirements

- **zsh**: Install with `sudo pacman -S zsh`
- **fzf** (optional): For fuzzy search features
- **Starship** (optional): For prompt (already configured)

## Compatibility

- **Aliases**: Bash aliases work in zsh (`.bash_aliases` can be sourced)
- **Functions**: Most bash functions work in zsh
- **Scripts**: Bash scripts still work (use `#!/bin/bash` shebang)
- **Starship**: Works with both shells
- **fzf**: Works with both shells

## Migration from Bash

If you're migrating from bash:
1. Your aliases will work (they're compatible)
2. Your functions will mostly work
3. Your environment variables will work
4. Only completion behavior changes (for the better!)

See `ZSH_MIGRATION_PLAN.md` in the root directory for full migration details.

## Notes

- **Menu selection** is the killer feature - scrollable completion lists!
- **Colors** use your terminal's Catppuccin Frappe theme
- **Completion** is faster and more intelligent than bash-completion
- **Backward compatible** with bash aliases and functions

