// noctalia-bridge.uc.js
// Hot-reload for Noctalia colors in Zen Browser, no restart required.
//
// Polls the mtime of Noctalia.css directly. When it changes, re-reads the
// file, extracts the variables from the active @media block (dark/light)
// and applies them two ways:
//
//   1. userChrome coverage: setProperty on the root of every open chrome
//      window — reactive because userChrome.css consumes these same
//      variable names via var(--bg0) etc.
//
//   2. userContent coverage: the same variables are re-emitted as a :root
//      block and registered as a global agent stylesheet (nsIStyleSheetService),
//      which also reaches about: pages that userContent.css targets via
//      @-moz-document url-prefix("about:") — those pages don't share the
//      chrome window's inline styles, so they need their own stylesheet.
//
// Requires fx-autoconfig installed (injects this file with chrome privileges).

console.log("[noctalia-bridge] script loaded");

(function () {
  function resolveProfileChromeDir() {
    // Resolves relative to the profile this script is actually running in,
    // instead of a hardcoded path — works across machines/profiles.
    const chromeDir = Services.dirsvc.get("UChrm", Ci.nsIFile);
    return chromeDir.path;
  }

  const CHROME_DIR = resolveProfileChromeDir();
  const CSS_PATH = PathUtils.join(CHROME_DIR, "Noctalia.css");

  const POLL_INTERVAL_MS = 200;
  const POST_CHANGE_DELAY_MS = 60;

  const VAR_NAMES = [
    "accent", "bg0", "bg1", "bg2", "bg3", "bg4", "bg5",
    "fg0", "fg1", "fg2", "fg3", "fg4",
    "accent-hover", "accent-active",
    "red", "green", "yellow", "blue", "purple", "aqua", "gray",
  ];

  let lastMtime = 0;
  let pollTimer = null;
  let contentSheetURI = null;

  function ts() {
    return new Date().toISOString().split("T")[1];
  }

  function prefersDark() {
    try {
      return Services.appinfo.chromeColorSchemeIsDark ??
        Services.prefs.getIntPref("ui.systemUsesDarkTheme", 0) === 1;
    } catch (e) {
      return true;
    }
  }

  // Extracts @media (prefers-color-scheme: dark|light) { :root { ... } }
  // and returns a Map of var -> value.
  function parseBlock(cssText, mode) {
    const blockRe = new RegExp(
      `@media\\s*\\(prefers-color-scheme:\\s*${mode}\\)\\s*\\{[\\s\\S]*?:root\\s*\\{([\\s\\S]*?)\\}`,
      "i"
    );
    const match = blockRe.exec(cssText);
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

  // ── userChrome coverage: inline CSS vars on every chrome window ────────
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

  // ── userContent coverage: global agent stylesheet reaching about: pages ─
  function buildContentCss(vars) {
    const lines = [];
    for (const [name, value] of vars) {
      lines.push(`  --${name}: ${value};`);
    }
    // :root here applies inside every content document the agent sheet
    // reaches, independent of the chrome window's own :root.
    return `:root {\n${lines.join("\n")}\n}`;
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
      const mode = prefersDark() ? "dark" : "light";
      const vars = parseBlock(cssText, mode);
      if (!vars || vars.size === 0) {
        console.warn("[noctalia-bridge]", ts(), "no @media block found for", mode);
        return;
      }
      applyToAllChromeWindows(vars);
      applyContentVars(vars);
      console.log("[noctalia-bridge]", ts(), "palette applied:", mode, vars.get("bg0"));
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

  // Apply once on load (covers restart and brand-new windows)
  reload();
  poll();

  // Also (re-)apply chrome vars when a new window opens, since inline
  // styles on documentElement don't exist yet on windows created after
  // this script's initial run.
  function onWindowCreated(win) {
    IOUtils.readUTF8(CSS_PATH)
      .then((cssText) => {
        const mode = prefersDark() ? "dark" : "light";
        const vars = parseBlock(cssText, mode);
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
