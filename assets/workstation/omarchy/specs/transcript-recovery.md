# Recovering a forked / lost Claude Code conversation

Claude Code lets you "rewind" a conversation to an earlier message and
continue from there. When you do, the conversation tree branches: the
current live thread is one branch; the abandoned content is another.
Both branches live in the same on-disk transcript file. **The abandoned
branch's text is recoverable indefinitely as long as the transcript file
is kept.**

This spec is what you (or a future agent) should consult if it feels
like the live thread is "missing context" that you remember discussing.

## Where transcripts live

Claude Code stores one JSONL transcript per project session under:

```
~/.claude/projects/<sanitized-cwd>/<session-uuid>.jsonl
```

Where `<sanitized-cwd>` is the working directory with slashes converted
to dashes. For example, sessions started in `~/` map to
`~/.claude/projects/-home-mh/`. Sessions started in `~/infra` map to
`~/.claude/projects/-home-mh-infra/`. Each `<session-uuid>.jsonl` file
contains every message exchanged in that session, including all forks
that ever happened in that session.

To enumerate them:

```bash
ls -lat ~/.claude/projects/*/*.jsonl
```

Sort by mtime to find the most recent.

## Format

Each line is a single JSON object. Relevant fields:

| Field | Notes |
|---|---|
| `type` | `user`, `assistant`, `system`, `file-history-snapshot`, `attachment`, ... |
| `uuid` | This message's unique id |
| `parentUuid` | Id of the message this one replies to. Builds a tree. |
| `timestamp` | ISO-8601 UTC |
| `message.content` | Either a string or an array of content blocks. Text content is at `.message.content[].text` (when array) or `.message.content` (when string). |
| `message.role` | `user` / `assistant` (when type is `user` or `assistant`) |

A **fork point** is any message whose `uuid` appears as the `parentUuid`
of two or more child messages. The branch that leads to the most-recent
file message is the "live" branch; the others are abandoned.

## Recovery procedure

1. **Find the fork points.**

   ```bash
   F=~/.claude/projects/-home-mh/<session-uuid>.jsonl
   jq -r '. | select(.parentUuid != null) | .parentUuid' "$F" \
     | sort | uniq -c | awk '$1 > 1 { print $2 }'
   ```

   Each line is a parent uuid that has multiple children (a fork point).

2. **Find the most-recent (live) message.**

   ```bash
   tail -1 "$F" | jq -r '.uuid // empty'
   # (or trace from the user's CURRENT prompt's parentUuid backward)
   ```

3. **For each fork point, walk both subtrees.**

   The subtree containing the live message is the live branch; the other
   subtrees are abandoned. Walking is just BFS/DFS on the `parentUuid`
   index.

4. **Dispatch the heavy reading to a sub-agent.** The transcript is
   typically 1k+ messages, several MB. Use the `Agent` tool with
   `subagent_type: general-purpose` and ask it to:
   - Build the parent->children index
   - Identify abandoned subtrees
   - Render the abandoned subtree(s) as readable markdown into
     `/tmp/recovered-fork.md`
   - Return a short summary

   Hand-roll this in the parent context only if the file is small or
   you only need a few specific messages.

## Loss model

- **Persistent on disk:** the JSONL transcript itself; any files on
  disk that were Written/Edited in the abandoned branch (those changes
  applied to the filesystem in real time and survive).
- **Lost to the live agent's context (but still recoverable from the
  jsonl):** the conversation text of the abandoned branch, including
  user prompts, assistant explanations, and intermediate decisions.
- **Truly lost:** task list state changes that the abandoned branch
  made via `TaskCreate` / `TaskUpdate` are kept centrally (Claude
  Code's task store is shared across forks within a session), so they
  generally survive forks. Verify by checking the live thread's task
  list against the recovered branch's task references.

## Forward-looking habits

- **Periodically commit the philosophy of "every adjustment leaves an
  artifact in infra"** (see [philosophy.md](philosophy.md)). The more
  decisions live as committed config / spec / script files in infra,
  the less reconstructive work is needed when a fork happens — the
  artifacts speak for themselves.
- **Update `done.md` and `todo.md` aggressively.** They're the
  human-readable rolling state; if a fork eats the last 30 minutes of
  conversation, these files should still reflect what was decided.
- **Save important explanatory back-and-forth to a relevant spec file
  while still in context**, not as a "I'll write that down later"
  commitment. The spec files survive forks; the conversation might not.
