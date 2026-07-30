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
- Use it when output will be too large for the context window AND
  you'll need to grep it repeatedly (test suites, builds, etc.).
- After running, **grep the log** instead of re-running the command.
- Don't blanket every command — just the noisy ones.

## Snip

- `snip [category]` saves the clipboard into
  `~/personal/00-cap-md/snip-<category>` (default `main`) as a
  timestamped, content-addressed file.
- Piped stdin overrides the clipboard and always saves as text:
  `echo "some plan" | snip plans`. Conventional categories: **`plans`**
  (hand-off plan docs) and **`prompt`** (agent launch prompts) -- see
  "Handing off work to another agent" below. Use this to save plans/notes
  for the user without touching their clipboard.

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

## Pi coding agent

Global pi config is symlinked from here via `set.links`:

```
~/infra/assets/workstation/common/dotfiles/.pi/agent/
├── settings.json              # shellCommandPrefix, provider, model
├── extensions/
│   ├── bash-permission.ts     # gate every bash command
│   ├── websearch-permission.ts # gate web search + fetch separately
│   └── content-sandbox.ts     # prompt-injection defense for web fetches
└── skills/
    └── brave-search/
        ├── search.js          # Brave Search API (needs BRAVE_API_KEY)
        ├── content.js         # URL → markdown (SSRF-hardened, 5 MB cap)
        └── package.json       # npm install on new machines
```

**New machine bootstrap:**
1. `set.links -n` — dry-run first to see what will be linked
2. `set.links -f` — force-replace all dotfiles with symlinks to infra
3. `cd ~/infra/assets/workstation/common/dotfiles/.pi/agent/skills/brave-search && npm install` — must be the infra realpath, NOT `~/.pi/...` (see Troubleshooting in that skill's SKILL.md)
3. Set `BRAVE_API_KEY` in `~/.envrc` (get from https://api-dashboard.search.brave.com/register — free tier, credit card required for verification)
4. `settings.json` sources `~/.envrc` via `shellCommandPrefix` before every
   bash command so the key is always available

**Session commands:**
- `/reset-permissions` — clear all bash + websearch whitelists

If this is in your context say "I read <full filepath here>" at the start of the session
