// noctalia-bridge.uc.js
// Hot-reload for Noctalia colors in Zen Browser, no restart required.
//
// Polls the mtime of Noctalia.css directly. When it changes, re-reads the
// file, extracts the variables from the single :root block (the template
// uses the "default" placeholders, so the file already follows the active
// Noctalia mode) and applies them two ways:
//
//   1. userChrome coverage: setProperty on the root of every open chrome
//      window — reactive because userChrome.css consumes these same
//      variable names via var(--noctalia-surface) etc.
//
//   2. userContent coverage: registers a global agent stylesheet
//      (nsIStyleSheetService) that redefines the same variables with
//      !important. userContent.css gets them from a static @import of
//      Noctalia.css, which only changes on restart; the agent sheet's
//      important declarations win over it and can be swapped live.
//
// Requires fx-autoconfig installed (injects this file with chrome privileges).

console.log("[noctalia-bridge] script loaded");

(function () {
  function resolveProfileChromeDir() {
    const chromeDir = Services.dirsvc.get("UChrm", Ci.nsIFile);
    return chromeDir.path;
  }

  const CHROME_DIR = resolveProfileChromeDir();
  const CSS_PATH = PathUtils.join(CHROME_DIR, "Noctalia.css");

  const POLL_INTERVAL_MS = 200;
  const POST_CHANGE_DELAY_MS = 60;

  // Must match the variables defined in template.zen.css.
  const VAR_NAMES = [
    "noctalia-primary", "noctalia-primary-hover", "noctalia-primary-active",
    "noctalia-surface", "noctalia-container-low", "noctalia-container",
    "noctalia-container-high", "noctalia-container-highest",
    "noctalia-outline", "noctalia-outline-variant",
    "noctalia-on-surface", "noctalia-on-surface-variant",
    "noctalia-term-red", "noctalia-term-green", "noctalia-term-yellow",
    "noctalia-term-blue", "noctalia-term-purple", "noctalia-term-cyan",
  ];

  let lastMtime = 0;
  let pollTimer = null;
  let contentSheetURI = null;

  function ts() {
    return new Date().toISOString().split("T")[1];
  }

  function parseBlock(cssText) {
    const match = /:root\s*\{([\s\S]*?)\}/.exec(cssText);
    if (!match) return null;

    const body = match[1];
    const vars = new Map();
    for (const name of VAR_NAMES) {
      const varRe = new RegExp(`--${name}\\s*:\\s*([^;]+);`);
      const varMatch = varRe.exec(body);
      if (varMatch) vars.set(name, varMatch[1].trim());
    }
    return vars;
  }

  function applyToChromeWindow(win, vars) {
    const root = win.document.documentElement;
    if (!root) return;
    for (const [name, value] of vars) {
      root.style.setProperty(`--${name}`, value);
    }
  }

  function applyToAllChromeWindows(vars) {
    for (const win of Services.wm.getEnumerator("navigator:browser")) {
      applyToChromeWindow(win, vars);
    }
  }

  // ── userContent coverage: agent sheet with !important ──
  function buildContentCss(vars) {
    const lines = [];
    for (const [name, value] of vars) {
      lines.push(`  --${name}: ${value} !important;`);
    }
    return `:root, * {\n${lines.join("\n")}\n}`;
  }

  function applyContentVars(vars) {
    const sss = Cc["@mozilla.org/content/style-sheet-service;1"]
      .getService(Ci.nsIStyleSheetService);

    if (contentSheetURI) {
      try {
        if (sss.sheetRegistered(contentSheetURI, sss.AGENT_SHEET)) {
          sss.unregisterSheet(contentSheetURI, sss.AGENT_SHEET);
        }
      } catch (e) {
        console.warn("[noctalia-bridge]", ts(), "failed to unregister previous content sheet:", e);
      }
    }

    const cssText = buildContentCss(vars);
    const dataURI = "data:text/css;charset=UTF-8," + encodeURIComponent(cssText);
    contentSheetURI = Services.io.newURI(dataURI);
    sss.loadAndRegisterSheet(contentSheetURI, sss.AGENT_SHEET);
  }

  async function reload() {
    try {
      const cssText = await IOUtils.readUTF8(CSS_PATH);
      const vars = parseBlock(cssText);
      if (!vars || vars.size === 0) {
        console.warn("[noctalia-bridge]", ts(), "no :root block found");
        return;
      }
      applyToAllChromeWindows(vars);
      applyContentVars(vars);
      console.log("[noctalia-bridge]", ts(), "palette applied:", vars.get("noctalia-surface"));
    } catch (e) {
      console.error("[noctalia-bridge]", ts(), "failed to read/apply Noctalia.css:", e);
    }
  }

  async function poll() {
    try {
      const info = await IOUtils.stat(CSS_PATH);
      const mtime = info.lastModified;
      if (mtime !== lastMtime) {
        const isFirstRun = lastMtime === 0;
        lastMtime = mtime;
        if (!isFirstRun) {
          console.log("[noctalia-bridge]", ts(), "change detected, mtime:", mtime);
          await new Promise((r) => setTimeout(r, POST_CHANGE_DELAY_MS));
        }
        await reload();
      }
    } catch (e) {
      console.error("[noctalia-bridge]", ts(), "failed to stat Noctalia.css:", e);
    }
    pollTimer = setTimeout(poll, POLL_INTERVAL_MS);
  }

  reload();
  poll();

  function onWindowCreated(win) {
    IOUtils.readUTF8(CSS_PATH)
      .then((cssText) => {
        const vars = parseBlock(cssText);
        if (vars) applyToChromeWindow(win, vars);
      })
      .catch(() => {});
  }

  try {
    const UC_API = ChromeUtils.importESModule(
      "chrome://userchromejs/content/uc_api.sys.mjs"
    );
    UC_API.Windows.onCreated(onWindowCreated);
  } catch (e) {
    // not critical — new windows still get covered on the next theme change
  }

  const win = Services.wm.getMostRecentWindow("navigator:browser");
  if (win) {
    win.addEventListener("unload", () => {
      if (pollTimer) clearTimeout(pollTimer);
    }, { once: true });
  }
})();
