# nvim2

A clean Neovim 0.12+ IDE configuration for Omarchy: native `vim.pack`, native
LSP/completion, Treesitter, four-space indentation, a Japanese dashboard, safe
project sessions, and a small dark theme set.

There is no `lazy.nvim`, Packer, or Mason.

## Features

- Omarchy, Vague, and Rosé Pine (dark) colorschemes; no light themes or theme bundle.
- The selected dark theme persists across restarts.
- Native LSP for Lua, TypeScript/JavaScript, React/Next.js, HTML/CSS/JSON, Go,
  C, and C++.
- Safe completion: the first LSP result is highlighted, not inserted; Enter
  accepts it and Space keeps your own text.
- Treesitter highlighting, folding, indentation, diagnostics, and inlay hints.
- Prettier, StyLua, clang-format, gofmt, format-on-save, and ESLint LSP.
- MiniFiles project-root explorer, MiniPick search/live grep, Flash jumps,
  Japanese dashboard, Discord presence, and automatic project sessions.
- Starship/tmux-inspired statusline and tabline.

## Requirements

- Neovim 0.12 or newer
- Git, `rg`, and `fd`
- `tree-sitter` CLI and the language tools you use

On Omarchy/Arch, the baseline tools are:

```sh
omarchy pkg add tree-sitter-cli lua-language-server stylua clang
npm install -g @vtsls/language-server typescript \
  vscode-langservers-extracted @tailwindcss/language-server prettier
go install golang.org/x/tools/gopls@latest
```

## Install

Back up an existing configuration, then clone this repository as
`~/.config/nvim`:

```sh
mv ~/.config/nvim ~/.config/nvim.backup-$(date +%Y%m%d-%H%M%S)
git clone <repository-url> ~/.config/nvim
nvim
```

The first launch downloads the plugins declared in `lua/config/plugins.lua` and
installs the configured Treesitter parsers. Internet access is only needed for
that initial install and later updates.

## Essential keys

The leader is Space. Press `<Space>?` at any time for the complete in-editor
reference; press `<Space>` and wait for the which-key popup for a quick menu.

| Key | Action |
| --- | --- |
| `<Space><Tab>` | Project-root file explorer |
| `<Space>ff` | Find files |
| `<Space>fw` | Live grep |
| `<Space>fP` | Search project directories |
| `<C-h/j/k/l>` | Move between panes |
| `<Space>w/` / `<Space>w-` | Vertical / horizontal split |
| `gd` / `gr` / `K` | Definition / references / hover docs |
| `<Space>cf` | Format the current buffer |
| `<C-Space>` | Trigger completion |
| `<CR>` | Accept the highlighted completion |
| `<Space>ss` / `<Space>sl` | Save / restore project session |
| `<Space>pu` | Update plugins |
| `<Space>hd` | Open the full manual |

Inside MiniFiles, `Enter` opens a file and closes the explorer, `l` enters a
directory, and `h`/`H` move upward without leaving the project root.

Launching `nvim .` restores that project's saved buffers and layout, then saves
them again on exit.

## Plugin management

Plugins are declared directly in `lua/config/plugins.lua` and locked in
`nvim-pack-lock.json`.

```vim
:lua vim.pack.update()
:lua vim.pack.update(nil, { offline = true })
:lua vim.pack.del({ "plugin-name" })
```

For a new plugin, add its source to `vim.pack.add({...})`, add its setup beside
the existing setup calls, then restart Neovim. Do not edit the lockfile by hand.

## Customization

| File | Purpose |
| --- | --- |
| `init.lua` | Startup order and default theme |
| `lua/config/options.lua` | Editor options and indentation |
| `lua/config/plugins.lua` | Plugins, UI, formatting, Treesitter |
| `lua/config/lsp.lua` | Language servers, completion, diagnostics |
| `lua/config/keymaps.lua` | Keybindings and user commands |
| `lua/config/sessions.lua` | Project session naming and restore/save |
| `lua/config/ui.lua` | Dashboard |
| `colors/omarchy.lua` | Omarchy palette and highlights |

For the complete operational reference, run:

```vim
:ConfigDocs
:help nvim2-keymaps
:checkhealth nvim2
```

## Updating safely

```sh
git -C ~/.config/nvim pull --ff-only
nvim
```

Then run `:checkhealth nvim2` and `:checkhealth vim.lsp` if a tool or plugin
was changed.
