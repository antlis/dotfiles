{ lib, ... }:
let
  notify = msg: "/run/current-system/sw/bin/notify-send -i dialog-information 'NFS Mount' '${msg}'";
  mkNotify = name: desc: mountUnit: msg: {
    description = desc;
    after = [ mountUnit ];
    bindsTo = [ mountUnit ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "lad";
      Environment = [
        "DISPLAY=:0"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
      ];
      ExecStart = notify msg;
    };
  };
in
{
  systemd.services."nfs-notify-media" = mkNotify
    "nfs-notify-media" "Notify when /mnt/media mounts"
    "mnt-media.mount" "/mnt/media mounted (LAN)";

  systemd.services."nfs-notify-archcraft" = mkNotify
    "nfs-notify-archcraft" "Notify when /mnt/archcraft mounts"
    "mnt-archcraft.mount" "/mnt/archcraft mounted (LAN)";

  systemd.services."nfs-notify-vera" = mkNotify
    "nfs-notify-vera" "Notify when /mnt/vera mounts"
    "mnt-vera.mount" "/mnt/vera mounted (LAN)";

  systemd.services."nfs-notify-media-mesh" = mkNotify
    "nfs-notify-media-mesh" "Notify when /mnt/media-mesh mounts"
    "mnt-media-mesh.mount" "/mnt/media-mesh mounted (Tailscale)";

  systemd.services."nfs-notify-archcraft-mesh" = mkNotify
    "nfs-notify-archcraft-mesh" "Notify when /mnt/archcraft-mesh mounts"
    "mnt-archcraft-mesh.mount" "/mnt/archcraft-mesh mounted (Tailscale)";

  systemd.services."nfs-notify-vera-mesh" = mkNotify
    "nfs-notify-vera-mesh" "Notify when /mnt/vera-mesh mounts"
    "mnt-vera-mesh.mount" "/mnt/vera-mesh mounted (Tailscale)";
}
