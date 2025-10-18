-- Configure lualine to use Catppuccin Frappe theme with custom colors
return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local frappe = require("catppuccin.palettes").get_palette("frappe")

    -- Get the catppuccin theme
    local catppuccin_theme = require("lualine.themes.catppuccin")

    -- Only override section c (main status line) backgrounds to use frappe.base
    -- Leave sections a and b alone as they use contrasting accent colors
    for mode, sections in pairs(catppuccin_theme) do
      if sections.c and sections.c.bg then
        sections.c.bg = frappe.base
      end
    end

    return {
      options = {
        theme = catppuccin_theme,
      },
    }
  end,
}
