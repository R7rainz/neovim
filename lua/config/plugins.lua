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
    "sql",
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
    { src = github("nvim-tree/nvim-tree.lua") },
    { src = github("MeanderingProgrammer/render-markdown.nvim") },
    { src = github("neovim/nvim-lspconfig") },
    { src = github("nvim-treesitter/nvim-treesitter"), version = "main" },
    { src = github("stevearc/conform.nvim") },
    { src = github("folke/which-key.nvim") },
    { src = github("folke/flash.nvim") },
    { src = github("nvim-lualine/lualine.nvim") },
    { src = github("saghen/blink.cmp"), version = vim.version.range("^1") },
    { src = github("sainnhe/edge") },
    { src = github("folke/tokyonight.nvim") },
    { src = github("craftzdog/solarized-osaka.nvim") },
    { src = github("rose-pine/neovim"), name = "rose-pine" },
    { src = github("rebelot/kanagawa.nvim") },
    { src = github("ellisonleao/gruvbox.nvim") },
    { src = github("AvengeMedia/base46") },
    { src = github("andweeb/presence.nvim"), version = "main" },
}, { confirm = false, load = true })

local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()

require("render-markdown").setup({
    enabled = true,
    render_modes = { "n", "c", "t" },
    completions = { lsp = { enabled = true } },
})

local tree_api = require("nvim-tree.api")
require("nvim-tree").setup({
    hijack_directories = { enable = true, auto_open = false },
    hijack_netrw = true,
    disable_netrw = true,
    sync_root_with_cwd = false,
    respect_buf_cwd = false,
    update_focused_file = { enable = true, update_root = false },
    view = {
        preserve_window_proportions = true,
        side = "left",
        signcolumn = "no",
        width = "25%",
    },
    renderer = {
        group_empty = true,
        indent_markers = { enable = false },
        root_folder_label = false,
        icons = {
            git_placement = "after",
            modified_placement = "after",
            padding = { folder_arrow = " ", icon = " " },
            show = { file = true, folder = true, folder_arrow = true, git = true, modified = true },
            web_devicons = {
                file = { enable = true, color = true },
                folder = { enable = false, color = true },
            },
            glyphs = {
                default = "",
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                    default = "",
                    empty = "",
                    empty_open = "",
                    open = "",
                },
            },
        },
    },
    filters = { dotfiles = false, git_ignored = false },
    git = { enable = true, ignore = false, timeout = 500 },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
        icons = { error = "", hint = "󰌵", info = "", warning = "" },
    },
    actions = {
        change_dir = { enable = false },
        open_file = {
            quit_on_open = false,
            resize_window = false,
            window_picker = { enable = false },
        },
    },
    on_attach = function(bufnr)
        tree_api.map.on_attach.default(bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
        vim.keymap.set(
            "n",
            "h",
            tree_api.node.navigate.parent_close,
            vim.tbl_extend("force", opts, { desc = "Go to parent" })
        )
        vim.keymap.set(
            "n",
            "l",
            tree_api.node.open.edit,
            vim.tbl_extend("force", opts, { desc = "Open" })
        )
        vim.keymap.set(
            "n",
            "<CR>",
            tree_api.node.open.edit,
            vim.tbl_extend("force", opts, { desc = "Open" })
        )
        for _, lhs in ipairs({ "-", "P", "<C-]>" }) do
            pcall(vim.keymap.del, "n", lhs, { buffer = bufnr })
        end
    end,
})

