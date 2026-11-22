-- Lualine statusline, ported from craftzdog's dotfiles
-- (~/Documents/dotfiles/dot_config/nvim). Adapted for this config: colors come
-- from nvim_get_hl instead of Snacks, and diff counts come from mini.diff
-- instead of gitsigns.
local M = {}

local icons = {
    diagnostics = { error = "  ", warn = "  ", info = "  ", hint = "  " },
    git = { added = "  ", modified = "  ", removed = "  " },
    readonly = " 󰌾 ",
    root = "󱉭  ",
    macro = "󰑋  ",
}

local root_patterns =
    { ".git", "lua", "package.json", "Makefile", "Cargo.toml", "go.mod", "pyproject.toml" }

local function fg(group)
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    return hl.fg and string.format("#%06x", hl.fg) or nil
end

local function normalize(path)
    path = vim.uv.fs_realpath(path) or path
    return (path:gsub("/$", ""))
end

local function get_cwd()
    return normalize(vim.uv.cwd() or vim.fn.getcwd())
end

local function get_root()
    local path = vim.api.nvim_buf_get_name(0)
    path = path == "" and get_cwd() or vim.fs.dirname(path)
    local marker = vim.fs.find(root_patterns, { path = path, upward = true })[1]
    return marker and normalize(vim.fs.dirname(marker)) or get_cwd()
end

-- Project root name, shown only when it differs from the cwd.
local function root_name()
    local root = get_root()
    return root ~= get_cwd() and vim.fs.basename(root) or nil
end

-- Path relative to the cwd: plain directory, bold filename (MatchParen when modified).
local function pretty_path(self)
    local path = vim.fn.expand("%:p")
    if path == "" then
        return ""
    end
    path = normalize(path)
    local cwd = get_cwd()
    if path:find(cwd .. "/", 1, true) == 1 then
        path = path:sub(#cwd + 2)
    end

    local dir, filename = path:match("^(.*/)([^/]*)$")
    if not dir then
        dir, filename = "", path
    end
    local section = self and self.options and self.options.section or "c"
    local file_hl = vim.bo.modified and "MatchParen" or "Bold"
    local result = dir .. "%#" .. file_hl .. "#" .. filename .. "%#lualine_" .. section .. "_normal#"
    if vim.bo.readonly or not vim.bo.modifiable then
        result = result .. icons.readonly
    end
    return result
end

-- This config's viewport bar for long unwrapped lines (documented in the README).
local function horizontal_scrollbar()
    if vim.wo.wrap then
        return ""
    end
    local width = vim.api.nvim_win_get_width(0)
    local line_width = vim.fn.strdisplaywidth(vim.fn.getline("."))
    if line_width <= width then
        return ""
    end

    local track = math.min(20, math.max(10, math.floor(width / 5)))
    local thumb = math.min(track, math.max(2, math.floor(track * width / line_width)))
    local max_left = math.max(1, line_width - width)
    local left = math.min(vim.fn.winsaveview().leftcol, max_left)
    local start = math.floor((left / max_left) * (track - thumb))
    return "↔ "
        .. string.rep("─", start)
        .. string.rep("━", thumb)
        .. string.rep("─", track - start - thumb)
end

local function define_bold()
    -- pretty_path needs a Bold group; most colorschemes (solarized-osaka included) lack one.
    vim.api.nvim_set_hl(0, "Bold", { bold = true, default = true })
end

-- The colorscheme's own lualine colours, filled across the whole bar. The cached "auto"
-- theme is dropped first so a :colorscheme switch rebuilds it from the new scheme.
local function colorscheme_theme()
    -- lualine has no "gruvbox-light" theme by that name (auto would guess a black bar).
    if vim.g.colors_name == "gruvbox-light" then
        return require("lualine.themes.gruvbox_light")
    end
    package.loaded["lualine.themes.auto"] = nil
    return require("lualine.themes.auto")
end

function M.setup()
    define_bold()

    local config = {
        options = {
            globalstatus = true,
            disabled_filetypes = { statusline = { "ministarter" } },
            refresh = {
                events = {
                    "WinEnter",
                    "BufEnter",
                    "BufWritePost",
                    "SessionLoadPost",
                    "FileChangedShellPost",
                    "VimResized",
                    "Filetype",
                    "CursorMoved",
                    "CursorMovedI",
                    "ModeChanged",
                    "RecordingEnter",
                    "RecordingLeave",
                    "WinScrolled",
                },
            },
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { { "branch", icon = " " } },
            lualine_c = {
                {
                    function()
                        return icons.root .. " " .. root_name()
                    end,
                    cond = function()
                        return root_name() ~= nil
                    end,
                    color = function()
                        return { fg = fg("Special") }
                    end,
                },
                { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                { pretty_path },
            },
            lualine_x = {
                {
                    function()
                        return icons.macro .. vim.fn.reg_recording()
                    end,
                    cond = function()
                        return vim.fn.reg_recording() ~= ""
                    end,
                    color = function()
                        return { fg = fg("DiagnosticError"), gui = "bold" }
                    end,
                },
                { "diagnostics", symbols = icons.diagnostics },
                {
                    "diff",
                    symbols = icons.git,
                    source = function()
                        local summary = vim.b.minidiff_summary
                        if summary and summary.add then
                            return {
                                added = summary.add,
                                modified = summary.change,
                                removed = summary.delete,
                            }
                        end
                    end,
                },
                { horizontal_scrollbar },
            },
            lualine_y = { { "progress", separator = " ", padding = { left = 1, right = 1 } } },
            lualine_z = { { "location", padding = { left = 1, right = 1 } } },
        },
    }

    local function apply()
        define_bold()
        config.options.theme = colorscheme_theme()
        require("lualine").setup(config)
    end
    apply()
    vim.api.nvim_create_autocmd("ColorScheme", {
        desc = "Rebuild the statusline colours for the new colorscheme",
        callback = function()
            vim.schedule(apply)
        end,
    })
end

return M
