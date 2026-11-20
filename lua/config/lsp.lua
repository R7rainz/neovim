-- Shared LSP client capabilities (blink.cmp adds completion/snippet support).
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

-- Language-server-specific settings.
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true },
            runtime = { version = "LuaJIT" },
            telemetry = { enable = false },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        },
    },
})

vim.lsp.config("vtsls", {
    settings = {
        typescript = {
            preferences = {
                includeCompletionsForImportStatements = true,
                includeCompletionsForModuleExports = true,
            },
            inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = false },
                variableTypes = { enabled = false },
            },
        },
        javascript = {
            preferences = {
                includeCompletionsForImportStatements = true,
                includeCompletionsForModuleExports = true,
            },
        },
        vtsls = { autoUseWorkspaceTsdk = true },
    },
})

vim.lsp.config("gopls", {
    settings = {
        gopls = {
            analyses = { shadow = true, unusedparams = true },
            completeUnimported = true,
            gofumpt = true,
            staticcheck = true,
            usePlaceholders = true,
        },
    },
})

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
    },
})

vim.lsp.config("eslint", {
    settings = { workingDirectory = { mode = "auto" } },
})

vim.lsp.config("postgres_lsp", {
    root_markers = { "postgres-language-server.jsonc", ".git" },
})

-- Servers enabled for matching project filetypes.
vim.lsp.enable({
    "clangd",
    "cssls",
    "eslint",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
    "postgres_lsp",
    "tailwindcss",
    "vtsls",
})

-- Diagnostics shown in buffers and floating windows.
vim.diagnostic.config({
    float = { border = "rounded", source = "if_many" },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        linehl = { [vim.diagnostic.severity.ERROR] = "DiagnosticLineError" },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
    underline = true,
    update_in_insert = false,
    virtual_text = { prefix = "●", source = "if_many", spacing = 2 },
})

-- Buffer-local navigation mappings (completion itself is blink.cmp, see plugins.lua).
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP buffer mappings",
    callback = function(event)
        -- Let the TypeScript server fix each line's indentation as you type (Enter, `;`,
        -- `}`), like VS Code, so typed code already sits where the formatter puts it.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.name == "vtsls" then
            vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
        end

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, silent = true })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    end,
})
