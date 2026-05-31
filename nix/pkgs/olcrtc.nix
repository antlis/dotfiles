{ lib, buildGoModule, fetchFromGitHub, go_1_26 }:

# olcrtc — encrypted TCP-over-WebRTC tunnel (server/client in one binary, mode: srv/cnc).
# Rides must-allow WebRTC SFUs (jitsi/telemost) — bypasses RU blocking, not throttled like CF.
# Pure Go (pion). Needs Go >= 1.26.3, so pin go_1_26 (default nixpkgs go is 1.25.9).
# Standalone build: nix-build -E 'with import <nixpkgs> {}; callPackage ./pkgs/olcrtc.nix {}'
(buildGoModule.override { go = go_1_26; }) rec {
  pname = "olcrtc";
  version = "0-unstable-2026-05-10";

  src = fetchFromGitHub {
    owner = "openlibrecommunity";
    repo = "olcrtc";
    rev = "master";
    hash = "sha256-H3ML8M/wF/Sb1dA6LM+MLyl5rfvYOonqie9BOLRweGw=";
  };

  vendorHash = "sha256-Gg4fjfip+5ESU9Z89YAS5grQdsGzs1zsc1pqJLKvF1M=";

  subPackages = [ "cmd/olcrtc" ];
  env.CGO_ENABLED = "0";
  ldflags = [ "-s" "-w" ];
  doCheck = false;

  meta = {
    description = "Encrypted TCP-over-WebRTC tunnel (olcrtc) — RU censorship bypass via WebRTC SFUs";
    homepage = "https://github.com/openlibrecommunity/olcrtc";
    mainProgram = "olcrtc";
  };
}
