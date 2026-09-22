local M = {}

-- Normalize paths before using them as project/session identifiers.
local function full_path(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

-- Use the nearest Git root, but never treat the home directory as a project.
function M.project_root(path)
    local cwd = full_path(path or vim.uv.cwd())
    local home = full_path(vim.env.HOME or vim.fn.expand("~"))
    local marker = vim.fs.find(".git", { path = cwd, upward = true, limit = 1 })[1]
    local root = marker and vim.fs.dirname(marker) or cwd
    return root == home and cwd or root
end

-- Stable readable name plus a collision-resistant path hash.
function M.name(path)
    local root = M.project_root(path)
    local name = vim.fs.basename(root):gsub("[^%w_.-]", "_")
    return string.format("%s-%s.vim", name, vim.fn.sha256(root):sub(1, 8))
end

-- Configure MiniSessions and auto-restore/save for `nvim .`.
function M.setup()
    require("mini.sessions").setup({
        autoread = false,
        autowrite = true,
        directory = vim.fn.stdpath("state") .. "/sessions",
        file = "",
    })

    local argument = vim.fn.argc() == 1 and vim.fn.argv(0) or nil
    if not argument or vim.fn.isdirectory(argument) == 0 then
        return
    end

    local project = M.project_root(vim.fn.fnamemodify(argument, ":p"))
    local session = M.name(project)
    vim.g.nvim2_session_project = project

    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        nested = true,
        callback = function()
            vim.schedule(function()
                vim.cmd.cd(vim.fn.fnameescape(project))
                if MiniSessions.detected[session] then
                    MiniSessions.read(session, { force = true, verbose = false })
                end
            end)
        end,
        desc = "Restore the launched project session",
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            MiniSessions.write(session, { force = true, verbose = false })
        end,
        desc = "Save the launched project session",
    })
end

return M
