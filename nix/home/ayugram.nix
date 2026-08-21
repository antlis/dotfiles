{ pkgs, lib, ... }:
let
  shortcuts-custom = pkgs.writeText "shortcuts-custom.json" ''
    // This is a list of changed shortcuts for Telegram Desktop
    // You can edit them in Settings > Chat Settings > Keyboard Shortcuts.

    [
        {
            "command": "account1",
            "keys": "alt+1"
        },
        {
            "command": "account2",
            "keys": "alt+2"
        },
        {
            "command": "account3",
            "keys": "alt+3"
        },
        {
            "command": "account4",
            "keys": "alt+4"
        },
        {
            "command": "account5",
            "keys": "alt+5"
        },
        {
            "command": "account6",
            "keys": "alt+6"
        }
    ]
  '';
in
{
  home.activation.ayugram-shortcuts = lib.mkAfter ''
    mkdir -p ~/.local/share/AyuGramDesktop/tdata
    cp ${shortcuts-custom} ~/.local/share/AyuGramDesktop/tdata/shortcuts-custom.json
  '';
}
