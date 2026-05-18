/**
 * list-stack.ts — Pi extension: /stack command
 *
 * Lists all loaded extensions, skills, prompts, and tools grouped by scope
 * (global ~/.pi/agent/ vs project .pi/ vs ancestor .agents/).
 *
 * Usage:
 *   /stack           — full breakdown with descriptions
 *   /stack names     — just names and scopes (compact)
 *   /stack tools     — all tools with descriptions
 *   /stack commands  — all /commands with descriptions
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile, readdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join, relative, resolve } from "node:path";

// ---------------------------------------------------------------------------
// Scope labels — explicit, no guessing
// ---------------------------------------------------------------------------

const SCOPE_TAG: Record<string, string> = {
	user: "[global]",
	project: "[project]",
	temporary: "[explicit]",
};

const SCOPE_DESCRIBE: Record<string, string> = {
	user: "~/.pi/agent/",
	project: ".pi/ or .agents/",
	temporary: "--flag / -e / packages",
};

// ---------------------------------------------------------------------------
// Extract description from file header
// ---------------------------------------------------------------------------

async function extractDescription(filePath: string): Promise<string | null> {
	try {
		const content = await readFile(filePath, "utf-8");
		const lines = content.split("\n");

		if (filePath.endsWith(".md")) {
			// Frontmatter: check for --- description: ... ---
			if (lines[0]?.trim() === "---") {
				for (let i = 1; i < Math.min(lines.length, 30); i++) {
					const trimmed = lines[i].trim();
					if (trimmed === "---") break;
					const match = trimmed.match(/^description:\s*"(.+)"$/);
					if (match) return match[1];
					const match2 = trimmed.match(/^description:\s*(.+)$/);
					if (match2) return match2[1];
				}
			}
			// Fallback: first non-empty line after frontmatter
			let inFrontmatter = lines[0]?.trim() === "---";
			for (let i = 1; i < Math.min(lines.length, 20); i++) {
				const trimmed = lines[i].trim();
				if (inFrontmatter && trimmed === "---") {
					inFrontmatter = false;
					continue;
				}
				if (inFrontmatter) continue;
				if (trimmed && !trimmed.startsWith("#") && !trimmed.startsWith(">")) {
					return trimmed.substring(0, 100);
				}
			}
			return null;
		}

		if (filePath.endsWith(".ts")) {
			// JSDoc or block comment at the top
			if (lines[0]?.trim().startsWith("/**")) {
				const descLines: string[] = [];
				for (let i = 1; i < Math.min(lines.length, 30); i++) {
					const trimmed = lines[i].trim();
					if (trimmed.startsWith("*/")) break;
					const cleaned = trimmed.replace(/^\s*\*\s?/, "");
					if (cleaned && !cleaned.startsWith("@")) descLines.push(cleaned);
				}
				return descLines.join(" ").substring(0, 120) || null;
			}
			// Single-line comment at the top
			if (lines[0]?.trim().startsWith("//")) {
				const desc = lines[0].replace(/^\/\/\s*/, "").substring(0, 120);
				return desc || null;
			}
			return null;
		}

		return null;
	} catch {
		return null;
	}
}

// ---------------------------------------------------------------------------
// Scan directories
// ---------------------------------------------------------------------------

interface ScannedEntry {
	name: string;
	path: string;
	scope: string;
	scopeDir: string;
	description: string | null;
}

async function scanDir(
	dir: string,
	scope: string,
	scopeDir: string,
): Promise<ScannedEntry[]> {
	try {
		const entries = await readdir(dir, { withFileTypes: true });
		const result: ScannedEntry[] = [];

		for (const e of entries) {
			if (e.isDirectory()) {
				const sub = join(dir, e.name);
				if (existsSync(join(sub, "SKILL.md"))) {
					const sp = join(sub, "SKILL.md");
					result.push({
						name: e.name,
						path: sp,
						scope,
						scopeDir,
						description: await extractDescription(sp),
					});
				} else if (existsSync(join(sub, "index.ts"))) {
					const ip = join(sub, "index.ts");
					result.push({
						name: e.name,
						path: ip,
						scope,
						scopeDir,
						description: await extractDescription(ip),
					});
				}
				// package.json with pi.extensions
				const pkgPath = join(sub, "package.json");
				if (existsSync(pkgPath)) {
					try {
						const pkg = JSON.parse(
							require("fs").readFileSync(pkgPath, "utf8"),
						);
						if (pkg.pi?.extensions) {
							const ep = join(sub, pkg.pi.extensions[0] ?? "index.ts");
							result.push({
								name: e.name,
								path: ep,
								scope,
								scopeDir,
								description: await extractDescription(ep),
							});
						}
					} catch {}
				}
			} else if (e.name.endsWith(".ts") || e.name.endsWith(".js")) {
				const fp = join(dir, e.name);
				result.push({
					name: e.name.replace(/\.(ts|js)$/, ""),
					path: fp,
					scope,
					scopeDir,
					description: await extractDescription(fp),
				});
			} else if (e.name.endsWith(".md")) {
				const fp = join(dir, e.name);
				result.push({
					name: e.name.replace(/\.md$/, ""),
					path: fp,
					scope,
					scopeDir,
					description: await extractDescription(fp),
				});
			}
		}

		return result;
	} catch {
		return [];
	}
}

