# Done — audit trail of completed work

Most-recent first. Each entry is a short rule + the rationale that's
useful to remember later.

## 2026-04-29 / 2026-04-30 (initial buildout session)

### Display layout

- Monitor arrangement set explicitly: DP-1 (Gigabyte M32U, 4K) at
  `0x0` left, HDMI-A-1 (Acer ED323QUR, 1440p) at `3840x0` right, both
  at 144 Hz.
- DP-1 set as XWayland primary via
  `exec-once = xrandr --output DP-1 --primary` in `autostart.conf`.
  Why: XWayland-side primacy is what older X11 apps key off of; without
  this, app resolution dropdowns capped at 2560x1440.
- Default workspace placement: 1-5 on DP-1, 6-7 on HDMI-A-1, persistent.

### Keyboard remap layer

- xremap configured for the Mac-on-Linux modifier story:
  - `LeftAlt` -> tap=Esc / hold=Ctrl
  - `LeftCtrl` -> Alt
  - `RightAlt` -> tap=RightAlt / hold=HYPER chord (Ctrl+Alt+Super)
- Auxiliary thumb-pad input device rewritten to `Ctrl+<key>` via a
  device-scoped xremap `keymap` block.
- `Ctrl+H/J/K/L` -> arrow keys via xremap (left-of-spacebar arrow
  layer; `Ctrl` is what `LeftAlt` produces when held).
- `Alt+H/J/K/L` -> arrow keys also via xremap. Reason: Caps and
  bottom-left ctrl both send `KEY_LEFTCTRL` (NuPhy firmware merges
  them), then the modmap remaps `KEY_LEFTCTRL` -> Alt. Without an
  Alt-prefixed arrow rule, the caps key would not produce arrows.
  Tradeoff accepted: `M-l` (zsh `downcase-word`) is shadowed.

### Hyprland customization

- Click-to-focus enabled (`follow_mouse = 0`).
- Mac muscle memory bindings in `personal.conf`:
  - `Ctrl+Q` -> killactive (Mac Cmd+Q close window)
  - `Ctrl+Space` -> walker (Mac Cmd+Space app launcher)
  - `Super+Ctrl+Space` -> omarchy-menu (override of Omarchy's theme
    background submenu)
- HYPER personal layer for window navigation and workspace switching:
  - `HYPER+P` -> deck/maximize
  - `HYPER+J` / `HYPER+K` -> cycle next / previous window
  - `HYPER+Q/W/E/R` -> workspaces 1-4
  - `HYPER+5/6/7` -> workspaces 5/6/7
  - `HYPER+Shift+same` -> move active window to that workspace WITHOUT
    following (movetoworkspacesilent)
- Modular overlay structure adopted: `omarchy-unbinds.conf` (delta
  opt-outs) and `personal.conf` (declarative additions), both
  symlinked from `~/infra/.../omarchy/dotfiles/.config/hypr/`.
- `SUPER+1..0` workspace switch + `SUPER+SHIFT+1..0` move + tab-style
  workspace nav opted out via `omarchy-unbinds.conf`. SUPER+drag mouse
  intentionally kept for right-hand-on-mouse muscle memory.
- Tearing enabled globally (`general { allow_tearing = true }`) so
  per-window `immediate = 1` rules can take effect.
- VRR set to fullscreen-only (`misc { vrr = 2 }`).

### YubiKey + GPG-agent + SSH

- `setup-yubikey.sh` (idempotent installer in
  `~/infra/assets/workstation/omarchy/`) installs `yubikey-manager`,
  `yubikey-personalization`, `pcsc-tools`, `libfido2`; enables and
  starts `pcscd.service`; symlinks `~/.gnupg/gpg-agent.conf` and
  `~/.ssh/config` from infra; drops a starter gitignored
  `~/.ssh/config.local`.
- `yubikey/import-pubkey.sh` curls the pubkey from `mhkr.xyz/key.pub`,
  ultimate-trusts it, runs `scd serialno + learn --force` to register
  YubiKey-resident secret subkeys with the agent, reloads agent.
- `yubikey/configure-yubikey.sh` (commented as fresh-key-only;
  the user's primary YubiKey is already provisioned and should not be
  reconfigured).
