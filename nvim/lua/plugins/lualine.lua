-- Configure lualine to use Catppuccin Frappe theme with custom colors
return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local frappe = require("catppuccin.palettes").get_palette("frappe")

    -- Get the catppuccin theme
    local catppuccin_theme = require("lualine.themes.catppuccin")

    -- Override all backgrounds to use frappe.base instead of mantle
    for _, section in pairs(catppuccin_theme) do
      for _, component in pairs(section) do
        if component.bg then
          component.bg = frappe.base
        end
      end
    end

    return {
      options = {
        theme = catppuccin_theme,
      },
    }
  end,
}
