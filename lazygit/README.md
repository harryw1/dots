# Lazygit Configuration

Lazygit is a simple terminal UI for git commands, providing a fast and intuitive interface for git operations.

## Installation

Lazygit is in the official repositories (already in `packages/development.txt`):

```bash
sudo pacman -S lazygit
```

The install script automatically symlinks this directory:
- `lazygit/` → `~/.config/lazygit/`

## Usage

### Launch Lazygit

```bash
lazygit
```

Or from within a git repository:

```bash
lg  # If you have the git alias configured
```

### Key Features

**Status View**:
- See unstaged, staged, and untracked files
- Quick staging/unstaging with `space`
- View diffs in the main panel

**Commits View**:
- Browse commit history
- Interactive rebase with drag-and-drop
- Cherry-pick, revert, amend commits
- Squash and fixup commits

**Branches View**:
- Switch branches with `enter`
- Create, rename, delete branches
- Merge, rebase, fast-forward
- Push/pull with `P`/`p`

**Stash View**:
- Create, pop, apply, drop stashes
- View stash contents

### Essential Keybindings

**Navigation** (Vim-style):
- `j`/`k` - Move down/up
- `h`/`l` - Previous/next panel
- `[`/`]` - Previous/next tab
- `1-5` - Jump to panel
- `tab` - Toggle between panels

**File Operations**:
- `space` - Stage/unstage file or hunk
- `a` - Stage/unstage all files
- `c` - Commit
- `C` - Commit with editor
- `A` - Amend last commit
- `d` - Discard changes (with confirmation)
- `e` - Edit file in nvim
- `o` - Open file in default app
- `i` - Ignore file

**Commit Operations**:
- `s` - Squash commit down
- `r` - Reword commit
- `f` - Fixup commit
- `p` - Pick commit (for cherry-pick)
- `v` - Paste commits
- `Ctrl-j`/`Ctrl-k` - Move commit down/up (reorder)

**Branch Operations**:
- `space` - Checkout branch
- `n` - New branch
- `M` - Merge into current branch
- `r` - Rebase branch
- `P` - Push
- `p` - Pull
- `f` - Fast-forward
- `u` - Set upstream

**General**:
- `?` - Open keybindings menu
- `x` - Open command menu
- `:` - Execute custom command
- `q` - Quit
- `R` - Refresh

## Theme

Configuration uses **Catppuccin Frappe** color scheme:
- Borders: Mauve (active), Overlay0 (inactive)
- Selected line: Surface0
- Git colors: Red (unstaged), Blue (info), Yellow (search)

Git diffs use `delta` with Catppuccin Frappe syntax highlighting (if delta is installed).

## Integration

### Git Alias

Add to `~/.gitconfig`:

```gitconfig
[alias]
    lg = !lazygit
```

### Hyprland Keybind

Launch lazygit in a terminal:

```conf
bind = $mainMod, G, exec, kitty -e lazygit
```

### Shell Alias

Add to `~/.bashrc`:

```bash
alias lg='lazygit'
```

## Advanced Features

### Custom Commands

Add custom commands to `config.yml` under `customCommands`:

```yaml
customCommands:
  - key: 'b'
    command: 'git bug {{index .SelectedCommit.Sha}}'
    context: 'commits'
    description: 'Mark commit as bug'
```

### Delta Integration

For better diff viewing, install `delta`:

```bash
sudo pacman -S git-delta
```

Already configured in `config.yml` to use Catppuccin Frappe theme.

## Comparison to Alternatives

**vs. raw git CLI**:
- ✅ Visual interface
- ✅ Faster for common operations
- ✅ Less error-prone
- ✅ Better for interactive rebase

**vs. GUI git clients (GitKraken, GitHub Desktop)**:
- ✅ Much faster to launch
- ✅ Keyboard-driven
- ✅ Lightweight (terminal-based)
- ✅ Works over SSH
- ⚠️ Less visual (but more efficient)

**vs. vim-fugitive**:
- ✅ Standalone (doesn't require Vim open)
- ✅ Easier for beginners
- ✅ More visual feedback
- ⚠️ Less integrated with editor

## Tips

1. **Learn the command menu**: Press `x` to see context-specific actions
2. **Use filtering**: Press `Ctrl-s` to filter commits/files
3. **Custom patches**: Press `Ctrl-p` for patch mode
4. **Diff view**: Press `W` to toggle diff viewing modes
5. **Undo/Redo**: Press `z` to undo, `Ctrl-z` to redo

## Troubleshooting

### Config not loading

Ensure config is at: `~/.config/lazygit/config.yml`

### Theme colors not showing

1. Ensure terminal supports true color
2. Check `$TERM` variable: `echo $TERM`
3. Should be `xterm-256color` or `xterm-kitty`

### Delta not working

Install delta: `sudo pacman -S git-delta`

## Related

- **git** - Version control system
- **delta** - Syntax highlighter for git diffs
- **nvim** - Editor integration for commit messages
- **gh** - GitHub CLI for PR/issue management
