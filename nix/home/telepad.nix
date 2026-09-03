{ pkgs, lib, telepadConfig ? null, ... }:
let
  # Which Telegram Desktop client telepad drives. Not secret, so it lives here in
  # the committed module rather than in private.nix. Change to "telegram" (the
  # upstream default) to target vanilla Telegram Desktop instead.
  client = "ayugram";

  renderAccount = a: ''

    [[accounts]]
    acc = ${toString a.acc}
    label = "${a.label}"
    session = "${a.session}"
    phone = "${a.phone}"
    switch_key = "${a.switch_key}"
  '';

  configToml = pkgs.writeText "telepad-config.toml" ''
    # Managed by home-manager (nix/home/telepad.nix) — do not edit by hand.
    # API creds and per-account phones come from the gitignored private.nix
    # (telepadConfig module arg); `client` is set in that module.

    api_id = ${toString telepadConfig.api_id}
    api_hash = "${telepadConfig.api_hash}"
    client = "${client}"
    ${lib.concatMapStrings renderAccount telepadConfig.accounts}'';
in
{
  # config.toml is a static input (telepad writes sessions/cache elsewhere), but
  # it already exists as a plain file, so copy over it on activation rather than
  # symlinking — mirrors home/ayugram.nix. chmod 600 keeps the creds owner-only.
  home.activation.telepadConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.config/telepad
    $DRY_RUN_CMD cp ${configToml} $HOME/.config/telepad/config.toml
    $DRY_RUN_CMD chmod 600 $HOME/.config/telepad/config.toml
  '';
}
