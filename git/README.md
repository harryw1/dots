# Git Configuration

Git global configuration for consistent development environment.

## Files

- `.gitconfig` - Global git configuration
- `.gitignore_global` - Global gitignore patterns

## Installation

The install script automatically symlinks these files:
- `.gitconfig` → `~/.gitconfig`
- `.gitignore_global` → `~/.gitignore_global`

## Customization

### User Information

Update your name and email in `.gitconfig`:

```gitconfig
[user]
	email = your.email@example.com
	name = Your Name
```

### Credentials

The configuration uses `gh` (GitHub CLI) for credential management. Ensure you have:

1. GitHub CLI installed: `pacman -S github-cli`
2. Authenticated: `gh auth login`

## Features

### Aliases

- `git st` - Status
- `git co` - Checkout
- `git br` - Branch
- `git ci` - Commit
- `git unstage` - Unstage files
- `git last` - Show last commit
- `git visual` - Visual branch graph
- `git lg` - Pretty log with graph

### Settings

- **Default branch**: `main`
- **Editor**: Neovim
- **Pull strategy**: Merge (not rebase)
- **Push**: Auto-setup remote tracking
- **Merge tool**: nvimdiff with 3-way diff
- **Rerere**: Enabled (reuse recorded resolution)

## Color Scheme

Git colors use terminal theme colors, which follow the Catppuccin Frappe palette when using the configured terminal (Kitty).
