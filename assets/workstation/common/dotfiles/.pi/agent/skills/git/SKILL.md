---
name: git
description: Git operations via dedicated permission-gated tools. Use for git status, diff, log, show, fetch, branch, remote, ls-files, add, pull --ff-only, and stash. NEVER use bash for git commands — the bash gate blocks them. ALWAYS use the git_* tools from this skill.
disable-model-invocation: false
---

# Git

All git operations go through dedicated `git_*` tools with their own
permission dialog.  **Do NOT use the bash tool for git** — bash is
configured to reject any command that invokes `git`.

## Available tools

### Read operations (safe — no side effects)

| Tool | What it does |
|------|-------------|
| `git_status` | Working tree status (porcelain + branch info) |
| `git_diff` | Show changes. Pass `args: "--staged"` for staged changes |
| `git_log` | Commit history. Pass `args: "--oneline -n 10"` for compact |
| `git_show` | Inspect a commit/ref. Pass `args: "HEAD"` or a SHA |
| `git_fetch` | Download remote objects (never modifies working tree) |
| `git_branch` | List branches. Pass `args: "-a"` for all remotes |
| `git_remote` | Show remote URLs |
| `git_ls_files` | List tracked files |

### Write operations (requires permission)

| Tool | What it does |
|------|-------------|
| `git_add` | Stage files. Pass `args: "<path>"`. Does NOT commit |
| `git_pull_ff` | Fast-forward pull. Safe — rejects if merge needed |
| `git_stash` | Stash changes. Pass `args: "push"`, `"pop"`, or `"list"` |

## Git rules (from AGENTS.md)

These rules are enforced by the tools:

- **Never** commit, push, rebase, or reset --hard.
  (These tools don't exist — use them and you'll fail.)
- `git status`, `git diff`, `git log`, `git fetch`, `git remote -v`,
  `git show <ref>`, `git ls-files` are always OK.
- `git add <path>` is allowed; the user reviews and commits themselves.
- `git pull --ff-only` is allowed with permission.

If you need to do something not covered by these tools (like `git blame`
or `git grep`), ask the user to run it manually.