-- Pickers and file navigation.
require("mini.pick").setup({
    options = { use_cache = true },
    window = {
        config = function()
            local height = math.max(1, math.floor(vim.o.lines * 0.68))
            local width = math.max(1, math.floor(vim.o.columns * 0.78))
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
        prompt_caret = "▏",
    },
})
require("mini.extra").setup()
require("mini.files").setup({
    options = { permanent_delete = false, use_as_default_explorer = false },
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

-- Completion (blink.cmp, as in craftzdog's dotfiles). Enter accepts, the first item is
-- highlighted but never inserted, Space just types a space, and comments stay quiet.
local function in_comment()
    local ok, node = pcall(vim.treesitter.get_node)
    while ok and node do
        if node:type():find("comment", 1, true) then
            return true
        end
        node = node:parent()
    end
    return false
end

require("blink.cmp").setup({
    enabled = function()
        return vim.fn.mode() == "c" or not in_comment()
    end,
    keymap = { preset = "enter", ["<C-y>"] = { "select_and_accept" } },
    completion = {
        list = {
            selection = {
                -- Highlight the first item only while typing a word or right after `.`,
                -- so a menu left open after `)` or `;` never swallows Enter.
                preselect = function(ctx)
                    local line, col = vim.api.nvim_get_current_line(), ctx.get_cursor()[2]
                    return ctx.get_keyword() ~= "" or line:sub(col, col) == "."
                end,
                auto_insert = false,
            },
        },
        accept = { auto_brackets = { enabled = true } },
        menu = { draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    cmdline = {
        enabled = true,
        keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
        completion = {
            list = { selection = { preselect = false } },
            menu = {
                auto_show = function()
                    return vim.fn.getcmdtype() == ":"
                end,
            },
            ghost_text = { enabled = true },
        },
    },
})
require("mini.diff").setup({
    view = {
        priority = 199,
        signs = { add = "▎", change = "▎", delete = "▁" },
        style = "sign",
    },
})
-- Colour codes like #7aa2f7 are drawn on their own colour.
local hipatterns = require("mini.hipatterns")
hipatterns.setup({ highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() } })
require("config.sessions").setup()

-- Statusline and tabline highlights.
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
        green = color("String", "fg", "#88998c"),
        red = color("DiagnosticError", "fg", "#ec8a73"),
        yellow = color("WarningMsg", "fg", "#e5b681"),
    }

    local set = vim.api.nvim_set_hl
    set(0, "StatusLine", { bg = "NONE", fg = palette.foreground })
    set(0, "StatusLineNC", { bg = "NONE", fg = palette.muted })

    set(0, "MiniTablineCurrent", { bg = palette.yellow, bold = true, fg = palette.base })
    set(0, "MiniTablineVisible", { bg = palette.block, fg = palette.bright })
    set(0, "MiniTablineHidden", { bg = "NONE", fg = palette.muted })
    set(0, "MiniTablineModifiedCurrent", { bg = palette.green, bold = true, fg = palette.base })
    set(0, "MiniTablineModifiedVisible", { bg = "NONE", bold = true, fg = palette.green })
    set(0, "MiniTablineModifiedHidden", { bg = "NONE", fg = palette.yellow })
    set(0, "MiniTablineFill", { bg = "NONE", fg = palette.muted })
    set(0, "MiniTablineTabpagesection", { bg = palette.blue, bold = true, fg = palette.base })
    set(0, "MiniTablineTrunc", { bg = "NONE", bold = true, fg = palette.yellow })
    set(0, "DiagnosticLineError", { bg = palette.block })
    set(0, "MiniDiffSignAdd", { bold = true, fg = palette.green })
    set(0, "MiniDiffSignChange", { bold = true, fg = palette.yellow })
    set(0, "MiniDiffSignDelete", { bold = true, fg = palette.red })

    set(0, "MiniPickNormal", { bg = "NONE", fg = palette.foreground })
    set(0, "MiniPickBorder", { bg = "NONE", fg = palette.block })
    set(0, "MiniPickBorderBusy", { bg = "NONE", fg = palette.yellow })
    set(0, "MiniPickBorderText", { bg = "NONE", bold = true, fg = palette.blue })
    set(0, "MiniPickPrompt", { bg = "NONE", bold = true, fg = palette.bright })
    set(0, "MiniPickPromptPrefix", { bg = "NONE", bold = true, fg = palette.yellow })
    set(0, "MiniPickPromptCaret", { bg = "NONE", fg = palette.yellow })
    set(0, "MiniPickMatchCurrent", { bg = palette.block, bold = true, fg = palette.bright })
    set(0, "MiniPickMatchRanges", { bold = true, fg = palette.yellow })
    set(0, "MiniPickPreviewLine", { bg = palette.block, fg = palette.bright })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Keep statusline and tabline aligned with the active theme",
    callback = setup_ui_highlights,
})

-- Statusline (lualine, see lua/config/statusline.lua) and buffer tabline.
require("config.statusline").setup()
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
    { "<leader>m", group = "Markdown" },
    { "<leader>p", group = "Packages" },
    { "<leader>q", group = "Quit" },
    { "<leader>s", group = "Sessions" },
    { "<leader>t", group = "Terminal / tabs" },
    { "<leader>u", group = "UI" },
    { "<leader>w", group = "Windows" },
    { "<leader>z", group = "Horizontal scroll" },
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
        sql = { "pg_format", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        typescriptreact = { "prettier", stop_after_first = true },
    },
    formatters = {
        clang_format = {
            stdin = false,
            args = {
                "-i",
                "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never, ColumnLimit: 100}",
                "$FILENAME",
            },
        },
        gofmt = { stdin = false, args = { "-w", "$FILENAME" } },
        pg_format = { stdin = false, args = { "--wrap-limit", "100", "--inplace", "$FILENAME" } },
        prettier = {
            stdin = false,
            args = {
                "--write",
                "--tab-width",
                "4",
                "--use-tabs",
                "false",
                "--print-width",
                "100",
                "--prose-wrap",
                "always",
                "$FILENAME",
            },
        },
        stylua = {
            stdin = false,
            args = {
                "--search-parent-directories",
                "--respect-ignores",
                "--column-width",
                "100",
                "--indent-type",
                "Spaces",
                "--indent-width",
                "4",
                "$FILENAME",
            },
        },
    },
})

