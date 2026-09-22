-- Parsers installed by nvim-treesitter.
local languages = {
    "bash",
    "c",
    "cpp",
    "css",
    "diff",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "query",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
}

-- presence.nvim otherwise runs setup() from plugin/presence.vim before our
-- options are available (and before headless Neovim has an RPC socket).
vim.g.presence_has_setup = 1

-- Keep Treesitter parsers in sync after plugin updates.
vim.api.nvim_create_autocmd("PackChanged", {
    desc = "Keep Treesitter parsers compatible with plugin updates",
    callback = function(event)
        local data = event.data
        if data.kind == "update" and data.spec.name == "nvim-treesitter" then
            vim.schedule(function()
                require("nvim-treesitter").update()
            end)
        end
    end,
})

local function github(repo)
    return "https://github.com/" .. repo
end

-- Native package declarations. Keep this list intentionally small.
vim.pack.add({
    { src = github("nvim-mini/mini.nvim") },
    { src = github("neovim/nvim-lspconfig") },
    { src = github("nvim-treesitter/nvim-treesitter"), version = "main" },
    { src = github("stevearc/conform.nvim") },
    { src = github("folke/which-key.nvim") },
    { src = github("folke/flash.nvim") },
    { src = github("vague-theme/vague.nvim") },
    { src = github("andweeb/presence.nvim"), version = "main" },
}, { confirm = false, load = true })

local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()

-- Pickers and file navigation.
require("mini.pick").setup({
    options = { use_cache = true },
    window = {
        config = function()
            local height = math.max(1, math.floor(vim.o.lines * 0.62))
            local width = math.max(1, math.floor(vim.o.columns * 0.72))
            return {
                anchor = "NW",
                border = "rounded",
                height = height,
                width = width,
                row = math.floor((vim.o.lines - height) / 2),
                col = math.floor((vim.o.columns - width) / 2),
            }
        end,
        prompt_prefix = "    ",
    },
})
require("mini.extra").setup()
require("mini.files").setup({
    options = { permanent_delete = false, use_as_default_explorer = true },
    mappings = {
        go_in_plus = "<CR>",
        go_out = "h",
        go_out_plus = "H",
    },
    windows = { preview = true, width_focus = 32, width_nofocus = 18, width_preview = 42 },
})
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(event)
        local function at_project_root()
            local state = MiniFiles.get_explorer_state()
            return state == nil or state.depth_focus <= 1
        end

        vim.keymap.set("n", "h", function()
            if not at_project_root() then
                MiniFiles.go_out()
            end
        end, { buffer = event.data.buf_id, desc = "Go to parent directory", nowait = true })

        vim.keymap.set("n", "H", function()
            if not at_project_root() then
                MiniFiles.go_out()
                MiniFiles.trim_right()
            end
        end, { buffer = event.data.buf_id, desc = "Go to parent and trim", nowait = true })
    end,
    desc = "Keep MiniFiles inside project root",
})
require("mini.pairs").setup()
require("mini.diff").setup({ view = { style = "sign" } })
require("mini.indentscope").setup({ draw = { animation = require("mini.indentscope").gen_animation.none() } })
require("config.sessions").setup()

