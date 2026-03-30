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

  nodePackages = import ./node-packages.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [

    # ── Core / System ─────────────────────────────────────────────────────────
    vim                    # Terminal text editor | https://www.vim.org
    wget                   # File downloader | https://www.gnu.org/software/wget
    git                    # Version control | https://git-scm.com
    tree                   # Directory tree viewer | https://oldmanprogrammer.net/source.php?dir=projects/tree
    unzip                  # Archive extraction | https://infozip.sourceforge.net
    xclip                  # Clipboard manager for X11 | https://github.com/astrand/xclip
    redshift               # Screen color temperature (night mode) | https://github.com/jonls/redshift
    keynav                 # Keyboard-driven mouse control | https://www.semicomplete.com/projects/keynav
    x2x                    # Share keyboard/mouse across X displays | https://github.com/dottedmag/x2x
    adwaita-icon-theme     # GNOME icon theme | https://gitlab.gnome.org/GNOME/adwaita-icon-theme
    dunst                  # Lightweight notification daemon | https://dunst-project.org
    libnotify              # Provides notify-send CLI for desktop notifications | https://man.archlinux.org/man/notify-send.1.en
    xev                    # X11 event viewer — shows keycodes, mouse events, and window events; useful for debugging keybindings | https://www.x.org/archive/X11R7.7/doc/man/man1/xev.1.xhtml
    gnupg                  # GNU Privacy Guard — encrypt, sign, and manage keys via OpenPGP | https://gnupg.org
    openssl                # Cryptography toolkit — TLS/SSL, certificates, and general-purpose crypto primitives | https://openssl.org

    # ── Terminal & Shell ──────────────────────────────────────────────────────
    kitty                  # GPU-accelerated terminal emulator | https://sw.kovidgoyal.net/kitty
    fzf                    # Fuzzy finder for terminal | https://junegunn.github.io/fzf
    television             # Fuzzy finder TUI with multiple data sources | https://github.com/alexpasmantier/television
    bat                    # Cat clone with syntax highlighting and Git integration | https://github.com/sharkdp/bat
    lsd                    # Modern ls replacement with icons and colors | https://github.com/lsd-rs/lsd
    btop                   # Interactive process and resource monitor | https://github.com/aristocratos/btop
    duf                    # Modern df replacement with a better UI | https://github.com/muesli/duf
    pay-respects           # Suggests correct command when you mistype (thefuck alternative) | https://codeberg.org/iff/pay-respects
    neofetch               # System info display in the terminal | https://github.com/dylanaraps/neofetch
    tldr                   # Simplified community-driven man pages with practical examples | https://tldr.sh
    navi                   # Interactive cheatsheet tool — browse and execute one-liners | https://github.com/denisidoro/navi
    lolcat                 # Rainbows and unicorns | https://github.com/busyloop/lolcat
    cowsay                 # Cowsay messages
    pv                     # Typewriter effect
    toilet                 # ASCII art for text | https://linuxcommandlibrary.com/man/toilet
    imagemagick            # https://imagemagick.org/

    # ── Zsh Plugins ───────────────────────────────────────────────────────────
    zsh-syntax-highlighting  # Fish-like syntax highlighting for zsh | https://github.com/zsh-users/zsh-syntax-highlighting
    zsh-fzf-tab              # Replace zsh tab completion with fzf | https://github.com/Aloxaf/fzf-tab
    zsh-you-should-use       # Reminds you to use existing aliases | https://github.com/MichaelAquilina/zsh-you-should-use
    zoxide                   # Smarter cd — jumps to frecent directories | https://github.com/ajeetdsouza/zoxide

    # ── Multiplexer ───────────────────────────────────────────────────────────
    tmux                   # Terminal multiplexer — split panes, sessions, and detach | https://github.com/tmux/tmux
    tmuxinator             # Manage and restore tmux session layouts via YAML | https://github.com/tmuxinator/tmuxinator

    # ── Editors & IDE ─────────────────────────────────────────────────────────
    neovim                 # Hyperextensible Vim-based text editor | https://neovim.io
    nodejs                 # JavaScript runtime (required by many LSPs and tools) | https://nodejs.org
    gcc                    # C compiler (required by treesitter parsers) | https://gcc.gnu.org
    tree-sitter            # Parser generator for syntax highlighting and code analysis | https://tree-sitter.github.io
    ripgrep                # Fast regex search tool (used by telescope/fzf) | https://github.com/BurntSushi/ripgrep
    fd                     # Fast and user-friendly find replacement (used by telescope/fzf) | https://github.com/sharkdp/fd

    # ── Notes & Knowledge ─────────────────────────────────────────────────────
    obsidian               # Markdown-based knowledge base and note-taking app | https://obsidian.md

    # ── File Management ───────────────────────────────────────────────────────
    yazi                   # Blazing-fast terminal file manager with image preview | https://github.com/sxyazi/yazi

    # ── Git TUIs ──────────────────────────────────────────────────────────────
    lazygit                # Terminal UI for git operations | https://github.com/jesseduffield/lazygit
    lazydocker             # Terminal UI for Docker container management | https://github.com/jesseduffield/lazydocker

    # ── Browsers ──────────────────────────────────────────────────────────────
    brave                  # Privacy-focused Chromium-based browser | https://brave.com
    surfraw                # CLI tool for fast web searches and browser bookmarks | https://gitlab.com/surfraw/Surfraw

    # ── Communication ─────────────────────────────────────────────────────────
    ayugram-desktop        # Telegram desktop client with Ghost mode and extra customization | https://ayugram.one
    slack                  # Team messaging and collaboration | https://slack.com
    discord                # Voice, video, and text chat for communities | https://discord.com

    # ── Media ─────────────────────────────────────────────────────────────────
    mpv                    # Minimal and scriptable video player | https://mpv.io
    yt-dlp                 # YouTube and media downloader supporting 1000+ sites | https://github.com/yt-dlp/yt-dlp
    pulseaudio             # Audio server — includes pactl for volume control | https://www.freedesktop.org/wiki/Software/PulseAudio

    # ── Screen Recording ──────────────────────────────────────────────────────
    peek                   # Simple animated GIF screen recorder | https://github.com/phw/peek
    simplescreenrecorder   # Feature-rich screen recorder with live preview | https://www.maartenbaert.be/simplescreenrecorder
    gnome-screenshot       # Screenshot tool with region and window capture | https://gitlab.gnome.org/GNOME/gnome-screenshot

    # ── Networking & API ──────────────────────────────────────────────────────
    httpie                 # User-friendly HTTP client for the terminal | https://httpie.io
    postman                # GUI HTTP client for API development and testing | https://www.postman.com
    amnezia-vpn            # Self-hosted VPN client with censorship bypass | https://amnezia.org
    dig                    # DNS lookup utility — query nameservers and troubleshoot DNS resolution | https://man.archlinux.org/man/dig.1
    kubectl                # Kubernetes CLI — deploy and manage containerized workloads on clusters | https://kubernetes.io/docs/reference/kubectl

    # ── Docker ────────────────────────────────────────────────────────────────
    docker                 # Container runtime for building and running images | https://www.docker.com
    docker-compose         # Multi-container Docker orchestration via YAML | https://docs.docker.com/compose

    # ── Rofi & Launchers ──────────────────────────────────────────────────────
    rofi                   # Application launcher and window switcher | https://github.com/davatorium/rofi
    brave-rofi-rust        # Rofi plugin to search Brave browser bookmarks and history | https://github.com/antlis/brave-rofi-rust

    # ── Rust Toolchain ────────────────────────────────────────────────────────
    cargo                  # Rust package manager and build tool | https://doc.rust-lang.org/cargo

    # ── AI ────────────────────────────────────────────────────────────────────
    opencode               # AI coding agent for the terminal | https://opencode.ai

  ] ++ nodePackages;
}
