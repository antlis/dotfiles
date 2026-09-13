// rofi-brave-cdp.mjs — Brave DevTools-protocol helper for the Brave cheatsheet.
// Two modes:
//   (no arg)           scrape brave://settings/system/shortcuts and print
//                      `<xdotool keyspec>\t<display>` rows (one per command).
//   fullscreen-toggle  toggle Brave's own window fullscreen (F11-equivalent);
//                      F11 replayed via xdotool reaches Brave but Brave doesn't
//                      act on it under i3, so we drive it over CDP instead.
//
// Brave must be running with --remote-debugging-port (default 9222; override
// with PORT=...). Both modes use a *background* tab (no foreground-tab steal).
//
// Article: https://antlis.is-a.dev/blog/rofi-cheatsheets

const PORT = process.env.PORT || 9222;

// --- CDP plumbing ------------------------------------------------------------
async function connect() {
  const ver = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json();
  const ws = new WebSocket(ver.webSocketDebuggerUrl);
  const pending = new Map();
  ws.addEventListener('message', (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  });
  await new Promise((r) => ws.addEventListener('open', r));
  let id = 0;
  const send = (method, params = {}, sessionId) => new Promise((res) => {
    const mid = ++id; pending.set(mid, res);
    ws.send(JSON.stringify({ id: mid, method, params, sessionId }));
  });
  return { ws, send };
}

// --- token -> xdotool keysym -------------------------------------------------
const MODS = { Control: 'ctrl', Alt: 'alt', Shift: 'shift', Meta: 'super', Command: 'super', Search: 'super', Super: 'super' };
const MOD_PRETTY = { ctrl: 'Ctrl', alt: 'Alt', shift: 'Shift', super: 'Super' };
const KEYS = {
  ArrowLeft: 'Left', ArrowRight: 'Right', ArrowUp: 'Up', ArrowDown: 'Down',
  Enter: 'Return', Return: 'Return', Space: 'space', Tab: 'Tab',
  Backspace: 'BackSpace', Delete: 'Delete', Del: 'Delete', Insert: 'Insert',
  Escape: 'Escape', Esc: 'Escape', PageUp: 'Page_Up', PageDown: 'Page_Down',
  Home: 'Home', End: 'End', Plus: 'plus', Equal: 'equal', '=': 'equal',
  Minus: 'minus', '-': 'minus', Period: 'period', '.': 'period', Comma: 'comma',
  Slash: 'slash', Backslash: 'backslash', Apostrophe: 'apostrophe',
  Quote: 'apostrophe', Semicolon: 'semicolon', Backquote: 'grave',
  BracketLeft: 'bracketleft', BracketRight: 'bracketright',
};
function keySym(k) {
  if (/^[a-zA-Z]$/.test(k)) return k.toLowerCase();
  if (/^[0-9]$/.test(k)) return k;
  if (/^F([1-9]|1[0-9]|2[0-4])$/.test(k)) return k;
  if (KEYS[k]) return KEYS[k];
  return null; // Num*, Browser*/media keys, New/Close/Open hardware keys, etc.
}
function keyPretty(k) {
  if (/^[a-zA-Z]$/.test(k)) return k.toUpperCase();
  const map = { ArrowLeft: '←', ArrowRight: '→', ArrowUp: '↑', ArrowDown: '↓',
    Return: 'Enter', Enter: 'Enter', Escape: 'Esc', PageUp: 'PgUp', PageDown: 'PgDn',
    Backspace: 'Backspace', Delete: 'Del' };
  return map[k] || k;
}
// one accelerator (token array) -> { keyspec, pretty } or null if not fireable
function convert(toks) {
  const mods = [], parts = [];
  let key = null;
  for (const t of toks) {
    if (MODS[t]) { mods.push(MODS[t]); parts.push(MOD_PRETTY[MODS[t]]); }
    else if (t === 'AltGr') return null; // ISO_Level3_Shift — skip
    else { if (key !== null) return null; key = t; }
  }
  if (key === null) return null;
  const sym = keySym(key);
  if (!sym) return null;
  parts.push(keyPretty(key));
  return { keyspec: [...mods, sym].join('+'), pretty: parts.join('+') };
}

