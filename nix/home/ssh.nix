{ sshHosts, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      archcraft = {
        user = "lad";
        # hostname = sshHosts.archcraft;        # old home-LAN IP; breaks when archcraft is on another network
        hostname = sshHosts.archrraftMesh;      # tailnet IP — reachable anywhere via the headscale mesh
      };
      archcraft-mesh = {
        user = "lad";
        hostname = sshHosts.archrraftMesh;
      };
      archcraft-lan = {
        user = "lad";
        hostname = sshHosts.archcraft;     # home-LAN IP — fallback when the mesh path is down (e.g. archcraft full-tunneling via Amnezia)
      };
      arch-t480 = {
        user = "lad";
        hostname = sshHosts.archT480;      # tailnet IP — reachable anywhere via the headscale mesh
      };
      arch-t480-mesh = {
        user = "lad";
        hostname = sshHosts.archT480;      # explicit tailnet alias (mirrors archcraft-mesh)
      };
      arch-t480-amn = {
        user = "lad";
        hostname = sshHosts.archT480Amn;   # Amnezia-subnet IP — reliable when both boxes share the Amnezia server
      };
      thinkbook = {
        user = "lad";
        hostname = sshHosts.thinkbook;
      };
      "gitlab.homelab.lan" = {
        hostname = "gitlab.homelab.lan";
        user = "git";
        port = 2222;
      };
    # VPS + work SSH match-blocks (real hostnames/users/proxy-jumps) live in the
    # gitignored private.nix as sshHosts.extraMatchBlocks and are merged here, so
    # they stay out of the public repo. Existing aliases are unchanged — same
    # `ssh`/`git` usage as before.
    } // (sshHosts.extraMatchBlocks or { });
  };
}
