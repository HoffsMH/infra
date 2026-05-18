import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { writeFileSync, unlinkSync } from "node:fs";
import { execSync } from "node:child_process";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("sysprompt", {
    description: "Dump the full system prompt to a temp file and view it in less",
    handler: async (_args, ctx) => {
      const prompt = ctx.getSystemPrompt();
      const tmp = `/tmp/pi-system-prompt-${Date.now()}.txt`;
      writeFileSync(tmp, prompt);
      try {
        execSync(`less ${tmp}`, { stdio: "inherit" });
      } finally {
        unlinkSync(tmp);
      }
    },
  });
}
