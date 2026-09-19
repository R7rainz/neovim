local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.confirm = true
opt.hidden = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 200
opt.timeoutlen = 400
-- Show the first completion as a highlighted candidate, but never insert it
-- until Enter confirms it. This keeps comments, punctuation, and prose safe.
opt.completeopt = { "menu", "menuone", "noinsert", "popup" }
opt.pumborder = "rounded"
opt.pumheight = 12
opt.winborder = "rounded"
opt.laststatus = 3
opt.showmode = false
opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "terminal" }

local group = vim.api.nvim_create_augroup("nvim2_core", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Highlight copied text",
    callback = function()
        vim.hl.on_yank({ timeout = 180 })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    desc = "Keep four-column indentation across development languages",
    pattern = {
        "c",
        "cpp",
        "css",
        "go",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "lua",
        "typescript",
        "typescriptreact",
    },
    callback = function(event)
        vim.bo[event.buf].tabstop = 4
        vim.bo[event.buf].shiftwidth = 4
        vim.bo[event.buf].softtabstop = 4
        vim.bo[event.buf].expandtab = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "help", "checkhealth", "qf", "man" },
    callback = function(event)
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = group,
    desc = "Notice files changed outside Neovim",
    command = "checktime",
})
