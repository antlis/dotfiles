{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "mimocode";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/XiaomiMiMo/MiMo-Code/releases/download/v${version}/mimocode-linux-x64.tar.gz";
    hash = "sha256-4O4NAyud0TUBk/5vPrC6KI/QpkHincZRzX499axvKa0=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 mimo "$out/bin/mimo"
    runHook postInstall
  '';

  meta = {
    description = "MiMoCode — open-source AI coding agent with cross-session memory (Xiaomi)";
    homepage = "https://mimo.xiaomi.com/mimocode";
    license = lib.licenses.mit;
    mainProgram = "mimo";
    platforms = [ "x86_64-linux" ];
  };
}
