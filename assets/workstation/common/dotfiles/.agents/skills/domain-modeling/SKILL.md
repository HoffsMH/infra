---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology or a ubiquitous language, record an architectural decision, or when another skill needs to maintain the domain model.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the
*active* discipline: challenging terms, inventing edge-case scenarios, and
writing the glossary and decisions down the moment they crystallise. Merely
*reading* a glossary for vocabulary is not this skill, that is a one-line habit
any skill can do. This skill is for when you are changing the model, not just
consuming it.

## Where the files live

Walk up from the repo root to the first ancestor directory containing a `specs/`
folder. That folder is private working knowledge shared by every repo beneath
it, and it sits above them deliberately, so a repo that gets published never
carries planning notes.

```
<specs>/<project>/
    domain.md          the glossary
    decisions/
        <kebab-case-title>.md
```

Read the specs folder's `README.md` first. **Its conventions win over anything
in this file**: filenames kebab-case and lowercase, no YAML front-matter but a
bold metadata block under the H1, `**Status:**` from its closed set, never move
or delete a document (flip its status), code cited as `file.lua:123` in
backticks rather than a link out of `specs/`, and every document ending with
`## See also`.

Decision records are named for what they decide, not numbered. Order them by
their `**Created:**` line.

Exception: if the repo already tracks a glossary or decision records in git,
keep editing those where they are. Do not migrate someone else's layout.

Create files lazily, only when you have something to write.

## During the session

**Challenge against the glossary.** When the user uses a term that conflicts
with the existing language, call it out immediately. "Your glossary defines
'cancellation' as X, but you seem to mean Y. Which is it?"

**Sharpen fuzzy language.** When the user uses vague or overloaded terms,
propose a precise canonical term. "You are saying 'account'. Do you mean the
Customer or the User? Those are different things."

**Discuss concrete scenarios.** When domain relationships are being discussed,
stress-test them with specific scenarios that probe edge cases and force the
user to be precise about the boundaries between concepts.

**Cross-reference with code.** When the user states how something works, check
whether the code agrees. If you find a contradiction, surface it: "Your code
cancels entire Orders, but you just said partial cancellation is possible.
Which is right?"

**Update the glossary inline.** When a term is resolved, write it down right
there. Do not batch these up. The glossary is a glossary and nothing else: no
implementation details, no specs, no scratch notes.

## Offer decision records sparingly

Only offer to record a decision when all three are true:

1. **Hard to reverse.** The cost of changing your mind later is meaningful.
2. **Surprising without context.** A future reader will wonder why it was done
   this way.
3. **The result of a real trade-off.** There were genuine alternatives and one
   was picked for specific reasons.

If any of the three is missing, skip it. A record carries the context, the
decision, the alternatives rejected and why, and the consequences.

## Boundaries

- Never write inside a repo that gets published. The glossary and decision
  records belong under the nearest parent `specs/`.
- Never post anything to GitHub, an issue tracker, or any other external
  service. Write the text and hand it to the user.
- Do not run `git commit`, `git push`, `git rebase`, `git reset --hard`, or
  `git add`. The user runs all git.
- The user owns builds, servers, databases, and every in-app verification. Where
  one of those is needed, hand over a precise checklist instead of running it.

Adapted from mattpocock/skills (MIT, Copyright (c) 2026 Matt Pocock).
