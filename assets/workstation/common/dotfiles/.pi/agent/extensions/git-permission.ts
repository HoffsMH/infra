/**
 * Git Permission Gate
 *
 * Registers custom git tools with their own permission dialog — visually
 * and behaviorally distinct from the bash permission gate.  Each tool
 * wraps a safe git subcommand.  Read-only commands share a whitelist;
 * write commands get individual scrutiny.
 *
 * The bash-permission gate is configured to reject any bash command
 * that invokes git, so these tools are the only path to git from within
 * an agent session.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  type SelectItem,
  truncateToWidth,
} from "@earendil-works/pi-tui";
import { execSync } from "node:child_process";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type DialogAction = "allow-once" | "allow-reads" | "allow-writes" | "block";

type GitOpKind = "read" | "write";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getGitBranch(cwd: string): string {
  try {
    return execSync("git branch --show-current", {
      cwd,
      encoding: "utf-8",
      stdio: ["ignore", "pipe", "ignore"],
      timeout: 3000,
    }).trim();
  } catch {
    return "(unknown)";
  }
}

function getGitTopLevel(cwd: string): string {
  try {
    return execSync("git rev-parse --show-toplevel", {
      cwd,
      encoding: "utf-8",
      stdio: ["ignore", "pipe", "ignore"],
      timeout: 3000,
    }).trim();
  } catch {
    return cwd;
  }
}

function kind(op: string): GitOpKind {
  // Write ops
  if (["add", "pull-ff", "stash"].includes(op)) return "write";
  return "read";
}

// ---------------------------------------------------------------------------
// Whitelist
// ---------------------------------------------------------------------------

function isReadWhitelisted(
  readsAllowed: boolean,
  whitelist: string[],
  toolName: string,
): boolean {
  return readsAllowed || whitelist.includes(toolName);
}

// ---------------------------------------------------------------------------
// Dialog — visually distinct from bash gate
// ---------------------------------------------------------------------------

function buildItems(op: string, opKind: GitOpKind): SelectItem[] {
  const items: SelectItem[] = [
    { value: "allow-once", label: "Yes, this once" },
  ];
  if (opKind === "read") {
    items.push({
      value: "allow-reads",
      label: "Yes, allow all git reads",
    });
  } else {
    items.push({
      value: "allow-writes",
      label: "Yes, allow all git writes",
    });
  }
  items.push({ value: "block", label: "No — block" });
  return items;
}

async function showGitDialog(
  toolName: string,
  description: string,
  opKind: GitOpKind,
  cwd: string,
  ctx: Parameters<ExtensionAPI["on"]>[1] extends (e: infer E, c: infer C) => any ? C : never,
): Promise<DialogAction | null> {
  const items = buildItems(toolName, opKind);
  const branch = getGitBranch(cwd);
  const topLevel = getGitTopLevel(cwd);

  return ctx.ui.custom<DialogAction | null>(
    (tui: any, theme: any, _kb: any, done: any) => {
      let optionIndex = 0;
      let editorMode = false;
      let cachedLines: string[] | undefined;

      const editorTheme: EditorTheme = {
        borderColor: (s) => theme.fg("warning", s),
        selectList: {
          selectedPrefix: (t) => theme.fg("warning", t),
          selectedText: (t) => theme.fg("warning", t),
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
          done((items[optionIndex]?.value as DialogAction) || "block");
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

        // Border in warning colour (yellow/orange) vs accent (blue) for bash
        add(theme.fg("warning", "─".repeat(width)));

        // Header
        const badge =
          opKind === "write"
            ? theme.fg("warning", " WRITE ")
            : theme.fg("accent", " READ ");
        const opLabel =
          opKind === "write"
            ? theme.fg("warning", theme.bold("Git write operation"))
            : theme.fg("accent", theme.bold("Git read operation"));
        add(` ${badge} ${opLabel}`);

        // Description
        add(theme.fg("dim", `   ${description}`));

        // Repo context
        add(theme.fg("dim", `   repo: ${topLevel}`));
        add(theme.fg("dim", `   branch: ${theme.bold(branch)}`));

        lines.push("");

        for (let i = 0; i < items.length; i++) {
          const item = items[i];
          const selected = i === optionIndex;
          const isNo = item.value === "block";
          const prefix = selected ? theme.fg("warning", "> ") : "  ";
          const num = theme.fg("dim", `${i + 1}.`);

          let label: string;
          if (selected) {
            label = theme.fg("warning", item.label);
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
          add(
            theme.fg(
              "muted",
              isNo
                ? " Tell pi what to do differently:"
                : " Add a message for pi:",
            ),
          );
          for (const line of editor.render(width - 2)) add(` ${line}`);
        }

        lines.push("");
        add(
          theme.fg(
            "dim",
            editorMode
              ? " Enter to submit • Esc to go back"
              : " ↑↓ navigate • Enter select • Tab add message • Esc cancel",
          ),
        );
        add(theme.fg("warning", "─".repeat(width)));

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
    },
  );
}

// ---------------------------------------------------------------------------
// runGit — shared implementation for all git tools
// ---------------------------------------------------------------------------

function runGit(
  args: string[],
  cwd: string,
  timeoutMs: number = 15000,
): { stdout: string; stderr: string; exitCode: number } {
  try {
    const stdout = execSync(["git", ...args].join(" "), {
      cwd,
      encoding: "utf-8",
      stdio: ["ignore", "pipe", "pipe"],
      timeout: timeoutMs,
      maxBuffer: 2 * 1024 * 1024, // 2 MB
    });
    return { stdout, stderr: "", exitCode: 0 };
  } catch (err: any) {
    return {
      stdout: err.stdout?.toString() || "",
      stderr: err.stderr?.toString() || err.message || "Unknown git error",
      exitCode: err.status ?? 1,
    };
  }
}

// ---------------------------------------------------------------------------
// Tool factory
// ---------------------------------------------------------------------------

interface GitToolDef {
  name: string;
  label: string;
  description: string;
  promptSnippet: string;
  args: string[];
  hasParams: boolean;
  /** Extra description for the permission dialog. */
  permDescription: string;
}

