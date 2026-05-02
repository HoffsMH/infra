# Agent orientation — full notes

Companion to `~/AGENTS.md`. The five-second summary lives there;
this file has the longer "you'll thank me when you hit it" version.

## YubiKey-backed SSH (extended)

The auth chain:

```
ssh client -> $SSH_AUTH_SOCK -> gpg-agent -> scdaemon -> YubiKey AUT subkey
```

Verified state across every shell context observed so far:

- `SSH_AUTH_SOCK` resolves to `/run/user/1000/gnupg/S.gpg-agent.ssh`
- `ssh-add -L` returns one identity ending in `cardno:<serial>`
- The github.com Host in `~/.ssh/config` has both `IdentitiesOnly yes`
  AND `IdentityFile ~/.ssh/id_yubikey_auth.pub` -- both required (see
  "Structural gotcha" below)
- `~/.ssh/id_yubikey_auth.pub` is a snapshot of the YubiKey AUT
  pubkey dumped via `ssh-add -L > ...`

### When auth fails

In order of likelihood:

1. **PIN cache expired.** `gpg-agent.conf` has `default-cache-ttl
   600`. After ~10 min idle, the next sign needs PIN re-entry +
   touch. Pinentry is `pinentry-gnome3` (Wayland-compatible GTK3).
2. **YubiKey not touched.** Touch policies are `CACHED-FIXED` --
   one tap unlocks for ~15s of subsequent sign ops.
3. **YubiKey unplugged.** `gpg --card-status` will say so.
4. **Pinentry can't draw.** Should be rare now -- there's an XDG
   autostart `~/.config/autostart/import-session-env.desktop` that
   runs `tmux.import-env system` on session start, pushing
   `WAYLAND_DISPLAY` / `DBUS_SESSION_BUS_ADDRESS` into the systemd
   user manager so gpg-agent's spawned pinentry-gnome3 can find the
   display. If pinentry isn't appearing, run
   `gpg-connect-agent updatestartuptty /bye` from a real terminal
   to push current TTY/DISPLAY into the agent.

### Don't reflexively

- **Don't** prefix commands with
  `SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"`. The env
  var is already inherited correctly in Claude's Bash tool. Past
  sessions did this constantly; it was placebo cargo-culting.
- **Don't** restart `gpg-agent.service` or `pcscd.service` as a first
  troubleshooting step. They're stateful: bouncing them invalidates
  the agent's view of the smartcard and creates more failures.
- **Don't** re-dump the pubkey, rewrite `~/.ssh/config`, re-run
  `setup-yubikey.sh`, or run `configure-yubikey.sh`. All already
  done; configure-yubikey.sh would actively wipe hardware policies
  on a YubiKey that's already correctly provisioned.

### Diagnose for real with

- `ssh-add -L` -- empty? Run
  `gpg-connect-agent "scd serialno" "learn --force" /bye` to make
  the agent re-discover the card.
- `gpg --card-status` -- shows what the YubiKey reports (serial,
  subkey fingerprints, touch policies, PIN retries).
- `ssh -vvv -T git@github.com 2>&1 | tail -40` -- the verbose log
  shows which keys SSH actually tried and what GitHub said back.
  Most "Permission denied" failures with this stack will say
  `agent returned 1 keys` followed by a sign attempt; if signing
  failed, you'll see `agent refused operation` (= YubiKey state).

### Structural gotcha (already fixed; don't undo)

`~/.ssh/config` declares `IdentitiesOnly yes`, which makes OpenSSH
*filter the agent's keys against on-disk pubkey files listed via
`IdentityFile`*. The YubiKey AUT subkey has no on-disk
representation by default, so it gets filtered out and SSH falls
through to trying `~/.ssh/id_{rsa,ecdsa,ed25519,...}` (which don't
exist), then errors with "Permission denied (publickey)".

Mitigation in place:

```
# ~/.ssh/config (symlinked from infra)
Host github.com
  User git
  IdentityFile ~/.ssh/id_yubikey_auth.pub
  IdentitiesOnly yes
  AddKeysToAgent yes
```

Plus `~/.ssh/id_yubikey_auth.pub` exists locally (per-machine; not
in infra; permissions 600). If it's missing on a fresh machine:

```bash
ssh-add -L > ~/.ssh/id_yubikey_auth.pub
chmod 600 ~/.ssh/id_yubikey_auth.pub
```

## Keyboard layer (extended)

Three modifier keys, three roles -- pick the right key for each
muscle-memory action.

| Physical key | After xremap | Used for |
|---|---|---|
| LeftAlt (1-left-of-space) | tap=Esc / hold=**Ctrl** | Mac Cmd-equivalent app shortcuts (Ctrl+C, Ctrl+V, Ctrl+W, Ctrl+T, Ctrl+F, etc.) |
| LeftCtrl + Caps (NuPhy firmware merges them into KEY_LEFTCTRL) | tap=Esc / hold=**Alt** | Shell readline M-keys (M-f forward, M-b back, M-d kill-word), Alt+hjkl arrow layer, Alt+Tab cycling |
| Win (KEY_LEFTMETA) | unchanged: **Super** | Omarchy's SUPER vocabulary; SUPER+drag mouse |
| RightAlt (1-right-of-space) | tap=RightAlt / hold=**HYPER chord** (Ctrl+Alt+Super) | Personal Hyprland layer prefix |

When porting Mac configs (ghostty, karabiner, aerospace), translate
`cmd -> alt` on the source side. The user's LeftAlt physical key
sends Ctrl, which is what you actually want for Mac-Cmd-equivalent
behavior on Linux.

His adjustments win over upstream defaults across the board. Not a
toggle, not negotiable -- the muscle memory is decades old.

Fuller breakdown in `keyboard/` here in this spec tree.

## Replay / bootstrap shape

The work-machine setup is a layered overlay on top of stock Omarchy:

- `~/.local/share/omarchy/**` is upstream / read-only
- `~/.config/**` is the user-side overlay; symlinked to infra where
  practical so the source-of-truth is in `~/infra/`
- A small set of installer scripts at
  `~/infra/assets/workstation/omarchy/setup-*.sh` replay the
  system-side bits (xremap, YubiKey stack)

`done.md` in this spec tree documents what each session accomplished
in chronological order. `todo.md` is the living queue.

## Past-session memory (Claude Code specific)

Claude Code auto-loads memory entries from
`~/.claude/projects/-home-mh/memory/`. Other agents won't see those.
The same critical content is in `~/AGENTS.md` and this file for
cross-agent visibility.

If you're a Claude Code agent in particular: the memory entries
relevant to this orientation are:

- `feedback_yubikey_auth_diagnosis.md`
- `feedback_use_trm_not_rm.md`
- `feedback_dont_auto_edit_repos.md`
- `user_keyboard_muscle_memory.md`
- `user_yubikey_already_provisioned.md`
