{ config, pkgs, lib, figmaApiKey ? "", ... }:
let
  c = import ../constants.nix;

  # Figma MCP server (Framelink figma-developer-mcp). Reads Figma files via the
  # REST API using a personal access token — works on a free Figma account.
  figmaServer = {
    command = "npx";
    args = [ "-y" "figma-developer-mcp" "--stdio" ];
    env.FIGMA_API_KEY = figmaApiKey;
  };
in
{
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${c.dotfilesDir}/.claude/settings.json";
  };

  # ~/.claude.json is stateful (Claude Code rewrites it at runtime), so it can't be
  # a nix symlink. Instead merge the Figma MCP server into it on activation. The
  # token comes from the gitignored private.nix via the figmaApiKey module arg.
  home.activation.claudeFigmaMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.claude.json"
    server=${lib.escapeShellArg (builtins.toJSON figmaServer)}
    if [ -f "$cfg" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson s "$server" \
        '.mcpServers.figma = $s' "$cfg" > "$cfg.tmp" \
        && $DRY_RUN_CMD mv "$cfg.tmp" "$cfg"
    else
      $DRY_RUN_CMD echo "{\"mcpServers\":{\"figma\":$server}}" > "$cfg"
    fi
  '';
}
