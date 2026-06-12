{ lib, stdenv, fetchurl }:

# codex — OpenAI Codex CLI. nixpkgs 25.11 is pinned to 0.92.0, which predates
# GPT-5.5 support (added in the 0.12x+ line). Rather than rebuild the Rust crate
# (slow + cargoHash churn on every bump), we wrap the official prebuilt release
# binary. The linux-musl artifact is fully static, so no autoPatchelfHook needed.
# Bump: change `version`, then `nix-prefetch-url <url> | xargs nix hash convert --hash-algo sha256`.
stdenv.mkDerivation rec {
  pname = "codex";
  version = "0.138.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-MDDto5nMiO2Ow8KAYWPde9xzkCkjR+UNj+BTgaguFd8=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex
    runHook postInstall
  '';

  meta = {
    description = "OpenAI Codex CLI — terminal coding agent (prebuilt release binary)";
    homepage = "https://developers.openai.com/codex/cli";
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
