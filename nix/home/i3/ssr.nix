# SimpleScreenRecorder headless toggle + i3bar indicator.
# One hotkey (keybindings.nix) starts/stops recording without touching the GUI:
# SSR is launched hidden with --start-recording and driven through a FIFO, so the
# stop path can send `record-save` for a properly finalized mp4. A marker file
# (ssr-current) holds the output path and doubles as the "recording?" flag the bar
# block reads. Timestamped filenames come from a throwaway settings file copied
# from ~/.ssr/settings.conf with `file=` rewritten, so the GUI profile is untouched.
{ pkgs }:
let
  ssr    = "${pkgs.simplescreenrecorder}/bin/simplescreenrecorder";
  notify = "${pkgs.libnotify}/bin/notify-send";
  pkill  = "${pkgs.procps}/bin/pkill";
  sed    = "${pkgs.gnused}/bin/sed";
in
{
  toggle = pkgs.writeShellScript "ssr-record-toggle" ''
    set -u
    run="''${XDG_RUNTIME_DIR:-/tmp}"
    fifo="$run/ssr.fifo"
    holder="$run/ssr-holder.pid"   # pid of the writer holding the FIFO open
    marker="$run/ssr-current"      # exists only while recording; holds the output path

    if [ -e "$marker" ]; then
      # ── STOP: finalise the file, then tear SSR down ────────────────────────
      out="$(cat "$marker" 2>/dev/null)"
      # timeout guards against a dead reader (open-for-write on a FIFO blocks otherwise)
      timeout 3 sh -c 'printf "record-save\n" > "$0"' "$fifo" 2>/dev/null || true
      # wait for the mp4 to stop growing (mux/moov written), cap ~5s
      prev=-1
      for _ in $(seq 1 20); do
        cur=$(stat -c%s "$out" 2>/dev/null || echo 0)
        [ "$cur" = "$prev" ] && [ "$cur" != "0" ] && break
        prev=$cur; sleep 0.25
      done
      [ -f "$holder" ] && kill "$(cat "$holder")" 2>/dev/null || true
      ${pkill} -f 'bin/simplescreenrecorder' 2>/dev/null || true
      rm -f "$fifo" "$holder" "$marker"
      ${notify} -u low "⏹ Recording saved" "$out"
    else
      # ── START: launch hidden, recording immediately from the current profile ─
      mkdir -p "$HOME/Videos"
      out="$HOME/Videos/ssr-$(date +%Y%m%d-%H%M%S).mp4"
      settings="$run/ssr-settings.conf"
      # Copy the GUI profile verbatim (fps, codecs, cursor, audio source, …) but point
      # it at our timestamped file and disable SSR's own add_timestamp so the name is
      # exactly $out (deterministic — the stop path and bar marker rely on it).
      ${sed} -e "s#^file=.*#file=$out#" \
             -e "s#^add_timestamp=.*#add_timestamp=false#" \
             "$HOME/.ssr/settings.conf" > "$settings"
      rm -f "$fifo"; mkfifo "$fifo"
      ${ssr} --start-hidden --no-systray --start-recording --settingsfile="$settings" < "$fifo" >/dev/null 2>&1 &
      # keep the write end open so SSR never sees EOF on stdin
      sleep infinity > "$fifo" &
      echo $! > "$holder"
      echo "$out" > "$marker"
      ${notify} -u low "⏺ Recording started" "$out"
    fi
    ${pkill} -USR1 -x i3status 2>/dev/null || true
  '';

  # i3bar block: red ● REC only while a recording is in progress.
  recBlock = pkgs.writeShellScript "i3-rec-block" ''
    if [ -e "''${XDG_RUNTIME_DIR:-/tmp}/ssr-current" ]; then
      printf '{"name":"rec","full_text":"● REC","color":"#ff5555","separator":true,"separator_block_width":15}'
    fi
  '';
}
