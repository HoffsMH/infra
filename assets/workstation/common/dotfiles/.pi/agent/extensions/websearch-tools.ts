/**
 * Web Search & Fetch Tools
 *
 * Registers web_search and web_fetch as first-class pi tools instead
 * of relying on regex-matching bash commands.  The permission gate
 * checks toolName directly — no fragile command-string parsing.
 *
 * Internally invokes the brave-search skill scripts via child_process.
 */

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  type SelectItem,
  truncateToWidth,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

const execFileAsync = promisify(execFile);

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

const SKILL_DIR = `${process.env.HOME}/.pi/agent/skills/brave-search`;
const SEARCH_JS = `${SKILL_DIR}/search.js`;
const CONTENT_JS = `${SKILL_DIR}/content.js`;

// ---------------------------------------------------------------------------
// Permission state
// ---------------------------------------------------------------------------

type DialogAction = "allow-once" | "allow-all" | "block";

let searchAllowed = false;
let fetchAllowed = false;

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

function buildItems(mode: "search" | "fetch"): SelectItem[] {
  const verb = mode === "fetch" ? "web fetch" : "web search";
  return [
    { value: "allow-once", label: `Yes (${verb} once)` },
    { value: "allow-all", label: `Yes, allow all ${verb}es this session` },
    { value: "block", label: "No" },
  ];
}

async function showWebDialog(
  mode: "search" | "fetch",
  detail: string,
  cwd: string,
  ctx: any,
): Promise<DialogAction | null> {
  const items = buildItems(mode);

  return ctx.ui.custom<DialogAction | null>((tui: any, theme: any, _kb: any, done: any) => {
    let optionIndex = 0;
    let editorMode = false;
    let cachedLines: string[] | undefined;

    const editorTheme: EditorTheme = {
      borderColor: (s) => theme.fg("accent", s),
      selectList: {
        selectedPrefix: (t) => theme.fg("accent", t),
        selectedText: (t) => theme.fg("accent", t),
        description: (t) => theme.fg("muted", t),
        scrollInfo: (t) => theme.fg("dim", t),
        noMatch: (t) => theme.fg("warning", t),
      },
    };
    const editor = new Editor(tui, editorTheme);

    editor.onSubmit = () => {
      const item = items[optionIndex];
      done((item?.value as DialogAction) || "block");
    };

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function handleInput(data: string) {
      if (editorMode) {
        if (matchesKey(data, Key.escape)) {
          editorMode = false;
          editor.setText("");
          refresh();
          return;
        }
        editor.handleInput(data);
        refresh();
        return;
      }

      if (matchesKey(data, Key.up)) {
        optionIndex = Math.max(0, optionIndex - 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.down)) {
        optionIndex = Math.min(items.length - 1, optionIndex + 1);
        refresh();
        return;
      }

      if (matchesKey(data, Key.tab)) {
        editor.setText("");
        editorMode = true;
        refresh();
        return;
      }

      if (matchesKey(data, Key.enter)) {
        const item = items[optionIndex];
        if (item) done(item.value as DialogAction);
        return;
      }

      if (matchesKey(data, Key.escape)) {
        done(null);
      }
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;

      const lines: string[] = [];
      const add = (s: string) => lines.push(truncateToWidth(s, width));

      const header = mode === "fetch" ? "Allow web fetch?" : "Allow web search?";

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("text", ` ${theme.bold(header)}`));

      if (mode === "fetch") {
        add(theme.fg("warning", " ⚠ Fetching URLs can expose internal network services."));
      }

      add(theme.fg("dim", `   ${detail}`));
      add(theme.fg("dim", `   [${cwd}]`));
      lines.push("");

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const selected = i === optionIndex;
        const isNo = i === 2;
        const prefix = selected ? theme.fg("accent", "> ") : "  ";
        const num = theme.fg("dim", `${i + 1}.`);

        let label: string;
        if (selected) label = theme.fg("accent", item.label);
        else if (isNo) label = theme.fg("warning", item.label);
        else label = theme.fg("text", item.label);

        if (selected && !editorMode) label += " " + theme.fg("dim", "[Tab to add message]");

        add(`${prefix}${num} ${label}`);
      }

      if (editorMode) {
        lines.push("");
        const item = items[optionIndex];
        const isNo = item?.value === "block";
        const prompt = isNo ? " Tell pi what to do differently:" : " Add a message for pi:";
        add(theme.fg("muted", prompt));
        for (const line of editor.render(width - 2)) add(` ${line}`);
      }

      lines.push("");
      if (editorMode) {
        add(theme.fg("dim", " Enter to submit • Esc to go back"));
      } else {
        add(theme.fg("dim", " ↑↓ navigate • Enter select • Tab add message • Esc cancel"));
      }
      add(theme.fg("accent", "─".repeat(width)));

      cachedLines = lines;
      return lines;
    }

    return { render, invalidate: () => { cachedLines = undefined; }, handleInput };
  });
}

