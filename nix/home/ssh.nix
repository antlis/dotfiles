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
      vps-nl = {
        user = "root";
        hostname = sshHosts.vpsNl;
      };
      vps-msk = {
        user = "root";
        hostname = sshHosts.vpsMsk;
      };
      vps-msk-2 = {
        user = "root";
        hostname = sshHosts.vpsMsk2;
      };
      vps-pl = {
        user = "root";
        hostname = sshHosts.vpsPl;
      };
      vps-usa = {
        user = "root";
        hostname = sshHosts.vpsUsa;
      };
      thinkbook = {
        user = "lad";
        hostname = sshHosts.thinkbook;
      };
      vmhost = {
        hostname = sshHosts.vmhost;
        user = "vboxuser";
      };
      "gitlab.corp.internal" = {
        proxyJump = "vps-msk-2";
        user = "git";
        serverAliveInterval = 15;
        serverAliveCountMax = 8;
      };
      bastion-02 = {
        hostname = "bastion.internal";
        user = "redacted-user";
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 240;
        forwardAgent = true;
      };
      "gitlab.internal" = {
        hostname = "gitlab.internal";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        proxyJump = "bastion-02";
        strictHostKeyChecking = "no";
        extraOptions = {
          PreferredAuthentications = "publickey";
          PubkeyAuthentication = "yes";
        };
      };
      "gitlab.homelab.lan" = {
        hostname = "gitlab.homelab.lan";
        user = "git";
        port = 2222;
      };
      "git.internal" = {
        hostname = "git.internal";
        user = "git";
        port = 2424;
      };
    };
  };
}
