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
  # LAN-primary, mesh-fallback: mount-nix-lan-or-mesh.sh handles switching.
  fileSystems."/mnt/archcraft" = {
    device = "homelab.lan:/home/lad";
    fsType = "nfs";
    options = [
      "noauto"                      # script owns mounting
      "x-systemd.requires=network-online.target"
      "nofail"                      # never block boot
    ];
  };

  # VeraCrypt 1TB drive — on-demand mount, only works if drive is unlocked
  # on archcraft first (~/my-scripts/mount-vera.sh). NFS export is dynamic.
  fileSystems."/mnt/vera" = {
    device = "homelab.lan:/mnt/vera";
    fsType = "nfs";
    options = [
      "noauto"                      # script owns mounting
      "x-systemd.requires=network-online.target"
      "nofail"                      # never block boot
    ];
  };
}
