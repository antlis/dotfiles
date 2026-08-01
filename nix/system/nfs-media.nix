{ ... }:
{
  # NFS client support so the kernel can mount nfs shares.
  boot.supportedFilesystems = [ "nfs" ];

  # 4TB media drive on the home server (homelab.lan -> resolved via the
  # networking.hosts entry in the gitignored private.nix).
  #
  # LAN-primary, mesh-fallback: mount-nix-lan-or-mesh.sh handles switching
  # between homelab.lan (LAN, fast) and 100.64.0.1 (mesh, fallback) based on
  # reachability probes. This unit only creates the mountpoint dir — the script
  # owns the actual mount.
  fileSystems."/mnt/media" = {
    device = "homelab.lan:/mnt/EHDDSG-4/data";
    fsType = "nfs";
    options = [
      "noauto"                      # script owns mounting
      "x-systemd.requires=network-online.target"
      "nofail"                      # never block boot
    ];
  };
}
