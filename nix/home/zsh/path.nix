{ config, pkgs, lib, ... }:
let
  c = import ../../constants.nix;
in
{
  programs.zsh = {
    sessionVariables = {
      NVIM_APPNAME = "nvim-lazyvim";
      GH_EDITOR    = "nvim";
      EDITOR       = "nvim";
      PAGER        = "more";
      GOPATH       = "${c.homeDir}/go";
      BUN_INSTALL  = "${c.homeDir}/.bun";
      NVM_DIR      = "${c.homeDir}/.nvm";
      PNPM_HOME    = "/home/${c.username}/.local/share/pnpm";
      VAULT        = "${c.homeDir}/Documents/vault";
      NOTES        = "${c.homeDir}/Documents/vault/notes/";
      MY_JOURNAL   = "${c.homeDir}/Documents/vault/journal/";
    };

    profileExtra = ''
      export PATH="${c.homeDir}/.opencode/bin:$PATH"
      export PATH="${c.homeDir}/.cargo/bin:$PATH"
      export PATH="${c.homeDir}/.local/bin:$PATH"
      export PATH="${c.homeDir}/my-scripts:$PATH"
      export PATH="${c.homeDir}/bin:$PATH"
      export PATH="/usr/local/bin:/usr/sbin:/sbin:$PATH"
      export PATH="$PATH:/opt/warpdotdev/warp-terminal"
      export PATH="$PATH:${c.homeDir}/.spoof-dpi/bin"
      export PATH="$PATH:${c.homeDir}/.spoofdpi/bin"
      export PATH="$PATH:$GOPATH/bin"
      export PATH="$PATH:${c.homeDir}/.rvm/bin"
      export PATH="$PATH:${c.homeDir}/.bun/bin"
      export PATH="$PATH:${c.homeDir}/perl5/bin"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      # perl
      PERL5LIB="${c.homeDir}/perl5/lib/perl5''${PERL5LIB:+:''${PERL5LIB}}"; export PERL5LIB;
      PERL_LOCAL_LIB_ROOT="${c.homeDir}/perl5''${PERL_LOCAL_LIB_ROOT:+:''${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
      PERL_MB_OPT="--install_base \"${c.homeDir}/perl5\""; export PERL_MB_OPT;
      PERL_MM_OPT="INSTALL_BASE=${c.homeDir}/perl5"; export PERL_MM_OPT;

      # bun completions
      [ -s "${c.homeDir}/.bun/_bun" ] && source "${c.homeDir}/.bun/_bun"

      # nix
      if [ -e "${c.homeDir}/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "${c.homeDir}/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';
  };
}