const READ_TOOLS: GitToolDef[] = [
  {
    name: "git_status",
    label: "Git Status",
    description:
      "Show the working tree status. Use before staging or committing to see what has changed.",
    promptSnippet: "git status — show working tree status",
    args: ["status", "--porcelain", "--branch"],
    hasParams: false,
    permDescription: "git status (check working tree state)",
  },
  {
    name: "git_diff",
    label: "Git Diff",
    description:
      "Show changes between commits, commit and working tree, etc. By default shows unstaged changes. Use args: '--staged' for staged changes.",
    promptSnippet: "git diff [--staged] — show working tree changes",
    args: ["diff", "--color=never"],
    hasParams: true,
    permDescription: "git diff (inspect changes)",
  },
  {
    name: "git_log",
    label: "Git Log",
    description:
      "Show commit history. Use --oneline for compact output, -n to limit, or provide a ref range.",
    promptSnippet: "git log [--oneline] [-n N] — show commit history",
    args: ["log", "--color=never"],
    hasParams: true,
    permDescription: "git log (browse history)",
  },
  {
    name: "git_show",
    label: "Git Show",
    description:
      "Show various types of objects (commits, tags, trees, blobs). Provide a ref like HEAD, a branch name, or a commit SHA.",
    promptSnippet: "git show <ref> — inspect a commit or object",
    args: ["show", "--color=never"],
    hasParams: true,
    permDescription: "git show <ref> (inspect object)",
  },
  {
    name: "git_fetch",
    label: "Git Fetch",
    description:
      "Download objects and refs from a remote repository. Safe read operation — never modifies working tree.",
    promptSnippet: "git fetch [remote] — download remote objects",
    args: ["fetch"],
    hasParams: true,
    permDescription: "git fetch (download remote refs)",
  },
  {
    name: "git_branch",
    label: "Git Branch",
    description:
      "List branches. Use -a for all (including remotes), -v for verbose with last commit.",
    promptSnippet: "git branch [-a] [-v] — list branches",
    args: ["branch"],
    hasParams: true,
    permDescription: "git branch (list branches)",
  },
  {
    name: "git_remote",
    label: "Git Remote",
    description:
      "Show remote repositories and their URLs. Use -v for verbose with fetch/push URLs.",
    promptSnippet: "git remote -v — show remote repositories",
    args: ["remote", "-v"],
    hasParams: false,
    permDescription: "git remote -v (show remotes)",
  },
  {
    name: "git_ls_files",
    label: "Git Ls-Files",
    description:
      "Show information about files in the index/working tree. Useful for listing tracked files.",
    promptSnippet: "git ls-files — list tracked files",
    args: ["ls-files"],
    hasParams: true,
    permDescription: "git ls-files (list tracked files)",
  },
];

const WRITE_TOOLS: GitToolDef[] = [
  {
    name: "git_add",
    label: "Git Add",
    description:
      "Stage file contents to the index. Accepts paths. Does NOT commit — user reviews and commits themselves.",
    promptSnippet: "git add <path> — stage file contents (does NOT commit)",
    args: ["add"],
    hasParams: true,
    permDescription: "git add <path> (stage changes — user will commit)",
  },
  {
    name: "git_pull_ff",
    label: "Git Pull (ff-only)",
    description:
      "Pull from remote with fast-forward only. Safe — will not create merge commits. Fails if a merge would be required.",
    promptSnippet: "git pull --ff-only [remote] [branch] — fast-forward pull",
    args: ["pull", "--ff-only"],
    hasParams: true,
    permDescription: "git pull --ff-only (safe fast-forward)",
  },
  {
    name: "git_stash",
    label: "Git Stash",
    description:
      "Stash changes in a dirty working directory. Use 'push' to stash, 'pop' to restore, 'list' to view.",
    promptSnippet: "git stash [push|pop|list] — manage stashed changes",
    args: ["stash"],
    hasParams: true,
    permDescription: "git stash (temporarily shelve changes)",
  },
];

