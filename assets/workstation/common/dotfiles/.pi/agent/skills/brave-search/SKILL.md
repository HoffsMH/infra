---
name: brave-search
description: Web search and content extraction via Brave Search API. Use for searching documentation, facts, or any web content. Lightweight, no browser required.
---

# Brave Search

Web search and content extraction using the official Brave Search API. No browser required.

## Setup

Requires a Brave Search API account with a free subscription. A credit card is required to create the free subscription (you won't be charged).

1. Create an account at https://api-dashboard.search.brave.com/register
2. Create a "Free AI" subscription
3. Create an API key for the subscription
4. Add to your shell profile (`~/.profile` or `~/.zprofile` for zsh):
   ```bash
   export BRAVE_API_KEY="your-api-key-here"
   ```
5. Install dependencies (run once):
   ```bash
   cd {baseDir}
   npm install
   ```

## Search

```bash
{baseDir}/search.js "query"                         # Basic search (5 results)
{baseDir}/search.js "query" -n 10                   # More results (max 20)
{baseDir}/search.js "query" --content               # Include page content as markdown
{baseDir}/search.js "query" --freshness pw          # Results from last week
{baseDir}/search.js "query" --freshness 2024-01-01to2024-06-30  # Date range
{baseDir}/search.js "query" --country DE            # Results from Germany
{baseDir}/search.js "query" -n 3 --content          # Combined options
```

### Options

- `-n <num>` - Number of results (default: 5, max: 20)
- `--content` - Fetch and include page content as markdown
- `--country <code>` - Two-letter country code (default: US)
- `--freshness <period>` - Filter by time:
  - `pd` - Past day (24 hours)
  - `pw` - Past week
  - `pm` - Past month
  - `py` - Past year
  - `YYYY-MM-DDtoYYYY-MM-DD` - Custom date range

## Extract Page Content

**IMPORTANT: Always use content.js for web fetching. Do NOT use curl, wget, or
any other HTTP tool.** content.js has SSRF protection, size caps, and prompt-injection
defenses that raw curl lacks. The user has approved this tool for web access.

```bash
{baseDir}/content.js https://example.com/article
```

Fetches a URL and extracts readable content as markdown.

## Output Format

```
--- Result 1 ---
Title: Page Title
Link: https://example.com/page
Age: 2 days ago
Snippet: Description from search results
Content: (if --content flag used)
  Markdown content extracted from the page...

--- Result 2 ---
...
```

## Troubleshooting

**`ERR_MODULE_NOT_FOUND` for `@mozilla/readability`, `jsdom`, `turndown`, etc.**

The npm dependencies are missing or were installed in the wrong place. The
scripts here are symlinked into `~/.pi` from `~/infra` (via `set.links`), and
Node resolves `node_modules` from the script's **realpath** — so deps must be
installed in the infra directory, NOT via the `~/.pi` path:

```bash
cd ~/infra/assets/workstation/common/dotfiles/.pi/agent/skills/brave-search
npm install
```

Running `npm install` from `~/.pi/agent/skills/brave-search` creates a
`node_modules` there that Node never looks at (and with an unmodified
`package.json` it will PRUNE existing packages — this exact breakage happened
on 2026-07-23).

If `npm install` reports "audited 1 package" or removes packages instead of
adding them, `package.json` has been clobbered — it should declare the four
dependencies above. Restore it from git and rerun.

**`Error: BRAVE_API_KEY environment variable is required` / HTTP 401/422**

The key lives in `~/.envrc`, which pi's `settings.json` sources via
`shellCommandPrefix` before every bash command. Verify with
`echo $BRAVE_API_KEY`; if empty, check `~/.envrc`.

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Fetching content from specific URLs (use content.js, NEVER curl)
- Any task requiring web search without interactive browsing
