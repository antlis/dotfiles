{ ... }:
{
  # NFS client support so the kernel can mount nfs shares.
  boot.supportedFilesystems = [ "nfs" ];

  # 4TB media drive on the home server (homelab.lan -> resolved via the
  # networking.hosts entry in the gitignored private.nix, so no IP lands in the
  # public repo), exported read-only from /mnt/EHDDSG-4/data (music, video,
  # books, podcasts, ...).
  #
  # Mounted via systemd automount, NOT at boot: nothing is mounted until the
  # first access to /mnt/media, then it mounts on demand and auto-unmounts after
  # 10 min idle. If the server is offline, touching the folder returns a quick
  # error instead of hanging — boot is never blocked (`nofail` + automount).
  # NFSv4 (single port 2049, no rpcbind) keeps the server/firewall side simple.
  fileSystems."/mnt/media" = {
    device = "homelab.lan:/mnt/EHDDSG-4/data";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "ro"
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
