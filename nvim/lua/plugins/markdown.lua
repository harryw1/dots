-- Markdown and Note-Taking Plugins
-- Provides Obsidian-like functionality in Neovim (TUI mode)
-- Features: wiki links, daily notes, tags, backlinks, beautiful rendering, image support

return {
  -- Obsidian.nvim - Obsidian-compatible note-taking
  -- Provides wiki links [[like this]], daily notes, tags, backlinks, and more
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
        {
          name = "work",
          path = "~/work-notes",
        },
      },

      -- Daily notes configuration
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = nil,
      },

      -- Completion settings
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      -- Wiki link format: [[link]] or [[link|alias]]
      wiki_link_func = function(opts)
        if opts.label ~= opts.path then
          return string.format("[[%s|%s]]", opts.path, opts.label)
        else
          return string.format("[[%s]]", opts.path)
        end
      end,

      -- Markdown link format: [text](url)
      markdown_link_func = function(opts)
        return string.format("[%s](%s)", opts.label, opts.path)
      end,

      -- Template directory
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      -- Follow URL behavior
      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Search tags" },
      { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Open today's daily note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Open yesterday's daily note" },
      { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Show links" },
      { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link under cursor" },
    },
  },

  -- Render Markdown - Beautiful in-editor rendering
  -- Shows headings, lists, code blocks, checkboxes with nice formatting
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown" },
      -- Render mode: 'normal' or 'full'
      render_modes = { "n", "c" },
      -- Code block configuration
      code = {
        enabled = true,
        sign = true,
        style = "full",
        position = "left",
        width = "block",
        left_pad = 0,
        right_pad = 0,
        min_width = 0,
      },
      -- Heading configuration
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      -- List configuration
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      -- Only render image at cursor (better performance)
      only_render_image_at_cursor = true,
    },
    ft = { "markdown" },
  },

  -- Marksman LSP for markdown
  -- Provides auto-completion, goto definition, find references for wiki links
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.marksman = {
        -- Marksman configuration
        filetypes = { "markdown" },
      }
      return opts
    end,
  },

  -- Image pasting from clipboard
  -- Paste images directly into markdown with <leader>p
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "assets/images",
        file_name = "%Y-%m-%d-%H-%M-%S",
        url_encode_path = false,
        use_absolute_path = false,
        relative_to_current_file = true,
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = "![$CURSOR]($FILE_PATH)",
          download_images = true,
        },
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
  },

  -- Markdown Preview (requires browser - optional for headless)
  -- Opens markdown preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>mp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  -- Better list handling
  {
    "dkarter/bullets.vim",
    ft = { "markdown", "text" },
  },

  -- Table mode for easier table editing
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "text" },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
  },
}
