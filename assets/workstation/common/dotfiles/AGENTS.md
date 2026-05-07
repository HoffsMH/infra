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
   his shells. **Agents: use `\rm` (or `command rm` / `rmdir`).** Do
   NOT use `trm` from agent shells -- it's an interactive trash helper
   that doesn't accept `-rf` and runs `du` on its argument, so common
   agent invocations fail. `trm` is for the user, `\rm` is for agents.

3. **Work GitHub via SSH host alias.** Personal `github.com` is bound
   to the YubiKey AUT subkey. The work account (matt-h-sage, orgs like
   `Anvyl`) uses a separate key under the `github.com-work` Host alias
   defined in `~/.ssh/config.local`. Clone work repos with
   `git@github.com-work:<org>/<repo>.git` (NOT `github.com:` and NOT
   `gh repo clone` -- the latter rewrites to `github.com:` and routes
   through the YubiKey, which will refuse). Push URLs use the same
   `-work` host, so cloning that way also fixes future pushes.

4. **Mac-on-Linux keyboard.** Left-of-spacebar physical key sends
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

## Runlog

- `runlog` (in `~/bin`) pipes a command's stdout+stderr to
  `../<dirname>-<command>.log`, skipping wrapper commands (bundle,
  npx, yarn, etc.) when naming the file.
- Use it when output will be too large for the context window AND
  you'll need to grep it repeatedly (test suites, builds, etc.).
- After running, **grep the log** instead of re-running the command.
- Don't blanket every command — just the noisy ones.

## Testing

- **Never trust a test you haven't seen fail.** If you write a test
  that passes on the first run, break or comment out the code you
  think makes it pass, then verify it fails for the right reason
  before restoring.

## Shell

- Commands run in `bash`, but the interactive shell is `zsh` where all
  aliases, functions, and some PATH additions live.
- Most utilities (`runlog`, `trm`, etc.) are standalone scripts in
  `~/bin/` or `~/.local/bin/` — they work in either shell.
- When adapting commands the user pastes from their zsh session,
  strip zsh-specific syntax/aliases and translate to bash equivalents.

## Detail

Full notes (more YubiKey diagnostic recipes, the `IdentitiesOnly +
IdentityFile` gotcha, replay/bootstrap flow, etc.) live at:

- [`~/infra/assets/workstation/omarchy/specs/agent-orientation.md`](infra/assets/workstation/omarchy/specs/agent-orientation.md)

Read that before you touch anything load-bearing.
