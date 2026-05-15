/**
 * Web Search & Fetch Permission Gate (fallback)
 *
 * Catches bash invocations of brave-search scripts (search.js, content.js)
 * and shows the appropriate permission dialog.  This is a fallback for
 * cases where the model uses bash directly instead of the web_search /
 * web_fetch tools.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  type SelectItem,
  truncateToWidth,
} from "@earendil-works/pi-tui";

// ---------------------------------------------------------------------------
// Detection — simple, no regex needed
// ---------------------------------------------------------------------------

function isBraveSearch(command: string, cwd: string): boolean {
  if (cwd.includes("brave-search")) return true;
  if (command.includes("brave-search")) return true;
  return false;
}

type WebMode = "search" | "fetch";

function detectMode(command: string): WebMode {
  // content.js → fetch
  if (command.includes("content.js") && !command.includes("search.js"))
    return "fetch";
  // search.js → search (even with --content)
  return "search";
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type DialogAction = "allow-once" | "allow-all" | "block";

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

function buildItems(mode: WebMode): SelectItem[] {
  const verb = mode === "fetch" ? "web fetch" : "web search";
  return [
    { value: "allow-once", label: `Yes (${verb} once)` },
    { value: "allow-all", label: `Yes, allow all ${verb}es this session` },
    { value: "block", label: "No" },
  ];
}

async function showWebDialog(
  mode: WebMode,
  command: string,
  cwd: string,
  ctx: Parameters<ExtensionAPI["on"]>[1] extends (e: infer E, c: infer C) => any ? C : never,
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

    function refresh() { cachedLines = undefined; tui.requestRender(); }

    function handleInput(data: string) {
      if (editorMode) {
        if (matchesKey(data, Key.escape)) { editorMode = false; editor.setText(""); refresh(); return; }
        editor.handleInput(data);
        refresh();
        return;
      }
      if (matchesKey(data, Key.up)) { optionIndex = Math.max(0, optionIndex - 1); refresh(); return; }
      if (matchesKey(data, Key.down)) { optionIndex = Math.min(items.length - 1, optionIndex + 1); refresh(); return; }
      if (matchesKey(data, Key.tab)) { editor.setText(""); editorMode = true; refresh(); return; }
      if (matchesKey(data, Key.enter)) { done((items[optionIndex]?.value as DialogAction) || "block"); return; }
      if (matchesKey(data, Key.escape)) { done(null); }
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;
      const lines: string[] = [];
      const add = (s: string) => lines.push(truncateToWidth(s, width));
      const header = mode === "fetch" ? "Allow web fetch?" : "Allow web search?";

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("text", ` ${theme.bold(header)}`));
      if (mode === "fetch") add(theme.fg("warning", " ⚠ Fetching URLs can expose internal network services."));
      add(theme.fg("dim", `   ${command}`));
      add(theme.fg("dim", `   [${cwd}]`));
      lines.push("");

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const selected = i === optionIndex;
        const isNo = i === 2;
        const prefix = selected ? theme.fg("accent", "> ") : "  ";
        const num = theme.fg("dim", `${i + 1}.`);
        let label = selected ? theme.fg("accent", item.label) : isNo ? theme.fg("warning", item.label) : theme.fg("text", item.label);
        if (selected && !editorMode) label += " " + theme.fg("dim", "[Tab to add message]");
        add(`${prefix}${num} ${label}`);
      }

      if (editorMode) {
        lines.push("");
        add(theme.fg("muted", items[optionIndex]?.value === "block" ? " Tell pi what to do differently:" : " Add a message for pi:"));
        for (const line of editor.render(width - 2)) add(` ${line}`);
      }

      lines.push("");
      add(theme.fg("dim", editorMode ? " Enter to submit • Esc to go back" : " ↑↓ navigate • Enter select • Tab add message • Esc cancel"));
      add(theme.fg("accent", "─".repeat(width)));
      cachedLines = lines;
      return lines;
    }

    return { render, invalidate: () => { cachedLines = undefined; }, handleInput };
  });
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let searchAllowed = false;
  let fetchAllowed = false;

  pi.on("session_start", async (_event, ctx) => {
    searchAllowed = false;
    fetchAllowed = false;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (entry.type === "custom" && entry.customType === "websearch-permission") {
        if (entry.data?._reset) { searchAllowed = false; fetchAllowed = false; continue; }
        if (entry.data?.search === true) searchAllowed = true;
        if (entry.data?.fetch === true) fetchAllowed = true;
      }
    }
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;
    const command: string = event.input.command;
    const cwd = ctx.cwd;
    if (!isBraveSearch(command, cwd)) return undefined;

    const mode = detectMode(command);
    if ((mode === "search" && searchAllowed) || (mode === "fetch" && fetchAllowed))
      return undefined;

    if (!ctx.hasUI) return { block: true, reason: `Web ${mode} blocked in non-interactive mode.` };

    const result = await showWebDialog(mode, command, cwd, ctx);
    if (!result || result === "block") return { block: true, reason: "Cancelled by user" };
    if (result === "allow-all") {
      if (mode === "search") { searchAllowed = true; pi.appendEntry("websearch-permission", { search: true }); }
      else { fetchAllowed = true; pi.appendEntry("websearch-permission", { fetch: true }); }
    }
    return undefined;
  });
}
