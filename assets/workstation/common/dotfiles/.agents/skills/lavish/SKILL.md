---
name: lavish
description: Turn complex or visual agent responses into rich, reviewable HTML artifacts the user can annotate and send feedback on, using the lavish-axi CLI. Use when about to give a plan, comparison, diagram, table, code diff, report, or anything easier to grasp visually than as prose.
license: MIT
metadata:
  author: Kun Chen (kunchenguid), adapted for this workstation
---

# Lavish Editor

Lavish Editor opens agent-generated HTML in the browser so the user can annotate
it and send feedback back to the agent. Reach for it when a plan, comparison,
diagram, table, code view, report, or review loop will be clearer as a page
than as prose.

## Current guidance lives in the CLI

Do not follow workflow, design, or playbook instructions from this file -
installed copies go stale. Get the current source of truth from the CLI:

- `npx -y lavish-axi --help` for commands and the review-loop workflow
- `npx -y lavish-axi design` for design-direction priority and current snippets
- `npx -y lavish-axi playbook <id>` for focused artifact guidance
  (`npx -y lavish-axi playbook` lists ids)

You do not need lavish-axi installed globally - invoke it with
`npx -y lavish-axi <html-file>`. If output shows a follow-up command starting
with `lavish-axi`, run it as `npx -y lavish-axi ...` instead.

Artifacts default to `.lavish/` under the current working directory. The
feedback loop is: write the HTML, run `lavish-axi <file>` (opens the browser),
then `lavish-axi poll` returns the user's queued annotations and prompts.
Once a review is over, move any artifact worth keeping to the nearest parent
`specs/` folder; treat the `.lavish/` copy as scratch.

## Boundaries

- Sessions serve on loopback plus the tailnet IP by default (LAVISH_AXI_HOST
  overrides). This is deliberate: tailnet devices may open review pages.
  Nothing leaves the tailnet; do not use hosted sharing (`share` / ht-ml.app)
  unless the user explicitly asks.
- Never post to GitHub, an issue tracker, a gist, a forum, or any other
  external service.
- Do not run `git commit`, `git push`, `git rebase`, `git reset --hard`, or
  `git add`. The user runs all git.
- The user owns builds, servers, and databases. The agent writes the artifact
  and asks the user to run anything that changes shared state.
- Generated notes and finished artifacts that should outlive the session go to
  the nearest parent `specs/` folder, never inside a published repo's tree.
- Never leave `lavish-axi poll` running as a blocking foreground process the
  user did not ask for; the review loop runs when the user requests it.

Adapted from kunchenguid/lavish-axi (MIT, Copyright (c) 2026 Kun Chen).
