{ pkgs }:
let
  # Shows which VPN is active in the i3bar (refreshes with i3status, ~5s).
  vpnStatus = pkgs.writeShellScript "i3-vpn-block" ''
    sc=${pkgs.systemd}/bin/systemctl
    # tiers with NL+PL configs show which server is live (see vpn-menu for the per-tier
    # detection: reality/hysteria/naive by exit IP, olcrtc by SSH-host marker, chain by port).
    g=${pkgs.gnugrep}/bin/grep; cfg=/home/lad/.config/sing-box
    srv()  { $g -q "127.0.0.1" "$cfg/$1.json" 2>/dev/null && echo "PL" || echo "NL"; }
    srvO() { $g -q "vl4-pl" /home/lad/.config/olcrtc/srv-host 2>/dev/null && echo "PL" || echo "NL"; }
    srvC() { $g -q '"server_port": 8443' "$cfg/chain.json" 2>/dev/null && echo "PL" || echo "NL"; }
    if   $sc is-active --quiet reality-vpn;  then t="VPN: Reality $(srv reality)";  c="#50fa7b"
    elif $sc is-active --quiet hysteria-vpn; then t="VPN: Hysteria $(srv hysteria)"; c="#8be9fd"
    elif $sc is-active --quiet chain-vpn;    then t="VPN: Chain $(srvC)";    c="#bd93f9"
    elif $sc is-active --quiet cf-vpn;       then t="VPN: Cloudflare"; c="#ff79c6"
    elif $sc is-active --quiet olcrtc-vpn;   then t="VPN: olcrtc $(srvO)";   c="#ff5555"
    elif $sc is-active --quiet naive-vpn;    then t="VPN: naive $(srv naive)"; c="#a4ffff"
    elif $sc is-active --quiet ssh-vpn;      then t="VPN: SSH";      c="#f1fa8c"
    elif ${pkgs.iproute2}/bin/ip link show amn0 >/dev/null 2>&1; then t="VPN: Amnezia"; c="#ffb86c"
    else t="VPN: off"; c="#6272a4"; fi
    printf '{"name":"vpn","full_text":"%s","color":"%s","separator":true,"separator_block_width":15}' "$t" "$c"
  '';
  # Active keyboard layout (us,ru toggled with grp:alt_shift_toggle). xkb-switch
  # reads the live XKB group — setxkbmap -query can't, it always reports "us,ru".
  # Polls with i3status (~5s interval), so a switch shows up after up to that delay.
  kbdStatus = pkgs.writeShellScript "i3-kbd-block" ''
    case "$(${pkgs.xkb-switch}/bin/xkb-switch 2>/dev/null)" in
      ru*) t="RU"; c="#ff79c6" ;;
      *)   t="EN"; c="#50fa7b" ;;
    esac
    printf '{"name":"kbd","full_text":"%s","color":"%s","separator":true,"separator_block_width":15}' "$t" "$c"
  '';
  # Wrap i3status' i3bar JSON and inject the keyboard + VPN blocks at the front of each line.
  statusWrapper = pkgs.writeShellScript "i3status-vpn" ''
    ${pkgs.i3status}/bin/i3status | while IFS= read -r line; do
      case "$line" in
        '{'*) echo "$line" ;;
        '[')  echo "$line" ;;
        *)    vpn="$(${vpnStatus})"; kbd="$(${kbdStatus})"; echo "''${line/\[/[$kbd,$vpn,}" ;;
      esac
    done
  '';
in
[
  {
    mode          = "hide";
    statusCommand = "${statusWrapper}";
    colors = {
      background     = "#282A36";
      statusline     = "#F8F8F2";
      separator      = "#44475A";
      focusedWorkspace  = { border = "#44475A"; background = "#44475A"; text = "#F8F8F2"; };
      activeWorkspace   = { border = "#282A36"; background = "#44475A"; text = "#F8F8F2"; };
      inactiveWorkspace = { border = "#282A36"; background = "#282A36"; text = "#BFBFBF"; };
      urgentWorkspace   = { border = "#FF5555"; background = "#FF5555"; text = "#F8F8F2"; };
      bindingMode       = { border = "#FF5555"; background = "#FF5555"; text = "#F8F8F2"; };
    };
  }
]
