import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("session-metrics", {
    description: "Show PR-ready session time and model costs (usage: /session-metrics [session-id])",
    handler: async (args, ctx) => {
      const id = args.trim();
      const file = id ? undefined : ctx.sessionManager.getSessionFile();
      if (!id && !file) {
        ctx.ui.notify("No active session file; pass an exact session ID.", "error");
        return;
      }

      const script = join(getAgentDir(), "scripts", "session-metrics.py");
      const { code, stdout, stderr } = await pi.exec("python3", [
        script,
        ...(file ? ["--session-file", file] : ["--", id]),
      ]);
      if (code !== 0) {
        ctx.ui.notify(stderr.trim() || `Session metrics failed (exit ${code}).`, "error");
        return;
      }
      ctx.ui.notify(stdout.trim(), "info");
    },
  });
}
