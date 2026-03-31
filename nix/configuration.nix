{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      (import "${home-manager}/nixos")
      /etc/nixos/hardware-configuration.nix
      ./packages.nix
      ./home.nix
      ./private.nix
      ./bluetooth.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "kvm_intel" "kvm_amd" ];

  services.openssh.enable = true;
  # Enable sshd, but don't start it on boot
  systemd.services.sshd.wantedBy = lib.mkForce [];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "lad" ]; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  # TODO: remove hubstaff l2p etc when find better job that this shit
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
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "en_US.UTF-8";
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  # TODO: Remove after ditching stopphish
  # /etc/nixos/configuration.nix
  security.pki.certificateFiles = [
    /home/lad/Projects/wrk/stopphish/rootCA.crt
    /etc/ssl/certs/custom/rootCA.crt
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.lad = {
    isNormalUser = true;
    description = "lad";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  users.defaultUserShell = pkgs.zsh;

  programs.dconf.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.shells = with pkgs; [ zsh ];
  environment.sessionVariables = {
    BROWSER = "brave";
    PAGER = "more";
  };

  # For gpg
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;  # terminal-based, works everywhere
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

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
    binfmt = true;  # lets you run AppImages directly without ./
  };

  services.libinput = {
     enable = true;
     touchpad = {
       accelSpeed = "1";
       accelProfile = "flat"; 
       disableWhileTyping = true;
       tapping = true;
       naturalScrolling = false;
     };
   };
}
