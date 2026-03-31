{ mod, pkgs }:

{
  # Terminal
  "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

  # Kill window
  "${mod}+Shift+q" = "kill";

  # Launchers
  "${mod}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun -show-icons";
  "${mod}+Shift+d" = "exec --no-startup-id zsh -c \"${pkgs.rofi}/bin/rofi -show window\"";

  # Custom scripts / apps
  "${mod}+o"       = "exec xset dpms force off";
  "${mod}+t"       = "exec --no-startup-id env PATH=\"$HOME/.cargo/bin:$PATH\" bbr";
  "${mod}+Shift+h" = "exec ~/bin/rofi/rofi-brave-beta-history";
  "${mod}+b"       = "exec ~/bin/rofi/rofi-bookmarks-brave";
  "${mod}+c"       = "exec ~/bin/rofi/rofi-kamoji-picker";
  "${mod}+Shift+b" = "exec ~/bin/rofi/rofi-saved-links";
  "${mod}+Shift+s" = "exec ~/bin/rofi/rofi-websearch";
  "${mod}+Shift+p" = "exec ~/bin/rofi/rofi-websearch-private";
  "${mod}+p"       = "exec rofi-rbw";

  # Focus (vim-style)
  "${mod}+h" = "focus left";
  "${mod}+j" = "focus down";
  "${mod}+k" = "focus up";
  "${mod}+l" = "focus right";

  # Focus (arrow keys)
  "${mod}+Left"  = "focus left";
  "${mod}+Down"  = "focus down";
  "${mod}+Up"    = "focus up";
  "${mod}+Right" = "focus right";

  # Move window (vim-style)
  "${mod}+Shift+j"         = "move left";
  "${mod}+Shift+k"         = "move down";
  "${mod}+Shift+l"         = "move up";
  "${mod}+Shift+semicolon" = "move right";

  # Move window (arrow keys)
  "${mod}+Shift+Left"  = "move left";
  "${mod}+Shift+Down"  = "move down";
  "${mod}+Shift+Up"    = "move up";
  "${mod}+Shift+Right" = "move right";

  # Split
  "${mod}+i" = "split h";
  "${mod}+v" = "split v";

  # Fullscreen
  "${mod}+f" = "fullscreen toggle";

  # Layout
  "${mod}+s"       = "layout stacking";
  "${mod}+w"       = "layout tabbed";
  "${mod}+e"       = "layout toggle split";
  "${mod}+Shift+w" = "layout toggle split";

  # Floating
  "${mod}+Shift+space" = "floating toggle";
  "${mod}+space"       = "focus mode_toggle";

  # Focus parent
  "${mod}+a" = "focus parent";

  # Workspaces 1–10
  "${mod}+1" = "workspace 1";
  "${mod}+2" = "workspace 2";
  "${mod}+3" = "workspace 3";
  "${mod}+4" = "workspace 4";
  "${mod}+5" = "workspace 5";
  "${mod}+6" = "workspace 6";
  "${mod}+7" = "workspace 7";
  "${mod}+8" = "workspace 8";
  "${mod}+9" = "workspace 9";
  "${mod}+0" = "workspace 10";

  # Workspaces 11–20
  "${mod}+Ctrl+Shift+1" = "workspace 11";
  "${mod}+Ctrl+Shift+2" = "workspace 12";
  "${mod}+Ctrl+Shift+3" = "workspace 13";
  "${mod}+Ctrl+Shift+4" = "workspace 14";
  "${mod}+Ctrl+Shift+5" = "workspace 15";
  "${mod}+Ctrl+Shift+6" = "workspace 16";
  "${mod}+Ctrl+Shift+7" = "workspace 17";
  "${mod}+Ctrl+Shift+8" = "workspace 18";
  "${mod}+Ctrl+Shift+9" = "workspace 19";
  "${mod}+Ctrl+Shift+0" = "workspace 20";

  # Move container to workspace
  "${mod}+Shift+1" = "move container to workspace 1";
  "${mod}+Shift+2" = "move container to workspace 2";
  "${mod}+Shift+3" = "move container to workspace 3";
  "${mod}+Shift+4" = "move container to workspace 4";
  "${mod}+Shift+5" = "move container to workspace 5";
  "${mod}+Shift+6" = "move container to workspace 6";
  "${mod}+Shift+7" = "move container to workspace 7";
  "${mod}+Shift+8" = "move container to workspace 8";
  "${mod}+Shift+9" = "move container to workspace 9";
  "${mod}+Shift+0" = "move container to workspace 10";

  # App shortcuts
  "${mod}+Ctrl+2" = "exec brave-browser-beta";
  "${mod}+Ctrl+8" = "exec AmneziaVPN";

  # i3 control
  "${mod}+Shift+c" = "reload";
  "${mod}+Shift+r" = "restart";
  "${mod}+Shift+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'\"";

  # Resize mode
  "${mod}+r" = "mode \"resize\"";

  # Move workspace between monitors
  "${mod}+Ctrl+l" = "move workspace to output right";
  "${mod}+Ctrl+h" = "move workspace to output left";

  # Back and forth
  "${mod}+Tab" = "workspace back_and_forth";

  # Screenshots
  "${mod}+Print"       = "exec gnome-screenshot && notify-send \"Screenshot saved\"";
  "${mod}+F11"         = "exec gnome-screenshot && notify-send \"Screenshot saved\"";
  "${mod}+Shift+Print" = "exec gnome-screenshot -a && notify-send \"Screenshot saved\"";
  "${mod}+Shift+F11"   = "exec gnome-screenshot -a && notify-send \"Screenshot saved\"";
  "Ctrl+Shift+Print"   = "exec peek";

  # Bar toggle
  "${mod}+x" = "exec i3-msg bar mode toggle";

  # System menu mode
  "${mod}+Shift+x" = "mode \"$sysmenu\"";

  # Screen off / lock
  "XF86LaunchA" = "exec i3lock --color=$(echo \"#$(openssl rand -hex 3)\")";

  # Volume
  "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
  "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
  "XF86AudioMute"        = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
  "XF86AudioMicMute"     = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

  # Brightness
  "XF86MonBrightnessUp"   = "exec --no-startup-id sh -c 'brightnessctl set +5% | grep -o \"[0-9]*%\" | xargs notify-send \"Brightness\"'";
  "XF86MonBrightnessDown" = "exec --no-startup-id sh -c 'brightnessctl set 5%- | grep -o \"[0-9]*%\" | xargs notify-send \"Brightness\"'";

  # Display toggle
  "XF86Display" = "exec --no-startup-id xrandr --auto";

  # Show keybindings
  "${mod}+slash" = "exec --no-startup-id grep \"^bindsym\" ~/.config/i3/config | sed 's/bindsym //' | rofi -dmenu -p \"⌨ keybindings\" -i";
}
