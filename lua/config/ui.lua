local keymaps = require("config.keymaps")
local starter = require("mini.starter")

-- Japanese dashboard header; each line is centered by display width.
local header_lines = {
    "静 け さ の 中 に",
    "強 さ が あ る",
    "",
    "富士の麓で、静かに作る",
    "不 動 心  ·  余 白",
}
local header_width = 0
for _, line in ipairs(header_lines) do
    header_width = math.max(header_width, vim.fn.strdisplaywidth(line))
end
local header = table.concat(vim.tbl_map(function(line)
    if line == "" then
        return line
    end
    local left_pad = math.floor((header_width - vim.fn.strdisplaywidth(line)) / 2)
    return string.rep(" ", left_pad) .. line
end, header_lines), "\n")

-- Dashboard content and actions.
starter.setup({
    evaluate_single = true,
    header = header,
    footer = function()
        local version = vim.version()
        return string.format("静けさの中に、強さがある  ·  Neovim %d.%d.%d", version.major, version.minor, version.patch)
    end,
    items = {
        { name = "Files", action = keymaps.find_files, section = "開く" },
        { name = "Projects", action = keymaps.project_dirs, section = "開く" },
        { name = "Grep", action = keymaps.live_grep, section = "開く" },
        { name = "New buffer", action = "enew | startinsert", section = "開く" },
        { name = "Config", action = keymaps.open_config, section = "整える" },
        { name = "Session", action = keymaps.restore_project_session, section = "整える" },
        { name = "Update plugins", action = vim.pack.update, section = "整える" },
        { name = "Help", action = "help nvim2", section = "整える" },
        { name = "Quit", action = "qall", section = "整える" },
        starter.sections.recent_files(5, true, false),
    },
    content_hooks = {
        starter.gen_hook.adding_bullet("  ▸ "),
        starter.gen_hook.indexing("section", { "Recent files" }),
        starter.gen_hook.aligning("center", "center"),
    },
})

-- Single-key dashboard shortcuts.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "ministarter",
    callback = function(event)
        local opts = { buffer = event.buf, nowait = true, silent = true }
        vim.keymap.set("n", "f", keymaps.find_files, opts)
        vim.keymap.set("n", "p", keymaps.project_dirs, opts)
        vim.keymap.set("n", "r", keymaps.recent_files, opts)
        vim.keymap.set("n", "g", keymaps.live_grep, opts)
        vim.keymap.set("n", "c", keymaps.open_config, opts)
        vim.keymap.set("n", "s", keymaps.restore_project_session, opts)
        vim.keymap.set("n", "n", "<cmd>enew | startinsert<cr>", opts)
        vim.keymap.set("n", "u", vim.pack.update, opts)
        vim.keymap.set("n", "h", "<cmd>help nvim2<cr>", opts)
        vim.keymap.set("n", "q", "<cmd>qall<cr>", opts)
    end,
})
