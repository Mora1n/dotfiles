# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Plugins
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Plugin manager and plugin list
set -g @plugin "tmux-plugins/tpm"
set -g @plugin "tmux-plugins/tmux-sensible"
set -g @plugin "tmux-plugins/tmux-resurrect"
set -g @plugin "tmux-plugins/tmux-continuum"
set -g @plugin "tmux-plugins/tmux-pain-control"
set -g @plugin "tmux-plugins/tmux-yank"
set -g @plugin "wfxr/tmux-fzf-url"
set -g @plugin "dracula/tmux"

# Session persistence
set -g @resurrect-strategy-vim "session"
set -g @resurrect-strategy-nvim "session"
set -g @resurrect-capture-pane-contents "on"
set -g @resurrect-processes 'ssh psql mysql sqlite3'
set -g @resurrect-save-script-path "/home/morain/.config/tmux/scripts/resurrect-safe-save.sh"
set -g @resurrect-restore-script-path "/home/morain/.config/tmux/scripts/resurrect-safe-restore.sh"

# Auto save and restore
set -g @continuum-restore "on"
set -g @continuum-save-interval "30"
set -g @continuum-boot "on"
set -g @continuum-systemd-start-cmd "start-server"

# Copy enhancement
set -g @yank_selection_mouse 'clipboard'
set -g @yank_action 'copy-pipe-no-clear'

# Theme
set -g @dracula-plugins "ssh-session synchronize-panes time"
set -g @dracula-show-powerline true
set -g @dracula-transparent-powerline-bg true
set -g @dracula-inverse-divider 
set -g @dracula-show-left-icon " #S"
set -g @dracula-synchronize-panes-label "󰌹"
set -g @dracula-refresh-rate 10
set -g @dracula-show-empty-plugins false
set -g @dracula-border-contrast true
set -g @dracula-show-flags true
set -g @dracula-show-ssh-only-when-connected true
set -g @dracula-show-ssh-session-port true
set -g @dracula-time-format "📅%a %m/%d 🕒%I:%M %p"
