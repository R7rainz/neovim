local M = {}

local executables = {
    { "git", "plugin installation" },
    { "rg", "file and text search" },
    { "fd", "fast file search fallback" },
    { "tree-sitter", "Treesitter parser installation" },
    { "lua-language-server", "Lua LSP" },
    { "vtsls", "TypeScript, React, and Next.js LSP" },
    { "vscode-eslint-language-server", "JavaScript and TypeScript linting" },
    { "tailwindcss-language-server", "Tailwind CSS LSP" },
    { "gopls", "Go LSP" },
    { "clangd", "C and C++ LSP" },
    { "stylua", "Lua formatting" },
    { "prettier", "web formatting" },
    { "gofmt", "Go formatting" },
    { "clang-format", "C and C++ formatting" },
}

function M.check()
    vim.health.start("nvim2")

    if vim.fn.has("nvim-0.12") == 1 then
        vim.health.ok("Neovim 0.12+")
    else
        vim.health.error("Neovim 0.12+ is required")
    end

    vim.health.ok(string.format("%d plugins managed by vim.pack", #vim.pack.get(nil, { info = false })))

    local palette = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")
    if vim.uv.fs_stat(palette) then
        vim.health.ok("Omarchy palette found")
    else
        vim.health.warn("Omarchy palette not found; :colorscheme omarchy will use its built-in fallback")
    end

    for _, entry in ipairs(executables) do
        if vim.fn.executable(entry[1]) == 1 then
            vim.health.ok(entry[1] .. " (" .. entry[2] .. ")")
        else
            vim.health.warn(entry[1] .. " missing (needed for " .. entry[2] .. ")", { "See :help nvim2-lsp" })
        end
    end
end

return M
