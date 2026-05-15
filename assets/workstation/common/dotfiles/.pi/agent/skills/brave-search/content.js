#!/usr/bin/env node

import { Readability } from "@mozilla/readability";
import { JSDOM } from "jsdom";
import TurndownService from "turndown";
import { gfm } from "turndown-plugin-gfm";

const url = process.argv[2];

if (!url) {
	console.log("Usage: content.js <url>");
	console.log("\nExtracts readable content from a webpage as markdown.");
	console.log("\nExamples:");
	console.log("  content.js https://example.com/article");
	console.log("  content.js https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html");
	process.exit(1);
}

// ---- URL validation (used for both initial and redirect URLs) ----
function validateUrl(urlStr) {
	const parsed = new URL(urlStr);
	if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
		console.error(`Blocked: unsupported protocol "${parsed.protocol}". Only http and https are allowed.`);
		process.exit(1);
	}

	const hostname = parsed.hostname.toLowerCase();

	// IPv4 internal ranges
	const ipv4Patterns = [
		/^127\./,
		/^10\./,
		/^172\.(1[6-9]|2\d|3[01])\./,
		/^192\.168\./,
		/^169\.254\./,
		/^0\.0\.0\.0$/,
	];
	for (const pattern of ipv4Patterns) {
		if (pattern.test(hostname)) {
			console.error(`Blocked: internal/private IP "${hostname}" is not allowed.`);
			process.exit(1);
		}
	}

	// Hostname blocklist
	const blockedHostnames = ["localhost", "127.0.0.1", "[::1]"];
	if (blockedHostnames.includes(hostname)) {
		console.error(`Blocked: "${hostname}" is not allowed.`);
		process.exit(1);
	}

	// IPv6 internal ranges
	if (hostname.startsWith("[")) {
		const inner = hostname.slice(1, -1);

		// Block all IPv4-mapped IPv6 — no legitimate use in URL fetching
		if (inner.startsWith("::ffff:")) {
			console.error(`Blocked: IPv4-mapped IPv6 address "${hostname}" is not allowed.`);
			process.exit(1);
		}

		if (inner === "::1" || inner.startsWith("fc") || inner.startsWith("fd") || inner.startsWith("fe8") || inner.startsWith("fe9") || inner.startsWith("fea") || inner.startsWith("feb")) {
			console.error(`Blocked: internal IPv6 address "${hostname}" is not allowed.`);
			process.exit(1);
		}
	}
}

function htmlToMarkdown(html) {
	const turndown = new TurndownService({ headingStyle: "atx", codeBlockStyle: "fenced" });
	turndown.use(gfm);
	turndown.addRule("removeEmptyLinks", {
		filter: (node) => node.nodeName === "A" && !node.textContent?.trim(),
		replacement: () => "",
	});
	return turndown
		.turndown(html)
		.replace(/\[\\?\[\s*\\?\]\]\([^)]*\)/g, "")
		.replace(/ +/g, " ")
		.replace(/\s+,/g, ",")
		.replace(/\s+\./g, ".")
		.replace(/\n{3,}/g, "\n\n")
		.trim();
}

// ---- Guard 3: response size cap (5 MB) ----
const MAX_BYTES = 5 * 1024 * 1024;

async function readResponseBody(response) {
	// Pre-check Content-Length
	const contentLength = response.headers.get("content-length");
	if (contentLength && parseInt(contentLength, 10) > MAX_BYTES) {
		throw new Error(
			`Response too large (${(parseInt(contentLength, 10) / 1024 / 1024).toFixed(1)} MB). Max is 5 MB.`,
		);
	}

	const reader = response.body.getReader();
	const chunks = [];
	let totalBytes = 0;

	while (true) {
		const { done, value } = await reader.read();
		if (done) break;
		totalBytes += value.length;
		if (totalBytes > MAX_BYTES) {
			reader.cancel();
			throw new Error("Response exceeded 5 MB limit.");
		}
		chunks.push(value);
	}

	// Decode all chunks into a string
	const decoder = new TextDecoder();
	return chunks.map((c) => decoder.decode(c, { stream: true })).join("") + decoder.decode();
}

// ---- Validate initial URL, then fetch ----
try {
	validateUrl(url);

	const response = await fetch(url, {
		headers: {
			"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
			"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
			"Accept-Language": "en-US,en;q=0.9",
		},
		signal: AbortSignal.timeout(15000),
	});
	
	if (!response.ok) {
		console.error(`HTTP ${response.status}: ${response.statusText}`);
		process.exit(1);
	}

	// Re-validate final URL after redirects.
	// Note: only catches URL-level redirects, not DNS rebinding
	// (a domain resolving to different IPs between validation and fetch).
	if (response.url !== url) {
		try {
			validateUrl(response.url);
		} catch (_) {
			console.error(`Blocked: redirect target "${response.url}" is invalid.`);
			process.exit(1);
		}
	}

	const html = await readResponseBody(response);
	const dom = new JSDOM(html, { url });
	const reader = new Readability(dom.window.document);
	const article = reader.parse();
	
	if (article && article.content) {
		if (article.title) {
			console.log(`# ${article.title}\n`);
		}
		console.log(htmlToMarkdown(article.content));
		process.exit(0);
	}
	
	// Fallback: try to extract main content
	const fallbackDoc = new JSDOM(html, { url });
	const body = fallbackDoc.window.document;
	body.querySelectorAll("script, style, noscript, nav, header, footer, aside").forEach(el => el.remove());
	
	const title = body.querySelector("title")?.textContent?.trim();
	const main = body.querySelector("main, article, [role='main'], .content, #content") || body.body;
	
	if (title) {
		console.log(`# ${title}\n`);
	}
	
	const text = main?.innerHTML || "";
	if (text.trim().length > 100) {
		console.log(htmlToMarkdown(text));
	} else {
		console.error("Could not extract readable content from this page.");
		process.exit(1);
	}
} catch (e) {
	console.error(`Error: ${e.message}`);
	process.exit(1);
}