interface ExtDirs {
	extensions: ScannedEntry[];
	skills: ScannedEntry[];
	prompts: ScannedEntry[];
	themes: ScannedEntry[];
}

async function scanAllScopes(cwd: string): Promise<ExtDirs> {
	const globalAgent = join(homedir(), ".pi", "agent");
	const projectPi = join(cwd, ".pi");

	// Walk up from cwd for .agents/ dirs
	const agentsDirs: string[] = [];
	const ancestors: string[] = [];
	let cur = resolve(cwd);
	let last = "";
	while (cur !== last) {
		ancestors.push(cur);
		last = cur;
		cur = resolve(cur, "..");
	}
	for (const dir of ancestors) {
		const ad = join(dir, ".agents");
		if (existsSync(ad)) agentsDirs.push(ad);
	}

	const scopes: Array<{
		dir: string;
		scope: string;
		scopeDir: string;
		label: keyof ExtDirs;
	}> = [
		{ dir: join(globalAgent, "extensions"), scope: "user", scopeDir: "~/.pi/agent/", label: "extensions" },
		{ dir: join(globalAgent, "skills"), scope: "user", scopeDir: "~/.pi/agent/", label: "skills" },
		{ dir: join(globalAgent, "prompts"), scope: "user", scopeDir: "~/.pi/agent/", label: "prompts" },
		{ dir: join(globalAgent, "themes"), scope: "user", scopeDir: "~/.pi/agent/", label: "themes" },
		{ dir: join(projectPi, "extensions"), scope: "project", scopeDir: ".pi/", label: "extensions" },
		{ dir: join(projectPi, "skills"), scope: "project", scopeDir: ".pi/", label: "skills" },
		{ dir: join(projectPi, "prompts"), scope: "project", scopeDir: ".pi/", label: "prompts" },
		{ dir: join(projectPi, "themes"), scope: "project", scopeDir: ".pi/", label: "themes" },
	];

	for (const ad of agentsDirs) {
		scopes.push(
			{ dir: ad, scope: "project", scopeDir: relative(cwd, ad) || ".agents/", label: "skills" },
			{ dir: ad, scope: "project", scopeDir: relative(cwd, ad) || ".agents/", label: "prompts" },
		);
	}

	const result: ExtDirs = { extensions: [], skills: [], prompts: [], themes: [] };

	for (const s of scopes) {
		const entries = await scanDir(s.dir, s.scope, s.scopeDir);
		result[s.label].push(...entries);
	}

	return result;
}

// ---------------------------------------------------------------------------
// Format helpers
// ---------------------------------------------------------------------------

function fmt(n: number): string {
	return n.toLocaleString();
}

function scopeTag(scope: string, theme: any): string {
	const tag = SCOPE_TAG[scope] ?? `[${scope}]`;
	const dir = SCOPE_DESCRIBE[scope] ?? scope;
	return theme.fg("dim", `${tag} ${dir}`);
}

function scopeBadge(scope: string, theme: any): string {
	const tag = SCOPE_TAG[scope] ?? `[${scope}]`;
	return theme.fg("muted", tag);
}

// ---------------------------------------------------------------------------
// Match a disk entry to its registered commands/tools
// ---------------------------------------------------------------------------

