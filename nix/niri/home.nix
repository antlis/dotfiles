{ pkgs, lib, ... }:
let
  c = import ../constants.nix;
  niriPackages = import ./packages.nix { inherit pkgs; };
in
{
  home-manager.users.${c.username} = { pkgs, lib, config, ... }: {
    home.stateVersion = "25.11";
    home.username = c.username;
    home.homeDirectory = c.homeDir;
    imports = [
      ../home/zsh/zshrc.nix
      ../home/tmux/tmux.nix
      ../home/desktop-entries.nix
      ../home/git.nix
      ../home/kitty.nix
      ../home/rofi.nix
      ../home/opencode.nix
    ];
    home.packages = niriPackages;
    services.dunst.enable = true;
    services.ssh-agent.enable = true;
    home.activation.createScreenshotDir = lib.mkAfter ''
      mkdir -p ${c.screenshotDir}
    '';
    home.activation.setupScreenlayout = lib.mkAfter ''
      mkdir -p ${c.homeDir}/.screenlayout
    '';
    dconf.settings = {
      "org/gnome/gnome-screenshot" = {
        auto-save-directory = "file://${c.screenshotDir}";
      };
    };
    home.file = {
      ".config/nvim-lazyvim".source = config.lib.file.mkOutOfStoreSymlink
        "${c.dotfilesDir}/nvim-lazyvim/.config/nvim-lazyvim";
      ".config/yazi".source             = "${c.dotfilesDir}/yazi/.config/yazi";
      ".xbindkeysrc".source             = "${c.dotfilesDir}/xbindkeysrc/.xbindkeysrc";
      ".config/keynav".source           = "${c.dotfilesDir}/keynav/.config/keynav";
      ".screenlayout/monitor.sh".source = "${c.dotfilesDir}/scripts/monitor.sh";
      ".config/tmux-airline-dracula".source = builtins.fetchGit {
        url = "https://github.com/sei40kr/tmux-airline-dracula.git";
        ref = "master";
      };
    };

    programs.niri.settings = {
      input.keyboard.xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };

      input.touchpad = {
        tap = true;
        natural-scroll = false;
        accel-profile = "flat";
        accel-speed = 1.0;
        disabled-on-external-mouse = false;
        dwt = true;
      };

      layout = {
        gaps = 8;

        center-focused-column = "never";

        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#6272A4";
          inactive.color = "#282A36";
        };

        border = {
          enable = false;
        };
      };

      spawn-at-startup = [
        { command = [ "${pkgs.kitty}/bin/kitty" ]; }
        { command = [ "noctalia-shell" ]; }
      ];

      workspaces = {
        "01" = {};
        "02" = {};
        "03" = {};
        "04" = {};
        "05" = {};
        "06" = {};
        "07" = {};
        "08" = {};
        "09" = {};
        "10" = {};
      };

      window-rules = [
        # Workspace 01 - Terminal
        {
          matches = [ { app-id = "kitty"; } ];
          open-on-workspace = "01";
          open-fullscreen = true;
          geometry-corner-radius = {
            top-left = 0.0;
            top-right = 0.0;
            bottom-left = 0.0;
            bottom-right = 0.0;
          };
        }

        # Workspace 02 - Browsers
        {
          matches = [
            { app-id = "firefox"; }
            { app-id = "Firefox"; }
            { app-id = "Navigator"; }
            { app-id = "chromium"; }
            { app-id = "chromium-browser"; }
            { app-id = "google-chrome"; }
            { app-id = "zen"; }
            { app-id = "brave-browser"; }
            { app-id = "brave"; }
            { app-id = "Brave"; }
            { app-id = "Brave-browser"; }
            { app-id = "qutebrowser"; }
          ];
          open-on-workspace = "02";
        }

        # Workspace 03 - File managers / torrents
        {
          matches = [
            { app-id = "org.gnome.Nautilus"; }
            { app-id = "nautilus"; }
            { app-id = "Nautilus"; }
            { app-id = "qbittorrent"; }
            { app-id = "thunar"; }
            { app-id = "transmission-gtk"; }
            { app-id = "transmission-qt"; }
          ];
          open-on-workspace = "03";
        }

        # Workspace 04 - Creative / AI
        {
          matches = [
            { app-id = "krita"; }
            { app-id = "aseprite"; }
            { app-id = "freetube"; }
            { app-id = "chat-gpt"; }
            { app-id = "claude"; }
            { app-id = "electron-deepseek"; }
            { app-id = "copilot-desktop"; }
          ];
          open-on-workspace = "04";
        }

        # Workspace 05 - Dev / editors
        {
          matches = [
            { app-id = "code"; }
            { app-id = "vscodium"; }
            { app-id = "cursor"; }
            { app-id = "obsidian"; }
            { app-id = "sublime_text"; }
          ];
          open-on-workspace = "05";
        }

        # Workspace 06 - Messaging
        {
          matches = [
            { app-id = "slack"; }
            { app-id = "signal"; }
            { app-id = "org.telegram.desktop"; }
            { app-id = "com.ayugram.desktop"; }
            { app-id = "zoom"; }
            { app-id = "discord"; }
            { app-id = "element"; }
            { app-id = "yougile"; }
          ];
          open-on-workspace = "06";
        }

        # Workspace 07 - Dev tools
        {
          matches = [
            { app-id = "bitwarden"; }
            { app-id = "insomnia"; }
            { app-id = "httpie"; }
            { app-id = "beekeeper-studio"; }
            { app-id = "dbeaver"; }
            { app-id = "postman"; }
          ];
          open-on-workspace = "07";
          open-fullscreen = true;
        }

        # Workspace 08 - Utilities / VPN
        {
          matches = [
            { app-id = "filezilla"; }
            { app-id = "kazam"; }
            { app-id = "simplescreenrecorder"; }
            { app-id = "pritunl"; }
            { app-id = "pavucontrol"; }
            { app-id = "steam"; }
            { app-id = "org.kde.kdeconnect"; }
            { app-id = "mullvad-vpn"; }
            { app-id = "pia-client"; }
            { app-id = "nekoray"; }
            { app-id = "com.cisco.anyconnect.gui"; }
          ];
          open-on-workspace = "08";
        }

        # AmneziaVPN - matched by title since app-id is empty
        {
          matches = [ { title = "AmneziaVPN"; } ];
          open-on-workspace = "08";
          open-fullscreen = true;
        }

        # Workspace 09 - VMs / remote
        {
          matches = [
            { app-id = "virtualbox"; }
            { app-id = "org.remmina.Remmina"; }
            { app-id = "netsoft-com.netsoft.hubstaff"; }
          ];
          open-on-workspace = "09";
        }

        # Workspace 10 - Media
        {
          matches = [
            { app-id = "mpv"; }
          ];
          open-on-workspace = "10";
        }
      ];

      binds = let
        spawn = cmd: { action.spawn = cmd; };
      in {
        # Terminal
        "Mod+Return" = spawn [ "${pkgs.kitty}/bin/kitty" ];

        # Kill window
        "Mod+Shift+Q".action.close-window = [];

        # Launchers
        "Mod+D" = spawn [ "${pkgs.rofi}/bin/rofi" "-show" "drun" "-show-icons" ];

        # Custom scripts
        "Mod+Alt+H" = spawn [ "bash" "-c" "~/bin/rofi/rofi-brave-beta-history" ];
        "Mod+Alt+B" = spawn [ "bash" "-c" "~/bin/rofi/rofi-bookmarks-brave" ];
        "Mod+Alt+C" = spawn [ "bash" "-c" "~/bin/rofi/rofi-kamoji-picker" ];
        "Mod+Alt+L" = spawn [ "bash" "-c" "~/bin/rofi/rofi-saved-links" ];
        "Mod+Alt+S" = spawn [ "bash" "-c" "~/bin/rofi/rofi-websearch" ];
        "Mod+P" = spawn [ "rofi-rbw" ];

        # Focus
        "Mod+H".action.focus-column-left = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+L".action.focus-column-right = [];

        "Mod+Left".action.focus-column-left = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Right".action.focus-column-right = [];

        # Move window
        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+J".action.move-window-down = [];
        "Mod+Shift+K".action.move-window-up = [];
        "Mod+Shift+L".action.move-column-right = [];

        "Mod+Shift+Left".action.move-column-left = [];
        "Mod+Shift+Down".action.move-window-down = [];
        "Mod+Shift+Up".action.move-window-up = [];
        "Mod+Shift+Right".action.move-column-right = [];

        # Consume/expel
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Period".action.expel-window-from-column = [];

        # Column width
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Window height
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        # Fullscreen
        "Mod+F".action.fullscreen-window = [];

        # Workspaces
        "Mod+1".action.focus-workspace = "01";
        "Mod+2".action.focus-workspace = "02";
        "Mod+3".action.focus-workspace = "03";
        "Mod+4".action.focus-workspace = "04";
        "Mod+5".action.focus-workspace = "05";
        "Mod+6".action.focus-workspace = "06";
        "Mod+7".action.focus-workspace = "07";
        "Mod+8".action.focus-workspace = "08";
        "Mod+9".action.focus-workspace = "09";

        "Mod+Shift+1".action.move-column-to-workspace = "01";
        "Mod+Shift+2".action.move-column-to-workspace = "02";
        "Mod+Shift+3".action.move-column-to-workspace = "03";
        "Mod+Shift+4".action.move-column-to-workspace = "04";
        "Mod+Shift+5".action.move-column-to-workspace = "05";
        "Mod+Shift+6".action.move-column-to-workspace = "06";
        "Mod+Shift+7".action.move-column-to-workspace = "07";
        "Mod+Shift+8".action.move-column-to-workspace = "08";
        "Mod+Shift+9".action.move-column-to-workspace = "09";

        # Move workspace between monitors
        "Mod+Ctrl+L".action.move-workspace-to-monitor-right = [];
        "Mod+Ctrl+H".action.move-workspace-to-monitor-left = [];

        # Switch between recent workspaces
        "Mod+Tab".action.focus-workspace-previous = [];

        # Screenshots
        "Mod+Print".action.screenshot = [];
        "Mod+Shift+Print".action.screenshot-window = [];
        "Mod+F11".action.screenshot = [];
        "Mod+Shift+F11".action.screenshot-window = [];

        # Volume
        "XF86AudioRaiseVolume" = spawn [ "pactl" "set-sink-volume" "0" "+5%" ];
        "XF86AudioLowerVolume" = spawn [ "pactl" "set-sink-volume" "0" "-5%" ];
        "XF86AudioMute" = spawn [ "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle" ];
        "XF86AudioMicMute" = spawn [ "pactl" "set-source-mute" "@DEFAULT_SOURCE@" "toggle" ];

        # Brightness
        "XF86MonBrightnessUp" = spawn [ "bash" "-c" "brightnessctl set +5% | grep -o '[0-9]*%' | xargs notify-send Brightness" ];
        "XF86MonBrightnessDown" = spawn [ "bash" "-c" "brightnessctl set 5%- | grep -o '[0-9]*%' | xargs notify-send Brightness" ];

        # Hibernate
        "Mod+F12" = spawn [ "bash" "-c" "loginctl lock-session && systemctl hibernate" ];

        # App shortcuts
        "Mod+Ctrl+2" = spawn [ "brave" ];
        "Mod+Ctrl+8" = spawn [ "/run/current-system/sw/bin/AmneziaVPN" ];

        # Niri control
        "Mod+Shift+E".action.quit = [];
      };
    };
  };
}
