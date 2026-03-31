{ config, pkgs, ... }:

{
  programs.i3status = {
    enable = true;
    enableDefault = false; 

    general = {
      colors = true;
      interval = 5;
    };

    modules = {
      "wireless _first_" = {
        position = 1;
        settings = {
          format_down = "W: DOWN";
          format_up   = "W: UP";
        };
      };

      "battery all" = {
        position = 2;
        settings = {
          format = "%status %percentage";
        };
      };

      "volume master" = {
        position = 3;
        settings = {
          format    = "♪: %volume";
          device    = "default";
          mixer     = "Master";
          mixer_idx = 0;
        };
      };

      "tztime local" = {
        position = 4;
        settings = {
          format = "%Y-%m-%d %H:%M";
        };
      };

      # Disabled modules — uncomment to enable and adjust position:
      # "ipv6" = {
      #   position = 5;
      #   settings = {};
      # };

      # "disk /" = {
      #   position = 5;
      #   settings = {
      #     format = "%avail";
      #   };
      # };

      # "load" = {
      #   position = 5;
      #   settings = {
      #     format = "%1min";
      #   };
      # };

      # "ethernet _first_" = {
      #   position = 5;
      #   settings = {
      #     format_up   = "E: %ip (%speed)";
      #     format_down = "E: down";
      #   };
      # };
    };
  };
}