function matchEntry(
	entry: ScannedEntry,
	cmds: ReturnType<ExtensionAPI["getCommands"]>,
	tools: ReturnType<ExtensionAPI["getAllTools"]>,
) {
	const entryBase = entry.path
		.replace(/\/src\/index\.ts$/, "")
		.replace(/\/index\.ts$/, "")
		.replace(/\.ts$/, "")
		.replace(/\.md$/, "");

	const matchedCmds = cmds.filter(
		(c) => c.sourceInfo.path && c.sourceInfo.path.startsWith(entryBase),
	);
	const matchedTools = tools.filter(
		(t) => t.sourceInfo.path && t.sourceInfo.path.startsWith(entryBase),
	);

	return { commands: matchedCmds, tools: matchedTools };
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
	pi.registerCommand("stack", {
		description:
			"Show loaded extensions, skills, prompts, and tools grouped by scope. " +
			"Usage: /stack [names|tools|commands]",
		handler: async (args, ctx) => {
			const ui = ctx.ui;
			const theme = ui.theme;
			const mode = (args || "").trim().toLowerCase();

			if (mode === "tools") {
				showTools(pi, ui, theme);
				return;
			}

			if (mode === "commands") {
				showCommands(pi, ui, theme);
				return;
			}

			const compact = mode === "names";
			const dirs = await scanAllScopes(ctx.cwd);
			const allCommands = pi.getCommands();
			const allTools = pi.getAllTools();

			const extCommands = allCommands.filter((c) => c.source === "extension");
			const skillCommands = allCommands.filter((c) => c.source === "skill");
			const promptCommands = allCommands.filter((c) => c.source === "prompt");
			const customTools = allTools.filter(
				(t) => t.sourceInfo.source !== "builtin" && t.sourceInfo.source !== "sdk",
			);
			const builtinTools = allTools.filter((t) => t.sourceInfo.source === "builtin");

			const lines: string[] = [];
			const h = (s: string) => theme.fg("toolTitle", theme.bold(s));
			const dim = (s: string) => theme.fg("dim", s);
			const acc = (s: string) => theme.fg("accent", s);
			const mut = (s: string) => theme.fg("muted", s);

			lines.push(h("╒══ Resource Stack ══╗"));
			lines.push("");

			// ── Extensions ──
			lines.push(h("Extensions"));
			if (dirs.extensions.length === 0) {
				lines.push(dim("  (none)"));
			}
			for (const e of dirs.extensions) {
				const { commands: cmds, tools: tools } = matchEntry(e, extCommands, customTools);
				const tag = scopeBadge(e.scope, theme);
				const desc = e.description ? dim(e.description) : "";

				const tags: string[] = [];
				for (const t of tools) tags.push(dim(t.name));
				for (const c of cmds) tags.push(mut("/" + c.name));

				if (compact) {
					lines.push(`  ${tag}  ${acc(e.name)}`);
				} else {
					lines.push(`  ${tag}  ${acc(e.name)}${desc ? "  " + desc : ""}`);
					if (tags.length > 0) {
						lines.push(`         ${tags.join(dim(" · "))}`);
					}
				}
			}
			lines.push("");

			// ── Skills ──
			lines.push(h("Skills"));
			const hasSkills = dirs.skills.length > 0 || skillCommands.length > 0;
			if (!hasSkills) {
				lines.push(dim("  (none)"));
			}
			for (const s of dirs.skills) {
				const cmd = skillCommands.find(
					(c) => c.sourceInfo.path === s.path,
				);
				const tag = scopeBadge(s.scope, theme);
				const desc = s.description ? dim(s.description) : "";
				const cmdName = cmd ? mut(" /skill:" + cmd.name) : "";

				if (compact) {
					lines.push(`  ${tag}  ${acc(s.name)}${cmdName}`);
				} else {
					lines.push(
						`  ${tag}  ${acc(s.name)}${cmdName}${desc ? "  " + desc : ""}`,
					);
				}
			}
			for (const cmd of skillCommands) {
				if (!dirs.skills.some((s) => s.path === cmd.sourceInfo.path)) {
					const tag = scopeBadge(cmd.sourceInfo.scope ?? "temporary", theme);
					lines.push(
						`  ${tag}  ${acc(cmd.name)}  ${mut("/skill:" + cmd.name)}  ${dim(cmd.description ?? "")}`,
					);
				}
			}
			lines.push("");

			// ── Prompt Templates ──
			lines.push(h("Prompt Templates"));
			const hasPrompts = dirs.prompts.length > 0 || promptCommands.length > 0;
			if (!hasPrompts) {
				lines.push(dim("  (none)"));
			}
			for (const p of dirs.prompts) {
				const cmd = promptCommands.find(
					(c) => c.sourceInfo.path === p.path,
				);
				const tag = scopeBadge(p.scope, theme);
				const desc = p.description ? dim(p.description) : "";
				const cmdName = cmd ? mut(" /" + cmd.name) : "";

				if (compact) {
					lines.push(`  ${tag}  ${acc(p.name)}${cmdName}`);
				} else {
					lines.push(
						`  ${tag}  ${acc(p.name)}${cmdName}${desc ? "  " + desc : ""}`,
					);
				}
			}
			lines.push("");

			// ── Tools ──
			lines.push(h("Tools"));
			lines.push(
				`  ${dim("builtin")}  ${acc(fmt(builtinTools.length))}  ` +
					builtinTools.map((t) => dim(t.name)).join(dim(", ")),
			);
			if (customTools.length > 0) {
				const byScope = new Map<string, typeof customTools>();
				for (const t of customTools) {
					const scope = t.sourceInfo.scope ?? "temporary";
					if (!byScope.has(scope)) byScope.set(scope, []);
					byScope.get(scope)!.push(t);
				}
				for (const [scope, tools] of byScope) {
					lines.push(
						`  ${scopeBadge(scope, theme)}  ${acc(fmt(tools.length))}  ` +
							tools.map((t) => dim(t.name)).join(dim(", ")),
					);
				}
			}
			lines.push("");

			// ── Commands ──
			lines.push(h("Commands"));
			const cmdSections = [
				{ label: "extension", cmds: extCommands },
				{ label: "skill", cmds: skillCommands },
				{ label: "prompt", cmds: promptCommands },
			];
			let anyCmds = false;
			for (const { label, cmds } of cmdSections) {
				if (cmds.length === 0) continue;
				anyCmds = true;
				const scopeInfo = [
					...new Set(cmds.map((c) => c.sourceInfo.scope).filter(Boolean)),
				]
					.map((s) => SCOPE_DESCRIBE[s!] ?? s!)
					.join(", ");
				lines.push(
					`  ${dim(label)}  ${acc(fmt(cmds.length))}  ` +
						cmds.map((c) => mut("/" + c.name)).join(dim(", ")) +
						dim(`  [${scopeInfo}]`),
				);
			}
			if (!anyCmds) lines.push(dim("  (none)"));
			lines.push("");

			lines.push(h("╘══════════════════════╛"));

			ui.notify(lines.join("\n"), "info");
		},
	});
}

