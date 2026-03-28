{ config, pkgs, ... }:
let
  brave-rofi-rust = pkgs.rustPlatform.buildRustPackage {
    pname = "brave-rofi-rust";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "antlis";
      repo = "brave-rofi-rust";
      rev = "master";
      hash = "sha256-STlBrSYZ+SkM1JV2pQciYfVQhKStnantUACxz7AuJxY=";
    };
    cargoHash = "sha256-Y50dAfbDVZGoTf0rq0Z5fMc9sFVVGGPQv+LCywaktEU=";
  };
in
{
  environment.systemPackages = with pkgs; [

    # ── Core / System ─────────────────────────────────────────────────────────
    vim                    # Terminal text editor
    wget                   # File downloader
    git                    # Version control
    tree                   # Directory tree viewer
    unzip                  # Archive extraction
    xclip                  # Clipboard manager for X11
    redshift               # Screen color temperature (night mode)
    keynav                 # Keyboard-driven mouse control
    x2x                    # Share keyboard/mouse across X displays
    adwaita-icon-theme     # GNOME icon theme
    dunst                  # Lightweight notification daemon
    libnotify              # Provides notify-send CLI for desktop notifications | https://man.archlinux.org/man/notify-send.1.en
    xev                    # X11 event viewer — shows keycodes, mouse events, and window events; useful for debugging keybindings | https://www.x.org/archive/X11R7.7/doc/man/man1/xev.1.xhtml
    gnupg                  # GNU Privacy Guard — encrypt, sign, and manage keys via OpenPGP | https://gnupg.org
    openssl                # Cryptography toolkit — TLS/SSL, certificates, and general-purpose crypto primitives | https://openssl.org
    nodePackages.pnpm      # Fast, disk-efficient Node.js package manager | https://pnpm.io
    # picom                  # Compositor for X11 (shadows, transparency, dimming)

    # ── Terminal & Shell ──────────────────────────────────────────────────────
    kitty                  # GPU-accelerated terminal emulator | https://sw.kovidgoyal.net/kitty/
    fzf                    # Fuzzy finder for terminal | https://junegunn.github.io/fzf/
    television             # Fuzzy finder | https://github.com/alexpasmantier/television
    bat                    # Cat clone with syntax highlighting | https://github.com/sharkdp/bat
    lsd                    # Modern ls replacement with icons | https://github.com/lsd-rs/lsd
    btop                   # Interactive process/resource monitor | https://github.com/aristocratos/btop
    duf                    # Modern df replacement | https://github.com/muesli/duf
    pay-respects           # Suggests correct command when you mistype (thefuck alternative)
    neofetch               # System info display | https://github.com/dylanaraps/neofetch

    # ── Zsh Plugins ───────────────────────────────────────────────────────────
    zsh-syntax-highlighting  # Fish-like syntax highlighting for zsh
    zsh-fzf-tab              # Replace zsh completion with fzf
    zsh-you-should-use       # Reminds you to use your aliases
    zoxide                   # A smarter cd | https://github.com/ajeetdsouza/zoxide

    # ── Multiplexer ───────────────────────────────────────────────────────────
    tmux                   # Terminal multiplexer
    tmuxinator             # Manage tmux session layouts via YAML

    # ── Editors & IDE ─────────────────────────────────────────────────────────
    neovim                 # Hyperextensible Vim-based text editor
    nodejs                 # JavaScript runtime (required by many LSPs)
    gcc                    # C compiler (required by treesitter)
    tree-sitter            # Parser generator for syntax highlighting
    ripgrep                # Fast grep replacement (used by telescope/fzf)
    fd                     # Fast find replacement (used by telescope/fzf)

    # ── File Management ───────────────────────────────────────────────────────
    yazi                   # Terminal file manager

    # ── Git TUIs ──────────────────────────────────────────────────────────────
    lazygit                # Terminal UI for git
    lazydocker             # Terminal UI for docker

    # ── Browsers ──────────────────────────────────────────────────────────────
    brave                  # Privacy-focused Chromium-based browser
    surfraw                # CLI browser bookmarks / web search

    # ── Communication ─────────────────────────────────────────────────────────
    # telegram-desktop     # Telegram messaging client
    ayugram-desktop        # Desktop Telegram client with good customization and Ghost mode
    slack                  # Team messaging
    discord                # Voice/text chat

    # ── Media ─────────────────────────────────────────────────────────────────
    mpv                    # Minimal video player | https://mpv.io/
    yt-dlp                 # YouTube/media downloader | https://github.com/yt-dlp/yt-dlp
    pulseaudio             # Contains pactl for volume control

    # ── Screen Recording ──────────────────────────────────────────────────────
    peek                   # Simple animated GIF screen recorder
    simplescreenrecorder   # Feature-rich screen recorder | https://simplescreenrecorder.com/
    gnome-screenshot       # Screenshots

    # ── Networking & API ──────────────────────────────────────────────────────
    httpie                 # User-friendly HTTP client | https://httpie.io/
    postman                # Indian HTTP client | https://www.postman.com/
    amnezia-vpn            # VPN client | https://amnezia.org/
    dig                    # DNS lookup utility — query nameservers and troubleshoot DNS resolution | https://man.archlinux.org/man/dig.1
    kubectl                # Kubernetes CLI — deploy and manage containerized workloads on clusters | https://kubernetes.io/docs/reference/kubectl/

    # ── Docker ────────────────────────────────────────────────────────────────
    docker                 # Container runtime
    docker-compose         # Multi-container Docker orchestration

    # ── Rofi & Launchers ──────────────────────────────────────────────────────
    rofi                   # Application launcher / window switcher
    brave-rofi-rust        # Rofi script to search Brave bookmarks/history

    # ── Rust Toolchain ────────────────────────────────────────────────────────
    cargo                  # Rust package manager and build tool

    # ── AI ────────────────────────────────────────────────────────────────────
    opencode               # AI coding agent for the terminal | https://opencode.ai/

    # Node
    nodePackages.pm2       # Production process manager for Node.js with built-in load balancer and zero-downtime reloads | https://github.com/Unitech/pm2

  ];
}
