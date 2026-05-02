# Neovim

Custom kickstart-derived configuration. **Not** Omarchy's stock LazyVim;
this host's `~/.config/nvim` is symlinked to the source-of-truth at
`~/infra/assets/workstation/common/dotfiles/.config/nvim/`. Mac shares the
same target, so fixes flow to both platforms.

## Three modes

The config has three different entry points loading different plugin
sets, so commands can pick the lightest mode that fits.

| Mode | Plugins | When to use |
|---|---|---|
| **base** | gruvbox theme only | View-only / pane scrollback |
| **text-editor** | telescope + small editing set | Notes, prose, command-line editing |
| **ide** | full kickstart-style IDE (~30 plugins: LSP, treesitter, mason, blink.cmp, oil, gitsigns, noice, which-key, flash, etc.) | Code editing |

Source files in the config:

```
init.lua                          -> require('ide')           (default mode)
lua/ide.lua                       -> deps/ide.lua             (also pulls deps/text-editor.lua plugins)
lua/text-editor.lua               -> deps/text-editor.lua
lua/base.lua                      -> deps/base.lua
lua/settings.lua                  -> shared options (leader=Space, etc.)
lua/keymap.lua                    -> small wrapper over vim.keymap.set
lua/deps/ide.lua                  -> ~30 IDE plugin specs
lua/deps/text-editor.lua          -> ~10 telescope-centered specs
lua/deps/base.lua                 -> just gruvbox
```

## Mode-specific commands

Aliases in `~/.zsh/functions_and_aliases.sh`:

| Alias | Mode | Resolves to |
|---|---|---|
| `e` | ide | `nvim` |
| `et` | text-editor | `nvim -u $HOME/.config/nvim/lua/text-editor.lua` |
| `eb` | base | `nvim -u $HOME/.config/nvim/lua/base.lua` |

Per-binding mode picks (chosen so each command runs the lightest mode
that fits its purpose):

| Trigger | Mode | What it does |
|---|---|---|
| `^e` in zsh (`edit_command` zle widget) | text-editor | Opens current shell command line in nvim for editing |
| `usnip` | text-editor | Picks a snip note from `~/personal/00-cap-md/clip/` and opens it |
| tmux **prefix + u** (`bind-key u`) | base | Captures pane scrollback to `/tmp/tmux-capture` and opens for vim-yank |

This per-command tiering came in the Apr 30 sweep; rationale: editing a
shell command doesn't need LSP, scrolling pane history doesn't need
telescope, etc.

## Treesitter v1.0 incompatibility

The 2025 v1.0 release of `nvim-treesitter` (default branch `main`)
**removed the `nvim-treesitter.configs` Lua module** that this config
uses for `setup()`. Without a pinned version, lazy.nvim grabs the v1.0
default and the config dies on startup with:

```
module 'nvim-treesitter.configs' not found
```

Fix in `lua/deps/ide.lua`: pin the legacy v0.x line by adding
`branch = 'master'` to the `nvim-treesitter` plugin spec. The `master`
branch keeps the v0.x API.

This is also why the config was broken on mac at the time of the port:
both platforms hit the same v1.0 upgrade. Pulling the infra fix on mac
resolves it there too.

## Bootstrap

On a fresh machine, after `~/.config/nvim` is symlinked:

```bash
nvim --headless "+Lazy! sync" +qa     # bootstrap lazy.nvim, install all plugins
```

Treesitter parsers download on first use (or via `:TSUpdate` /
`:TSInstall <lang>`). LSP/formatters are managed by `mason.nvim`;
mason-tool-installer auto-installs the configured set on first run.

## Plugin lock

`lazy-lock.json` is **not** checked in under
`infra/.../common/dotfiles/.config/nvim/`. Without it, every machine
bootstraps to whatever's at `main`/`master` of every plugin at install
time. That's how the treesitter v1.0 break hit; a checked-in
lazy-lock.json would have prevented it.

**TODO**: add `lazy-lock.json` to the repo (as part of bootstrap
hardening). Each machine writes its own when `Lazy! sync` runs;
committing the one from a known-good state acts as a reproducibility
floor across machines.
