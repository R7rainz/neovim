-- Gruvbox light, soft contrast, on its own cream background. Unlike the dark themes it is not
-- transparent: a dark terminal showing through would put dark text on a dark background.
-- gruvbox.load() is called directly (not :colorscheme gruvbox) so no second ColorScheme event fires.
vim.o.background = "light"
local gruvbox = require("gruvbox")
gruvbox.setup({ contrast = "soft", transparent_mode = false })
gruvbox.load()
-- Back to the dark default from plugins.lua, so :colorscheme gruvbox stays transparent.
gruvbox.setup({ contrast = "hard", transparent_mode = true })
vim.g.colors_name = "gruvbox-light"
