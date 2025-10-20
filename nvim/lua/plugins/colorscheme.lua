-- Comprehensive Catppuccin Frappe Configuration with Plugin Integrations
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
      transparent_background = "true",
      float = {
        transparent = true,
      },
      -- Enable integrations for all installed plugins
      integrations = {
        -- Core LazyVim plugins
        flash = true,
        gitsigns = true,
        mason = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        noice = true,
        snacks = {
          enabled = true,
          indent_scope_color = "",
        },
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        -- Additional plugins
        grug_far = true,
        lsp_trouble = true, -- for trouble.nvim
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
