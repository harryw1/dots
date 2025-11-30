return {
  {
    "lewis6991/spellsitter.nvim",
    event = "BufRead",
    config = function()
      require("spellsitter").setup()
    end,
  },
}

