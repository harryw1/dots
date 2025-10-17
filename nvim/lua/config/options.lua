-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Font settings (for GUI Neovim like Neovide)
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h11"

-- Better defaults
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.wrap = false -- Disable line wrap

-- Set leader key (LazyVim default is space, but good to be explicit)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
