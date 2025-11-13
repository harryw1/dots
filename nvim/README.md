# Neovim with LazyVim Configuration

This directory contains documentation for setting up Neovim with LazyVim, a modern Neovim distribution.

## What is LazyVim?

LazyVim is a Neovim setup powered by lazy.nvim to make it easy to customize and extend your config. It comes with:
- Sane default settings
- Pre-configured plugins (LSP, Treesitter, Telescope, etc.)
- Beautiful UI with Catppuccin theme support
- Easy to extend and customize

## Prerequisites

All required packages are included in the dotfiles installation. The key dependencies are:

**From development.txt:**
- `neovim` - The editor itself
- `git` - Version control
- `ripgrep` - Fast grep tool (for Telescope)
- `fd` - Fast find alternative
- `lazygit` - Terminal UI for git
- `lua` - Lua interpreter
- `luarocks` - Lua package manager (required for plugins with native dependencies like markdown-preview.nvim)

**Fonts:**
- JetBrains Mono Nerd Font (for icons and ligatures)

## Installation

### Method 1: Fresh LazyVim Install (Recommended)

This is the cleanest approach for new users:

```bash
# Backup existing Neovim config (if any)
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# Clone LazyVim starter template
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove the starter's .git directory (make it yours)
rm -rf ~/.config/nvim/.git

# Start Neovim (LazyVim will automatically install plugins)
nvim
```

### Method 2: Using this Dotfiles Repo

If you want LazyVim managed within this dotfiles repo:

```bash
# Clone the starter to nvim/ directory in this repo
git clone https://github.com/LazyVim/starter ./nvim/lazyvim-starter

# Then symlink it
ln -sf $(pwd)/nvim/lazyvim-starter ~/.config/nvim
```

## First Launch

On first launch, LazyVim will:
1. Install lazy.nvim plugin manager
2. Download and install all configured plugins
3. Set up LSP servers, linters, and formatters

This takes a few minutes. Be patient!

## Configuration Structure

LazyVim follows this structure:

```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   ├── autocmds.lua      # Auto commands
│   │   ├── keymaps.lua       # Key mappings
│   │   ├── lazy.lua          # Lazy.nvim bootstrap
│   │   └── options.lua       # Vim options
│   └── plugins/
│       ├── example.lua       # Your custom plugins
│       └── ...
└── init.lua                  # Entry point
```

## Customization

### Change Colorscheme to Catppuccin Frappe

Create `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
```

### Set JetBrains Mono Font

Edit `~/.config/nvim/lua/config/options.lua`:

```lua
-- Font settings (for GUI Neovim)
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h11"
```

### Enable Python LSP

LazyVim includes Python support. Enable the extra:

```bash
# In Neovim, run:
:LazyExtras
```

Then enable:
- `lang.python` - Python language support
- `editor.telescope` - Telescope file finder (if preferred over fzf)

### Install Language Servers

LazyVim uses Mason to manage LSP servers. In Neovim:

```vim
:Mason
```

Recommended LSP servers to install:
- **Python**: `pyright` or `basedpyright`
- **C/C++**: `clangd`
- **Bash**: `bash-language-server`
- **Lua**: `lua-language-server` (pre-installed)
- **JSON**: `json-lsp`
- **YAML**: `yaml-language-server`

## Key Bindings

LazyVim uses `<space>` as the leader key. Essential keybindings:

### General
- `<leader>l` - Lazy (plugin manager UI)
- `<leader>gg` - LazyGit
- `<leader>qq` - Quit

### File Navigation
- `<leader><space>` - Find files
- `<leader>ff` - Find files
- `<leader>fr` - Recent files
- `<leader>fg` - Grep files
- `<leader>fb` - Browse buffers

### Code
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol

### Window Management
- `<C-h/j/k/l>` - Navigate between windows
- `<leader>w` - Window commands

### Terminal
- `<C-/>` - Toggle terminal
- `<Esc><Esc>` - Exit terminal mode

## Troubleshooting

### Build/Installation Errors

If you encounter build errors when LazyVim installs plugins, check the following:

**Missing LuaRocks:**
Some plugins (like `markdown-preview.nvim`) require LuaRocks to install native Lua dependencies:
```bash
# Check if luarocks is installed
which luarocks

# If missing, install it (should be in development.txt)
sudo pacman -S luarocks lua
```

**Missing Build Tools:**
Ensure all build dependencies are installed:
```bash
# Check if base-devel is installed (includes make, gcc, etc.)
pacman -Q base-devel

# If missing, install it
sudo pacman -S base-devel
```

**Node.js for markdown-preview.nvim:**
The markdown preview plugin requires Node.js:
```bash
# Check Node.js version
node --version

# Should be Node.js 14+ (included in development.txt)
```

### Plugins Not Loading
```bash
# Clear cache and reinstall
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
nvim
```

### LSP Not Working
```vim
:checkhealth
:Mason
```

### Font Icons Not Showing
Ensure JetBrains Mono Nerd Font is installed:
```bash
fc-list | grep -i jetbrains
```

## Resources

- [LazyVim Documentation](https://www.lazyvim.org/)
- [LazyVim GitHub](https://github.com/LazyVim/LazyVim)
- [Neovim Documentation](https://neovim.io/doc/)
- [Catppuccin for Neovim](https://github.com/catppuccin/nvim)

## Tips

1. **Learn the Leader Key**: Almost everything in LazyVim starts with `<space>`
2. **Use Which-Key**: LazyVim shows available keybindings when you pause after `<space>`
3. **Explore Extras**: Run `:LazyExtras` to see additional language and feature packs
4. **Keep Updated**: Run `:Lazy update` regularly to update plugins
5. **Backup Configs**: Your LazyVim config is in `~/.config/nvim` - back it up!
