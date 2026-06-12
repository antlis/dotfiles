{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "rtk";
  version = "0.42.3";

  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-XfdkpjNwnLhdJIJY0IXSTslfqovKDmg1qTzVfK3E654=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 rtk "$out/bin/rtk"
    runHook postInstall
  '';

  meta = {
    description = "Rust Token Killer CLI proxy for compact AI-agent command output";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.asl20;
    mainProgram = "rtk";
    platforms = [ "x86_64-linux" ];
  };
}
