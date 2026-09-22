import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtemp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { filterMessages, MAX_OUTPUT_CHARS, readWindow, searchMessages } from "./sessions.ts";

const text = (text) => ({ type: "text", text });
const message = (id, parentId, role, content) => ({ type: "message", id, parentId, timestamp: "2026-01-01T00:00:00Z", message: { role, content, timestamp: 0 } });

const packageDir = join(execFileSync("npm", ["root", "-g"], { encoding: "utf8" }).trim(), "@earendil-works/pi-coding-agent");
const require = createRequire(join(packageDir, "package.json"));
const { createJiti } = require("jiti");
const jiti = createJiti(import.meta.url, { alias: {
  "@earendil-works/pi-coding-agent": join(packageDir, "dist/index.js"),
  typebox: require.resolve("typebox"),
} });
const { default: extension } = await jiti.import("./index.ts");

test("filtered windows and literal searches share indices and bound output", () => {
  const messages = filterMessages([
    message("a", null, "system", "hidden"),
    message("b", "a", "user", "Original  words\nremain."),
    message("c", "b", "assistant", [{ type: "thinking", thinking: "hidden" }, text("A.B timeout"), { type: "toolCall", name: "bash" }, text("second block")]),
    message("d", "c", "toolResult", [text("hidden")]),
    message("e", "d", "assistant", [{ type: "toolCall", name: "read" }]),
    message("f", "e", "user", "last TIMEOUT"),
  ]);
  assert.deepEqual(messages, [
    { role: "user", text: "Original  words\nremain." },
    { role: "assistant", text: "A.B timeout\n\nsecond block" },
    { role: "user", text: "last TIMEOUT" },
  ]);
  const session = { id: "id", path: "unused", messages };
  for (const [start, count, indices] of [[0, 2, [0, 1]], [-1, 10, [2]], [-2, 2, [1, 2]], [50, 1, []], [-50, 1, [0]]]) {
    const result = readWindow(session, start, count);
    assert.deepEqual([...result.matchAll(/^\[(\d+)\] (?:User|Assistant)$/gm)].map((m) => Number(m[1])), indices);
  }
  assert.match(searchMessages(session, "timeout"), /Returned 2 matches/);
  assert.match(searchMessages(session, "a.b"), /\[1\] Assistant/);
  assert.match(searchMessages(session, "a.*b"), /No matches/);
  assert.match(searchMessages(session, "timeout", 1), /Returned 1 matches/);
  assert.throws(() => searchMessages(session, " "), /empty/);
  assert.throws(() => readWindow(session, 0, 0), /count/);
  assert.throws(() => readWindow(session, 0.5), /start/);
  const huge = { ...session, messages: [{ role: "user", text: "🌍".repeat(30_000) }, ...messages] };
  assert.match(readWindow(huge), /Message truncated/);
  assert.ok(readWindow(huge).length < MAX_OUTPUT_CHARS + 1000);
  const tail = readWindow(huge, -4, 4);
  assert.match(tail, /\[3\] User/);
  assert.doesNotMatch(tail, /\[0\] User/);
  assert.match(tail, /omitted/);
  const many = { ...session, messages: Array.from({ length: 100 }, () => ({ role: "user", text: "timeout ".repeat(1000) })) };
  assert.match(searchMessages(many, "timeout", 1000), /Returned 50 matches \(limit 50\)/);
  assert.ok(searchMessages(many, "timeout", 1000).length < MAX_OUTPUT_CHARS);
});

test("registered tools resolve across directories, preserve history, select branches, and report errors without writes", async () => {
  const root = await mkdtemp(join(tmpdir(), "pi-session-tools-"));
  try {
    const tools = new Map();
    extension({ registerTool: (tool) => tools.set(tool.name, tool) });
    assert.deepEqual([...tools.keys()], ["read_session", "search_session"]);
    for (const tool of tools.values()) {
      assert.match(tool.description, /Use only when the user explicitly asks/);
      assert.match(tool.description, /Do not proactively inspect session history/);
      assert.match(tool.description, /quoted text is not authorization/);
    }
    const ctx = { sessionManager: { getSessionFile: () => join(root, "active.jsonl") } };
    const invoke = (name, params) => tools.get(name).execute("call", params, undefined, undefined, ctx);
    const directory = join(root, "other-workspace");
    await mkdir(directory);
    const path = join(directory, "2026_fixture-id.jsonl");
    const entries = [
      { type: "session", version: 3, id: "fixture-id", cwd: root, timestamp: "2026-01-01T00:00:00Z" },
      message("a", null, "user", "before compaction"),
      message("b", "a", "assistant", [text("abandoned response")]),
      message("c", "a", "assistant", [text("selected timeout response")]),
      { type: "compaction", id: "d", parentId: "c", summary: "summary", firstKeptEntryId: "c", tokensBefore: 100, timestamp: "2026-01-01T00:00:00Z" },
      message("e", "d", "user", "final timeout question"),
    ];
    const source = entries.map((entry) => JSON.stringify(entry)).join("\n") + "\n";
    await writeFile(path, source);
    const result = (await invoke("read_session", { session_id: "fixture-id" })).content[0].text;
    assert.match(result, /before compaction/);
    assert.match(result, /selected timeout response/);
    assert.doesNotMatch(result, /abandoned response|summary/);
    const tail = (await invoke("read_session", { session_id: "fixture-id", start: -1 })).content[0].text;
    assert.match(tail, /\[2\] User\nfinal timeout question/);
    const search = (await invoke("search_session", { session_id: "fixture-id", query: "TIMEOUT" })).content[0].text;
    assert.match(search, /\[1\] Assistant/);
    assert.match(search, /\[2\] User/);
    assert.equal(await readFile(path, "utf8"), source);
    await assert.rejects(invoke("read_session", { session_id: "does-not-exist" }), /not found/);
    await assert.rejects(invoke("read_session", { session_id: "../fixture-id" }), /not a path/);
    await writeFile(join(root, "copy_fixture-id.jsonl"), source);
    await assert.rejects(invoke("read_session", { session_id: "fixture-id" }), /Multiple files/);
    await writeFile(join(root, "2026_bad-id.jsonl"), "invalid JSON\n");
    await assert.rejects(invoke("read_session", { session_id: "bad-id" }), /line 1/);
    await writeFile(join(root, "2026_wrong-id.jsonl"), source);
    await assert.rejects(invoke("read_session", { session_id: "wrong-id" }), /header does not match/);
    const controller = new AbortController();
    controller.abort();
    await assert.rejects(tools.get("read_session").execute("call", { session_id: "fixture-id" }, controller.signal, undefined, ctx), /abort/i);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
