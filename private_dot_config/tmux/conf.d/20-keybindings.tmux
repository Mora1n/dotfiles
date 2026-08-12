# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Key Bindings
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Prefix keys
unbind C-b
set -g prefix M-z
set -g prefix2 C-\\
bind M-Z send-prefix
bind C-\\ send-prefix -2

# Session management
bind a choose-session
bind s new-session
bind BSpace switch-client -l

bind S display-popup -k -E "\
    (tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' | grep '^\*'; \
     tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' | grep -v '^\*') |\
    fzf --reverse --header kill-session |\
    sed 's/^[* ] *//' |\
    xargs -r tmux kill-session -t"

# Window management
bind -r Tab last-window

bind W display-popup -k -E "\
    (tmux list-windows -F '#{?window_active,* ,  }#{window_index} #{window_name}' | grep '^\*'; \
     tmux list-windows -F '#{?window_active,* ,  }#{window_index} #{window_name}' | grep -v '^\*') |\
    fzf --reverse --header kill-window |\
    sed 's/^[* ] *//' | cut -d' ' -f1 |\
    xargs -r tmux kill-window -t"

# Pane management
bind = setw synchronize-panes

# Copy mode
bind v copy-mode
bind P choose-buffer
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi g send-keys -X top-line
bind -T copy-mode-vi G send-keys -X bottom-line

# Clipboard integration
bind C-c run "tmux save-buffer - | xsel -i -b"
bind C-v run "tmux set-buffer \"$(xsel -o -b)\"; tmux paste-buffer"

# Utilities
bind r source-file ~/.config/tmux/tmux.conf \; display "✓ Config reloaded!"
bind R run-shell 'eval $(tmux show-environment -s DBUS_SESSION_BUS_ADDRESS); eval $(tmux show-environment -s DISPLAY); tmux display-message "✓ Environment refreshed"'
bind b set status

# Popups
bind C-p display-popup -k -E -w 80% -h 80% -d "#{pane_current_path}"
bind B display-popup -k -E -w 90% -h 90% "btm"
