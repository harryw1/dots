-- Image.nvim - Display images in the terminal
-- Works with Kitty terminal (uses Kitty graphics protocol)
-- Displays images inline in markdown, allowing for visual note-taking

return {
  -- luarocks.nvim - Provides local luarocks installation for plugins that need it
  -- Required by image.nvim for native Lua dependencies
  -- Must load early to set up local luarocks before image.nvim tries to use it
  {
    "vhyrro/luarocks.nvim",
    priority = 1001, -- Load before image.nvim
    lazy = false, -- Load immediately, not lazily
    opts = {
      rocks = { "magick" }, -- Install magick rock required by image.nvim
    },
  },
  {
    "3rd/image.nvim",
    dependencies = {
      "vhyrro/luarocks.nvim",
    },
    -- Ensure luarocks.nvim is fully initialized before image.nvim loads
    lazy = true,
    event = "VeryLazy",
    opts = {
      backend = "kitty", -- Use Kitty terminal graphics protocol
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = true, -- Better performance
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
          enabled = false,
        },
        html = {
          enabled = false,
        },
        css = {
          enabled = false,
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50, -- Limit image height to 50% of window
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = true,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
    },
  },
}
