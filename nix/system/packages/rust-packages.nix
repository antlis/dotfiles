{ pkgs, inputs, ... }:
let
  brave-rofi-rust = pkgs.rustPlatform.buildRustPackage {
    pname = "brave-rofi-rust";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "antlis";
      repo = "brave-rofi-rust";
      rev = "master";
      hash = "sha256-STlBrSYZ+SkM1JV2pQciYfVQhKStnantUACxz7AuJxY=";
    };
    cargoHash = "sha256-Y50dAfbDVZGoTf0rq0Z5fMc9sFVVGGPQv+LCywaktEU=";
  };

  telepad = pkgs.rustPlatform.buildRustPackage {
    pname = "telepad";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "antlis";
      repo = "telepad";
      rev = "v0.4.0";
      hash = "sha256-Q0xVbRILi+B0fOwDV67D9V+JQHzljgKIckILu8j+4Jk=";
    };
    cargoHash = "sha256-z270iMOZ5HBzl26n23WZKYgtQF5Zff0d4kf+3Lz9dnI=";
  };
in
[
  brave-rofi-rust  # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust
  telepad          # Rofi Telegram/AyuGram quick-switcher | https://github.com/antlis/telepad
  pkgs.cargo       # Rust package manager and build tool | https://github.com/rust-lang/cargo
]
