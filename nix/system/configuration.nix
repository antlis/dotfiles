{ config, pkgs, lib, ... }:
{
  imports =
    [
      ../home/home.nix
      ./packages/packages.nix
      ./bluetooth.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "kvm_intel" "kvm_amd" "tiny_power_button" ];

  # Hibernation settings
  boot.initrd.kernelModules = [ "nvme_core" "nvme" "ext4" ];
  powerManagement.enable = true;
  # Use root partition UUID for resume
  boot.resumeDevice = "/dev/disk/by-uuid/e49c4ff0-e799-4ee0-a97c-666e71c3a004";
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];
  # Suspend-then-hibernate and power buttons
  services.power-profiles-daemon.enable = true;
  services.logind.settings = {
    Login = {
      HandleLidSwitch            = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      # HandlePowerKey             = "hibernate";
      HandlePowerKeyLongPress    = "poweroff";
    };
  };
  services.acpid = {
    enable = true;
    handlers = {
      # power = {
      #   event = "button/power.*";
      #   action = "${pkgs.systemd}/bin/systemctl hibernate";
      # };
      lid = {
        event = "button/lid.*";
        action = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      };
    };
  };
  # Set suspend-to-hibernate delay (default 1h)
  environment.etc."systemd/sleep.conf".text = ''
    [Sleep]
    HibernateDelaySec=5min
  '';

  services.openssh.enable = true;
  # Enable sshd, but don't start it on boot
  systemd.services.sshd.wantedBy = lib.mkForce [];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "lad" ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-strongswan
    ];
  };
  services.strongswan = {
    enable = true;
    secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };
  environment.etc."strongswan.conf".text = ''
    charon {
      integrity_test = no
    }
  '';
  services.xl2tpd.enable = true;
  environment.etc."NetworkManager/VPN/nm-l2tp-service.name".source = "${pkgs.networkmanager-l2tp}/lib/NetworkManager/VPN/nm-l2tp-service.name";
  # TODO: remove hubstaff l2tp etc when find better job
  environment.systemPackages = with pkgs; [
    ppp
    hubstaff
  ];

  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT    = "ru_RU.UTF-8";
    LC_MONETARY       = "ru_RU.UTF-8";
    LC_NAME           = "ru_RU.UTF-8";
    LC_NUMERIC        = "ru_RU.UTF-8";
    LC_PAPER          = "ru_RU.UTF-8";
    LC_TELEPHONE      = "ru_RU.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
        dmenu
      ];
    };
  };

  services.displayManager = {
    gdm.enable = true;
    defaultSession = "none+i3";
  };
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  # TODO: Remove after ditching stopphish
  security.pki.certificateFiles = [
    /home/lad/Projects/wrk/stopphish/rootCA.crt
    /etc/ssl/certs/custom/rootCA.crt
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.lad = {
    isNormalUser = true;
    description = "lad";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
  users.defaultUserShell = pkgs.zsh;

  programs.dconf.enable = true;
  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    BROWSER = "brave";
    PAGER   = "more";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.amnezia-vpn.enable = true;
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };
  programs.nix-ld.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.libinput = {
    enable = true;
    touchpad = {
      accelSpeed        = "1";
      accelProfile      = "flat";
      disableWhileTyping = true;
      tapping           = true;
      naturalScrolling  = false;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
