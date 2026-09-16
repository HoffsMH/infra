# TODO — open work and parked ideas

When something here gets done, move it to `done.md` with the date and
keep its rationale.

## Infrastructure / portability

- **Enable syncthing user service** on fresh installs:
  `systemctl --user enable --now syncthing`. The package is installed
  but the user unit ships disabled by default.
- **Symlink remaining configs into infra**:
  - `~/.config/tmux/tmux.conf` (currently in-place)
  - `~/.zshrc` (currently in-place)
  - `~/.config/hypr/{monitors,input,looknfeel,autostart}.conf` (in-place)
  - Each move: write infra source-of-truth file, back up current,
    symlink. Same pattern as ghostty + personal.conf / omarchy-unbinds.conf.
- **Bootstrap automation**: build a small set of idempotent shell
  setup scripts for a fresh Omarchy install. Keep package installation,
  linking, and post-auth handoff separate enough to resume safely.
- **Wire `tmux.import-env` into Hyprland autostart** so tmux servers
  inherit Wayland/Hyprland env (`WAYLAND_DISPLAY`, `SSH_AUTH_SOCK`,
  `HYPRLAND_INSTANCE_SIGNATURE`, etc.):
  `exec-once = ~/bin/tmux.import-env tmux`.

## Keyboard / input

- **Tune xremap `alone_timeout_millis`** on left-of-space tap-Esc if
  150 ms ever fires Esc during fast typing. Bump to 200 ms.

## Hyprland

- **Decide on tab-style workspace nav under HYPER**: currently
  unbound (Omarchy SUPER+TAB family was opted out and not replaced).
  Add HYPER+Tab if an "alt-tab" feel is missed.
- **Watch `omarchy-update` audits**: each time it runs, review newly-
  added bindings in `~/.local/share/omarchy/default/hypr/bindings/*.conf`
  against `omarchy-unbinds.conf`. Add unbinds where new defaults
  conflict.
- **Review common and Omarchy helpers**: decide which shared helpers
  belong in `common/dotfiles/bin` and which Linux mechanics belong in
  the Omarchy overlay.

## Applications / tooling

- **Local model harness for Kimi K2** (see
  [applications/ai-tooling.md](applications/ai-tooling.md)).
- **Inventory hardware** (GPU, VRAM, RAM headroom) so the local-model
  decision can be sized properly.

## Documentation / specs

- **Fold remaining session changes into infra notes** (some are still
  in scratch markdown like `monitors.md`, `ghostty.md`
  at the top of `~/infra/assets/workstation/omarchy/`). Decide whether
  to merge them into the spec tree or keep as a separate "session
  journal" layer.
