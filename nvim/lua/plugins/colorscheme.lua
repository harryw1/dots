-- Minimal Catppuccin Frappe Configuration
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
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
