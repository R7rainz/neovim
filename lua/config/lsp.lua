-- Shared LSP client capabilities.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", { capabilities = capabilities })

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

-- Servers enabled for matching project filetypes.
vim.lsp.enable({
    "clangd",
    "cssls",
    "eslint",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
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
    },
    underline = true,
    update_in_insert = false,
    virtual_text = { prefix = "●", source = "if_many", spacing = 2 },
})

-- Buffer-local completion and navigation mappings.
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Native LSP completion and buffer mappings",
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        -- Trigger explicitly below so punctuation (notably `/` in comments)
        -- can never cause an unrelated LSP item to be inserted or suggested.
        vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = false })

        if not vim.b[event.buf].nvim2_completion then
            vim.b[event.buf].nvim2_completion = true
            local function in_comment()
                local ok, node = pcall(vim.treesitter.get_node, { bufnr = event.buf })
                if not ok or not node then
                    return false
                end
                while node do
                    if node:type():find("comment", 1, true) then
                        return true
                    end
                    node = node:parent()
                end
                return false
            end

            vim.api.nvim_create_autocmd("InsertCharPre", {
                buffer = event.buf,
                callback = function()
                    local char = vim.v.char
                    -- Only identifiers and member access start completion. A
                    -- slash, quote, space, or other punctuation stays exactly
                    -- what the user typed. Comments remain completion-free.
                    if not in_comment() and (char:match("[%w_]") or char == ".") then
                        vim.lsp.completion.get()
                    end
                end,
            })
        end

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc, silent = true })
        end

        local function keycode(key)
            return vim.api.nvim_replace_termcodes(key, true, false, true)
        end

        -- `noinsert` highlights the best candidate without changing the
        -- buffer. Enter commits it; Space cancels the menu and stays literal.
        vim.keymap.set("i", "<CR>", function()
            local info = vim.fn.complete_info({ "selected" })
            if vim.fn.pumvisible() == 1 and info.selected >= 0 then
                return keycode("<C-y>")
            end
            if MiniPairs and MiniPairs.cr then
                return MiniPairs.cr()
            end
            return keycode("<CR>")
        end, { buffer = event.buf, desc = "Accept selected completion", expr = true, silent = true })

        vim.keymap.set("i", "<Space>", function()
            if vim.fn.pumvisible() == 1 then
                return keycode("<C-e>") .. " "
            end
            return " "
        end, { buffer = event.buf, desc = "Keep typed space", expr = true, silent = true })

        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("i", "<C-Space>", vim.lsp.completion.get, "Trigger completion")
    end,
})