// ---------------------------------------------------------------------------
// Sub-commands: /stack tools and /stack commands
// ---------------------------------------------------------------------------

function showTools(pi: ExtensionAPI, ui: any, theme: any) {
	const allTools = pi.getAllTools();
	const dim = (s: string) => theme.fg("dim", s);
	const acc = (s: string) => theme.fg("accent", s);
	const mut = (s: string) => theme.fg("muted", s);

	const lines: string[] = [];

	const builtin = allTools.filter((t) => t.sourceInfo.source === "builtin");
	lines.push(theme.fg("toolTitle", theme.bold("Built-in Tools")));
	for (const t of builtin) {
		lines.push(`  ${acc(t.name)}  ${dim(t.description?.substring(0, 80) ?? "")}`);
	}

	const extTools = allTools.filter(
		(t) => t.sourceInfo.source !== "builtin" && t.sourceInfo.source !== "sdk",
	);
	if (extTools.length > 0) {
		lines.push("");
		lines.push(theme.fg("toolTitle", theme.bold("Extension Tools")));
		for (const t of extTools) {
			const scope = SCOPE_TAG[t.sourceInfo.scope ?? "temporary"] ?? t.sourceInfo.scope;
			const src = t.sourceInfo.path
				? dim(t.sourceInfo.path.replace(homedir(), "~"))
				: dim(scope);
			lines.push(`  ${mut(scope)} ${acc(t.name)}  ${dim(t.description?.substring(0, 80) ?? "")}`);
			lines.push(`       ${src}`);
		}
	}

	ui.notify(lines.join("\n"), "info");
}

function showCommands(pi: ExtensionAPI, ui: any, theme: any) {
	const allCommands = pi.getCommands();
	const dim = (s: string) => theme.fg("dim", s);
	const acc = (s: string) => theme.fg("accent", s);
	const mut = (s: string) => theme.fg("muted", s);

	const bySource = new Map<string, typeof allCommands>();
	for (const c of allCommands) {
		if (!bySource.has(c.source)) bySource.set(c.source, []);
		bySource.get(c.source)!.push(c);
	}

	const lines: string[] = [];

	for (const [source, cmds] of bySource) {
		lines.push(
			theme.fg("toolTitle", theme.bold(`${source} commands (${cmds.length})`)),
		);
		for (const c of cmds) {
			const scope = SCOPE_TAG[c.sourceInfo.scope ?? "temporary"] ?? c.sourceInfo.scope;
			const desc = c.description ? dim(c.description) : "";
			lines.push(`  ${mut(scope)} ${acc("/" + c.name)}  ${desc}`);
		}
		lines.push("");
	}

	ui.notify(lines.join("\n"), "info");
}
