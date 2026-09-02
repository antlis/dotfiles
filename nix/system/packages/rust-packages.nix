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
    version = "0.8.1";
    src = pkgs.fetchFromGitHub {
      owner = "antlis";
      repo = "telepad";
      rev = "v0.8.1";
      hash = "sha256-VD/pTqcYFk+2FwbK31zjAghEUxQU4XYJido4okX4r+o=";
    };
    cargoHash = "sha256-2Ut1404M09brbMo+/LCLd9BgaaFZD/iXrCUDbdWv8Uc=";
  };
in
[
  brave-rofi-rust  # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust
  telepad          # Rofi Telegram/AyuGram quick-switcher | https://github.com/antlis/telepad
  pkgs.cargo       # Rust package manager and build tool | https://github.com/rust-lang/cargo
]
