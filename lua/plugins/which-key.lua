return {
  {
    "folke/which-key.nvim",
    lazy = false,  -- Ensure it loads immediately
    config = function()
      require("which-key").setup({})
    end,
  },
}

