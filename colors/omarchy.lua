local colors = {
    accent = "#d8785f",
    background = "#1a1b1f",
    blue = "#7e91aa",
    bright_blue = "#a9bfd4",
    bright_cyan = "#b8cbd2",
    bright_foreground = "#f7f1e6",
    bright_green = "#b0c0ac",
    bright_magenta = "#ceb0b4",
    bright_red = "#ec8a73",
    bright_yellow = "#e5b681",
    brown = "#a16f5b",
    cyan = "#8ea2ad",
    dark_background = "#141519",
    dark_foreground = "#858b95",
    darker_background = "#0f1013",
    foreground = "#e7e2db",
    green = "#88998c",
    light_foreground = "#c9c6bf",
    lighter_background = "#282a30",
    magenta = "#ad8f96",
    muted = "#73777d",
    orange = "#c98661",
    red = "#d76555",
    selection = "#3c3435",
    yellow = "#d39a67",
}

local palette = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")
local ok, lines = pcall(vim.fn.readfile, palette)
if ok then
    for _, line in ipairs(lines) do
        local key, value = line:match('^([%w_]+)%s*=%s*"(#[%x]+)"')
        if key and colors[key] then
            colors[key] = value
        end
    end
end

vim.o.background = "dark"
vim.cmd.highlight("clear")
vim.g.colors_name = "omarchy"

local set = vim.api.nvim_set_hl
local function link(group, target)
    set(0, group, { link = target })
end

set(0, "Normal", { bg = colors.background, fg = colors.foreground })
set(0, "NormalNC", { bg = colors.dark_background, fg = colors.light_foreground })
set(0, "NormalFloat", { bg = colors.dark_background, fg = colors.foreground })
set(0, "FloatBorder", { bg = colors.dark_background, fg = colors.muted })
set(0, "FloatTitle", { bg = colors.dark_background, bold = true, fg = colors.accent })
set(0, "WinSeparator", { fg = colors.lighter_background })
set(0, "Cursor", { bg = colors.bright_foreground, fg = colors.background })
set(0, "CursorLine", { bg = colors.dark_background })
set(0, "CursorColumn", { bg = colors.dark_background })
set(0, "ColorColumn", { bg = colors.dark_background })
set(0, "LineNr", { fg = colors.muted })
set(0, "CursorLineNr", { bold = true, fg = colors.accent })
set(0, "SignColumn", { bg = colors.background, fg = colors.muted })
set(0, "FoldColumn", { bg = colors.background, fg = colors.muted })
set(0, "Folded", { bg = colors.dark_background, fg = colors.dark_foreground })
set(0, "Visual", { bg = colors.selection })
set(0, "Search", { bg = colors.yellow, fg = colors.darker_background })
set(0, "CurSearch", { bg = colors.accent, bold = true, fg = colors.darker_background })
set(0, "IncSearch", { bg = colors.accent, bold = true, fg = colors.darker_background })
set(0, "MatchParen", { bold = true, fg = colors.bright_yellow, underline = true })
set(0, "NonText", { fg = colors.lighter_background })
set(0, "Whitespace", { fg = colors.lighter_background })
set(0, "EndOfBuffer", { fg = colors.background })

set(0, "Pmenu", { bg = colors.dark_background, fg = colors.light_foreground })
set(0, "PmenuSel", { bg = colors.selection, bold = true, fg = colors.bright_foreground })
set(0, "PmenuSbar", { bg = colors.lighter_background })
set(0, "PmenuThumb", { bg = colors.muted })
set(0, "PmenuBorder", { fg = colors.muted })
set(0, "WildMenu", { bg = colors.selection, fg = colors.bright_foreground })

set(0, "StatusLine", { bg = colors.dark_background, fg = colors.light_foreground })
set(0, "StatusLineNC", { bg = colors.darker_background, fg = colors.muted })
set(0, "TabLine", { bg = colors.dark_background, fg = colors.dark_foreground })
set(0, "TabLineSel", { bg = colors.selection, bold = true, fg = colors.bright_foreground })
set(0, "TabLineFill", { bg = colors.darker_background })

set(0, "Title", { bold = true, fg = colors.accent })
set(0, "Directory", { fg = colors.blue })
set(0, "Question", { fg = colors.green })
set(0, "MoreMsg", { fg = colors.green })
set(0, "ModeMsg", { bold = true, fg = colors.accent })
set(0, "ErrorMsg", { bold = true, fg = colors.bright_red })
set(0, "WarningMsg", { fg = colors.bright_yellow })
set(0, "QuickFixLine", { bg = colors.selection, bold = true })

