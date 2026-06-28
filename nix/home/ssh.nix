{ sshHosts, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      archcraft = {
        user = "lad";
        hostname = sshHosts.archcraft;
      };
      archcraft-mesh = {
        user = "lad";
        hostname = sshHosts.archrraftMesh;
      };
      weasel-nl = {
        user = "root";
        hostname = sshHosts.weaselNl;
      };
      weasel-msk = {
        user = "root";
        hostname = sshHosts.weaselMsk;
      };
      weasel-msk-2 = {
        user = "root";
        hostname = sshHosts.weaselMsk2;
      };
      weasel-vl4-pl = {
        user = "root";
        hostname = sshHosts.weaselPl;
      };
      weasel-usa = {
        user = "root";
        hostname = sshHosts.weaselUsa;
      };
      thinkbook = {
        user = "lad";
        hostname = sshHosts.thinkbook;
      };
      stopphish = {
        hostname = sshHosts.stopphish;
        user = "vboxuser";
      };
      "gitlab.umbrella.moscow" = {
        proxyJump = "weasel-msk-2";
        user = "git";
        serverAliveInterval = 15;
        serverAliveCountMax = 8;
      };
      bastion-02 = {
        hostname = "nbg1-c3-infra-bastion-02.kobx.org";
        user = "alisovsky";
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 240;
        forwardAgent = true;
      };
      "gitlab.ctgroup.io" = {
        hostname = "gitlab.ctgroup.io";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        proxyJump = "bastion-02";
        extraOptions = {
          StrictHostKeyChecking = "no";
          PreferredAuthentications = "publickey";
          PubkeyAuthentication = "yes";
        };
      };
      "gitlab.homelab.lan" = {
        hostname = "gitlab.homelab.lan";
        user = "git";
        port = 2222;
      };
      "git.stopphish.ru" = {
        hostname = "git.stopphish.ru";
        user = "git";
        port = 2424;
      };
    };
  };
}
