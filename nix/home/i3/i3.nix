{ config, pkgs, ... }:

let
  mod = "Mod4";
  assigns = import ./assigns.nix;
  colors = import ./colors.nix;
  bars = import ./bars.nix { inherit pkgs; };
  keybindings = import ./keybindings.nix { inherit mod pkgs; };
in
{
  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;
      workspaceLayout = "tabbed";

      fonts = {
        names = [ "monospace" ];
        size = 8.0;
      };

      terminal = "kitty";

      # ── Keybindings ────────────────────────────────────────────────────────
      keybindings = keybindings;

      # ── Modes ──────────────────────────────────────────────────────────────
      modes = {
        resize = {
          j          = "resize shrink width 10 px or 10 ppt";
          k          = "resize grow height 10 px or 10 ppt";
          l          = "resize shrink height 10 px or 10 ppt";
          semicolon  = "resize grow width 10 px or 10 ppt";
          Left       = "resize shrink width 10 px or 10 ppt";
          Down       = "resize grow height 10 px or 10 ppt";
          Up         = "resize shrink height 10 px or 10 ppt";
          Right      = "resize grow width 10 px or 10 ppt";
          Return     = "mode \"default\"";
          Escape     = "mode \"default\"";
        };
      };

      # ── Window assignments ─────────────────────────────────────────────────
      assigns = assigns;

      # ── Floating / focus rules ─────────────────────────────────────────────
      floating = {
        modifier = mod;
      };

      window = {
        border = 0;
        hideEdgeBorders = "both";
        commands = [
          { command = "border pixel 0"; criteria = { class = "^.*"; }; }
          { command = "floating enable, border pixel 2, resize set 800 600, move position center"; criteria = { class = "popup_kitty"; }; }
          { command = "floating enable"; criteria = { title = "fzf-menu"; }; }
          { command = "fullscreen enable"; criteria = { class = "Code"; }; }
          { command = "fullscreen enable"; criteria = { class = "mpv"; }; }
          { command = "fullscreen enable"; criteria = { class = "pia-client"; }; }
          { command = "floating disabled"; criteria = { class = "Skype"; }; }
          { command = "floating disabled"; criteria = { class = "zoom"; }; }
          { command = "floating disabled"; criteria = { class = "Kazam"; }; }
          { command = "focus"; criteria = { class = "Pavucontrol"; }; }
          { command = "focus"; criteria = { class = "Insomnia"; }; }
          { command = "focus"; criteria = { class = "Chromium"; }; }
          { command = "focus"; criteria = { class = "Dragon"; }; }
        ];
      };

      # ── Colors (Dracula theme) ─────────────────────────────────────────────
      colors = colors;

      # ── Bar ───────────────────────────────────────────────────────────────
      bars = bars;

      # ── Startup ───────────────────────────────────────────────────────────
      startup = [
        { command = "keynav </dev/null &>/dev/null"; notification = false; }
        { command = "pidgin"; notification = false; }
        { command = "AmneziaVPN"; notification = false; }
        {
          command = "setxkbmap us,ru -option grp:alt_shift_toggle -model pc105";
          always = true;
          notification = false;
        }
        {
          command = "gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'";
          always = true;
          notification = false;
        }
        { command = "~/.screenlayout/monitor.sh"; notification = false; }
        { command = "killall -q notify-osd"; notification = false; }
        { command = "dunst -config ~/.config/dunst/dunstrc"; notification = false; }
        { command = "xsetroot -solid \"#000\""; notification = false; }
        { command = "synclient MaxTapTime=0"; notification = false; }
        { command = "/usr/lib/gnome-settings-daemon/gsd-xsettings"; always = true; notification = false; }
        { command = "i3-msg 'workspace 1; exec kitty'"; notification = false; }
      ];
    };

    # ── extraConfig: things the HM module can't express ───────────────────
    extraConfig = ''
      # Floating modifier
      floating_modifier ${mod}

      # System menu mode
      set $sysmenu (l)ock, (L)ogout, (P)oweroff, (R)eboot
      mode "$sysmenu" {
          bindsym l       exec "i3lock -c 111111", mode "default"
          bindsym Shift+l exec "i3-msg exit",      mode "default"
          bindsym Shift+p exec "shutdown now",      mode "default"
          bindsym Shift+r exec reboot,              mode "default"
          bindsym Return  mode "default"
          bindsym Escape  mode "default"
      }
    '';
  };
}