- `gpg-agent.conf` uses `pinentry-program /usr/bin/pinentry-gnome3`
  (Arch ships pinentry 1.3.x with GTK3 only; pinentry-gtk-2 no longer
  exists).
- `~/.ssh/config` (in infra, symlinked) sources `~/.ssh/config.local`
  via `Include` for per-machine work-account / private host entries
  that are NOT in infra.
- Cross-DE-portable env-push via XDG autostart:
  `~/.config/autostart/import-session-env.desktop` (symlinked from
  infra) runs `tmux.import-env system && systemctl --user restart
  gpg-agent.service` at session start. Without this, gpg-agent
  inherits empty DISPLAY/WAYLAND_DISPLAY from systemd-user-manager,
  pinentry fails to draw a PIN dialog, and YubiKey-backed SSH auth
  silently dies with "Permission denied (publickey)". XDG autostart
  works in Hyprland (via uwsm), XFCE, GNOME, KDE, MATE -- so this
  survives a future DE switch.
- **`IdentitiesOnly yes` + YubiKey gotcha**: with `IdentitiesOnly yes`
  in `~/.ssh/config`, OpenSSH only considers identities whose pubkey
  file is listed via `IdentityFile`. The YubiKey's AUT subkey has no
  on-disk file representation by default, so it gets filtered out,
  even though `gpg-agent` is offering it. Fix: dump the agent's key
  to a file (`ssh-add -L > ~/.ssh/id_yubikey_auth.pub`) and add
  `IdentityFile ~/.ssh/id_yubikey_auth.pub` to the github.com Host
  block in ssh config.
- Infra git remote on SSH (`git@github.com:HoffsMH/infra.git`).

### Misc artifacts

- `runlog` (in `~/infra/.../common/dotfiles/bin/runlog`, symlinked to
  `~/bin/runlog`). Wraps a command, captures stdout/stderr to
  `<dir>/<dirname>-<rootcmd>.log`. Skips wrappers like `bundle`,
  `npx`, `sudo`. On PATH after symlink.
- Ghostty `Ctrl+V` paste binding (`unconsumed:ctrl+v=paste_from_clipboard`)
  added in infra so left-of-space + V pastes in the terminal.
- `g.http-to-ssh` symlinked from `~/infra/.../mac/dotfiles/bin/` into
  `~/bin/`. Converts a repo's `origin` from HTTPS to SSH in one
  invocation; cd into a repo and run.

### Snip / usnip pipeline

Cross-platform clipboard-snip workflow ported into
`common/dotfiles/bin/`, all symlinked into `~/bin/`:

- `snip` - reads clipboard, hashes, writes to
  `~/personal/00-cap-md/clip/<iso>-<sha>.md`. Notifies via desktop.
- `usnip` - fzf-pick a snip note, open in nvim **text-editor mode**.
- `uclip`, `clip` - cross-platform clipboard read/write
  (auto-detects Wayland / X11 / pbpaste/pbcopy).
- `notify` - cross-platform desktop notification wrapper
  (osascript on darwin, notify-send on linux).
- `iso-str`, `fif` - timestamps + interactive fuzzy file search.
- `~/personal/00-cap-md/clip/` directory created.

### Neovim

Detailed in [terminal/nvim.md](terminal/nvim.md). Highlights:

- Replaced Omarchy's stock LazyVim with the user's kickstart-derived
  config, symlinked from
  `~/infra/.../common/dotfiles/.config/nvim/`.
- Three modes (base / text-editor / ide) with aliases `eb` / `et` /
  `e` and per-binding mode picks (e.g. `^e` zle widget uses
  text-editor; tmux `prefix+u` capture uses base).
- Treesitter v1.0+ migration done in infra: `branch = 'main'`,
  `lazy = false`, new `install{}` + `vim.treesitter.start` autocmd
  pattern. Mac side fixed at the same time since both share common
  config.
- `vim-matchup` configured with
  `vim.g.matchup_treesitter_enabled = 0` (its treesitter integration
  broke against treesitter v1.0 -- mac fix).
- Go installed via asdf (`asdf plugin add golang && asdf install
  golang latest && asdf set -u golang latest`) so blink.cmp /
  treesitter parsers / etc. can build.

### Settings.json (Claude Code) and MCPs

