assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
assert(vim.o.tabstop == 4 and vim.o.shiftwidth == 4, "four-space indentation is not active")
assert(vim.o.wrap, "long-line soft wrapping is not active")
assert(
    vim.tbl_contains(
        { "base46-gruvchad", "cursor-dark", "edge", "omarchy", "tokyonight-night" },
        vim.g.colors_name
    ),
    "configured colorscheme did not load"
)
assert(vim.fn.exists(":Theme") == 2, ":Theme command is missing")
assert(vim.fn.exists(":ConfigDocs") == 2, ":ConfigDocs command is missing")
assert(vim.fn.exists(":NvimTreeToggle") == 2, "nvim-tree command is missing")
assert(vim.fn.exists(":RenderMarkdown") == 2, "render-markdown command is missing")
local tree_config = require("nvim-tree.config").g
assert(tree_config.view.width == "25%", "nvim-tree width is not 25%")
assert(not tree_config.hijack_directories.auto_open, "nvim-tree auto-open must stay off for sessions")
assert(vim.fn.maparg("<leader>ff", "n") ~= "", "file picker mapping is missing")
assert(vim.fn.maparg("<leader>fw", "n") ~= "", "live grep mapping is missing")
assert(vim.fn.maparg("<leader>mp", "n") ~= "", "markdown preview mapping is missing")
assert(vim.fn.maparg("<leader>E", "n") ~= "", "side explorer mapping is missing")
assert(vim.fn.maparg("<leader>uE", "n") ~= "", "side explorer position mapping is missing")
assert(vim.fn.maparg("<C-S-Left>", "n") ~= "", "side explorer shrink mapping is missing")
assert(vim.fn.maparg("<C-S-Right>", "n") ~= "", "side explorer grow mapping is missing")
assert(vim.fn.maparg("<leader>w[", "n") ~= "", "side explorer shrink fallback is missing")
assert(vim.fn.maparg("<leader>w]", "n") ~= "", "side explorer grow fallback is missing")
assert(vim.fn.maparg("<C-h>", "n") ~= "", "pane navigation mapping is missing")
assert(vim.fn.maparg("<leader>zh", "n") ~= "", "horizontal scrolling mapping is missing")
assert(vim.fn.maparg("<S-ScrollWheelUp>", "n") ~= "", "mouse horizontal scrolling mapping is missing")
assert(#vim.pack.get(nil, { info = false }) == 13, "unexpected plugin count")
local diff_config = require("mini.diff").config
assert(diff_config.view.style == "sign", "mini.diff sign view is not active")
assert(
    diff_config.view.signs.add == "▎" and diff_config.view.signs.delete == "▁",
    "mini.diff signs are not visible"
)
local ts_buf = vim.api.nvim_create_buf(false, true)
vim.bo[ts_buf].filetype = "typescript"
vim.api.nvim_buf_call(ts_buf, function()
    vim.cmd("doautocmd FileType typescript")
end)
assert(vim.bo[ts_buf].shiftwidth == 4, "TypeScript shiftwidth is not four")
assert(
    vim.bo[ts_buf].cindent and vim.bo[ts_buf].indentexpr == "",
    "TypeScript does not use four-space auto-indent"
)
vim.api.nvim_buf_delete(ts_buf, { force = true })

print("nvim2: all checks passed")
vim.cmd.qall()
