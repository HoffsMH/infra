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

## Reply length

- Abbreviation: ri <time> <prompt>
  - means keep your answer to this prompt readable in <time> timeframe
  - so ri 10 seconds summarize this file means give me a summary of this file
    that is readable in 10 seconds
  - If I simply say ri 15 seconds It means summarize what you are already trying
    to tell me in 15 seconds

- In general any reply you give use should not be over a 1 minute read if user 
  wants more detail they will ask but in general user will prefer not to have
  keep track of 20 parked questions as they read through your 5 minute read to 
  to see if they answer any of those questions


## File-edit rules

- `~/.config/**` — runtime config; editing in place is fine.
- `~/infra/**` — curated source-of-truth; draft + propose, let user
  apply.
- `/etc/**` — write to `/tmp/<file>`, give user `sudo install ...`.

### Comment style

My policy for comments, in every repo. Applies to comments you
**write or rewrite**.

- **Short.** A comment earns its length by saying what the code
  can't. Pare rather than pad.
- **Self-contained.** No out-of-band referents: no cross-repo
  `file:line`, no dates, no "verified against the dev server",
  no PR/ticket narrative. In-repo pointers (a sibling test, a
  `file:line` in this repo) are fine.
- **No archaeology.** Comments describe the code as it is now.
  Never "an earlier version of this said X", never a changelog
  of the comment or of the diff that produced it.
- **No shouting, no emoji, ASCII only.** No ALL-CAPS emphasis
  (acronyms like `RFQ` are fine), no box-drawing rules, no
  em-dashes or curly quotes.

- **Don't over-reach in shared repos.** This is my policy, not the
  repo's. Where other contributors' comments don't follow it, leave
  them alone -- no sweeps, no drive-by rewrites of comments your
  change didn't touch. Rewrite a pre-existing comment only when I
  ask, or when your change made its claim false. If the repo has a
  real convention that conflicts, follow the repo and tell me.

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

## GitHub / outward-facing writes

- **Never post to GitHub on my behalf — sister rule to
  never-commit/never-push.** No PR or issue comments, no review
  comments, no review submissions (approve / request-changes /
  comment), no thread replies, reactions, or edits to PR/issue
  titles, bodies, labels, or assignees -- via `gh`, the REST/GraphQL
  API, an MCP server, or any other tool. **Absolute: no exceptions,
  work repo or personal, and never "ask then do it."** If you have
  something to say on a PR, write it in chat and I post it.
- **Read-only GitHub is fine** and encouraged: `gh pr
  view/list/diff/checks`, `gh run view`, `gh api` GET requests.
  Anything that writes or mutates (comment, review, merge, close,
  reopen, label, assign, edit, create) is mine to run.
- Same spirit for every other outward channel -- Slack, email,
  Asana/Jira comments, etc.: draft it in chat; I send it.

## Runlog

- `runlog` (in `~/bin`) pipes a command's stdout+stderr to
  `../<dirname>-<command>.log`, skipping wrapper commands (bundle,
  npx, yarn, etc.) when naming the file.
- Use it when output will be too large and would pollute the context window AND
  you'll need to grep it repeatedly (test suites, builds, etc.).
- After running, **grep the log** instead of re-running the command.
- Don't blanket every command — just the noisy ones.

## Snips and screenshotting

- `snip [category]` saves the clipboard into
  `~/personal/00-cap-md/snip-<category>` (default `main`) as a
  timestamped, content-addressed file.
- Piped stdin overrides the clipboard and always saves as text:
  `echo "some plan" | snip plans`. Conventional categories: **`plans`**
  (hand-off plan docs) and **`prompt`** (agent launch prompts) -- see
  "Handing off work to another agent" below. Use this to save plans/notes
  for the user without touching their clipboard.

- `ss` means inspect my recent screenshot run in
  `~/personal/00-cap-md/snip-screenshot/`. Start with the newest and work
  backward until timestamps, image content, or this conversation show where
  the run began. Inspect every relevant image, including saved annotations.
  State the oldest screenshot included and why you stopped there.
  `ss <category>` uses `snip-<category>` instead.
- `sf <category>` means inspect the newest file in `snip-<category>`.
- `ssc` means inspect the current clipboard image.

### `ssc` clipboard-image workflow

- `ssc` means: inspect the current image in the system clipboard. If it
  starts a longer prompt, inspect the image before investigating the rest.
- `ssc` reads the live system clipboard; `ss` reads saved files.
- Do not ask what `ssc` means.
- `ssc` does not imply archiving. Prefer direct inspection:
  1. Use the cross-platform helper:
     `ext="$(iclip type)" && iclip save "/tmp/omp-clipboard.${ext}"`
  2. Verify the file is nonempty.
  3. Use the image-capable `read` tool on the saved path.

- If `iclip type` or `iclip save` fails, stop and report that no clipboard
  image is available. Do not inspect an existing file at the target path.
- Chain clipboard capture and validation with `&&`, not `;`, and use a fresh
  temporary path when possible.
- Prefer `iclip` because it abstracts Wayland, X11, and macOS clipboard
  implementations. Use a platform-specific command only if `iclip` is
  unavailable.
