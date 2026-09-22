import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";

export function lastAssistantText(entries: readonly SessionEntry[]): string {
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const text = entry.message.content
			.filter((block) => block.type === "text")
			.map((block) => block.text)
			.join("\n\n");
		if (text.trim()) return text;
	}
	return "No previous agent response in this branch.";
}

export default function (pi: ExtensionAPI) {
	pi.registerShortcut("ctrl+g", {
		description: "Edit in Neovim with the previous agent response",
		handler: async (ctx) => {
			if (ctx.mode !== "tui") return;
			let directory: string | undefined;
			try {
				directory = mkdtempSync(join(tmpdir(), "pi-nvim-context-"));
				const draftPath = join(directory, "prompt.md");
				const responsePath = join(directory, "response.md");
				writeFileSync(draftPath, ctx.ui.getEditorText(), { mode: 0o600 });
				writeFileSync(responsePath, lastAssistantText(ctx.sessionManager.getBranch()), { mode: 0o600 });
				const result = await ctx.ui.custom<ReturnType<typeof spawnSync>>((tui, _theme, _kb, done) => {
					tui.stop();
					let editorResult: ReturnType<typeof spawnSync>;
					try {
						editorResult = spawnSync("nvim", ["-c", "lua dofile(vim.env.PI_NVIM_SETUP)", "--", draftPath], {
							stdio: "inherit",
							cwd: ctx.cwd,
							env: {
								...process.env,
								PI_NVIM_SETUP: fileURLToPath(new URL("./context.lua", import.meta.url)),
								PI_NVIM_RESPONSE: responsePath,
							},
						});
					} finally {
						tui.start();
						tui.requestRender(true);
					}
					done(editorResult);
					return { render: () => [], invalidate() {} };
				});
				if (result.error) throw result.error;
				if (result.status === 0) {
					ctx.ui.setEditorText(readFileSync(draftPath, "utf8").replace(/^\uFEFF/, "").replace(/\n$/, ""));
				} else {
					ctx.ui.notify(`Neovim exited (${result.signal ?? result.status}); draft unchanged.`, "warning");
				}
			} catch (error) {
				ctx.ui.notify(`Could not edit in Neovim: ${error instanceof Error ? error.message : String(error)}`, "error");
			} finally {
				if (directory) {
					try {
						rmSync(directory, { recursive: true, force: true });
					} catch (error) {
						ctx.ui.notify(`Could not remove ${directory}: ${String(error)}`, "warning");
					}
				}
			}
		},
	});
}
