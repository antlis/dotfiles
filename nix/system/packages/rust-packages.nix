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
# tmuxrs = pkgs.rustPlatform.buildRustPackage {
#     pname = "tmuxrs";
#     version = "0.1.1";
#     src = pkgs.fetchCrate {
#       pname = "tmuxrs";
#       version = "0.1.1";
#       hash = "sha256-eFOlFmH2SXWszXTHOih538541RVDQA30cXvNfkMaUUc=";
#     };
#     cargoHash = "sha256-iQkoRuigeMhZdB7KxVAYmXmfynoycLkugNQYc+V5eGI=";
#     doCheck = false;
#   };
in
[
  brave-rofi-rust  # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust
  # tmuxrs           # Rust drop-in replacement for tmuxinator, centralized config | https://github.com/beijaflor/tmuxrs
  pkgs.cargo       # Rust package manager and build tool | https://github.com/rust-lang/cargo
]
