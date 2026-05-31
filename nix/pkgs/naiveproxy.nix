{ lib, stdenv, fetchurl, autoPatchelfHook }:

# naiveproxy — Chrome-network-stack HTTP/2 CONNECT proxy client (klzgrad).
# The client MUST be the real naive binary (that's where the genuine Chrome TLS
# fingerprint comes from) — nixpkgs has no package, so we wrap the official
# prebuilt static-ish linux-x64 release. Server side = sing-box `naive` inbound.
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "148.0.7778.96-5";

  src = fetchurl {
    url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
    sha256 = "0b9mqwgvh4vmclavhsfr2wa3rki7d6mks8asqlw1nyzvpgf5hsfa";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 */naive $out/bin/naive
    runHook postInstall
  '';

  meta = {
    description = "naiveproxy client — censorship-resistant proxy using Chrome's network stack";
    homepage = "https://github.com/klzgrad/naiveproxy";
    mainProgram = "naive";
    platforms = [ "x86_64-linux" ];
  };
}