-- Statusline and tabline highlights.
-- Keep the editor chrome in the same visual language as the Omarchy tmux and
-- Starship setup: one clear mode pill, quiet context text, and no noisy empty
-- separators or oversized blocks.
local function setup_ui_highlights()
    local function color(group, field, fallback)
        local ok, value = pcall(function()
            return vim.api.nvim_get_hl(0, { name = group, link = false })[field]
        end)
        return ok and value and string.format("#%06x", value) or fallback
    end

    local palette = {
        base = color("NormalNC", "bg", "#141519"),
        foreground = color("Normal", "fg", "#e7e2db"),
        bright = color("Normal", "fg", "#f7f1e6"),
        muted = color("Comment", "fg", "#73777d"),
        block = color("WinSeparator", "fg", "#282a30"),
        blue = color("Directory", "fg", "#7e91aa"),
        cyan = color("Type", "fg", "#8ea2ad"),
        green = color("String", "fg", "#88998c"),
        magenta = color("Constant", "fg", "#ceb0b4"),
        red = color("DiagnosticError", "fg", "#ec8a73"),
        yellow = color("WarningMsg", "fg", "#e5b681"),
    }

    local set = vim.api.nvim_set_hl
    set(0, "StatusLine", { bg = palette.base, fg = palette.foreground })
    set(0, "StatusLineNC", { bg = palette.base, fg = palette.muted })
    set(0, "Nvim2StatusContext", { bg = palette.base, fg = palette.muted })
    set(0, "Nvim2StatusInfo", { bg = palette.base, fg = palette.blue })
    set(0, "Nvim2StatusFile", { bg = palette.base, fg = palette.bright })
    set(0, "Nvim2StatusLocation", { bg = palette.blue, bold = true, fg = palette.base })

    local modes = {
        Normal = palette.yellow,
        Insert = palette.green,
        Visual = palette.magenta,
        Replace = palette.red,
        Command = palette.blue,
        Other = palette.cyan,
    }
    for name, background in pairs(modes) do
        set(0, "Nvim2StatusMode" .. name, { bg = background, bold = true, fg = palette.base })
    end

    -- mini.tabline supplies the buffer-state groups; only their colors are
    -- changed here, so buffer switching and click actions stay native.
    set(0, "MiniTablineCurrent", { bg = palette.yellow, bold = true, fg = palette.base })
    set(0, "MiniTablineVisible", { bg = palette.block, fg = palette.bright })
    set(0, "MiniTablineHidden", { bg = palette.base, fg = palette.muted })
    set(0, "MiniTablineModifiedCurrent", { bg = palette.green, bold = true, fg = palette.base })
    set(0, "MiniTablineModifiedVisible", { bg = palette.base, bold = true, fg = palette.green })
    set(0, "MiniTablineModifiedHidden", { bg = palette.base, fg = palette.yellow })
    set(0, "MiniTablineFill", { bg = palette.base, fg = palette.muted })
    set(0, "MiniTablineTabpagesection", { bg = palette.blue, bold = true, fg = palette.base })
    set(0, "MiniTablineTrunc", { bg = palette.base, bold = true, fg = palette.yellow })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Keep statusline and tabline aligned with the active theme",
    callback = setup_ui_highlights,
})

-- Statusline and buffer tabline content.
local statusline = require("mini.statusline")
statusline.setup({
    use_icons = true,
    content = {
        active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local mode_names = {
                MiniStatuslineModeNormal = "Nvim2StatusModeNormal",
                MiniStatuslineModeInsert = "Nvim2StatusModeInsert",
                MiniStatuslineModeVisual = "Nvim2StatusModeVisual",
                MiniStatuslineModeReplace = "Nvim2StatusModeReplace",
                MiniStatuslineModeCommand = "Nvim2StatusModeCommand",
                MiniStatuslineModeOther = "Nvim2StatusModeOther",
            }
            local mode_group = mode_names[mode_hl] or "Nvim2StatusModeNormal"
            local function join(parts, separator)
                return table.concat(vim.tbl_filter(function(value)
                    return value ~= nil and value ~= ""
                end, parts), separator)
            end

            local git = statusline.section_git({ trunc_width = 45, icon = "" })
            local diff = statusline.section_diff({ trunc_width = 95 })
            local diagnostics = statusline.section_diagnostics({ trunc_width = 95 })
            local lsp = statusline.section_lsp({ trunc_width = 95, icon = "󰒋" })
            local filename = statusline.section_filename({ trunc_width = 150 })
            local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
            local search = statusline.section_searchcount({ trunc_width = 90 })
            local directory = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            local session = vim.v.this_session ~= ""
                    and "󰗼 " .. vim.fn.fnamemodify(vim.v.this_session, ":t:r")
                or ""

            local context = join({ "󰉋 " .. directory, git, diff, diagnostics, lsp }, "  │  ")
            local right = join({ session, fileinfo, search }, "  │  ")
            local location = string.format("%d:%d", vim.fn.line("."), vim.fn.col("."))

            return statusline.combine_groups({
                { hl = mode_group, strings = { mode } },
                { hl = "Nvim2StatusContext", strings = { context } },
                "%<",
                { hl = "Nvim2StatusFile", strings = { filename } },
                "%=",
                { hl = "Nvim2StatusInfo", strings = { right } },
                { hl = "Nvim2StatusLocation", strings = { location } },
            })
        end,
        inactive = function()
            return statusline.combine_groups({
                "%<",
                {
                    hl = "Nvim2StatusContext",
                    strings = { statusline.section_filename({ trunc_width = 140 }) },
                },
                "%=",
            })
        end,
    },
})
require("mini.tabline").setup({
    show_icons = true,
    tabpage_section = "right",
    format = function(buf_id, label)
        local modified = vim.bo[buf_id].modified and " ●" or ""
        return " " .. label .. modified .. " "
    end,
})

