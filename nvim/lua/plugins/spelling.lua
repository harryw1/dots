-- Spelling and Grammar Checking
-- Provides spell checking for markdown, text files, and comments
-- Uses built-in Neovim spell checking with aspell/hunspell dictionaries

return {
  -- Configure built-in spell checking
  {
    "LazyVim/LazyVim",
    opts = {
      -- Enable spell checking for specific file types
      defaults = {
        autocmds = true,
      },
    },
  },

  -- Set up spell checking for markdown and text files
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Enable spell checking in markdown, text, and gitcommit
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = "en_us"
        end,
      })

      -- Keymaps for spell checking
      vim.keymap.set("n", "<leader>ss", ":setlocal spell!<CR>", { desc = "Toggle spell check", silent = true })
      vim.keymap.set("n", "<leader>sn", "]s", { desc = "Next spelling error", silent = true })
      vim.keymap.set("n", "<leader>sp", "[s", { desc = "Previous spelling error", silent = true })
      vim.keymap.set("n", "<leader>sa", "zg", { desc = "Add word to dictionary", silent = true })
      vim.keymap.set("n", "<leader>s?", "z=", { desc = "Spelling suggestions", silent = true })

      return opts
    end,
  },

  -- Optional: LTeX Language Server for advanced grammar/spell checking
  -- Requires Java runtime, provides grammar checking beyond spell check
  -- Uncomment if you want advanced grammar checking
  --[[
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.ltex = {
        settings = {
          ltex = {
            language = "en-US",
            diagnosticSeverity = "information",
            additionalRules = {
              enablePickyRules = true,
              motherTongue = "en-US",
            },
            disabledRules = {
              ["en-US"] = { "PROFANITY" },
            },
            dictionary = {},
          },
        },
        filetypes = { "markdown", "text", "gitcommit" },
      }
      return opts
    end,
  },
  ]]--
}
