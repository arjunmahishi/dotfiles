import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { lastAssistantText } from "./index.ts";

const message = (role, content) => ({ type: "message", message: { role, content } });
const text = (text) => ({ type: "text", text });

test("lastAssistantText uses the supplied branch and only visible assistant text", () => {
	for (const { entries, expected } of [
		{ entries: [], expected: "No previous agent response in this branch." },
		{ entries: [message("user", "hello")], expected: "No previous agent response in this branch." },
		{
			entries: [message("assistant", [text("old")]), message("assistant", [
				{ type: "thinking", thinking: "private" }, text("new"),
				{ type: "toolCall", name: "bash" }, text("second block"),
			]), message("toolResult", [text("tool output")])],
			expected: "new\n\nsecond block",
		},
		{
			entries: [message("assistant", [text("visible")]), message("assistant", [
				text("  "), { type: "toolCall", name: "bash" },
			])],
			expected: "visible",
		},
	]) assert.equal(lastAssistantText(entries), expected);
});

test("Neovim keeps reference edits separate on save, quit, and cancel", () => {
	for (const { command, status, expected, responseText } of [
		{ command: "wq", status: 0, expected: "edited draft\n" },
		{ command: "wqa", status: 0, expected: "edited draft\n" },
		{ command: "wincmd k | wqa", status: 0, expected: "edited draft\n" },
		{ command: "q!", status: 0, expected: "original draft" },
		{ command: "cq", status: 1, expected: "original draft" },
	].flatMap((scenario) => [
		"# Reference\n",
		"# Reference\nUnicode: café 🌍\nvim: set modifiable:\n",
		"# Reference\n" + "line\n".repeat(9),
		"# Reference\n" + "line\n".repeat(10),
		"# Reference\n" + "line\n".repeat(40),
	].map((responseText) => ({ ...scenario, responseText })))) {
		const directory = mkdtempSync(join(tmpdir(), "pi-nvim-test-"));
		try {
			const draft = join(directory, "prompt with spaces.md");
			const response = join(directory, "response.md");
			const assertions = join(directory, "assert.lua");
			writeFileSync(draft, "original draft");
			writeFileSync(response, responseText);
			writeFileSync(assertions, `
local draft = vim.api.nvim_get_current_buf()
assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(draft)) == vim.uv.fs_realpath(vim.env.TEST_DRAFT))
local windows = vim.api.nvim_list_wins()
assert(#windows == 2)
for _, window in ipairs(windows) do
  local buffer = vim.api.nvim_win_get_buf(window)
  if buffer ~= draft then
    local expected_height = math.min(#vim.fn.readfile(vim.env.PI_NVIM_RESPONSE) + 1, math.floor(vim.g.test_editor_height / 2))
    assert(vim.api.nvim_win_get_height(window) == expected_height, "incorrect reference height")
    assert(vim.bo[buffer].buftype == "nofile")
    assert(not vim.bo[buffer].readonly and vim.bo[buffer].modifiable)
    assert(not vim.bo[buffer].modeline)
    assert(vim.api.nvim_buf_get_lines(buffer, 0, 1, false)[1] == "# Reference")
    assert(vim.api.nvim_win_get_position(window)[1] < vim.api.nvim_win_get_position(0)[1])
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {"trimmed reference"})
    assert(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)[1] == "trimmed reference")
    assert(vim.api.nvim_buf_get_lines(draft, 0, -1, false)[1] == "original draft")
  end
end
vim.api.nvim_buf_set_lines(draft, 0, -1, false, {"edited draft"})
vim.cmd(vim.env.TEST_QUIT)
`);
			const result = spawnSync("nvim", [
				"--headless", "-u", "NONE", "-i", "NONE", "-n",
				"--cmd", "set lines=24 laststatus=2 cmdheight=1",
				"-c", "lua vim.g.test_editor_height = vim.api.nvim_win_get_height(0); dofile(vim.env.PI_NVIM_SETUP)",
				"-c", "lua dofile(vim.env.TEST_ASSERTIONS)", "--", draft,
			], {
				encoding: "utf8", timeout: 10000,
				env: { ...process.env,
					PI_NVIM_SETUP: fileURLToPath(new URL("./context.lua", import.meta.url)),
					PI_NVIM_RESPONSE: response, TEST_DRAFT: draft,
					TEST_ASSERTIONS: assertions, TEST_QUIT: command,
				},
			});
			assert.equal(result.error, undefined, `${command}: ${result.error}\n${result.stderr}`);
			assert.equal(result.status, status, result.stderr);
			assert.doesNotMatch(result.stderr, /Error|E\d+:/);
			assert.equal(readFileSync(draft, "utf8"), expected);
			assert.equal(readFileSync(response, "utf8"), responseText);
		} finally {
			rmSync(directory, { recursive: true, force: true });
		}
	}
});
