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
    hooks = {
      # Shows startify quote https://github.com/antlis/vim-startify-quotes
      post-commit = pkgs.writeShellScript "post-commit" ''
        QUOTES_FILE="/home/lad/Projects/github/vim-startify-quotes/vim-startify-quotes.json"
        if [ -f "$QUOTES_FILE" ]; then
          NUM_QUOTES=$(jq 'length' "$QUOTES_FILE")
          RANDOM_INDEX=$((RANDOM % NUM_QUOTES))
          QUOTE=$(jq -r ".[$RANDOM_INDEX]" "$QUOTES_FILE")
          echo "$QUOTE" | ${pkgs.toilet}/bin/toilet -f pagga --gay
        else
          echo "COMMITTED!" | ${pkgs.toilet}/bin/toilet -f pagga --gay
        fi
      '';
    };
    settings = {
      user.name  = "lad";
      user.email = "antlis@protonmail.com";
      # This setting enhances the safety of force pushes by ensuring that you have fetched and integrated the latest changes from the remote
      # before allowing the push to proceed.
      push.useForceIfIncludes = true;
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
