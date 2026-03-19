{ config, pkgs, lib, ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      dark = true;
      syntax-theme = "Dracula";
    };
  };
  programs.git = {
    enable = true;
    settings = {
      user.name  = "lad";
      user.email = "antlis@protonmail.com";
      alias = {
        fzf-add      = "!git status -s | awk '{print $2}' | fzf -m | xargs git add";
        fzf-diff     = "!git status -s | awk '{print $2}' | fzf -m --preview 'git diff -- {} | delta --syntax-theme=Dracula' | xargs -I {} git diff -- {} | delta";
        fzf-reset    = "!git status -s | awk '{print $2}' | fzf -m | xargs git reset";
        fzf-checkout = "!git status -s | awk '{print $2}' | fzf -m | xargs git checkout --";
      };
      credential."https://github.com".helper      = ["" "!/usr/bin/gh auth git-credential"];
      credential."https://gist.github.com".helper = ["" "!/usr/bin/gh auth git-credential"];
      core.excludesfile  = "/home/lad/.gitignore_global";
      merge.conflictstyle = "zdiff3";
    };
  };
}
