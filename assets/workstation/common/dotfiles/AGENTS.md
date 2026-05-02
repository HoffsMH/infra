# Agent orientation — read first

Things that have repeatedly tripped past sessions up. Five-second
internalize, then read the full doc linked at the bottom before
debugging anything.

## Load-bearing

1. **YubiKey-backed SSH.** `git pull` / `ssh -T` failures are almost
   always YubiKey state (PIN cache expired, key needs touch), NOT
   wiring. Don't prefix commands with `SSH_AUTH_SOCK=$(...)` --
   already inherited correctly. Don't restart `gpg-agent` or `pcscd`.
   First move when auth fails: ask the user to touch the YubiKey.

2. **`rm` is aliased** to print "use trm". Bash `rm <path>` no-ops in
   his shells. Use `\rm`, `command rm`, `rmdir`, or `trm`.

3. **Mac-on-Linux keyboard.** Left-of-spacebar physical key sends
   Ctrl (Mac Cmd-equivalent on Linux) via xremap. Caps + bottom-left
   ctrl send Alt (shell readline M-keys, Alt+hjkl arrows). Right-of-
   spacebar is a HYPER chord (Ctrl+Alt+Super). When porting Mac
   configs, translate `cmd -> alt` on the source side.

## Spec tree

`~/infra/assets/workstation/omarchy/specs/` — workstation (employer-
facing-adjacent). Mac/Linux dev setup, keyboard, Hyprland, terminal,
etc. `README.md` and `philosophy.md` at the root.

## File-edit rules

- `~/.config/**` — runtime config; editing in place is fine.
- `~/infra/**` — curated source-of-truth; draft + propose, let user
  apply.
- `/etc/**` — write to `/tmp/<file>`, give user `sudo install ...`.

## Git rules

- **Never run `git commit`, `git commit --amend`, `git commit -a`,
  or any other commit-creating invocation.** No exceptions. The user
  reviews and commits themselves.
- Same for `git push`, `git push --force`, `git rebase` (any flavor
  that rewrites history), and `git reset --hard`.
- OK to run on your own: `git status`, `git diff`, `git log`,
  `git fetch`, `git remote -v`, `git show <ref>`, `git ls-files`.
- OK to run with permission / when explicitly asked: `git add <path>`
  (staging is fine; user will inspect before committing), `git pull
  --ff-only` (fast-forward only, no merge commits).
- When you finish a chunk of work, summarize the changes and let the
  user run the commit. Optionally draft a commit message they can
  copy-paste, but don't run the commit yourself.

## Detail

Full notes (more YubiKey diagnostic recipes, the `IdentitiesOnly +
IdentityFile` gotcha, replay/bootstrap flow, etc.) live at:

- [`~/infra/assets/workstation/omarchy/specs/agent-orientation.md`](infra/assets/workstation/omarchy/specs/agent-orientation.md)

Read that before you touch anything load-bearing.
