{ pkgs, lib, ... }:
let
  nfs-refresh-dispatcher = pkgs.writeShellScript "99-nfs-refresh" ''
    # Refresh NFS mounts when tailscale0 comes up (e.g. after sleep, network change)
    INTERFACE="$1"
    ACTION="$2"

    if [[ "$INTERFACE" == "tailscale0" && "$ACTION" == "up" ]]; then
      sleep 2
      /run/current-system/sw/bin/systemctl restart mnt-media-mesh.automount 2>/dev/null || true
      /run/current-system/sw/bin/systemctl restart mnt-archcraft-mesh.automount 2>/dev/null || true
      /run/current-system/sw/bin/systemctl restart mnt-vera-mesh.automount 2>/dev/null || true
    fi
  '';

  nfs-cleanup-script = pkgs.writeShellScript "nfs-cleanup.sh" ''
    for pid in $(pgrep -f 'mount\.nfs'); do
      elapsed=$(ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' ')
      if [[ -n "$elapsed" && "$elapsed" -gt 30 ]]; then
        echo "Killing stuck mount.nfs (pid $pid, ${elapsed}s old)"
        kill -9 "$pid" 2>/dev/null || true
      fi
    done
  '';
in
{
  # ── NFS resilience ──────────────────────────────────────────────────────────
  # Auto-refresh NFS mounts when Tailscale reconnects, and clean up stuck
  # mount processes that block new mount attempts.

  # NetworkManager dispatcher: refresh NFS mounts when tailscale0 comes up
  environment.etc."NetworkManager/dispatcher.d/99-nfs-refresh" = {
    source = nfs-refresh-dispatcher;
    mode = "0755";
  };

  # Stuck mount cleanup: kill zombie mount.nfs processes every 5 minutes
  systemd.services.nfs-mount-cleanup = {
    description = "Clean up stuck NFS mount processes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = nfs-cleanup-script;
    };
  };

  systemd.timers.nfs-mount-cleanup = {
    description = "Run NFS mount cleanup every 5 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };

  # Restart automount units on failure
  systemd.services."mnt-media-mesh".unitConfig = {
    Restart = "on-failure";
    RestartSec = "10";
  };

  systemd.services."mnt-archcraft-mesh".unitConfig = {
    Restart = "on-failure";
    RestartSec = "10";
  };

  systemd.services."mnt-vera-mesh".unitConfig = {
    Restart = "on-failure";
    RestartSec = "10";
  };
}
