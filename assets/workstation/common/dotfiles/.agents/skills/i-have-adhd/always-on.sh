#!/usr/bin/env sh
# SessionStart hook: prints the i-have-adhd ruleset into context when the
# opt-in flag exists. Delete the flag to go back to on-demand /i-have-adhd.
# Never blocks session start: every failure path exits 0.

flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.i-have-adhd-always"
[ -f "$flag" ] || exit 0

skill="$(dirname -- "$0")/SKILL.md"
[ -f "$skill" ] || exit 0

# Drop the leading YAML frontmatter block.
body=$(awk 'NR==1 && /^---[[:space:]]*$/ {fm=1; next} fm && /^---[[:space:]]*$/ {fm=0; next} !fm' "$skill") || exit 0

printf 'ADHD MODE ACTIVE (always-on). The ruleset below applies to every response. "stop adhd mode" turns it off for this session; delete %s to turn always-on off for good.\n\n%s\n' "$flag" "$body"
