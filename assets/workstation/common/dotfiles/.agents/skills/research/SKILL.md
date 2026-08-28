---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file under the nearest parent specs folder. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it
reads.

Its job:

1. Investigate the question against **primary sources**: official docs, source
   code, specs, first-party APIs. Not a secondary write-up of them. Follow every
   claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it under the **nearest parent `specs/` folder**, never inside the repo
   being worked on. Walk up from the repo root to the first ancestor containing
   `specs/`. Read that folder's `README.md` first and follow its conventions:
   filenames, the metadata block, the status vocabulary, and the closing
   `## See also`.

## Boundaries

- Repos here get published. Research notes are private working knowledge, so
  they live in `specs/`, above the repos, and never in a repo's own tree.
- Never post findings to GitHub, an issue tracker, a gist, a forum, or any other
  external service. Write the text and hand it to the user to post.
- Do not run `git commit`, `git push`, `git rebase`, `git reset --hard`, or
  `git add`. The user runs all git.
- If a claim cannot be traced to a primary source, say so in the file rather
  than repeating it. An unverified claim is a finding about the sources.

Adapted from mattpocock/skills (MIT, Copyright (c) 2026 Matt Pocock).
