# Yazi Configuration

Yazi is a blazing fast terminal file manager written in Rust with async I/O, featuring image previews, vim-like keybindings, and extensive customization.

## Installation

Yazi is in the official repositories. Add to `packages/productivity.txt`:

```bash
sudo pacman -S yazi ffmpegthumbnailer unarchiver jq poppler fd ripgrep fzf zoxide imagemagick
```

**Required dependencies**:
- `ffmpegthumbnailer` - Video thumbnails
- `unarchiver` (or `p7zip`) - Archive preview/extraction
- `jq` - JSON preview
- `poppler` - PDF preview
- `fd` - File search
- `ripgrep` - Content search
- `fzf` - Fuzzy finding
- `zoxide` - Smart directory jumping
- `imagemagick` - Image operations (you already use this)

The install script automatically symlinks this directory:
- `yazi/` → `~/.config/yazi/`

## Usage

### Launch Yazi

```bash
yazi
```

Or with a specific directory:

```bash
yazi ~/Documents
```

### Essential Keybindings

**Navigation** (Vim-style):
- `h` - Go to parent directory
- `j` - Move down
- `k` - Move up
- `l` - Enter directory / open file
- `g`+`g` - Go to top
- `G` - Go to bottom

**Quick Jumps** (Custom):
- `g`+`h` - Home directory
- `g`+`c` - `~/.config`
- `g`+`d` - Downloads
- `g`+`D` - Documents
- `g`+`.` - `~/dots`

**File Operations**:
- `y`+`y` - Yank (copy) file
- `d`+`d` - Delete file
- `p` - Paste
- `c`+`c` - Create file/directory
- `r` - Rename
- `Space` - Toggle selection
- `v` / `V` - Enter/exit visual mode

**Search**:
- `/` - Find file by name
- `n` / `N` - Next/previous match
- `Ctrl-s` - Search file contents (ripgrep)

**Sorting**:
- `s`+`m` - Sort by modified time
- `s`+`n` - Sort by name
- `s`+`s` - Sort by size

**Other**:
- `.` or `z`+`h` - Toggle hidden files
- `R` - Refresh directory
- `q` - Quit
- `?` - Show help
- `~` - Open shell in current directory

## Features

### Image Preview

Yazi can preview images directly in the terminal using Kitty's image protocol (which you use):

- Works automatically with PNG, JPG, GIF, WebP
- Video thumbnails via `ffmpegthumbnailer`
- PDF previews via `poppler`

### Archive Support

Preview and extract archives:

- ZIP, TAR, GZ, BZ2, XZ, 7Z, RAR
- Press `l` on archive to see contents
- Configured to use `ouch` for extraction (install with `pacman -S ouch`)

### File Opening

Configured to open files with appropriate applications:

- **Text files**: Opens in Neovim
- **Images**: Displays with Kitty icat
- **PDFs**: Opens in Zathura
- **Archives**: Extracts with ouch

### Integration with Modern Tools

- **fd**: Fast file finding
- **ripgrep**: Content search
- **fzf**: Fuzzy file selection
- **zoxide**: Smart directory jumping

## Theme

Uses **Catppuccin Frappe** color scheme:
- Blue accents for active elements
- Mauve for selections and highlights
- Proper color coding for file types
- Nerd Font icons for files and folders

## Shell Integration

### Change directory on quit

Add to `~/.bashrc`:

```bash
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

Now when you exit yazi with `q`, your shell changes to the directory you were in.

### Alias

```bash
alias fm='yazi'
```

## Hyprland Integration

Add keybind to launch yazi:

```conf
bind = $mainMod, E, exec, kitty -e yazi
```

## Advanced Usage

### Bulk Rename

1. Select files with `Space` or `v` (visual mode)
2. Press `r` for bulk rename
3. Edit filenames in your editor (Neovim)
4. Save and quit to apply changes

### Tabs

- `Ctrl-t` - New tab
- `Ctrl-w` - Close tab
- `1`-`9` - Switch to tab

### Bookmarks

- `m` - Create bookmark
- `'` - Jump to bookmark

### Shell Integration

- `!` - Run shell command
- `~` - Open shell in current directory

## Plugin System

Yazi supports plugins written in Lua. Popular plugins:

- **full-border.yazi** - Better borders
- **git.yazi** - Git integration
- **starship.yazi** - Starship prompt integration

Install plugins to `~/.config/yazi/plugins/`.

## Comparison to Alternatives

**vs. ranger (Python)**:
- ✅ Much faster (Rust vs Python)
- ✅ Async I/O
- ✅ Better image preview
- ✅ Modern codebase
- ✅ Better performance

**vs. lf (Go)**:
- ✅ More features out of box
- ✅ Better theming
- ✅ Image preview built-in
- ✅ More active development

**vs. nnn (C)**:
- ✅ More user-friendly
- ✅ Better default config
- ✅ Visual theme
- ⚠️ Slightly heavier (but still very fast)

**vs. GUI file managers (Thunar, Nautilus)**:
- ✅ Keyboard-driven
- ✅ Much faster
- ✅ Works over SSH
- ✅ Integrates with terminal workflow
- ✅ Scriptable

## Tips

1. **Use preview**: The preview pane (rightmost) shows file contents automatically
2. **Search with fzf**: Use fuzzy finding for large directories
3. **Batch operations**: Select multiple files with visual mode
4. **Custom openers**: Edit `yazi.toml` to configure file type handlers
5. **Shell integration**: Use the `y` function to cd on exit

## Troubleshooting

### Images not previewing

1. Ensure you're using Kitty terminal
2. Check `$TERM`: should be `xterm-kitty`
3. Verify Kitty image protocol is working:
   ```bash
   kitty +kitten icat /path/to/image.png
   ```

### Icons not showing

1. Install a Nerd Font (JetBrainsMono already installed)
2. Set `nerdfonts = "v3"` in `yazi.toml`

### Slow directory loading

1. Disable preview for large directories
2. Adjust `max_width` and `max_height` in preview settings
3. Use `show_hidden = false` for directories with many dotfiles

## Related

- **fd** - Fast file search (used by yazi)
- **ripgrep** - Content search (used by yazi)
- **fzf** - Fuzzy finder (yazi integration)
- **zoxide** - Smart cd (yazi integration)
- **ouch** - Archive extraction tool
- **bat** - Syntax highlighting for file preview
