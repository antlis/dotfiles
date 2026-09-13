# rofi cheatsheets

A set of standalone **executable** keybinding cheatsheets for rofi. Each one
lists an app's shortcuts in a fullscreen rofi menu, and — for most apps —
**pressing Enter performs the shortcut**, not just shows it.

They're deployed as a live out-of-store symlink
(`~/.local/share/rofi-cheatsheets` → this dir via home-manager), so editing a
script takes effect immediately, no rebuild.

- Article (EN): https://antlis.is-a.dev/blog/rofi-cheatsheets

## Shared anatomy

Every sheet follows the same shape:

```
gather items  →  rofi -dmenu -format i  →  act on the selection
```

- **Fullscreen** via the shared theme idiom
  (`-theme-str 'window { fullscreen: true; } mainbox { padding: 2%; } …'`).
- `-format i` returns the selected **index**, so a parallel `real[]` array maps
  the pretty row back to a runnable command / keyspec.
- Rows are tab-delimited `realcmd\tprettylabel` where a script needs to keep the
  real action separate from the display text (avoids `eval` on generated code).

## The launcher + the two i3 bindings

`rofi-keybindings` is the entry point:

| Invocation | i3 binding | What it does |
|---|---|---|
| `rofi-keybindings` | `mod+/` | Pick a sheet, then browse/act on it |
| `rofi-keybindings all` | **`mod+Shift+/`** | **Show ALL keybindings** from every sheet in one flat, single-column list, each row tagged `[source]` |

### "Show all keybindings" mode (`mod+Shift+/`)

The `all` mode aggregates every sheet into one searchable list — great when you
know *what* you want but not *which app's* shortcut it is. Implementation notes:

- Each sheet exposes an **`--emit-sh`** mode that prints self-contained
  `command<TAB>label` rows (no rofi). The launcher merges them, prefixes a
  fixed-width `[source]` tag, shows one rofi, and runs the chosen command.
- Sheets are gathered **in parallel** (`&` + `wait`), so the list is as slow as
  the *slowest* sheet, not the sum of all of them.
- Apps that aren't running emit nothing and silently drop out.
- Firing goes through one uniform path (`setsid bash -c "$cmd"`), because each
  `--emit-sh` command is fully self-contained — **each script owns its own
  firing logic**, so there's no central "action layer" to drift or break.

The sheet list is defined once, in `rofi-keybindings` (`sheets=( "label:script" )`),
and drives both the picker and `all`.

## The cheatsheets

| Sheet | App | Data source | How Enter fires it |
|---|---|---|---|
| `rofi-i3-cheatsheet` | i3 WM | **Live** `i3-msg -t get_config` | `i3-msg` / exec (detached) |
| `rofi-tmux-keybindings` | tmux | Curated (from `tmux.nix`) | `tmux <cmd>` (attached client) |
| `rofi-kitty-keybindings` | kitty | Curated (stock defaults) | `kitten @ action` (remote control) |
| `rofi-yazi-keybindings` | yazi | **Live** `keymap.toml` (perl parse) | `ya emit-to <id> <cmd>` |
| `rofi-mpv-keybindings` | mpv | **Live** mpv IPC (`input-bindings`) | `keypress` over the IPC socket |
| `rofi-discord-keybindings` | Discord | Curated (Electron, opaque) | focus window + `xdotool key` |
| `rofi-ayugram-keybindings` | AyuGram/Telegram | **Live** shortcuts JSON + hardcoded | focus window + `xdotool key` |
| `rofi-zen-keybindings` | Zen browser | **Live** profile JSON | focus window + `xdotool key` |
| `rofi-brave-keybindings` | Brave | **Live** via CDP scrape (cached) | focus window + `xdotool key` (F11 → CDP) |
| `rofi-figma-keybindings` | Figma (browser) | Curated (web app, no keymap) | focus active-tab window + `xdotool key` |

`rofi-brave-cdp.mjs` is a helper (node + Chrome DevTools Protocol) used by the
Brave sheet to scrape `brave://settings/system/shortcuts`.

## Two firing models (and why)

**1. Native command / IPC — reliable, in-process, no window focus:**
i3, tmux, kitty, yazi, mpv. The app has a control channel (i3-msg, tmux CLI,
kitty remote control, `ya emit-to`, mpv IPC), so the sheet asks the app to
perform the action directly. Works even if the app isn't focused.

**2. Focus + key replay (`xdotool`) — for apps with no control channel:**
Discord, AyuGram, Zen, Brave, Figma. The sheet focuses the app's window (via
`i3-msg [class=…] focus`, because `xdotool windowactivate` is unreliable under
i3) then replays the keystroke. This performs the **real** action (e.g. Ctrl+W
closes a tab) and depends on the right window/context being focused.

## Per-sheet setup & gotchas

### i3 — `rofi-i3-cheatsheet`
- Source of truth is the **live** config, so it's always in sync.
- `awk` resolves `set $var` definitions, skips `mode` blocks (they only make
  sense inside their mode), and strips `/nix/store/…/bin/` prefixes from labels.
- A few cryptic commands get friendly labels (DND toggle, screen recording, …).

### tmux — `rofi-tmux-keybindings`
- Prefix is **`C-a`**. Fires the equivalent `tmux` command against the running
  server (affects the currently attached client), so no terminal focus needed.
