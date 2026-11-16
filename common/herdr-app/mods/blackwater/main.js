import { View } from "gpui-kit";
import { props } from "herdr";
import Chrome from "./chrome.js";
import Spaces from "./spaces.js";
import Agents from "./agents.js";
import Tabs from "./tabs.js";

const ROLES = { chrome: Chrome, spaces: Spaces, agents: Agents, tabs: Tabs };

export default class Blackwater extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const Role = ROLES[pr.role ?? "chrome"];
    if (!Role) throw new Error(`Unknown Blackwater role: ${pr.role}`);
    this.role = new Role();
    this.role.init?.(pr, cx);
  }

  render(cx) {
    return this.role.render(cx);
  }
}
