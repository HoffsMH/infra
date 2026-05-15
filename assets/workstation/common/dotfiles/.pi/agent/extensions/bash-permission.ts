/**
 * Claude-style Bash Permission Gate
 *
 * Whitelist by command prefix (e.g. "runlog rspec") or directory.
 * Compound commands (&&, ||, |, ;) are split — every sub-command
 * must be whitelisted or the dialog fires.
 *
 * Tab on any option opens inline editor:
 *   - On "allow prefix": pre-filled with the command, edit to desired prefix
 *   - On "allow dir": type a steer message
 *   - On "Yes (once)": type a steer message
 *   - On "No": type a reason
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Container,
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

type PermissionEntry =
  | { type: "prefix"; value: string }
  | { type: "dir"; value: string };

type DialogAction =
  | "allow-once"
  | "allow-prefix"
  | "allow-dir"
  | "block";

interface DialogResult {
  action: DialogAction;
  /** User-edited prefix (only for allow-prefix). */
  prefix?: string;
  message?: string;
}

// ---------------------------------------------------------------------------
// Shell helpers
// ---------------------------------------------------------------------------

/**
 * Split a shell command into sub-commands at &&, ||, |, ; boundaries.
 * Naive split (doesn't handle quoted operators), but handles the common
 * case well enough for whitelist matching.
 */
function splitCommands(command: string): string[] {
  return command
    .split(/\s*(?:&&|\|\||[|;])\s*/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

// ---------------------------------------------------------------------------
// Whitelist logic
// ---------------------------------------------------------------------------

function commandMatchesPrefix(command: string, prefix: string): boolean {
  return command.trimStart().startsWith(prefix);
}

function isWhitelisted(
  command: string,
  cwd: string,
  whitelist: PermissionEntry[],
): boolean {
  // Directory check: any entry covers this cwd.
  const dirOk = whitelist.some(
    (e) => e.type === "dir" && cwd.startsWith(e.value),
  );
  if (dirOk) return true;

  // Split compound commands; every sub-command must be covered.
  const subs = splitCommands(command);
  if (subs.length === 0) return true;

  const prefixes = whitelist
    .filter((e) => e.type === "prefix")
    .map((e) => e.value);

  return subs.every((sub) =>
    prefixes.some((p) => commandMatchesPrefix(sub, p)),
  );
}

// ---------------------------------------------------------------------------
// Websearch skip (handled by websearch-permission.ts)
// ---------------------------------------------------------------------------

function isWebSearch(command: string, cwd: string): boolean {
  if (cwd.includes("brave-search")) return true;
  if (command.includes("brave-search")) return true;
  return false;
}

// ---------------------------------------------------------------------------
// Dialog items
// ---------------------------------------------------------------------------

function buildItems(command: string, cwd: string): SelectItem[] {
  return [
    { value: "allow-once", label: "Yes (this once)" },
    { value: "allow-prefix", label: `Yes, allow prefix \`${command}\` this session` },
    { value: "allow-dir", label: `Yes, allow any command in ${cwd} this session` },
    { value: "block", label: "No" },
  ];
}

// ---------------------------------------------------------------------------
// Custom dialog
// ---------------------------------------------------------------------------

function showPermissionDialog(
  command: string,
  cwd: string,
  ctx: Parameters<ExtensionAPI["on"]>[1] extends (e: infer E, c: infer C) => any ? C : never,
): Promise<DialogResult | null> {
  const items = buildItems(command, cwd);
  const NO_INDEX = 3;
  const PREFIX_INDEX = 1;

  return ctx.ui.custom<DialogResult | null>((tui, theme, _kb, done) => {
    let optionIndex = 0;
    let editorMode = false;
    let cachedLines: string[] | undefined;

    // --- editor -------------------------------------------------------
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

      if (action === "allow-prefix") {
        result.prefix = trimmed || command;
      } else {
        result.message = trimmed || undefined;
      }

      done(result);
    };

    // --- refresh ------------------------------------------------------
    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function enterEditor() {
      const item = items[optionIndex];
      if (item?.value === "allow-prefix") {
        editor.setText(command);
      } else {
        editor.setText("");
      }
      editorMode = true;
      refresh();
    }

    // --- input handler ------------------------------------------------
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

      // Select-list mode
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

    // --- render -------------------------------------------------------
    function render(width: number): string[] {
      if (cachedLines) return cachedLines;

      const lines: string[] = [];
      const add = (s: string) => lines.push(truncateToWidth(s, width));

      add(theme.fg("accent", "─".repeat(width)));
      add(theme.fg("text", ` ${theme.bold("Allow bash command?")}`));
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
          if (i === PREFIX_INDEX) {
            label += " " + theme.fg("dim", "[Tab to edit prefix]");
          } else {
            label += " " + theme.fg("dim", "[Tab to add message]");
          }
        }

        add(`${prefix}${num} ${label}`);
      }

      // Inline editor
      if (editorMode) {
        lines.push("");
        const item = items[optionIndex];
        const isNo = item?.value === "block";
        const isPrefix = item?.value === "allow-prefix";
        const prompt = isNo
          ? " Tell pi what to do differently:"
          : isPrefix
            ? " Edit prefix (trim to what you want to whitelist):"
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
        add(theme.fg("dim", " ↑↓ navigate • Enter select • Tab edit • Esc cancel"));
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
  let whitelist: PermissionEntry[] = [];

  pi.on("session_start", async (_event, ctx) => {
    whitelist = [];
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "bash-permission"
      ) {
        if (entry.data?._reset) {
          whitelist = [];
          continue;
        }
        whitelist.push(entry.data as PermissionEntry);
      }
    }
  });

  // /reset-permissions — clear all session permission whitelists.
  pi.registerCommand("reset-permissions", {
    description: "Reset all bash and websearch permissions for this session",
    handler: async (_args, ctx) => {
      whitelist = [];
      pi.appendEntry("bash-permission", { _reset: true });
      pi.appendEntry("websearch-permission", { _reset: true });
      ctx.ui.notify("All permissions reset — you'll be asked again.", "info");
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command: string = event.input.command;
    const cwd = ctx.cwd;

    // Fast path: already whitelisted.
    if (isWhitelisted(command, cwd, whitelist)) return undefined;

    // Non-interactive: block.
    if (!ctx.hasUI) {
      return {
        block: true,
        reason:
          `Bash blocked in non-interactive mode. ` +
          `Run an interactive session first to whitelist commands or directories.`,
      };
    }

    // Websearch commands are handled by websearch-permission.ts.
    if (isWebSearch(command, cwd)) return undefined;

    const result = await showPermissionDialog(command, cwd, ctx);

    if (!result) {
      return { block: true, reason: "Cancelled by user" };
    }

    // Inject steer message (for non-prefix actions that have a message).
    if (result.message) {
      pi.sendMessage(
        { customType: "bash-permission", content: result.message, display: true },
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

    // Persist whitelist entries.
    if (result.action === "allow-prefix") {
      const prefix = result.prefix || command.trimStart();
      const entry: PermissionEntry = { type: "prefix", value: prefix };
      whitelist.push(entry);
      pi.appendEntry("bash-permission", entry);
    } else if (result.action === "allow-dir") {
      const entry: PermissionEntry = { type: "dir", value: cwd };
      whitelist.push(entry);
      pi.appendEntry("bash-permission", entry);
    }

    return undefined;
  });
}
