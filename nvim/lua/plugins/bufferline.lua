-- Configure bufferline to use Catppuccin Frappe theme
return {
  "akinsho/bufferline.nvim",
  opts = function()
    local frappe = require("catppuccin.palettes").get_palette("frappe")
    return {
      highlights = require("catppuccin.special.bufferline").get_theme({
        custom = {
          all = {
            fill = { bg = frappe.base },
          },
        },
      }),
    }
  end,
}
