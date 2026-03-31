{ pkgs }:

[
  {
    mode          = "hide";
    statusCommand = "${pkgs.i3status}/bin/i3status";
    colors = {
      background     = "#282A36";
      statusline     = "#F8F8F2";
      separator      = "#44475A";
      focusedWorkspace  = { border = "#44475A"; background = "#44475A"; text = "#F8F8F2"; };
      activeWorkspace   = { border = "#282A36"; background = "#44475A"; text = "#F8F8F2"; };
      inactiveWorkspace = { border = "#282A36"; background = "#282A36"; text = "#BFBFBF"; };
      urgentWorkspace   = { border = "#FF5555"; background = "#FF5555"; text = "#F8F8F2"; };
      bindingMode       = { border = "#FF5555"; background = "#FF5555"; text = "#F8F8F2"; };
    };
  }
]