const ALL_TOOLS = [...READ_TOOLS, ...WRITE_TOOLS];

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  let readsAllowed = false;
  const writeWhitelist: Set<string> = new Set();

  // Restore state from session entries
  pi.on("session_start", async (_event, ctx) => {
    readsAllowed = false;
    writeWhitelist.clear();
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "git-permission"
      ) {
        if (entry.data?._reset) {
          readsAllowed = false;
          writeWhitelist.clear();
          continue;
        }
        if (entry.data?.readsAllowed === true) readsAllowed = true;
        if (entry.data?.writeTool)
          writeWhitelist.add(entry.data.writeTool);
      }
    }
  });

  // Register each git tool
  for (const def of ALL_TOOLS) {
    pi.registerTool({
      name: def.name,
      label: def.label,
      description: def.description,
      promptSnippet: def.promptSnippet,
      parameters: def.hasParams
        ? Type.Object({
            args: Type.Optional(
              Type.String({
                description:
                  "Additional git arguments (e.g. '--staged' for diff, '--oneline' for log, a ref for show)",
              }),
            ),
          })
        : Type.Object({}),

      async execute(toolCallId, params, signal, _onUpdate, ctx) {
        const opKind = kind(
          def.args[0] || def.name.replace("git_", ""),
        );
        const cwd = ctx.cwd;

        // Check whitelist
        const alreadyAllowed =
          opKind === "read"
            ? isReadWhitelisted(readsAllowed, [...writeWhitelist], def.name)
            : writeWhitelist.has(def.name);

        if (!alreadyAllowed) {
          if (!ctx.hasUI) {
            return {
              content: [
                {
                  type: "text",
                  text: `Git ${opKind} operation "${def.name}" blocked in non-interactive mode.`,
                },
              ],
              details: { blocked: true },
              isError: true,
            };
          }

          const action = await showGitDialog(
            def.name,
            def.permDescription,
            opKind,
            cwd,
            ctx,
          );

          if (!action || action === "block") {
            return {
              content: [
                {
                  type: "text",
                  text: `Git ${opKind} operation cancelled by user.`,
                },
              ],
              details: { blocked: true },
              isError: true,
            };
          }

          if (action === "allow-reads") {
            readsAllowed = true;
            pi.appendEntry("git-permission", { readsAllowed: true });
          } else if (action === "allow-writes") {
            writeWhitelist.add(def.name);
            pi.appendEntry("git-permission", { writeTool: def.name });
          }
        }

        // Build command
        const allArgs = [...def.args];
        if (params.args) {
          allArgs.push(
            ...params.args.trim().split(/\s+/).filter(Boolean),
          );
        }

        const result = runGit(allArgs, cwd);

        if (result.exitCode !== 0) {
          return {
            content: [
              {
                type: "text",
                text:
                  `git ${allArgs.join(" ")}\n` +
                  `exit code: ${result.exitCode}\n\n` +
                  `stdout:\n${result.stdout || "(empty)"}\n\n` +
                  `stderr:\n${result.stderr}`,
              },
            ],
            details: {
              exitCode: result.exitCode,
              args: allArgs,
            },
            isError: true,
          };
        }

        const output = result.stdout || "(no output)";
        const truncated =
          output.length > 50000
            ? output.slice(0, 50000) +
              `\n\n... [truncated ${output.length - 50000} bytes]`
            : output;

        return {
          content: [
            {
              type: "text",
              text: `git ${allArgs.join(" ")}\n\n${truncated}`,
            },
          ],
          details: {
            exitCode: 0,
            args: allArgs,
            truncated: output.length > 50000,
          },
        };
      },
    });
  }

  // Mid-session reset: bash-permission's /reset-permissions appends
  // { _reset: true } to git-permission entries.  Check on every turn
  // start so in-memory state clears immediately without needing /reload.
  pi.on("before_agent_start", async (_event, ctx) => {
    for (const entry of ctx.sessionManager.getEntries()) {
      if (
        entry.type === "custom" &&
        entry.customType === "git-permission" &&
        entry.data?._reset
      ) {
        readsAllowed = false;
        writeWhitelist.clear();
        return;
      }
    }
  });
}