-- Discoverable leader-key groups.
require("which-key").setup({
    delay = 300,
    preset = "modern",
    win = { border = "rounded" },
})
require("which-key").add({
    { "<leader>b", group = "Buffers" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Diagnostics / Discord" },
    { "<leader>f", group = "Find" },
    { "<leader>h", group = "Help" },
    { "<leader>p", group = "Packages" },
    { "<leader>q", group = "Quit" },
    { "<leader>s", group = "Sessions" },
    { "<leader>t", group = "Terminal / tabs" },
    { "<leader>u", group = "UI" },
    { "<leader>w", group = "Windows" },
})

-- Fast jump navigation.
require("flash").setup({
    label = { rainbow = { enabled = true, shade = 3 } },
    modes = { char = { enabled = false } },
})

-- Format-on-save and formatter commands.
require("conform").setup({
    default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end
        return { lsp_format = "fallback", timeout_ms = 3000 }
    end,
    formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        css = { "prettier", stop_after_first = true },
        go = { "gofmt" },
        html = { "prettier", stop_after_first = true },
        javascript = { "prettier", stop_after_first = true },
        javascriptreact = { "prettier", stop_after_first = true },
        json = { "prettier", stop_after_first = true },
        jsonc = { "prettier", stop_after_first = true },
        lua = { "stylua" },
        markdown = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        typescriptreact = { "prettier", stop_after_first = true },
    },
    formatters = {
        clang_format = {
            prepend_args = { "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}" },
        },
        prettier = { prepend_args = { "--tab-width", "4", "--use-tabs", "false" } },
    },
})

-- Theme, syntax parsers, and language highlighting.
require("vague").setup({ transparent = true, bold = true, italic = true })

local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "FloatTitle",
    "Pmenu",
    "PmenuSbar",
    "Folded",
    "MsgSeparator",
    "StatusLine",
    "StatusLineNC",
    "StatusLineTerm",
    "StatusLineTermNC",
    "TabLine",
    "TabLineFill",
    "WinBar",
    "WinBarNC",
}

local function setup_transparency()
    for _, group in ipairs(transparent_groups) do
        local highlights = vim.api.nvim_get_hl(0, { name = group, link = false })
        highlights.bg = "NONE"
        vim.api.nvim_set_hl(0, group, highlights)
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Keep theme surfaces transparent",
    callback = setup_transparency,
})

require("nvim-treesitter").setup()
vim.treesitter.language.register("json", "jsonc")
if vim.env.NVIM2_SKIP_PARSERS ~= "1" then
    require("nvim-treesitter").install(languages)
end

vim.api.nvim_create_autocmd("FileType", {
    desc = "Enable native Treesitter highlighting, folds, and indentation",
    pattern = {
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "gitcommit",
        "go",
        "gomod",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "typescript",
        "typescriptreact",
        "vim",
        "vimdoc",
    },
    callback = function(event)
        if pcall(vim.treesitter.start, event.buf) then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo.foldlevel = 99
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- Discord Rich Presence.
local presence
local presence_config = {
        auto_update = true,
        client_id = "793271441293967371",
        debounce_timeout = 10,
        enable_line_number = false,
        main_image = "file",
        neovim_image_text = "Neovim beneath Mount Fuji",
        show_time = true,
        editing_text = "Crafting %s",
        reading_text = "Reading %s",
        file_explorer_text = "Exploring %s",
        plugin_manager_text = "Tending the tool garden",
        workspace_text = "Working in %s",
        buttons = {
            { label = "GitHub Profile", url = "https://github.com/r7rainz" },
        },
}

local function start_presence()
    if presence then
        presence:update()
        return
    end

    local ok_presence, result = pcall(function()
        return require("presence").setup(presence_config)
    end)
    if not ok_presence then
        vim.notify("Discord presence: " .. result, vim.log.levels.WARN)
        return
    end
    presence = result
    presence:update()
end

vim.api.nvim_create_user_command("Presence", start_presence, { desc = "Enable or refresh Discord presence" })
vim.api.nvim_create_user_command("PresenceCancel", function()
    if presence then
        presence:cancel()
    end
end, { desc = "Disable Discord presence" })

if vim.env.NVIM2_NO_PRESENCE ~= "1" and not vim.env.SSH_CONNECTION and #vim.api.nvim_list_uis() > 0 then
    start_presence()
end

-- Apply the configured startup theme last so all UI modules see its colors.
local ok = pcall(vim.cmd.colorscheme, vim.g.nvim2_theme)
if not ok then
    vim.notify("Unknown theme '" .. vim.g.nvim2_theme .. "'; using omarchy", vim.log.levels.WARN)
    vim.cmd.colorscheme("omarchy")
end
