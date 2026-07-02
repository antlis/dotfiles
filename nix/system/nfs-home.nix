{ sshHosts, ... }:
{
  # NFS client support (also set in nfs-media.nix; list options merge, so this
  # module stays self-contained).
  boot.supportedFilesystems = [ "nfs" ];

  # Home directory of the home server `archcraft`, reached over the headscale
  # mesh (sshHosts.archrraftMesh, always up regardless of network) rather than
  # the LAN-only homelab.lan, so this mount works both at home and away.
  # Tailscale/headscale negotiates a direct peer connection when both sides
  # are on the same LAN, falling back to DERP only when they can't see each
  # other, so this isn't a speed regression at home.
  #
  # Exported READ-WRITE but scoped on the server to this laptop's IP only
  # (home holds ~/.ssh secrets) — the server's /etc/exports ACL includes the
  # laptop's mesh IP alongside its LAN IP. The server export uses
  # all_squash,anonuid=1000,anongid=1000 so files map cleanly to lad:lad despite
  # the laptop/server primary-gid mismatch.
  #
  # Same systemd automount behaviour as the media mount: lazy on first access to
  # /mnt/archcraft, auto-unmounts when idle, never blocks boot.
  #
  # Note: moving files BETWEEN this mount and the read-only media drive from the
  # laptop copies bytes server->laptop->server. For bulk moves onto the 4TB
  # drive, run the move server-side over SSH instead (stays disk-to-disk).
  fileSystems."/mnt/archcraft" = {
    device = "${sshHosts.archrraftMesh}:/home/lad";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noauto"                      # don't mount at boot
      "x-systemd.automount"         # mount lazily on first access
      "x-systemd.idle-timeout=600"  # unmount after 10 min idle
      "x-systemd.mount-timeout=10s" # give up fast if the server is down
      "_netdev"                     # network filesystem
      "soft" "timeo=150" "retrans=3" # return errors instead of hanging forever
      "nofail"                      # never block boot on this mount
    ];
  };
}
