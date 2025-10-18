-- Comprehensive Catppuccin Frappe Configuration with Plugin Integrations
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
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
      -- Fix: Make floating windows use the same background as normal windows
      custom_highlights = function(colors)
        return {
          NormalFloat = { bg = colors.base },
          FloatBorder = { bg = colors.base, fg = colors.surface0 },
          FloatTitle = { bg = colors.base, fg = colors.text },
          -- Fix Snacks explorer colors
          SnacksPickerBorder = { bg = colors.base, fg = colors.surface0 },
          SnacksPickerInput = { bg = colors.base, fg = colors.text },
          SnacksPickerPrompt = { fg = colors.text },
          SnacksWinBar = { bg = colors.base, fg = colors.text },
          SnacksWinBarNC = { bg = colors.base, fg = colors.text },
          -- Fix cursor colors
          Cursor = { bg = colors.text, fg = colors.base },
          TermCursor = { bg = colors.text, fg = colors.base },
          TermCursorNC = { bg = colors.overlay0, fg = colors.base },
          -- Fix directory colors
          Directory = { fg = colors.blue },
          -- Fix which-key colors
          WhichKey = { fg = colors.blue },
          WhichKeyGroup = { fg = colors.mauve },
          WhichKeyDesc = { fg = colors.text },
          WhichKeyFloat = { bg = colors.base },
          WhichKeyBorder = { bg = colors.base, fg = colors.surface0 },
          -- Fix status line colors (lualine)
          StatusLine = { bg = colors.base },
          StatusLineNC = { bg = colors.base },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
