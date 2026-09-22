import type {
	ExtensionAPI,
	ReadonlyFooterDataProvider,
} from "@earendil-works/pi-coding-agent";

const REFRESH_INTERVAL_MS = 1_000;
const NO_BOOKMARK = "no bookmark";

async function getJjBookmark(pi: ExtensionAPI, cwd: string): Promise<string | null> {
	const result = await pi.exec(
		"jj",
		[
			"--ignore-working-copy",
			"--color=never",
			"log",
			"--no-graph",
			"-r",
			"heads(::@ & bookmarks())",
			"-T",
			'local_bookmarks.map(|bookmark| bookmark.name()).join(", ") ++ "\\n"',
		],
		{ cwd, timeout: 5_000 },
	);
	if (result.code !== 0) return null;

	const bookmarks = result.stdout
		.split("\n")
		.map((bookmark) => bookmark.trim())
		.filter(Boolean);
	return bookmarks.join(", ") || NO_BOOKMARK;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		let bookmark: string | null;
		try {
			bookmark = await getJjBookmark(pi, ctx.cwd);
		} catch (error) {
			ctx.ui.notify(
				`Could not read JJ bookmark: ${error instanceof Error ? error.message : String(error)}`,
				"warning",
			);
			return;
		}
		if (bookmark === null) return;

		let active = true;
		let lastRefresh = Date.now();
		let refreshInFlight = false;
		let restoreGetGitBranch: (() => void) | undefined;

		ctx.ui.setFooter((tui, _theme, footerData) => {
			const originalGetGitBranch = footerData.getGitBranch.bind(footerData);
			const mutableFooterData = footerData as ReadonlyFooterDataProvider & {
				getGitBranch: () => string | null;
			};

			mutableFooterData.getGitBranch = () => {
				const now = Date.now();
				if (active && !refreshInFlight && now - lastRefresh >= REFRESH_INTERVAL_MS) {
					lastRefresh = now;
					refreshInFlight = true;
					void getJjBookmark(pi, ctx.cwd)
						.then((nextBookmark) => {
							if (active && nextBookmark !== null && nextBookmark !== bookmark) {
								bookmark = nextBookmark;
								tui.requestRender();
							}
						})
						.catch((error) => {
							if (active) {
								ctx.ui.notify(
									`Could not refresh JJ bookmark: ${error instanceof Error ? error.message : String(error)}`,
									"warning",
								);
							}
						})
						.finally(() => {
							refreshInFlight = false;
						});
				}
				return bookmark;
			};

			restoreGetGitBranch = () => {
				mutableFooterData.getGitBranch = originalGetGitBranch;
			};

			return {
				render: () => [],
				invalidate() {},
			};
		});
		ctx.ui.setFooter(undefined);

		pi.on("session_shutdown", () => {
			active = false;
			restoreGetGitBranch?.();
		});
	});
}
