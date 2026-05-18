# Neovim Config

Personal Neovim setup focused on PHP/web development, LSP, Treesitter, Git, Telescope, snippets, and a small set of native replacements.

## Layout
- `init.lua`: loads the configuration modules in order.
- `lua/user/options.lua`: editor options, indentation markers, native folds, providers.
- `lua/user/keymaps.lua`: global keymaps and keymap documentation.
- `lua/user/plugins.lua`: lazy.nvim bootstrap and plugin loader.
- `lua/user/plugins/*.lua`: plugin specs grouped by responsibility.
- `lua/user/LSP/*.lua`: diagnostics, LSP capabilities, attach logic, and server enabling.
- `lsp/*.lua`: Neovim native LSP config files for servers that need dedicated overrides.

## Plugin Specs
Plugin declarations are split by category:

- `completion.lua`: `nvim-cmp`, snippets, completion sources.
- `editor.lua`: general editor helpers like autopairs and VimTeX.
- `git.lua`: Git UI helpers.
- `lsp.lua`: Mason, Mason LSP integration, LSP defaults.
- `navigation.lua`: Telescope and nvim-tree.
- `tools.lua`: AI assistant and database tools.
- `treesitter.lua`: Treesitter and Astro syntax support.
- `ui.lua`: colorscheme.

`lua/user/plugins.lua` should stay small. Add new plugins to the category file that best matches their purpose.

## LSP Notes
LSP setup uses Neovim's native API:

- `vim.lsp.config(...)` defines server-specific config.
- `vim.lsp.enable(...)` enables each server.
- `lua/user/LSP/on_attach.lua` adds buffer-local LSP keymaps and format-on-save.
- `lsp/*.lua` contains dedicated server config files for servers with larger overrides.

Avoid defining the same server in both `lua/user/LSP/lsp.lua` and `lsp/<server>.lua` unless you intentionally understand which values are being merged or overwritten.

## Keymaps
Leader is Space.

| Key | Mode | Action |
| --- | --- | --- |
| `<C-h>` | normal/terminal | Move to left split |
| `<C-j>` | normal/terminal | Move to lower split |
| `<C-k>` | normal/terminal | Move to upper split |
| `<C-l>` | normal/terminal | Move to right split |
| `<C-w>` | normal | Increase split height |
| `<C-s>` | normal | Decrease split height |
| `<C-f>` | normal | Decrease split width |
| `<C-a>` | normal | Increase split width |
| `<leader>w` | normal | Save file |
| `<leader>q` | normal | Close buffer/window |
| `<S-l>` | normal | Next buffer |
| `<S-h>` | normal | Previous buffer |
| `<leader>nt` | normal | Open nvim-tree |
| `j` / `k` | normal | Move by visual wrapped lines |
| `gj` / `gk` | normal | Move by real file lines |
| `<Tab>` | normal/visual | Increase indent |
| `<S-Tab>` | normal/visual | Decrease indent |
| `<A-j>` / `<A-k>` | visual/select | Move selected lines down/up |
| `p` | visual | Paste without replacing the default register |
| `gcc` | normal | Toggle comment on current line, native Neovim |
| `gc{motion}` | normal | Toggle comment over motion, native Neovim |
| `gc` | visual | Toggle comment over selection, native Neovim |
| `gcb` | normal/visual | Alias to native comment mapping |
| `<leader><leader>l` | normal | Open LazyGit in a full tab terminal |
| `<leader>T` | normal | Open terminal in bottom split |
| `<leader><leader>o` | normal | Enable spellcheck |
| `<leader><leader>O` | normal | Disable spellcheck |
| `<leader>f` | normal | Telescope files |
| `<C-t>` | normal | Telescope live grep |
| `<leader>lD` | normal | Telescope workspace diagnostics |
| `<leader>ld` | normal | Telescope buffer diagnostics |

## LSP Keymaps
These are buffer-local and only exist after an LSP attaches.

| Key | Action |
| --- | --- |
| `gl` | Open diagnostic float |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gr` | List references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |

## Completion Keymaps
These are active in insert/cmdline mode through `nvim-cmp`.

| Key | Action |
| --- | --- |
| `<C-j>` | Next completion item |
| `<C-b>` | Scroll docs up |
| `<C-f>` | Scroll docs down |
| `<C-Space>` | Trigger completion manually |
| `<C-leader>` | Trigger completion manually |
| `<C-e>` | Abort/close completion |
| `<CR>` | Confirm selected item |
| `<Tab>` | Next item, expand snippet, or jump snippet |
| `<S-Tab>` | Previous item or jump snippet backwards |

## Git Keymaps
These are buffer-local and come from `gitsigns.nvim`.

| Key | Action |
| --- | --- |
| `]c` / `[c` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo staged hunk |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>tb` | Toggle current line blame |
| `<leader>hd` | Diff current file |
| `<leader>hD` | Diff against previous revision |
| `<leader>td` | Toggle deleted lines |
| `ih` | Hunk text object in operator/visual mode |

## Native Movement Instead Of EasyMotion
This config removed EasyMotion in favor of native motions:

- `/` and `?`: search forward/backward.
- `n` and `N`: repeat search forward/backward.
- `*` and `#`: search word under cursor forward/backward.
- `f`, `F`, `t`, `T`: jump within current line.
- `;` and `,`: repeat line jumps forward/backward.
- `%`: jump between matching pairs.

## Native Folds
Folds use Treesitter through Neovim's native fold expression.

| Key | Action |
| --- | --- |
| `za` | Toggle fold under cursor |
| `zo` | Open fold |
| `zc` | Close fold |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open one recursive level |
| `zm` | Close one recursive level |

## Emmet In PHP
`emmet_ls` is enabled for `php`, so HTML abbreviations can work inside PHP templates. If `!` does not appear automatically, type `!` and trigger completion with `<C-Space>`.

## Maintenance
- Run `:Lazy sync` after changing plugin specs.
- Run `:Mason` to inspect installed LSP/tools.
- Use `:checkhealth` after large changes.
- Keep plugin declarations in `lua/user/plugins/*.lua`, not in config modules.
