/**
 * export-markdown.ts — Pi extension: /export-md command
 *
 * Exports the current session to a Markdown file using pi-session-to-md.
 * Output goes to ./pi-session-export-<timestamp>.md in the project root.
 *
 * Usage from within pi:
 *   /export-md                      → auto-named file in cwd
 *   /export-md path/to/out.md       → custom output path
 *   /export-md -b                   → brief mode (collapsed tool outputs)
 *   /export-md -T                   → no thinking blocks
 *   /export-md -t                   → text-only (just user + assistant text)
 *   /export-md -b path/to/out.md    → combined
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";

function timestamp(): string {
  return new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("export-md", {
    description:
      "Export current session to Markdown (agent analysis). Flags: -b brief, -T no-thinking, -t text-only",
    handler: async (args, ctx) => {
      const sessionFile = ctx.sessionManager.getSessionFile();

      if (!sessionFile || !existsSync(sessionFile)) {
        ctx.ui.notify(
          "No session file (ephemeral session). Export works only with persisted sessions.",
          "error"
        );
        return;
      }

      const script = join(process.env.HOME || "~", "bin/pi-session-to-md");

      if (!existsSync(script)) {
        ctx.ui.notify(
          `pi-session-to-md not found at ${script}. Install it first.`,
          "error"
        );
        return;
      }

      // Parse flags and output path from args
      const tokens = (args || "").trim().split(/\s+/);
      const flags: string[] = [];
      let outFile = "";

      for (const t of tokens) {
        if (t === "-b" || t === "--brief") flags.push("-b");
        else if (t === "-T" || t === "--no-thinking") flags.push("-T");
        else if (t === "-t" || t === "--text-only") flags.push("-t");
        else outFile = t;
      }

      if (!outFile) {
        outFile = join(ctx.cwd, `pi-session-export-${timestamp()}.md`);
      } else if (!outFile.startsWith("/")) {
        outFile = join(ctx.cwd, outFile);
      }

      try {
        execSync(
          `node "${script}" ${flags.join(" ")} "${sessionFile}" "${outFile}"`,
          { stdio: "pipe", timeout: 30_000 }
        );

        const flagLabel = flags.length > 0 ? ` (${flags.join("")})` : "";
        ctx.ui.notify(`Exported${flagLabel} → ${outFile}`, "success");
      } catch (err: any) {
        ctx.ui.notify(`Export failed: ${err.message || err}`, "error");
      }
    },
  });
}
