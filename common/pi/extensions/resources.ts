import { homedir } from "node:os";
import type { ExtensionAPI, SourceInfo } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Named = { name: string; sourceInfo: SourceInfo };

// Global = user-level or built-in; repo = project scope.
function groupByScope(items: Named[]): { global: string[]; repo: string[] } {
	const names = (repo: boolean) =>
		items
			.filter((item) => (item.sourceInfo.scope === "project") === repo)
			.map((item) => item.name)
			.sort((a, b) => a.localeCompare(b));
	return { global: names(false), repo: names(true) };
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("resources", {
		description: "Show context files, tools, and skills for this session",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/resources requires interactive mode", "error");
				return;
			}

			const options = ctx.getSystemPromptOptions();
			const home = homedir();
			const contextPaths = (options.contextFiles ?? []).map((file) =>
				file.path.startsWith(home) ? `~${file.path.slice(home.length)}` : file.path,
			);
			const active = new Set(pi.getActiveTools());
			const tools = groupByScope(pi.getAllTools().filter((tool) => active.has(tool.name)));
			const skills = groupByScope(options.skills ?? []);

			await ctx.ui.custom<void>(
				(tui, theme, keybindings, done) => {
					const scoped = (group: { global: string[]; repo: string[] }) => {
						const list = (names: string[]) => (names.length > 0 ? names : [theme.fg("dim", "—")]);
						return [theme.fg("accent", "GLOBAL"), ...list(group.global), "", theme.fg("accent", "REPO"), ...list(group.repo)];
					};
					const columns = [
						{ label: "Context", lines: contextPaths.length > 0 ? contextPaths : [theme.fg("dim", "—")] },
						{ label: "Tools", lines: scoped(tools) },
						{ label: "Skills", lines: scoped(skills) },
					];
					const bodyRows = Math.max(...columns.map((column) => column.lines.length));
					const footer = `${contextPaths.length} context · ${active.size} tools · ${skills.global.length + skills.repo.length} skills`;
					const border = (text: string) => text;
					const cell = (text: string, width: number) => {
						const fitted = truncateToWidth(text, width);
						return fitted + " ".repeat(Math.max(0, width - visibleWidth(fitted)));
					};
					const paddedCell = (text: string, width: number) => ` ${cell(text, width - 1)}`;
					let scrollTop = 0;
					const viewportRows = () => Math.max(3, Math.floor(tui.terminal.rows * 0.8) - 4);
					const scrollBy = (delta: number) => {
						scrollTop = Math.max(0, Math.min(bodyRows - viewportRows(), scrollTop + delta));
						tui.requestRender();
					};

					return {
						render(width: number): string[] {
							// Three columns plus four border characters; context gets the extra space for paths.
							const inner = width - 4;
							const contextWidth = Math.floor(inner * 0.4);
							const toolsWidth = Math.floor((inner - contextWidth) / 2);
							const widths = [contextWidth, toolsWidth, inner - contextWidth - toolsWidth];
							const title = (label: string, w: number) => truncateToWidth(`─ ${label} ${"─".repeat(w)}`, w, "");
							const rows = Math.min(bodyRows, viewportRows());
							const lines = [border("┌") + columns.map((c, i) => border(title(c.label, widths[i]))).join(border("┬")) + border("┐")];
							for (let row = scrollTop; row < scrollTop + rows; row++) {
								const cells = columns.map((c, i) => paddedCell(c.lines[row] ?? "", widths[i]));
								lines.push(border("│") + cells.join(border("│")) + border("│"));
							}
							const hint = bodyRows > rows ? "↑↓ scroll · esc close" : "esc close";
							const gap = Math.max(1, width - 4 - visibleWidth(footer) - visibleWidth(hint));
							lines.push(border("├" + widths.map((w) => "─".repeat(w)).join("┴") + "┤"));
							lines.push(border("│ ") + cell(footer + " ".repeat(gap) + theme.fg("dim", hint), width - 4) + border(" │"));
							lines.push(border("└" + "─".repeat(width - 2) + "┘"));
							return lines;
						},
						handleInput(data: string): void {
							if (keybindings.matches(data, "tui.select.cancel")) done();
							else if (keybindings.matches(data, "tui.select.up")) scrollBy(-1);
							else if (keybindings.matches(data, "tui.select.down")) scrollBy(1);
							else if (keybindings.matches(data, "tui.select.pageUp")) scrollBy(-viewportRows());
							else if (keybindings.matches(data, "tui.select.pageDown")) scrollBy(viewportRows());
						},
						invalidate() {},
					};
				},
				{ overlay: true, overlayOptions: { width: "80%" } },
			);
		},
	});
}
