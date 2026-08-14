# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Options
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Terminal
set -s default-terminal "tmux-256color"
set -g terminal-overrides "linux*:AX@,*256col*:Tc,xterm*:Tc"
set -g allow-passthrough on
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM

# Input and navigation
set -g mouse on
set -g mode-keys vi
set -g status-keys emacs
set -s escape-time 10
set -g repeat-time 600
set -g display-time 4000
set -g history-limit 50000
set -g focus-events on
setw -g aggressive-resize on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g detach-on-destroy off

# tmux 3.6 UI refinements
set -g pane-border-lines heavy
set -g copy-mode-position-style bg=#f1fa8c,fg=#282a36,bold
set -g copy-mode-selection-style bg=#8be9fd,fg=#282a36
set -g prompt-cursor-colour "#8be9fd"
set -g prompt-cursor-style blinking-bar
set -g input-buffer-size 2097152

# Status bar
set -g status-position top

# Clipboard
set -s set-clipboard on
set -s copy-command "xsel -i --clipboard"
