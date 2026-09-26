local M = {}
local map = vim.keymap.set
local sessions = require("config.sessions")

-- Search and project navigation helpers.
function M.find_files(cwd)
    MiniPick.builtin.files({ tool = "rg" }, { source = { cwd = cwd or vim.uv.cwd() } })
end

function M.live_grep(cwd)
    MiniPick.builtin.grep_live(nil, { source = { cwd = cwd or vim.uv.cwd() } })
end

function M.recent_files()
    MiniExtra.pickers.oldfiles({ current_dir = false, preserve_order = true })
end

function M.project_dirs()
    local home = vim.fn.expand("~")
    local command = {
        "fd",
        "--type",
        "d",
        "--hidden",
        "--max-depth",
        "5",
        ".",
    }
    for _, name in ipairs({
        ".git",
        ".cache",
        ".cargo",
        ".config",
        ".local",
        ".mise",
        ".npm",
        ".pnpm-store",
        "build",
        "dist",
        "node_modules",
        "target",
        ".venv",
        "venv",
    }) do
        table.insert(command, #command, "--exclude")
        table.insert(command, #command, name)
    end

    MiniPick.builtin.cli({ command = command, spawn_opts = { cwd = home } }, {
        source = {
            cwd = home,
            name = "Project directories",
            choose = function(item)
                local path = type(item) == "table" and (item.path or item.text) or item
                if type(path) ~= "string" then
                    return
                end
                path = path:sub(1, 1) == "/" and path or home .. "/" .. path
                path = vim.fs.normalize(path)
                if vim.fn.isdirectory(path) == 0 then
                    return
                end
                vim.cmd.cd(vim.fn.fnameescape(path))
                vim.notify("Project: " .. vim.fn.fnamemodify(path, ":~"))
            end,
        },
    })
end

function M.open_config()
    vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end

-- Buffer, explorer, and project-session helpers.
local function close_other_buffers()
    local current = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if buffer ~= current and vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].buflisted then
            vim.api.nvim_buf_delete(buffer, {})
        end
    end
end

local function toggle_files()
    if MiniFiles.close() == nil then
        MiniFiles.open(sessions.project_root(), true)
    end
end

local function session_name()
    return sessions.name()
end

local function restore_project_session()
    local name = session_name()
    if MiniSessions.detected[name] then
        MiniSessions.read(name)
    else
        vim.notify("No saved session for " .. vim.uv.cwd(), vim.log.levels.INFO)
    end
end

M.restore_project_session = restore_project_session

-- Reusable terminal windows.
local terminals = {}
local toggle_terminal

toggle_terminal = function(kind)
    local terminal = terminals[kind]
    if terminal and terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
        vim.api.nvim_win_close(terminal.win, true)
        terminal.win = nil
        return
    end

    local running = terminal
        and terminal.buf
        and vim.api.nvim_buf_is_valid(terminal.buf)
        and terminal.job
        and vim.fn.jobwait({ terminal.job }, 0)[1] == -1

    if not running then
        terminal = { buf = vim.api.nvim_create_buf(false, true) }
        terminals[kind] = terminal
    end

    if kind == "float" then
        local width = math.max(1, math.floor(vim.o.columns * 0.82))
        local height = math.max(1, math.floor(vim.o.lines * 0.72))
        terminal.win = vim.api.nvim_open_win(terminal.buf, true, {
            border = "rounded",
            col = math.floor((vim.o.columns - width) / 2),
            height = height,
            relative = "editor",
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            width = width,
        })
    else
        vim.cmd(kind == "vertical" and "botright vsplit" or "botright 12split")
        terminal.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(terminal.win, terminal.buf)
    end

    if not running then
        terminal.job = vim.fn.jobstart(vim.o.shell, { term = true })
        vim.bo[terminal.buf].bufhidden = "hide"
        vim.bo[terminal.buf].filetype = "nvim2_terminal"
        map("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = terminal.buf, desc = "Terminal normal mode" })
        map("t", "<C-h>", "<C-\\><C-n><C-w>h", { buffer = terminal.buf })
        map("t", "<C-j>", "<C-\\><C-n><C-w>j", { buffer = terminal.buf })
        map("t", "<C-k>", "<C-\\><C-n><C-w>k", { buffer = terminal.buf })
        map("t", "<C-l>", "<C-\\><C-n><C-w>l", { buffer = terminal.buf })
        map("t", "<C-`>", function()
            toggle_terminal(kind)
        end, { buffer = terminal.buf, desc = "Hide terminal" })
    end
    vim.cmd.startinsert()
end

-- Dark-theme chooser and user commands.
local function pick_theme()
    local themes = {
        { label = "Omarchy (active desktop palette)", name = "omarchy" },
        { label = "Vague (dark low-contrast)", name = "vague" },
        { label = "Rosé Pine (dark)", name = "rose-pine" },
    }
    vim.ui.select(themes, {
        prompt = "Dark theme",
        format_item = function(item)
            return item.label
        end,
    }, function(item)
        if item then
            vim.g.nvim2_theme = item.name
            vim.cmd.colorscheme(item.name)
        end
    end)
end

vim.api.nvim_create_user_command("Theme", pick_theme, { desc = "Choose a dark colorscheme" })
vim.api.nvim_create_user_command("ConfigDocs", "help nvim2", { desc = "Open this config's manual" })
vim.api.nvim_create_user_command("FormatDisable", function(event)
    if event.bang then
        vim.b.disable_autoformat = true
    else
        vim.g.disable_autoformat = true
    end
end, { bang = true, desc = "Disable autoformat globally (or buffer-local with !)" })
vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, { desc = "Enable autoformat" })

function M.setup()
    -- Files and search.
    map("n", "<leader><Tab>", toggle_files, { desc = "File explorer" })
    map("n", "<leader>e", M.find_files, { desc = "Find files" })
    map("n", "<leader>ff", M.find_files, { desc = "Find files" })
    map("n", "<leader>fg", M.live_grep, { desc = "Live grep" })
    map("n", "<leader>fw", M.live_grep, { desc = "Live grep" })
    map("n", "<leader>fb", MiniPick.builtin.buffers, { desc = "Buffers" })
    map("n", "<leader>fh", MiniPick.builtin.help, { desc = "Help tags" })
    map("n", "<leader>fr", M.recent_files, { desc = "Recent files" })
    map("n", "<leader>fP", M.project_dirs, { desc = "Project directories" })
    map("n", "<leader>fA", function()
        M.find_files(vim.uv.os_homedir())
    end, { desc = "Find files in home" })
    map("n", "<leader>fp", function()
        M.find_files(vim.fn.stdpath("data") .. "/site/pack/core/opt")
    end, { desc = "Find plugin file" })
    map("n", "<leader>fs", function()
        MiniExtra.pickers.lsp({ scope = "document_symbol" })
    end, { desc = "Document symbols" })
    map("n", "<leader>ws", function()
        MiniExtra.pickers.lsp({ scope = "workspace_symbol_live" })
    end, { desc = "Workspace symbols" })

    map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
    map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
    map("n", "<C-x>", "<cmd>bdelete<cr>", { desc = "Close buffer" })
    map("n", "<leader>X", "<cmd>bdelete!<cr>", { desc = "Force close buffer" })
    map("n", "<leader>bo", close_other_buffers, { desc = "Close other buffers" })

    -- Pane navigation and layout.
    map("n", "<C-h>", "<C-w>h", { desc = "Focus left pane" })
    map("n", "<C-j>", "<C-w>j", { desc = "Focus lower pane" })
    map("n", "<C-k>", "<C-w>k", { desc = "Focus upper pane" })
    map("n", "<C-l>", "<C-w>l", { desc = "Focus right pane" })
    map("n", "<A-h>", "<cmd>vertical resize -3<cr>", { desc = "Shrink pane horizontally" })
    map("n", "<A-l>", "<cmd>vertical resize +3<cr>", { desc = "Grow pane horizontally" })
    map("n", "<A-j>", "<cmd>resize -2<cr>", { desc = "Shrink pane vertically" })
    map("n", "<A-k>", "<cmd>resize +2<cr>", { desc = "Grow pane vertically" })
    map("n", "<leader>w/", "<C-w>v", { desc = "Split vertical" })
    map("n", "<leader>w-", "<C-w>s", { desc = "Split horizontal" })
    map("n", "<leader>ww", "<C-w>w", { desc = "Next window" })
    map("n", "<leader>wx", "<cmd>close<cr>", { desc = "Close window" })
    map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })
    map("n", "<leader>wH", "<C-w>H", { desc = "Move window left" })
    map("n", "<leader>wJ", "<C-w>J", { desc = "Move window down" })
    map("n", "<leader>wK", "<C-w>K", { desc = "Move window up" })
    map("n", "<leader>wL", "<C-w>L", { desc = "Move window right" })

    -- Terminal toggles.
    map("n", "<leader>tt", function()
        toggle_terminal("horizontal")
    end, { desc = "Terminal horizontal" })
    map("n", "<leader>tv", function()
        toggle_terminal("vertical")
    end, { desc = "Terminal vertical" })
    map({ "n", "t" }, "<C-`>", function()
        toggle_terminal("float")
    end, { desc = "Terminal float" })
    map("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })

    -- Sessions.
    map("n", "<leader>ss", function()
        MiniSessions.write(session_name())
    end, { desc = "Save project session" })
    map("n", "<leader>sl", restore_project_session, { desc = "Restore project session" })
    map("n", "<leader>sd", function()
        MiniSessions.delete(session_name())
    end, { desc = "Delete project session" })
    map("n", "<leader>sf", function()
        MiniSessions.select("read")
    end, { desc = "Find session" })

    -- Diagnostics, formatting, and code actions.
    map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
    map("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
    end, { desc = "Previous diagnostic" })
    map("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
    end, { desc = "Next diagnostic" })
    map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
    map("n", "<leader>cf", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format buffer" })
    map("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
    end, { desc = "Toggle inlay hints" })

    -- Flash navigation and UI/help commands.
    map({ "n", "x", "o" }, "s", function()
        require("flash").jump()
    end, { desc = "Flash jump" })
    map({ "n", "o" }, "S", function()
        require("flash").treesitter()
    end, { desc = "Flash Treesitter" })

    map("n", "<leader>ut", pick_theme, { desc = "Choose theme" })
    map("n", "<leader>?", "<cmd>help nvim2-keymaps<cr>", { desc = "Keybinding manual" })
    map("n", "<leader>hd", "<cmd>help nvim2<cr>", { desc = "Config manual" })
    map("n", "<leader>hh", "<cmd>checkhealth nvim2<cr>", { desc = "Config health" })
    map("n", "<leader>pp", function()
        vim.pack.update(nil, { offline = true })
    end, { desc = "Inspect plugins" })
    map("n", "<leader>pu", vim.pack.update, { desc = "Update plugins" })

    map("n", "<leader>dc", function()
        vim.cmd.PresenceCancel()
        vim.defer_fn(vim.cmd.Presence, 500)
        vim.notify("Discord presence restarted")
    end, { desc = "Restart Discord presence" })
    map("n", "<leader>dd", "<cmd>PresenceCancel<cr>", { desc = "Disable Discord presence" })
    map("n", "<leader>de", "<cmd>Presence<cr>", { desc = "Enable Discord presence" })

    map("n", "<leader>qq", "<cmd>quit<cr>", { desc = "Quit" })
    map("n", "<leader>qQ", "<cmd>quit!<cr>", { desc = "Quit force" })
    map("n", "<leader>qa", "<cmd>qall<cr>", { desc = "Quit all" })
    map("n", "<leader>qA", "<cmd>qall!<cr>", { desc = "Quit all force" })
    map("n", "<leader>cx", "<cmd>cclose<cr>", { desc = "Close quickfix" })
    map("n", "<leader>lx", "<cmd>lclose<cr>", { desc = "Close location list" })

    map("n", ";", ":", { desc = "Command line" })
    map("i", "jk", "<Esc>", { desc = "Normal mode" })
    map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
    map("x", "<", "<gv", { desc = "Indent left" })
    map("x", ">", ">gv", { desc = "Indent right" })
end

return M
