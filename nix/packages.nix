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

    # ── Terminal & Shell ──────────────────────────────────────────────────────
    kitty                  # GPU-accelerated terminal emulator
    fzf                    # Fuzzy finder for terminal
    bat                    # Cat clone with syntax highlighting
    lsd                    # Modern ls replacement with icons
    btop                   # Interactive process/resource monitor
    pay-respects           # Suggests correct command when you mistype (thefuck alternative)
    neofetch               # System info display

    # ── Zsh Plugins ───────────────────────────────────────────────────────────
    zsh-syntax-highlighting  # Fish-like syntax highlighting for zsh
    zsh-fzf-tab              # Replace zsh completion with fzf
    zsh-you-should-use       # Reminds you to use your aliases

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
    telegram-desktop       # Telegram messaging client
    slack                  # Team messaging
    discord                # Voice/text chat

    # ── Media ─────────────────────────────────────────────────────────────────
    mpv                    # Minimal video player
    yt-dlp                 # YouTube/media downloader
    pulseaudio             # Contains pactl for volume control

    # ── Screen Recording ──────────────────────────────────────────────────────
    peek                   # Simple animated GIF screen recorder
    simplescreenrecorder   # Feature-rich screen recorder

    # ── Networking & API ──────────────────────────────────────────────────────
    httpie                 # User-friendly HTTP client
    amnezia-vpn            # VPN client

    # ── Databases ─────────────────────────────────────────────────────────────
    dbeaver-bin            # Universal database GUI client

    # ── Docker ────────────────────────────────────────────────────────────────
    docker                 # Container runtime
    docker-compose         # Multi-container Docker orchestration

    # ── Rofi & Launchers ──────────────────────────────────────────────────────
    rofi                   # Application launcher / window switcher
    brave-rofi-rust        # Rofi script to search Brave bookmarks/history

    # ── Rust Toolchain ────────────────────────────────────────────────────────
    cargo                  # Rust package manager and build tool

    # ── AI ────────────────────────────────────────────────────────────────────
    opencode               # AI coding agent for the terminal

  ];
}
