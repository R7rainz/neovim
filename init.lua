-- Validate the runtime before loading the configuration.
if vim.fn.has("nvim-0.12") ~= 1 then
    error("This config requires Neovim 0.12 or newer")
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Restore and persist only the themes this config intentionally supports.
local theme_file = vim.fn.stdpath("state") .. "/theme"
local read_ok, saved_theme_lines = pcall(vim.fn.readfile, theme_file)
local saved_theme = read_ok and saved_theme_lines[1] or nil
local supported_themes = { omarchy = true, vague = true, ["rose-pine"] = true }
if not supported_themes[saved_theme] then
    saved_theme = nil
end
vim.g.nvim2_theme = vim.g.nvim2_theme or saved_theme or "omarchy"

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Persist the selected nvim2 theme",
    callback = function()
        local theme = vim.g.colors_name
        if supported_themes[theme] then
            pcall(vim.fn.mkdir, vim.fn.stdpath("state"), "p")
            pcall(vim.fn.writefile, { theme }, theme_file)
        end
    end,
})

-- Load in dependency order: options, plugins, LSP, mappings, dashboard.
require("config.options")
require("config.plugins")
require("config.lsp")
require("config.keymaps").setup()
require("config.ui")
