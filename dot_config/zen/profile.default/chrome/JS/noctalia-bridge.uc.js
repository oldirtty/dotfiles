// noctalia-bridge.uc.js
// Hot-reload das cores do Noctalia no chrome do Zen Browser, sem reiniciar.
//
// Faz polling do mtime de Noctalia.css diretamente. Quando muda, rele o
// arquivo, extrai as variaveis do bloco @media ativo (dark/light) e aplica
// via setProperty na raiz de cada janela de chrome aberta.
//
// Requer fx-autoconfig instalado (injeta este arquivo com privilegios de chrome).

console.log("[noctalia-bridge] script loaded");

(function () {
  const NOCTALIA_DIR = "/home/ian/.config/zen/profile.default/chrome";
  const CSS_PATH = NOCTALIA_DIR + "/Noctalia.css";
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

  function applyToWindow(win, vars) {
    const root = win.document.documentElement;
    if (!root) return;
    for (const [name, value] of vars) {
      root.style.setProperty(`--${name}`, value);
    }
  }

  function applyToAllWindows(vars) {
    for (const win of Services.wm.getEnumerator("navigator:browser")) {
      applyToWindow(win, vars);
    }
  }

  async function reload() {
    try {
      const cssText = await IOUtils.readUTF8(CSS_PATH);
      const mode = prefersDark() ? "dark" : "light";
      const vars = parseBlock(cssText, mode);
      if (!vars || vars.size === 0) {
        console.warn("[noctalia-bridge]", ts(), "nenhum bloco @media encontrado para", mode);
        return;
      }
      applyToAllWindows(vars);
      console.log("[noctalia-bridge]", ts(), "paleta aplicada:", mode, vars.get("bg0"));
    } catch (e) {
      console.error("[noctalia-bridge]", ts(), "falha ao ler/aplicar Noctalia.css:", e);
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
          console.log("[noctalia-bridge]", ts(), "mudança detectada, mtime:", mtime);
          await new Promise((r) => setTimeout(r, POST_CHANGE_DELAY_MS));
        }
        await reload();
      }
    } catch (e) {
      console.error("[noctalia-bridge]", ts(), "falha ao checar mtime:", e);
    }
    pollTimer = setTimeout(poll, POLL_INTERVAL_MS);
  }

  reload();
  poll();

  const win = Services.wm.getMostRecentWindow("navigator:browser");
  if (win) {
    win.addEventListener("unload", () => {
      if (pollTimer) clearTimeout(pollTimer);
    }, { once: true });
  }
})();
