{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # ── General ───────────────────────────────────────────────────────────────
    prefix = "C-a";
    baseIndex = 1;
    historyLimit = 10000;
    mouse = true;
    escapeTime = 0;
    statusInterval = 5;
    keyMode = "vi";
    terminal = "screen-256color";

    # ── Plugins ───────────────────────────────────────────────────────────────
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      open
      copycat
    ];

    extraConfig = ''
      # ── Terminal ─────────────────────────────────────────────────────────────
      set-option -sa terminal-features ',screen-256color:RGB'
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # ── Pane indexing ─────────────────────────────────────────────────────────
      setw -g pane-base-index 1

      # ── Activity ──────────────────────────────────────────────────────────────
      setw -g monitor-activity on
      set -g visual-activity on
      set-option -g bell-action none

      # ── Vi copy mode ──────────────────────────────────────────────────────────
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      # ── Splits ────────────────────────────────────────────────────────────────
      bind - split-window -v
      bind | split-window -h

      # ── Pane navigation (vim-style) ───────────────────────────────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Pane navigation (alt arrows) ─────────────────────────────────────────
      bind -n M-Left  select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D

      # ── Pane resize ───────────────────────────────────────────────────────────
      bind H resize-pane -L 5
      bind J resize-pane -D 5
      bind K resize-pane -U 5
      bind L resize-pane -R 5

      # ── Mouse scroll ──────────────────────────────────────────────────────────
      bind -n WheelUpPane   if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      bind -n WheelDownPane select-pane -t= \; send-keys -M

      # ── Misc ──────────────────────────────────────────────────────────────────
      bind C-a send-prefix
      bind r source-file ~/.tmux.conf \; display "tmux.conf reloaded"
      bind-key 0 run "tmux split-window -p 40 'bash -ci ftpane'"
      bind N split-window -h -l 3 -b "printf '\e[38;5;0m\e[48;5;226m' && seq 200 1 && echo -n 0 && read" \; select-pane -l

      # ── Theme ─────────────────────────────────────────────────────────────────
      run-shell '. ~/.config/tmux-airline-dracula/airline-dracula.tmux'
    '';
  };
}
