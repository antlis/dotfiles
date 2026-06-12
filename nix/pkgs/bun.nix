{ lib, stdenv, fetchurl, unzip }:

# Bun pinned to a specific upstream release. nixpkgs 25.11 ships 1.3.3 and
# nixpkgs-unstable is currently at 1.3.13 — both too old for @oh-my-pi (needs
# ≥1.3.14) and for the latest opencode binaries. Bumping is a one-line change
# here plus a hash recompute; see README in the bun release page.
#
# Install method mirrors nixpkgs' own `bun` derivation: GitHub release zip,
# strip nested directory, drop the binary in $out/bin.
stdenv.mkDerivation rec {
  pname = "bun";
  version = "1.3.14";

  src = fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
    hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = "bun-linux-x64";
  # GitHub release zip wraps the binary in a top-level `bun-linux-x64/` dir.
  # `sourceRoot` makes stdenv cd into it so installPhase sees `bun` flat.
  installPhase = ''
    runHook preInstall
    install -Dm755 bun "$out/bin/bun"
    [ -f LICENSE ] && install -Dm644 LICENSE "$out/share/licenses/bun/LICENSE" || true
    runHook postInstall
  '';

  # Patchelf not required — upstream publishes a fully self-contained binary.
  dontStrip = false;

  meta = {
    description = "Incredibly fast JavaScript runtime, bundler, transpiler and package manager";
    homepage = "https://bun.sh";
    license = lib.licenses.mit;
    mainProgram = "bun";
    platforms = [ "x86_64-linux" ];
  };
}
