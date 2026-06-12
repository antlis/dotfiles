{ config, pkgs, inputs, ... }:
let
  worktrunk = inputs.worktrunk.packages.${pkgs.stdenv.hostPlatform.system}.default;

  nodePackages = import ./node-packages.nix { inherit pkgs; };

  rustPackages = import ./rust-packages.nix { inherit pkgs inputs; };

  pythonPackages = import ./python-packages.nix { inherit pkgs; };

  opencode = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
    papirus-icon-theme     # Full-color icon theme — provides named icons (network-vpn, etc.) Adwaita 49 dropped; rofi resolves against it | https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
    dunst                  # Lightweight notification daemon | https://dunst-project.org
    libnotify              # Provides notify-send CLI for desktop notifications | https://man.archlinux.org/man/notify-send.1.en
    xev                    # X11 event viewer — shows keycodes, mouse events, and window events; useful for debugging keybindings | https://www.x.org/archive/X11R7.7/doc/man/man1/xev.1.xhtml
    gnupg                  # GNU Privacy Guard — encrypt, sign, and manage keys via OpenPGP | https://gnupg.org
    openssl                # Cryptography toolkit — TLS/SSL, certificates, and general-purpose crypto primitives | https://openssl.org
    xss-lock               # xss-lock hooks up your favorite locker to the MIT screen saver extension for X and also to systemd's login manager. | https://man.archlinux.org/man/xss-lock.1
    pandoc                 # Document converter | https://pandoc.org/
    texliveMedium          # TeX Live — provides pdflatex and common LaTeX packages. pdflatex engine for pandoc

    # ── Terminal & Shell ──────────────────────────────────────────────────────
    kitty                  # GPU-accelerated terminal emulator | https://sw.kovidgoyal.net/kitty
    television             # Fuzzy finder TUI with multiple data sources | https://github.com/alexpasmantier/television
    lsd                    # Modern ls replacement with icons and colors | https://github.com/lsd-rs/lsd
    btop                   # Interactive process and resource monitor | https://github.com/aristocratos/btop
    duf                    # Modern df replacement with a better UI | https://github.com/muesli/duf
    pay-respects           # Suggests correct command when you mistype (thefuck alternative) | https://codeberg.org/iff/pay-respects
    fastfetch              # System info display in the terminal | https://github.com/fastfetch-cli/fastfetch
    tldr                   # Simplified community-driven man pages with practical examples | https://tldr.sh
    navi                   # Interactive cheatsheet tool — browse and execute one-liners | https://github.com/denisidoro/navi
    lolcat                 # Rainbows and unicorns | https://github.com/busyloop/lolcat
    cowsay                 # Cowsay messages
    pv                     # Typewriter effect
    toilet                 # ASCII art for text | https://linuxcommandlibrary.com/man/toilet
    imagemagick            # https://imagemagick.org/
    worktrunk              # Git worktree management for parallel | https://worktrunk.dev/
    gh                     # GitHub CLI | https://cli.github.com
    glab                   # GitLab CLI | https://gitlab.com/gitlab-org/cli
    asciinema              # Terminal session recorder | https://asciinema.org
    dragon-drop            # Drag-and-drop source/target for X11 | https://github.com/mwh/dragon

    # ── Multiplexer ───────────────────────────────────────────────────────────
    tmux                   # Terminal multiplexer — split panes, sessions, and detach | https://github.com/tmux/tmux
    sesh                   # Manage tmux session with zoxide | https://github.com/joshmedeski/sesh

    # ── Editors & IDE ─────────────────────────────────────────────────────────
    neovim                 # Hyperextensible Vim-based text editor | https://neovim.io
    nodejs                 # JavaScript runtime (required by many LSPs and tools) | https://nodejs.org
    bubblewrap             # Bubblewrap sandbox runtime used by Codex | https://github.com/containers/bubblewrap
    playwright             # Browser automation library and CLI | https://playwright.dev
    playwright-mcp         # MCP server for browser control via Playwright | https://www.npmjs.com/package/@playwright/mcp
    (callPackage ../../pkgs/bun.nix { }) # Bun 1.3.14 pinned; nixpkgs 25.11 has 1.3.3 (too old for oh-my-pi) | https://bun.com/
    gcc                    # C compiler (required by treesitter parsers) | https://gcc.gnu.org
    stdenv.cc.cc.lib       # libstdc++.so.6 for Rust-backed tools like Headroom | https://gcc.gnu.org/onlinedocs/libstdc++/
    tree-sitter            # Parser generator for syntax highlighting and code analysis | https://tree-sitter.github.io
    ripgrep                # Fast regex search tool (used by telescope/fzf) | https://github.com/BurntSushi/ripgrep
    fd                     # Fast and user-friendly find replacement (used by telescope/fzf) | https://github.com/sharkdp/fd
    zed-editor             # Zed is a minimal code editor crafted for speed and collaboration with humans and AI. | https://zed.dev/

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
    ffmpegthumbnailer      # Lightweight video thumbnailer for file managers (MKV/MP4/etc) | https://github.com/dirkvdb/ffmpegthumbnailer
    totem                  # GNOME video player — provides totem-video-thumbnailer for Nautilus | https://wiki.gnome.org/Apps/Videos
    gst_all_1.gst-libav    # GStreamer ffmpeg plugin — provides video codecs for thumbnailing | https://gstreamer.freedesktop.org
    pulseaudio             # Audio server — includes pactl for volume control | https://www.freedesktop.org/wiki/Software/PulseAudio
    krita                  # Digital painting and illustration app | https://krita.org

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
    jq                     # JSON processor | https://jqlang.org/

    # ── Docker ────────────────────────────────────────────────────────────────
    docker                 # Container runtime for building and running images | https://www.docker.com
    docker-compose         # Multi-container Docker orchestration via YAML | https://docs.docker.com/compose

    # ── .NET ──────────────────────────────────────────────────────────────────
    (with dotnetCorePackages; combinePackages [
      dotnet-sdk_9           # .NET 9 SDK
      dotnet-sdk_10          # .NET 10 SDK
    ])

    # ── Wine (for U-SIEM Console) ────────────────────────────────────────────
    wineWow64Packages.stable # Windows compatibility layer (32+64-bit) | https://www.winehq.org
    winetricks               # Wine helper for installing Windows components | https://github.com/Winetricks/winetricks

    # ── Rofi & Launchers ──────────────────────────────────────────────────────
    rofi                   # Application launcher and window switcher | https://github.com/davatorium/rofi

    # ── Rust Toolchain ────────────────────────────────────────────────────────

    # ── AI ────────────────────────────────────────────────────────────────────
    opencode               # AI coding agent for the terminal | https://opencode.ai
    (callPackage ../../pkgs/codex.nix { }) # OpenAI Codex CLI — pinned prebuilt 0.137.0 (GPT-5.5); nixpkgs has only 0.92.0 | https://developers.openai.com/codex/cli
    (callPackage ../../pkgs/headroom.nix { inherit (pkgs) python312; }) # Headroom context compression wrapper for Codex/Claude | https://github.com/chopratejas/headroom
    (callPackage ../../pkgs/rtk.nix { }) # RTK compact command-output proxy for AI agents | https://github.com/rtk-ai/rtk
    (callPackage ../../pkgs/omp.nix { }) # oh-my-pi coding agent (pi fork with LSP/DAP + Python+Bun kernels) | https://omp.sh
    claude-code            # Claude Code CLI (Anthropic) | https://github.com/sadjow/claude-code-nix
    pi-coding-agent        # pi minimal terminal coding agent | https://pi.dev (flake: github:lukasl-dev/pi.nix)

  ] ++ nodePackages ++ rustPackages ++ pythonPackages;
}
