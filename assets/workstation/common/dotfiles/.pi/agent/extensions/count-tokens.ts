/**
 * count-tokens.ts — Pi extension: /tokens command and count_tokens tool
 *
 * Counts tokens in a file without reading it into the LLM's context window.
 * Uses pi's own estimation (chars / 4) — same heuristic pi uses internally.
 * No external dependencies.
 *
 * Usage (interactive):
 *   /tokens <path>                         → quick count
 *   /tokens <path> --cost                  → include $ estimate
 *   /tokens <path> --detail                → full breakdown
 *
 * The agent can call count_tokens directly when you ask
 * "how many tokens is this file?"
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { resolve } from "node:path";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// Token estimation (mirrors pi's internal estimateTokens: chars / 4)
// ---------------------------------------------------------------------------

function estimateTokens(text: string): number {
	return Math.ceil(text.length / 4);
}

// ---------------------------------------------------------------------------
// Cost table ($/1M input tokens) — common models the user might ask about
// ---------------------------------------------------------------------------

interface CostRow {
	input: number;
	cacheHit: number;
	output: number;
}

const COST_TABLE: Record<string, CostRow> = {
	"claude-sonnet-4-20250514": { input: 3.00, cacheHit: 0.30, output: 15.00 },
	"claude-haiku-3-5": { input: 1.00, cacheHit: 0.10, output: 5.00 },
	"gpt-4o": { input: 2.50, cacheHit: 1.25, output: 10.00 },
	"gpt-4o-mini": { input: 0.15, cacheHit: 0.075, output: 0.60 },
	"deepseek-chat": { input: 0.27, cacheHit: 0.07, output: 1.10 },
};

// ---------------------------------------------------------------------------
// Path resolution
// ---------------------------------------------------------------------------

function resolvePath(raw: string, cwd: string): string {
	const expanded = raw.startsWith("~") ? homedir() + raw.slice(1) : raw;
	return resolve(cwd, expanded);
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

function fmt(n: number): string {
	return n.toLocaleString();
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
	// ---- count_tokens tool (callable by the agent) ----

	pi.registerTool({
		name: "count_tokens",
		label: "Count Tokens",
		description:
			"Count tokens in a file without reading it into context. " +
			"Reads the file from disk and estimates tokens using pi's standard heuristic (chars / 4). " +
			"Use this to quickly check a file's size before deciding to read it.",
		promptSnippet: "Count tokens in a file without reading it into context",
		promptGuidelines: [
			"Use count_tokens to check how large a file is in tokens before reading it. " +
				"Prefer this over reading a file first when you only need its size.",
		],
		parameters: Type.Object({
			path: Type.String({ description: "Path to the file to count" }),
		}),

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const { path } = params as { path: string };

			try {
				const absolutePath = resolvePath(path, ctx.cwd);
				const content = await readFile(absolutePath, "utf-8");
				const tokens = estimateTokens(content);
				const chars = content.length;
				const lines = content === "" ? 0 : content.split("\n").length;
				const bytes = Buffer.byteLength(content, "utf-8");
				const tpl = lines > 0 ? Math.round(tokens / lines) : 0;

				const linesOut = [
					`File:   ${absolutePath}`,
					`Tokens: ${fmt(tokens)} (estimated · chars/4)`,
					`Chars:  ${fmt(chars)}`,
					`Lines:  ${fmt(lines)}`,
					`Bytes:  ${fmt(bytes)}`,
					`Ratio:  ${tpl} tok/line · ${(chars / Math.max(tokens, 1)).toFixed(1)} chars/tok`,
				];

				return {
					content: [{ type: "text" as const, text: linesOut.join("\n") }],
					details: {
						path: absolutePath,
						tokens,
						characters: chars,
						lines,
						bytes,
						tokensPerLine: tpl,
						charsPerToken: tokens > 0 ? Math.round((chars / tokens) * 10) / 10 : 0,
					},
				};
			} catch (err) {
				const message = err instanceof Error ? err.message : String(err);
				return {
					content: [{ type: "text" as const, text: `Error: ${message}` }],
					details: { error: message, path },
				};
			}
		},

		renderCall(args: { path?: string }, theme: any) {
			const text = new Text(
				theme.fg("toolTitle", theme.bold("count_tokens ")) +
					theme.fg("muted", args.path ?? "?"),
				0,
				0,
			);
			return text;
		},

		renderResult(
			result: {
				content?: Array<{ text?: string }>;
				details?: Record<string, unknown>;
				isError?: boolean;
			},
			_options: { expanded: boolean; isPartial: boolean },
			theme: any,
		) {
			if (result.isError) {
				return new Text(
					theme.fg("error", "✗ ") +
						theme.fg("dim", result.details?.error ? String(result.details.error) : "Error"),
					0,
					0,
				);
			}

			const d = result.details as
				| { tokens?: number; characters?: number; lines?: number; tokensPerLine?: number }
				| undefined;
			if (!d?.tokens) return new Text(theme.fg("dim", "—"), 0, 0);

			const line = [
				theme.fg("accent", theme.bold(`${fmt(d.tokens)} tokens`)),
				theme.fg("dim", ` · ${fmt(d.characters ?? 0)} chars · ${fmt(d.lines ?? 0)} lines`),
				theme.fg("muted", ` · ${fmt(d.tokensPerLine ?? 0)} tok/line`),
			].join("");

			return new Text(line, 0, 0);
		},
	});

	// ---- /tokens command (interactive use) ----

	pi.registerCommand("tokens", {
		description:
			"Count tokens in a file (chars/4 heuristic). " +
			"Usage: /tokens <path> [--cost] [--detail]",
		handler: async (args, ctx) => {
			const ui = ctx.ui;

			// Parse args
			const parts = args.match(/(?:[^\s"]+|"[^"]*")+/g) ?? [];
			let path = "";
			let showCost = false;
			let showDetail = false;

			for (let i = 0; i < parts.length; i++) {
				const p = parts[i].replace(/(^"|"$)/g, "");
				if (p === "--cost") showCost = true;
				else if (p === "--detail") showDetail = true;
				else if (!path) path = p;
			}

			if (!path) {
				ui.notify("Usage: /tokens <path> [--cost] [--detail]", "warning");
				return;
			}

			try {
				const absolutePath = resolvePath(path, ctx.cwd);
				const content = await readFile(absolutePath, "utf-8");
				const tokens = estimateTokens(content);
				const chars = content.length;
				const lines = content === "" ? 0 : content.split("\n").length;
				const bytes = Buffer.byteLength(content, "utf-8");

				const parts_out: string[] = [`${fmt(tokens)} tok`];
				if (showDetail) {
					parts_out.push(`(${(chars / Math.max(tokens, 1)).toFixed(1)} c/t)`);
				}
				parts_out.push(`· ${fmt(chars)} chars`);
				parts_out.push(`· ${fmt(lines)} lines`);
				parts_out.push(`· ${fmt(bytes)} bytes`);

				// Briefly flash status
				ui.setStatus("tokens", `${fmt(tokens)} tok · ${absolutePath}`);
				setTimeout(() => ui.setStatus("tokens", undefined), 4000);

				let msg = parts_out.join(" ");

				if (showCost) {
					const costLines = Object.entries(COST_TABLE)
						.map(([model, r]) => {
							const c = (tokens / 1_000_000) * r.input;
							return `${model}: $${c.toFixed(4)}`;
						})
						.join(", ");
					msg += `\n${costLines}`;
				}

				ui.notify(msg, "info");
			} catch (err) {
				const message = err instanceof Error ? err.message : String(err);
				ui.notify(`Error: ${message}`, "error");
			}
		},
	});
}
