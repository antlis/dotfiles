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
    version = "0.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "antlis";
      repo = "telepad";
      rev = "v0.5.0";
      hash = "sha256-wNH9kNWLy33SqzXs4LcEqGkQ+HPrxLxVpf0FmO2SR1E=";
    };
    cargoHash = "sha256-do2ev5tpUxLFHnT+sYOF1cgMFrpZiZ1R2FuMm6b0s8g=";
  };
in
[
  brave-rofi-rust  # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust
  telepad          # Rofi Telegram/AyuGram quick-switcher | https://github.com/antlis/telepad
  pkgs.cargo       # Rust package manager and build tool | https://github.com/rust-lang/cargo
]
