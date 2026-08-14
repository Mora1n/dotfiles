# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Plugins
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Plugin manager and plugin list
set -g @plugin "https://github.com/tmux-plugins/tpm.git"
set -g @plugin "https://github.com/tmux-plugins/tmux-resurrect.git"
set -g @plugin "https://github.com/tmux-plugins/tmux-continuum.git"
set -g @plugin "https://github.com/laktak/extrakto.git"
set -g @plugin "https://github.com/dracula/tmux.git"

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

# Text, path, and URL extraction
set -g @extrakto_key "none"
set -g @extrakto_grab_area "window 500"
set -g @extrakto_filter_order "all url path line word"
set -g @extrakto_clip_mode "bg"
set -g @extrakto_clip_mode_order "bg buffer"
set -g @extrakto_clip_tool "xsel -i --clipboard"
set -g @extrakto_editor "nvim"
set -g @extrakto_fzf_layout "reverse"
set -g @extrakto_fzf_header "i c o e f g h m"
set -g @extrakto_split_direction "p"
set -g @extrakto_popup_size "80%,70%"

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