set(0, "Comment", { fg = colors.muted, italic = true })
set(0, "Constant", { fg = colors.bright_magenta })
set(0, "String", { fg = colors.green })
set(0, "Character", { fg = colors.bright_green })
set(0, "Number", { fg = colors.orange })
set(0, "Boolean", { bold = true, fg = colors.orange })
set(0, "Float", { fg = colors.orange })
set(0, "Identifier", { fg = colors.foreground })
set(0, "Function", { fg = colors.bright_blue, italic = true })
set(0, "Statement", { fg = colors.accent })
set(0, "Conditional", { fg = colors.magenta })
set(0, "Repeat", { fg = colors.magenta })
set(0, "Label", { fg = colors.yellow })
set(0, "Operator", { fg = colors.cyan })
set(0, "Keyword", { fg = colors.accent })
set(0, "Exception", { fg = colors.red })
set(0, "PreProc", { fg = colors.yellow })
set(0, "Include", { fg = colors.cyan })
set(0, "Define", { fg = colors.yellow })
set(0, "Macro", { fg = colors.yellow })
set(0, "Type", { fg = colors.cyan })
set(0, "StorageClass", { fg = colors.cyan })
set(0, "Structure", { fg = colors.cyan })
set(0, "Typedef", { fg = colors.cyan })
set(0, "Special", { fg = colors.bright_yellow })
set(0, "SpecialChar", { fg = colors.orange })
set(0, "Delimiter", { fg = colors.light_foreground })
set(0, "Underlined", { fg = colors.blue, underline = true })
set(0, "Todo", { bg = colors.yellow, bold = true, fg = colors.darker_background })
set(0, "Error", { fg = colors.bright_red })

set(0, "DiffAdd", { bg = "#243029", fg = colors.bright_green })
set(0, "DiffChange", { bg = "#2b2d36", fg = colors.bright_blue })
set(0, "DiffDelete", { bg = "#352426", fg = colors.bright_red })
set(0, "DiffText", { bg = colors.selection, bold = true, fg = colors.bright_foreground })
set(0, "MiniDiffSignAdd", { fg = colors.green })
set(0, "MiniDiffSignChange", { fg = colors.blue })
set(0, "MiniDiffSignDelete", { fg = colors.red })

set(0, "DiagnosticError", { fg = colors.bright_red })
set(0, "DiagnosticWarn", { fg = colors.bright_yellow })
set(0, "DiagnosticInfo", { fg = colors.bright_blue })
set(0, "DiagnosticHint", { fg = colors.bright_cyan })
set(0, "DiagnosticOk", { fg = colors.bright_green })
set(0, "DiagnosticUnderlineError", { sp = colors.bright_red, undercurl = true })
set(0, "DiagnosticUnderlineWarn", { sp = colors.bright_yellow, undercurl = true })
set(0, "DiagnosticUnderlineInfo", { sp = colors.bright_blue, undercurl = true })
set(0, "DiagnosticUnderlineHint", { sp = colors.bright_cyan, undercurl = true })

link("@annotation", "PreProc")
link("@attribute", "PreProc")
link("@boolean", "Boolean")
link("@character", "Character")
link("@comment", "Comment")
link("@comment.documentation", "Comment")
link("@conditional", "Conditional")
link("@constant", "Constant")
link("@constant.builtin", "Special")
link("@constructor", "Function")
link("@function", "Function")
link("@function.builtin", "Special")
link("@function.call", "Function")
link("@function.method", "Function")
link("@function.method.call", "Function")
link("@keyword", "Keyword")
link("@keyword.function", "Keyword")
link("@keyword.import", "Include")
link("@keyword.operator", "Operator")
link("@label", "Label")
link("@markup.heading", "Title")
link("@markup.link", "Underlined")
link("@markup.raw", "String")
link("@module", "Include")
link("@number", "Number")
link("@operator", "Operator")
link("@property", "Identifier")
link("@punctuation.bracket", "Delimiter")
link("@punctuation.delimiter", "Delimiter")
link("@repeat", "Repeat")
link("@string", "String")
link("@string.escape", "SpecialChar")
link("@tag", "Keyword")
link("@tag.attribute", "Identifier")
link("@tag.delimiter", "Delimiter")
link("@type", "Type")
link("@type.builtin", "Special")
link("@variable", "Identifier")
link("@variable.builtin", "Special")
link("@lsp.type.comment", "Comment")
link("@lsp.type.function", "Function")
link("@lsp.type.method", "Function")

set(0, "MiniPickBorder", { fg = colors.muted })
set(0, "MiniPickBorderBusy", { fg = colors.accent })
set(0, "MiniPickBorderText", { bold = true, fg = colors.blue })
set(0, "MiniPickMatchCurrent", { bg = colors.selection, bold = true })
set(0, "MiniPickMatchRanges", { bold = true, fg = colors.accent })
set(0, "MiniStarterHeader", { bold = true, fg = colors.accent })
set(0, "MiniStarterSection", { bold = true, fg = colors.blue })
set(0, "MiniStarterItemPrefix", { fg = colors.muted })
set(0, "MiniStarterFooter", { fg = colors.muted, italic = true })
