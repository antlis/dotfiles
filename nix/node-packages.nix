{ pkgs }:

let
  pdf-reader-mcp = pkgs.writeShellScriptBin "pdf-reader-mcp" ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    exec ${pkgs.nodejs}/bin/npx --prefix "$HOME/.npm-global" -y @sylphx/pdf-reader-mcp "$@"
  '';
in
[
  pkgs.nodejs
  pkgs.nodePackages.pnpm
  pkgs.nodePackages.pm2
  pdf-reader-mcp
]
