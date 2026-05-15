/**
 * Web Search & Fetch Permission Gate
 *
 * Standalone gate for web searches and URL fetches (Brave Search via
 * pi-skills).  Separate detection and separate whitelists for search
 * vs fetch — approving searches does not approve fetches.
 *
 * Tab on any option opens inline editor:
 *   - On "allow once / allow all": type a steer message
 *   - On "No": type a reason
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
// Detection
// ---------------------------------------------------------------------------

const SEARCH_PATTERN = /brave-search\/search\.js(?!.*--content)/;
const FETCH_PATTERN =
  /brave-search\/(?:content\.js|search\.js\b.*--content)/;

type WebMode = "search" | "fetch";

function detectWebMode(command: string, cwd: string): WebMode | null {
  if (FETCH_PATTERN.test(command)) return "fetch";
  if (SEARCH_PATTERN.test(command)) return "search";
  if (cwd.includes("brave-search")) {
    // Can't distinguish from cwd alone — check command content.
    if (command.includes("content.js") || command.includes("--content"))
      return "fetch";
    if (command.includes("search.js")) return "search";
  }
  return null;
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type DialogAction = "allow-once" | "allow-all" | "block";

interface DialogResult {
  action: DialogAction;
  message?: string;
}

// ---------------------------------------------------------------------------
// Dialog items (per mode)
// ---------------------------------------------------------------------------

function buildItems(mode: WebMode): SelectItem[] {
  const verb = mode === "fetch" ? "web fetch" : "web search";
  return [
    { value: "allow-once", label: `Yes (${verb} once)` },
    { value: "allow-all", label: `Yes, allow all ${verb}es this session` },
    { value: "block", label: "No" },
  ];
}

// ---------------------------------------------------------------------------
// Custom dialog
// ---------------------------------------------------------------------------

function showWebDialog(
  mode: WebMode,
  command: string,
  cwd: string,
  ctx: Parameters<ExtensionAPI["on"]>[1] extends (e: infer E, c: infer C) => any ? C : never,
): Promise<DialogResult | null> {
  const items = buildItems(mode);
  const NO_INDEX = 2;

  return ctx.ui.custom<DialogResult | null>((tui, theme, _kb, done) => {
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

    editor.onSubmit = (value) => {
      const item = items[optionIndex];
      const result: DialogResult = {
        action: (item?.value as DialogAction) || "block",
        message: value.trim() || undefined,
      };
      done(result);
    };

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function enterEditor() {
      editor.setText("");
      editorMode = true;
      refresh();
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
        enterEditor();
        return;
      }

      if (matchesKey(data, Key.enter)) {
        const item = items[optionIndex];
        if (item) {
          done({ action: item.value as DialogAction });
        }
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

      const header =
        mode === "fetch" ? "Allow web fetch?" : "Allow web search?";

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("text", ` ${theme.bold(header)}`));

      if (mode === "fetch") {
        add(
          theme.fg(
            "warning",
            " ⚠ Fetching URLs can expose internal network services.",
          ),
        );
      }

      add(theme.fg("dim", `   ${command}`));
      add(theme.fg("dim", `   [${cwd}]`));
      lines.push("");

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        const selected = i === optionIndex;
        const isNo = i === NO_INDEX;
        const prefix = selected ? theme.fg("accent", "> ") : "  ";
        const num = theme.fg("dim", `${i + 1}.`);

        let label: string;
        if (selected) {
          label = theme.fg("accent", item.label);
        } else if (isNo) {
          label = theme.fg("warning", item.label);
        } else {
          label = theme.fg("text", item.label);
        }

        if (selected && !editorMode) {
          label += " " + theme.fg("dim", "[Tab to add message]");
        }

        add(`${prefix}${num} ${label}`);
      }

      if (editorMode) {
        lines.push("");
        const item = items[optionIndex];
        const isNo = item?.value === "block";
        const prompt = isNo
          ? " Tell pi what to do differently:"
          : " Add a message for pi:";
        add(theme.fg("muted", prompt));
        for (const line of editor.render(width - 2)) {
          add(` ${line}`);
        }
      }

      lines.push("");
      if (editorMode) {
        add(theme.fg("dim", " Enter to submit • Esc to go back"));
      } else {
        add(
          theme.fg(
            "dim",
            " ↑↓ navigate • Enter select • Tab add message • Esc cancel",
          ),
        );
      }
      add(theme.fg("accent", "─".repeat(width)));

      cachedLines = lines;
      return lines;
    }

    return {
      render,
      invalidate: () => { cachedLines = undefined; },
      handleInput,
    };
  });
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let searchAllowed = false;
  let fetchAllowed = false;

  // --- session resume ------------------------------------------------
  pi.on("session_start", async (_event, ctx) => {
    searchAllowed = false;
    fetchAllowed = false;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "websearch-permission"
      ) {
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

  // --- gate ----------------------------------------------------------
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command: string = event.input.command;
    const cwd = ctx.cwd;
    const mode = detectWebMode(command, cwd);
    if (!mode) return undefined; // Not ours.

    // Already whitelisted for this mode.
    const allowed = mode === "search" ? searchAllowed : fetchAllowed;
    if (allowed) return undefined;

    if (!ctx.hasUI) {
      return {
        block: true,
        reason: `Web ${mode} blocked in non-interactive mode.`,
      };
    }

    const result = await showWebDialog(mode, command, cwd, ctx);

    if (!result) {
      return { block: true, reason: "Cancelled by user" };
    }

    if (result.message) {
      pi.sendMessage(
        {
          customType: "websearch-permission",
          content: result.message,
          display: true,
        },
        { deliverAs: "steer" },
      );
    }

    if (result.action === "block") {
      return {
        block: true,
        reason: result.message
          ? `Blocked: ${result.message}`
          : "Blocked by user",
      };
    }

    if (result.action === "allow-all") {
      if (mode === "search") {
        searchAllowed = true;
        pi.appendEntry("websearch-permission", { search: true });
      } else {
        fetchAllowed = true;
        pi.appendEntry("websearch-permission", { fetch: true });
      }
    }

    return undefined;
  });
}
