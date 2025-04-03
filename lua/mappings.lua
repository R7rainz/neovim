local wk = require("which-key")

local icons = {
  setting = "",
  lock = "",
  search = "",
  git = "",
  lsp = "󰂓",
  diag = "",
  magic = "",
  tree = "",
  success = "",
  failure = "",
  view = "󰈈",
}

local function map(mode, keys, action, desc, icon)
  desc = desc or ""
  local opts = { noremap = true, silent = true, desc = desc }
  vim.keymap.set(mode, keys, action, opts)

  if icon then
    wk.add({
      [keys] = { action, desc, icon = icon },
    })
  end
end

local M = {}
M.map = map

M.conform = function()
  map({ "n", "v" }, "<leader>mp", function()
    require("conform").format({
      timeout_ms = 1000,
      async = true, -- Optional: Runs formatting asynchronously
    })
  end, "[M]ake [P]retty", icons.magic)
end

M.oil = function()
  map("n", "-", "<cmd>Oil<CR>", "Project View (Netrw)")
end

return M -- Ensure the module is returned correctly
