/**
 * Answer Extension
 *
 * Parses the previous AI response for questions, asks them interactively
 * to the user one at a time, then feeds the Q&A pairs back to the AI.
 *
 * Usage:
 *   /answer   - extract questions from the last assistant message and answer them
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

function getLastAssistantText(ctx: ExtensionCommandContext): string | null {
  const branch = ctx.sessionManager.getBranch();
  for (let i = branch.length - 1; i >= 0; i--) {
    const entry = branch[i];
    if (entry.type !== "message") continue;
    const msg = entry.message;
    if (!("role" in msg) || msg.role !== "assistant") continue;
    const textParts = msg.content
      .filter((c): c is { type: "text"; text: string } => c.type === "text")
      .map((c) => c.text);
    if (textParts.length > 0) return textParts.join("\n");
  }
  return null;
}

/**
 * Extract questions from text.
 *
 * Strategy: find any sentence ending with "?". Works across list items,
 * numbered items, inline prose. Strips leading bullet/number markers and
 * common markdown emphasis so the prompt reads cleanly.
 */
function extractQuestions(text: string): string[] {
  const questions: string[] = [];
  const seen = new Set<string>();

  // Split into lines, find those containing ?.
  // Line-based matching avoids the period-in-file-path problem
  // (e.g. "answer-extension.ts") that sentence-splitting regex hits.
  const lines = text.split(/\n/);
  for (const rawLine of lines) {
    let line = rawLine.trim();

    // Skip blank lines
    if (!line) continue;

    // Skip markdown code-fence lines (just ``` or ```lang)
    if (/^```\s*\w*$/.test(line)) continue;

    // Strip trailing markdown/whitespace, then check for ?
    // Uses a test-strip so we don't mutate line yet.
    const trailingStripped = line.replace(/[*_`\s]+$/, "");
    if (!trailingStripped.endsWith("?")) continue;

    // Strip leading list/number markers: "- ", "* ", "1. ", "1) ", "**1.** "
    line = line.replace(/^[-*+•]\s+/, "");
    line = line.replace(/^\d+[.)]\s+/, "");
    // Bold-number prefix like **3.**
    line = line.replace(/^\*\*\d+\.?\*\*\s*[:\.\-]?\s*/, "");

    // Strip markdown formatting (emphasis, code spans, links)
    line = line.replace(/\*\*/g, "").replace(/__/g, "").replace(/\*/g, "");
    line = line.replace(/`([^`]+)`/g, "$1");
    // Strip inline links: [text](url) -> text
    line = line.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1");
    // Strip trailing markdown that might follow the ?
    line = line.replace(/\*+$/, "").trim();

    // Collapse whitespace
    line = line.replace(/\s+/g, " ").trim();

    if (line.length < 3) continue;
    if (seen.has(line)) continue;
    seen.add(line);
    questions.push(line);
  }

  return questions;
}

function formatQA(pairs: Array<{ question: string; answer: string }>): string {
  const lines: string[] = [
    "Here are my answers to the questions you asked:",
    "",
  ];
  pairs.forEach((p, i) => {
    lines.push(`${i + 1}. ${p.question}`);
    lines.push(`   ${p.answer}`);
    lines.push("");
  });
  lines.push("Please continue based on these answers.");
  return lines.join("\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("answer", {
    description: "Extract questions from the last AI response and answer them interactively",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) {
        ctx.ui.notify("/answer requires interactive mode", "error");
        return;
      }

      const lastText = getLastAssistantText(ctx);
      if (!lastText) {
        ctx.ui.notify("No previous assistant message found", "error");
        return;
      }

      const questions = extractQuestions(lastText);
      if (questions.length === 0) {
        ctx.ui.notify("No questions found in the last AI response", "warning");
        return;
      }

      ctx.ui.notify(
        `Found ${questions.length} question${questions.length === 1 ? "" : "s"}`,
        "info",
      );

      const pairs: Array<{ question: string; answer: string }> = [];
      for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        const title = `Question ${i + 1}/${questions.length}: ${q}`;
        const answer = await ctx.ui.input(title, "Type your answer...");
        if (answer === null || answer === undefined) {
          ctx.ui.notify("Cancelled", "info");
          return;
        }
        pairs.push({ question: q, answer: answer.trim() || "(no answer)" });
      }

      const reply = formatQA(pairs);
      if (ctx.isIdle()) {
        pi.sendUserMessage(reply);
      } else {
        pi.sendUserMessage(reply, { deliverAs: "followUp" });
      }
      ctx.ui.notify("Answers sent to AI", "info");
    },
  });
}
