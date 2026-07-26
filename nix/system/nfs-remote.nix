{ sshHosts, ... }:
{
  # Remote counterparts of nfs-media.nix / nfs-home.nix, reached over the
  # headscale mesh (sshHosts.archrraftMesh) instead of the LAN-only
  # homelab.lan, for use when away from home. Deliberately separate
  # mountpoints rather than one auto-switching path: avoids Tailscale
  # subnet-route + source-NAT headaches, and never routes LAN traffic over
  # Tailscale while home. At home use /mnt/media + /mnt/archcraft; away use
  # these. Slightly higher mount-timeout than the LAN mounts for internet
  # latency.
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/media-mesh" = {
    device = "${sshHosts.archrraftMesh}:/mnt/EHDDSG-4/data";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "rw"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=15s"
      "_netdev"
      "soft" "timeo=200" "retrans=3"
      "nofail"
    ];
  };

  fileSystems."/mnt/archcraft-mesh" = {
    device = "${sshHosts.archrraftMesh}:/home/lad";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=15s"
      "_netdev"
      "soft" "timeo=200" "retrans=3"
      "nofail"
    ];
  };

  fileSystems."/mnt/vera-mesh" = {
    device = "${sshHosts.archrraftMesh}:/mnt/vera";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "rw"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=15s"
      "_netdev"
      "soft" "timeo=200" "retrans=3"
      "nofail"
    ];
  };
}