// --- mode: scrape shortcuts --------------------------------------------------
async function scrape({ send }) {
  const t = await send('Target.createTarget', { url: 'brave://settings/system/shortcuts', background: true });
  const targetId = t.result.targetId;
  try {
    const a = await send('Target.attachToTarget', { targetId, flatten: true });
    const sessionId = a.result.sessionId;
    await send('Page.enable', {}, sessionId);
    await send('Runtime.enable', {}, sessionId);
    await send('Emulation.setFocusEmulationEnabled', { enabled: true }, sessionId);
    await send('Page.setWebLifecycleState', { state: 'active' }, sessionId);

    const findPage = `(() => {const stack=[document]; while(stack.length){const root=stack.pop(); for(const el of (root.children||[])){ if((el.tagName||'').toLowerCase()==='settings-brave-shortcuts-page') return el; if(el.shadowRoot) stack.push(el.shadowRoot); stack.push(el);}} return null;})()`;
    const extract = `(() => {
      const page = (${findPage}); if(!page||!page.shadowRoot) return null;
      const sr = page.shadowRoot;
      const grids = [...sr.querySelectorAll('[class^="Grid-sc"]')];
      const res = [];
      for (const g of grids) {
        const nameDiv = [...g.children].find(c => c.tagName==='DIV' && !c.className);
        if (!nameDiv) continue;
        const name = nameDiv.textContent.trim();
        const col = g.querySelector('[class^="Column-sc"]');
        const accels = [];
        if (col) for (const row of col.querySelectorAll('[class^="Row-sc"]')) {
          const toks = [];
          for (const kbd of row.querySelectorAll('[class^="Kbd-sc"]')) {
            const txt = kbd.textContent.replace(/[\\u2318\\u2325\\u2303\\u21e7\\u2387\\uf8ff]/g,'').trim();
            if (txt) toks.push(txt);
          }
          if (toks.length) accels.push(toks);
        }
        res.push({ name, accels });
      }
      return JSON.stringify(res);
    })()`;

    let json = null;
    for (let i = 0; i < 30 && !json; i++) {
      await new Promise((r) => setTimeout(r, 400));
      const r = await send('Runtime.evaluate', { expression: extract, returnByValue: true }, sessionId);
      const v = r.result && r.result.result && r.result.result.value;
      if (v && v !== 'null' && v.length > 20) json = v;
    }
    const data = json ? JSON.parse(json) : [];
    const out = [];
    for (const cmd of data) {
      if (!cmd.name) continue;
      const fired = [];
      for (const acc of cmd.accels) { const c = convert(acc); if (c) fired.push(c); }
      if (!fired.length) continue; // unbound or no fireable accelerator
      const combos = [...new Set(fired.map((f) => f.pretty))].join(' / ');
      out.push(`${fired[0].keyspec}\t${cmd.name.padEnd(30)}  ${combos}`);
    }
    process.stdout.write(out.join('\n') + '\n');
  } finally {
    await send('Target.closeTarget', { targetId });
  }
}

// --- mode: toggle Brave's own window fullscreen ------------------------------
async function toggleFullscreen({ send }) {
  // A fresh target is guaranteed to have web contents (many tabs may be
  // discarded by the memory saver, and getWindowForTarget fails on those).
  const t = await send('Target.createTarget', { url: 'about:blank', background: true });
  const targetId = t.result.targetId;
  try {
    const w = await send('Browser.getWindowForTarget', { targetId });
    const { windowId, bounds } = w.result;
    // Exit via 'normal' (fullscreen -> 'maximized' does NOT clear fullscreen);
    // under i3 the window is re-tiled to fill its container either way.
    const next = bounds.windowState === 'fullscreen' ? 'normal' : 'fullscreen';
    await send('Browser.setWindowBounds', { windowId, bounds: { windowState: next } });
  } finally {
    await send('Target.closeTarget', { targetId });
  }
}

async function main() {
  const cmd = process.argv[2];
  const conn = await connect();
  try {
    if (cmd === 'fullscreen-toggle') await toggleFullscreen(conn);
    else await scrape(conn);
  } finally { conn.ws.close(); }
}
main().catch((e) => { console.error('brave-cdp failed:', e.message); process.exit(1); });
