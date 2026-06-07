{ ... }:
{
  # NFS client support (also set in nfs-media.nix; list options merge, so this
  # module stays self-contained).
  boot.supportedFilesystems = [ "nfs" ];

  # Home directory of the home server `archcraft` (homelab.lan -> resolved via
  # the gitignored private.nix), exported READ-WRITE but scoped on the server to
  # this laptop's IP only (home holds ~/.ssh secrets). The server export uses
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
    device = "homelab.lan:/home/lad";
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