// ---------------------------------------------------------------------------
// Tool executors
// ---------------------------------------------------------------------------

async function runWebSearch(
  params: { query: string; num?: number; content?: boolean },
): Promise<string> {
  const args = [params.query];
  if (params.num) args.push("-n", String(params.num));
  if (params.content) args.push("--content");

  const { stdout, stderr } = await execFileAsync("node", [SEARCH_JS, ...args], {
    timeout: 30_000,
    maxBuffer: 5 * 1024 * 1024,
  });
  if (stderr) console.error("search.js stderr:", stderr);
  return stdout;
}

async function runWebFetch(params: { url: string }): Promise<string> {
  const { stdout, stderr } = await execFileAsync("node", [CONTENT_JS, params.url], {
    timeout: 30_000,
    maxBuffer: 5 * 1024 * 1024,
  });
  if (stderr) console.error("content.js stderr:", stderr);
  return stdout;
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  // --- session resume ------------------------------------------------
  pi.on("session_start", async (_event, ctx) => {
    searchAllowed = false;
    fetchAllowed = false;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === "websearch-permission") {
        if (entry.data?._reset) {
          searchAllowed = false;
          fetchAllowed = false;
          continue;
        }
        if (entry.data?.search === true) searchAllowed = true;
        if (entry.data?.fetch === true) fetchAllowed = true;
      }
    }
  });

  // --- web_search tool -----------------------------------------------
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web via Brave Search API. Returns results with title, link, age, and snippet. Use for finding documentation, facts, current information, or anything not in training data.",
    promptSnippet: "Search the web via Brave Search API",
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      num: Type.Optional(
        Type.Number({ description: "Number of results (default 5, max 20)" }),
      ),
      content: Type.Optional(
        Type.Boolean({
          description: "Include full page content as markdown for each result",
        }),
      ),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI && !searchAllowed) {
        return {
          content: [{ type: "text", text: "Web search blocked in non-interactive mode." }],
          details: {},
        };
      }

      // Permission gate
      if (!searchAllowed) {
        const action = await showWebDialog(
          "search",
          `search for "${params.query}"`,
          ctx.cwd,
          ctx,
        );
        if (!action || action === "block") {
          return {
            content: [{ type: "text", text: "Web search cancelled by user." }],
            details: { cancelled: true },
          };
        }
        if (action === "allow-all") {
          searchAllowed = true;
          pi.appendEntry("websearch-permission", { search: true });
        }
      }

      try {
        const output = await runWebSearch(params);
        return {
          content: [{ type: "text", text: output }],
          details: { query: params.query },
        };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: `Web search error: ${err.message}` }],
          details: { error: err.message },
          isError: true,
        };
      }
    },
  });

  // --- web_fetch tool ------------------------------------------------
  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch and extract readable content from a URL as markdown. Has SSRF protection (blocks internal IPs), 5MB size cap, and prompt-injection sandboxing. Use for reading full page content from search results or known URLs.",
    promptSnippet: "Fetch and extract content from a URL as markdown",
    parameters: Type.Object({
      url: Type.String({ description: "URL to fetch and extract content from" }),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI && !fetchAllowed) {
        return {
          content: [{ type: "text", text: "Web fetch blocked in non-interactive mode." }],
          details: {},
        };
      }

      // Permission gate
      if (!fetchAllowed) {
        const action = await showWebDialog("fetch", params.url, ctx.cwd, ctx);
        if (!action || action === "block") {
          return {
            content: [{ type: "text", text: "Web fetch cancelled by user." }],
            details: { cancelled: true },
          };
        }
        if (action === "allow-all") {
          fetchAllowed = true;
          pi.appendEntry("websearch-permission", { fetch: true });
        }
      }

      try {
        const output = await runWebFetch(params);
        return {
          content: [{ type: "text", text: output }],
          details: { url: params.url },
        };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: `Web fetch error: ${err.message}` }],
          details: { error: err.message },
          isError: true,
        };
      }
    },
  });
}