- **Gotcha:** the server socket lives under `$TMUX_TMPDIR` (= `$XDG_RUNTIME_DIR`
  here), which i3/rofi launches don't set → `tmux` reports "no server". The
  script re-exports it. Interactive overlays (`choose-tree`, `copy-mode`) render
  in the attached client.
- Display-only: prompts that need typing, copy-mode motions, and **kill**
  window/pane (CLI skips the confirmation, so an accidental pick is unsafe).

### kitty — `rofi-kitty-keybindings`
- `kitty_mod` = **Ctrl+Shift**. Fires via `kitten @ --to unix:@mykitty-<pid> action …`.
- **Requires remote control** (`nix/home/kitty.nix`):
  `allow_remote_control = "socket-only"` + `listen_on = "unix:@mykitty"`.
- **Gotcha:** those are read **only at kitty startup** — a config *reload* or an
  already-open window won't gain them. Restart kitty after enabling.
- **Gotcha:** kitty **appends `-<pid>`** to the socket, so the real address is
  `@mykitty-<pid>`, not `@mykitty`. The sheet discovers it at run time
  (`ss -xlp | grep @mykitty-`), baked into each fired command so it re-resolves and
  survives kitty restarts.
- **Multi-instance:** each kitty gets its own `-<pid>` socket, so several coexist fine;
  the sheet targets whichever one `ss` reports first.

### yazi — `rofi-yazi-keybindings`
- Source is the **live** `keymap.toml` (manager keys), parsed with **perl** —
  `python3`/`tomllib` is *not* on the i3/rofi launch PATH, so a python parser
  silently produced zero rows.
- Fires with `ya emit-to 424242 <cmd>`. **Gotcha:** `ya emit` needs `$YAZI_ID`,
  which only exists inside yazi's own subprocesses (not discoverable from
  outside). So yazi must be **launched with a fixed `--client-id 424242`** —
  wired in `nix/home/desktop-entries.nix` (the `yazi` + `yazifloat` entries) and
  a `yazi()` wrapper in `nix/home/zsh/zshrc.nix`. Relaunch yazi after a rebuild.
- **Multi-instance:** only one yazi can hold id 424242 at a time; firing hits
  whichever holds it.
- Fires almost everything (navigation, tabs, sort, view, copy, prompts…);
  **display-only** are only the destructive/session-ending commands
  (`remove`/`delete`/`quit`/`close`/`suspend`) and multi-command chains.

### mpv — `rofi-mpv-keybindings`
- Reads mpv's **live** key map over its JSON IPC socket and fires by sending a
  `keypress` back through the same socket — exact round-trip, no xdotool.
- **Requires** mpv started with an IPC socket
  (`input-ipc-server=/tmp/mpvsocket` in `mpv.conf`; override with `MPV_SOCKET`).

### Discord — `rofi-discord-keybindings`
- Electron app with no machine-readable keymap → **curated** from the Ctrl+/
  overlay. Focuses `[class="discord"]` (the real managed window, not the
  override-redirect helpers) and replays the key.

### AyuGram / Telegram — `rofi-ayugram-keybindings`
- Reads the **live** shortcuts JSON (defaults + custom overrides) plus a
  hardcoded block for shortcuts not in the JSON.
- Real chords fire (focus `[class="AyuGramDesktop"]` + xdotool via `to_keyspec`);
  Qt-special names ("search"/"find"/…) and unmappable rows stay display-only.

### Zen — `rofi-zen-keybindings`
- Reads the **live** `zen-keyboard-shortcuts.json` from the newest profile (a
  plain file read — no CDP). Focuses `[class="zen-beta"]` + replays the key.

### Brave — `rofi-brave-keybindings`
- Scrapes shortcuts **live** from `brave://settings/system/shortcuts` over the
  DevTools protocol (`rofi-brave-cdp.mjs`) and **caches** them (the scrape is
  ~5s and opens a background tab). Run with `--refresh` after rebinding.
- **Requires** Brave launched with `--remote-debugging-port` (default 9222;
  `BRAVE_CDP_PORT` to override). F11 doesn't reach Brave under i3, so it drives
  Brave's window fullscreen over CDP instead of via xdotool.

### Figma — `rofi-figma-keybindings`
- Figma is a **web app**: no live keymap and the Figma MCP is design-data only,
  so the list is **curated** from documented defaults.
- Focuses the browser window whose **active tab** is Figma (matched by window
  title, so it works for Brave *or* Zen) and replays the key; if no window has
  Figma active it notifies instead of misfiring.
- **Gotcha:** most Figma shortcuts are single letters (V/R/T/P…) — they only do
  the right thing when the **canvas** has focus, not a text field or panel.

## Adding a new cheatsheet

1. Create `rofi-<app>-keybindings`, `chmod +x`, following the shared anatomy.
2. Add an `--emit-sh` mode that prints self-contained `command<TAB>label` rows
   (empty command = display-only) so it joins the `all` aggregate.
3. Register it in `rofi-keybindings`' `sheets=( … )` list.

## Conventions

- **New/edited files must be `chmod +x`.**
- **No `set -euo pipefail`** — several scripts rely on `sed`/`awk` producing
  empty output or non-fatal exits.
- **Prefer native control channels over key replay** where the app offers one
  (more reliable, no focus dependency).
- These are interactive GUI scripts — syntax-check with `bash -n`, run the
  underlying data command in isolation, and test the picker/action live.
