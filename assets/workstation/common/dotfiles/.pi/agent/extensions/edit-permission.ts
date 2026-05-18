/**
 * Edit Permission Gate
 *
 * Whitelist by session flag. Simple model: allow once, or allow all edits
 * for the rest of the session.
 *
 * Tab on any option opens inline editor for additional context/message.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  type SelectItem,
  Text,
  truncateToWidth,
} from "@earendil-works/pi-tui";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type DialogAction = "allow-once" | "allow-session" | "block";

interface DialogResult {
  action: DialogAction;
  message?: string;
}

// ---------------------------------------------------------------------------
// Edit preview helper
// ---------------------------------------------------------------------------

/**
 * Generate a preview of the edit showing old and new text snippets.
 * Truncate if too long.
 */
function previewEdit(oldText: string, newText: string, maxChars: number = 200): string {
  // Show a snippet of what changed
  const oldSnippet = oldText.length > maxChars
    ? oldText.slice(0, maxChars) + "..."
    : oldText;
  const newSnippet = newText.length > maxChars
    ? newText.slice(0, maxChars) + "..."
    : newText;

  // Count the lines changed
  const oldLines = oldText.split("\n").length - 1;
  const newLines = newText.split("\n").length - 1;

  return `Replacing ${oldLines + 1} line(s) → ${newLines + 1} line(s)`;
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

function buildItems(): SelectItem[] {
  return [
    { value: "allow-once", label: "Yes, this once" },
    { value: "allow-session", label: "Yes, allow all edits this session" },
    { value: "block", label: "No" },
  ];
}

async function showEditDialog(
  filePath: string,
  oldText: string,
  newText: string,
  cwd: string,
  ctx: Parameters<ExtensionAPI["on"]>[1] extends (e: infer E, c: infer C) => any ? C : never,
): Promise<DialogResult | null> {
  const items = buildItems();
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
      const action = item?.value as DialogAction;
      const trimmed = value.trim();
      const result: DialogResult = { action };

      if (trimmed) {
        result.message = trimmed;
      }

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

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("text", ` ${theme.bold("Allow file edit?")}`));

      // File path
      add(theme.fg("dim", `   ${filePath}`));

      // Preview of change
      const preview = previewEdit(oldText, newText);
      add(theme.fg("muted", `   ${preview}`));

      // Context
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
        const isNo = items[optionIndex]?.value === "block";
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
        add(theme.fg("dim", " ↑↓ navigate • Enter select • Tab add message • Esc cancel"));
      }
      add(theme.fg("accent", "─".repeat(width)));

      cachedLines = lines;
      return lines;
    }

    return {
      render,
      invalidate: () => {
        cachedLines = undefined;
      },
      handleInput,
    };
  });
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let editsAllowed = false;

  pi.on("session_start", async (_event, ctx) => {
    editsAllowed = false;
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "edit-permission"
      ) {
        if (entry.data?._reset) {
          editsAllowed = false;
          continue;
        }
        if (entry.data?.editsAllowed === true) editsAllowed = true;
      }
    }
  });

  // Mid-session reset: bash-permission's /reset-permissions appends
  // { _reset: true } to edit-permission entries.  Check on every turn
  // start so in-memory state clears immediately without needing /reload.
  pi.on("before_agent_start", async (_event, ctx) => {
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "edit-permission" &&
        entry.data?._reset
      ) {
        editsAllowed = false;
        return;
      }
    }
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "edit") return undefined;

    // Already whitelisted for this session
    if (editsAllowed) return undefined;

    const filePath: string = event.input.path || "(unknown)";
    const oldText: string = event.input.oldText || "";
    const newText: string = event.input.newText || "";
    const cwd = ctx.cwd;

    // Non-interactive: block
    if (!ctx.hasUI) {
      return {
        block: true,
        reason:
          `Edit blocked in non-interactive mode. ` +
          `Run an interactive session first to whitelist edits.`,
      };
    }

    const result = await showEditDialog(filePath, oldText, newText, cwd, ctx);

    if (!result) {
      return { block: true, reason: "Cancelled by user" };
    }

    // Inject steer message if provided
    if (result.message) {
      pi.sendMessage(
        { customType: "edit-permission", content: result.message, display: true },
        { deliverAs: "steer" },
      );
    }

    if (result.action === "block") {
      return {
        block: true,
        reason: result.message ? `Blocked: ${result.message}` : "Blocked by user",
      };
    }

    // Persist whitelist entry for "allow session"
    if (result.action === "allow-session") {
      editsAllowed = true;
      pi.appendEntry("edit-permission", { editsAllowed: true });
    }

    return undefined;
  });
}
