import { constants } from "node:fs";
import { mkdtemp, open, realpath, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { extname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { Type } from "typebox";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const imageSignatures: Record<string, (data: Buffer) => boolean> = {
	".png": (data) => data.subarray(0, 8).equals(Buffer.from("89504e470d0a1a0a", "hex")),
	".jpg": (data) => data[0] === 0xff && data[1] === 0xd8 && data[2] === 0xff,
	".jpeg": (data) => imageSignatures[".jpg"](data),
	".gif": (data) => /^(GIF87a|GIF89a)$/.test(data.toString("ascii", 0, 6)),
	".webp": (data) => data.toString("ascii", 0, 4) === "RIFF" && data.toString("ascii", 8, 12) === "WEBP",
	".avif": (data) => data.toString("ascii", 4, 8) === "ftyp" && /^(avif|avis)$/.test(data.toString("ascii", 8, 12)),
};

export async function prepareBrowserFile(path: string, cwd: string) {
	if (!path.trim() || /^[a-z][a-z\d+.-]*:/i.test(path)) {
		throw new Error("Provide a local file path, not a URL.");
	}
	const source = await realpath(resolve(cwd, path));
	const extension = extname(source).toLowerCase();
	const textPreview = [".md", ".markdown", ".txt"].includes(extension);
	if (!textPreview && ![".html", ".htm", ".svg"].includes(extension) && !imageSignatures[extension]) {
		throw new Error(`Unsupported browser format: ${extension || "(no extension)"}`);
	}
	// Nonblocking open avoids hanging if a path points to a FIFO instead of a file.
	const file = await open(source, constants.O_RDONLY | constants.O_NONBLOCK);
	let data: Buffer;
	try {
		if (!(await file.stat()).isFile()) throw new Error("Path must be a regular file.");
		data = await file.readFile();
	} finally {
		await file.close();
	}
	if (imageSignatures[extension]) {
		if (!imageSignatures[extension](data)) throw new Error("File contents do not match the image format.");
		return { source, url: pathToFileURL(source).href };
	}
	const text = new TextDecoder("utf-8", { fatal: true }).decode(data);
	if (text.includes("\0")) throw new Error("Binary contents are not supported.");
	if (!textPreview) {
		const marker = extension === ".svg" ? /<svg(?:\s|>)/i : /<!doctype\s+html(?:\s|>)|<html(?:\s|>)/i;
		if (!marker.test(text)) throw new Error("File contents do not match the document format.");
		return { source, url: pathToFileURL(source).href };
	}
	const escape = (value: string) => value.replace(/[&<>"']/g, (character) => ({
		"&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
	})[character]!);
	const directory = await mkdtemp(join(tmpdir(), "pi-browser-"));
	try {
		const preview = join(directory, "preview.html");
		await writeFile(preview, `<!doctype html><html><head><meta charset="utf-8"><meta http-equiv="Content-Security-Policy" content="default-src 'none'"><title>${escape(source)}</title></head><body><pre>${escape(text)}</pre></body></html>`, { mode: 0o600 });
		return { source, url: pathToFileURL(preview).href, directory };
	} catch (error) {
		await rm(directory, { recursive: true, force: true });
		throw error;
	}
}

export default function (pi: ExtensionAPI) {
	let stopwatch: ReturnType<typeof setInterval> | undefined;
	const previews = new Set<string>();

	pi.registerTool({
		name: "open_in_browser",
		label: "Open in browser",
		description: "Show a local file in the user's default browser (macOS). Supports HTML, SVG, PNG, JPEG, GIF, WebP, AVIF, and UTF-8 text/Markdown. Text and Markdown are shown as escaped raw text in a temporary HTML preview. Rejects URLs, directories, missing files, and unsupported formats such as PDF. HTML and SVG are opened directly and may run scripts or load remote resources; browser settings can override normal display behavior. Use to show the user existing files or agent-generated artifacts, including HTML diagrams, mockups, and explanations during planning or discussion. Create the file first, then call this tool; the user does not need to name the file explicitly.",
		parameters: Type.Object({
			path: Type.String({ minLength: 1, description: "Absolute local file path, or path relative to the current working directory." }),
		}),
		async execute(_id, params, signal, _update, ctx) {
			if (process.platform !== "darwin") throw new Error("Opening files in the default browser currently requires macOS.");
			signal?.throwIfAborted();
			const file = await prepareBrowserFile(params.path, ctx.cwd);
			try {
				signal?.throwIfAborted();
				const browser = await pi.exec("osascript", ["-l", "JavaScript", "-e", 'ObjC.import("AppKit"); var app = $.NSWorkspace.sharedWorkspace.URLForApplicationToOpenURL($.NSURL.URLWithString("https://example.com")); $.NSBundle.bundleWithURL(app).bundleIdentifier.js;'], { signal, timeout: 10_000 });
				if (browser.code !== 0 || !browser.stdout.trim()) {
					throw new Error(`Could not determine the default browser: ${browser.stderr || browser.stdout}`);
				}
				const result = await pi.exec("open", ["-b", browser.stdout.trim(), file.url], { signal, timeout: 10_000 });
				if (result.code !== 0) throw new Error(`Could not open browser: ${result.stderr || result.stdout}`);
				if (file.directory) previews.add(file.directory);
				return { content: [{ type: "text", text: `Requested browser open for ${file.source}${file.directory ? " (raw-text preview)" : ""}.` }], details: undefined };
			} catch (error) {
				if (file.directory) await rm(file.directory, { recursive: true, force: true });
				throw error;
			}
		},
	});

	const stopStopwatch = () => {
		if (stopwatch !== undefined) {
			clearInterval(stopwatch);
			stopwatch = undefined;
		}
	};

	pi.on("agent_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		stopStopwatch();
		const startedAt = performance.now();
		const updateStopwatch = () => {
			const elapsedSeconds = Math.floor((performance.now() - startedAt) / 1_000);
			const minutes = String(Math.floor(elapsedSeconds / 60)).padStart(2, "0");
			const seconds = String(elapsedSeconds % 60).padStart(2, "0");
			ctx.ui.setWorkingMessage(`Working [${minutes}:${seconds}]`);
		};

		updateStopwatch();
		stopwatch = setInterval(updateStopwatch, 1_000);
	});

	pi.on("agent_end", (_event, ctx) => {
		stopStopwatch();
		if (ctx.mode === "tui") ctx.ui.setWorkingMessage();
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		for (const directory of previews) {
			await rm(directory, { recursive: true, force: true });
			previews.delete(directory);
		}
		stopStopwatch();
		if (ctx.mode === "tui") ctx.ui.setWorkingMessage();
	});
}
