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
in
[
  brave-rofi-rust  # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust
  pkgs.cargo       # Rust package manager and build tool | https://github.com/rust-lang/cargo
]