-- Theme, syntax parsers, and language highlighting.
vim.g.edge_better_performance = 1
vim.g.edge_enable_italic = 1
vim.g.edge_style = "default"
vim.g.edge_transparent_background = 2

require("tokyonight").setup({
    style = "night",
    transparent = true,
    styles = { comments = { italic = true }, keywords = { italic = true } },
})

require("solarized-osaka").setup({
    style = "vivid",
    transparent = true,
    terminal_colors = true,
    styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
    },
    hide_inactive_statusline = false,
    dim_inactive = false,
})

require("base46").setup({ transparency = true })

require("rose-pine").setup()

-- Kanagawa Dragon with no background of its own, so the terminal's pure black shows through.
-- `background` picks the variant for :colorscheme kanagawa, so it has to say dragon too.
require("kanagawa").setup({
    theme = "dragon",
    background = { dark = "dragon", light = "lotus" },
    transparent = true,
    colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
})

require("gruvbox").setup({ contrast = "hard", transparent_mode = true })

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
        "sql",
        "typescript",
        "typescriptreact",
        "vim",
        "vimdoc",
    },
    callback = function(event)
        local treesitter_ok = pcall(vim.treesitter.start, event.buf)
        if treesitter_ok then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo.foldlevel = 99
        end
        -- Treesitter indents every language, TS/TSX included (cindent read object keys
        -- like `name:` as C labels and pushed them to column 0 while typing).
        if treesitter_ok then
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

vim.api.nvim_create_user_command(
    "Presence",
    start_presence,
    { desc = "Enable or refresh Discord presence" }
)
vim.api.nvim_create_user_command("PresenceCancel", function()
    if presence then
        presence:cancel()
    end
end, { desc = "Disable Discord presence" })

if
    vim.env.NVIM2_NO_PRESENCE ~= "1"
    and not vim.env.SSH_CONNECTION
    and #vim.api.nvim_list_uis() > 0
then
    start_presence()
end

-- Apply the configured startup theme last so all UI modules see its colors.
local ok = pcall(vim.cmd.colorscheme, vim.g.nvim2_theme or "solarized-osaka")
if not ok then
    vim.notify(
        "Unknown theme '" .. vim.g.nvim2_theme .. "'; using solarized-osaka",
        vim.log.levels.WARN
    )
    vim.cmd.colorscheme("solarized-osaka")
end