- `~/.claude/settings.json` symlinked to
  `~/infra/assets/workstation/common/dotfiles/.claude/settings.json`
  so the same allowlist applies on every machine.
- `permissions.allow` includes
  `Read(//tmp/claude-clipboard-*/**)` (Linux temp pattern),
  `Read(//var/folders/*/*/T/claude-clipboard-*/**)` (mac temp),
  `Read(//private/var/folders/*/*/T/claude-clipboard-*/**)` (mac
  resolved), and
  `mcp__clipboard-paste-mcp__paste_clipboard_screenshot` so the MCP
  tool itself can fire without a permission prompt.
- `clipboard-paste-mcp` registered at user scope. Cross-platform
  refactor done in
  `~/code/unpaid/clipboard-paste-mcp/`: new `clip/` package abstracts
  `Reader` interface, picks `wl-paste` (Wayland) > `xclip` (X11) >
  native `golang.design/x/clipboard` (darwin/windows) at runtime.
  See `~/infra/specs/clipboard-paste-mcp.md` (top-level infra spec).

### Modes wired into commands

`~/.zshrc` aliases plus per-binding mode picks finalised:

| Trigger | Mode | What |
|---|---|---|
| `e` (alias) | ide | full-IDE nvim |
| `et` (alias) | text-editor | telescope + light editing |
| `eb` (alias) | base | gruvbox-only nvim |
| `^e` zle (`edit_command`) | text-editor | edit current shell command in nvim |
| `usnip` | text-editor | open a snip note |
| tmux `prefix + u` (capture pane) | base | view-only scrollback in nvim |

### Hyprland polish

- `border_size = 4` in `~/.config/hypr/looknfeel.conf` (default 2 was
  hard to see for the 4K monitor).
- `general { allow_tearing = true }` and `misc { vrr = 2 }` left in
  place from earlier (per-window tearing opt-in, fullscreen-only VRR).

### Conversation recovery

- Forked / abandoned conversation threads in Claude Code are
  recoverable from the on-disk transcript jsonl. See
  [transcript-recovery.md](transcript-recovery.md) for the procedure.

### Fonts (system-wide)

- `ttf-ibm-plex` and `ttf-ibmplex-mono-nerd` installed.
  - **BlexMono Nerd Font Mono** (the IBM Plex Mono fork from Nerd
    Fonts, with powerline / devicons / etc. baked in) is the default
    monospace.
  - **IBM Plex Sans / IBM Plex Serif** are the default sans-serif /
    serif.
- `~/.config/fontconfig/fonts.conf` (symlinked from infra) declares
  fontconfig aliases pinning `monospace`, `sans-serif`, `serif` to the
  faces above. This is the omarchy/Arch analog of nix's
  `fonts.fontconfig.defaultFonts` block.
- Apps that hard-code a font-family override these. Apps that use a
  generic family inherit. **Ghostty** uses `font-family = "monospace"`
  so it inherits BlexMono via fontconfig.
- `fc-match monospace` should resolve to `BlexMono Nerd Font Mono`.
- Pitfall: XML doesn't allow `--` (double-dash) inside comments. The
  fontconfig file uses single dashes only.

### Terminal stack

- Ghostty installed and made the default terminal via
  `omarchy-install-terminal ghostty`.
- Ghostty config ported from the Mac infra config with `cmd -> alt`
  translation discipline; symlinked from infra. Font bumped to size 13
  for the 4K monitor.
- tmux config ported from the Mac infra `.tmux.conf` with prefix flipped
  to `C-f` to match the Mac muscle memory after the keyboard remap.
- tmux helper scripts copied into `~/bin/`: `e.tmux-wrapper`,
  `lzg.tmux-wrapper`, `zsh.tmux-wrapper`, `tmux.sessionizer`,
  `tmux.hist`, `tmux.import-env`.
- zsh installed as login shell (`chsh -s /usr/bin/zsh`).
- `~/.zshrc` written for Arch (gracefully skipping missing tools);
  `~/.zsh/functions_and_aliases.sh` copied from the **common** variant
  in infra (newer than nix's variant).
- zsh deps installed: zoxide, fzf, lazygit, atuin, direnv, duf,
  zsh-fast-syntax-highlighting, zsh-autopair-git. fastfetch reused
  from Omarchy default install.