- Do not use text clipboard APIs or send binary image data through a text
  pathway.
- The screenshot shortcut and notification editor save directly to
  `snip-screenshot`; do not archive those captures again. Use `snip screenshot`
  only for a clipboard image that has not already been saved.
- When using `snip screenshot`, invoke it directly with no piped stdin:
  `snip screenshot`
- Never pipe binary image output into `snip` or an equivalent text pathway.
  Piped stdin forces `snip` into its text-input path.
- Do not substitute a newly captured desktop screenshot for the requested
  clipboard image.


## Handing off work to another agent (plan / prompt / command)

For substantial multi-step work -- or any work on a branch/repo/tool the
user drives themselves -- don't just start editing. Package it as a
hand-off the user can launch in a fresh agent, and let THEM launch it:

1. **Write a plan file** in the project's plans dir (e.g. a repo's
   `specs/**/plans/<name>.md`): the problem, the concrete steps with
   `file:line` cites, what's in/out of scope, who runs what, and how to
   verify. Save a copy: `cat plan.md | snip plans`.
2. **Write a launch prompt** and save it: `cat prompt.md | snip prompt`.
   A good hand-off prompt has: `study` lines (which files to read first --
   a project may ship a template, e.g. a `PROMPT-*-TEMPLATE.md`); a
   one-line scoped task; an IMPORTANT block of constraints; and a "work one
   file/step at a time, then STOP for me to inspect" instruction.
3. **Give the user a launch command**, don't run it yourself:
   `cd <repo> && cat <snip-prompt-file> | claude`. The user drives
   launching; do not spawn nested agents unless explicitly asked.

Constraints every hand-off prompt should carry (they mirror my standing
rules): the USER owns all git (commit/push/rebase) and typically build /
server / DB -- the agent edits code and asks the user to run those; never
post to GitHub; never trust a test you haven't seen fail; cite only
`file:line` actually opened. State the who-runs-what boundary explicitly so
the sub-agent doesn't run git or a build.

Iterate on a hand-off by editing the plan/prompt and re-snipping (a fresh
timestamped file); hand the user the newest command.

## Testing

- **Never trust a test you haven't seen fail.** If you write a test
  that passes on the first run, break or comment out the code you
  think makes it pass, then verify it fails for the right reason
  before restoring.

## Coding: New code

## Shell

- Commands run in `bash`, but the interactive shell is `zsh` where all
  aliases, functions, and some PATH additions live.
- Most utilities (`runlog`, `trm`, etc.) are standalone scripts in
  `~/bin/` or `~/.local/bin/` — they work in either shell.
- When adapting commands the user pastes from their zsh session,
  strip zsh-specific syntax/aliases and translate to bash equivalents.

## Machine-specific

`~/AGENTS-MACHINE.md` — machine-specific overrides, additions, and
reference material that supplement this orientation. If the file
exists, read it after this one.

## Agent config, infra, and dotfile lifecycle

Agent config lives in `~/infra/assets/workstation/common/dotfiles/` --
`.pi/agent/` (settings, extensions, skills), `.agents/skills/`, and this file
itself. Skills are ours: written or adapted here, edited in one place, never
pulled from a checkout that can change under us. `links.set` mirrors every
**file** in that tree as a symlink under `$HOME`, so each skill is one real
infra copy, edited there, never through a symlink path. Adding a skill on a
new machine is `links.set -f`, plus a directory symlink for any harness that
needs one (Claude Code reads `~/.claude/skills`, not `~/.agents/skills`).

Use the lifecycle in this order:

1. `links.scan` inspects symlinks and candidates without changing anything.
2. `links.prune` previews dangling infra links; `--apply` removes only those
   links and requires an explicit user request.
3. `links.adopt FILE` adopts one regular home file into the detected platform
   overlay. Use `--dry-run` when the result has not already been reviewed.
4. Review the platform copy. Promotion to common is a separate manual decision
   for each file; agents must not infer or automate it.
5. `links.set` links common first and the detected platform second. Use `-f`
   only when replacement of every reported target is intended.

Never overwrite an existing common or platform dotfile during adoption.
`links.adopt` must no-op on either collision and on directories, special files,
existing symlinks, outside-home paths, or files already within infra. Do not
bypass these checks with `cp`, `mv`, or `ln`. Edit an existing infra source in
place only when the user explicitly asked for that content change.

Not everything under `~/.pi`, `~/.claude`, or `~/.agents` is infra-managed. A
real file where a symlink should be is unversioned aftermarket; audit before
trusting it.

**Every skill must carry a boundaries block** repeating the rules above it
could break: no external posting, no git writes, I own builds and
verification, generated notes go to the nearest parent `specs/`. Third-party
skills routinely violate all four -- read before installing, neuter in place.

Installed: `research`, `domain-modeling`, `grilling`, `git`, `grill-me`,
`youtube-summarizer`, `brave-search` (all infra-backed), and `omarchy`
(Omarchy install, linked outside infra).

================================================================================

If this is in your context say "I read <full filepath here>" at the start of the session
