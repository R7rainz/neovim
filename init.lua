if vim.fn.has("nvim-0.12") ~= 1 then
    error("This config requires Neovim 0.12 or newer")
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.nvim2_theme = vim.g.nvim2_theme or "omarchy"

require("config.options")
require("config.plugins")
require("config.lsp")
require("config.keymaps").setup()
require("config.ui")
