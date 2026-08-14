# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Key Bindings
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Prefix keys
unbind C-b
unbind M-z
unbind M-Z
set -g prefix M-t
set -g prefix2 C-\\
bind M-T send-prefix
bind C-\\ send-prefix -2

# Session management
bind -N "Choose session with native tree and layout" a choose-tree -Zs
bind -N "Choose a project session with sesh" s run-shell -E -c "#{pane_current_path}" "~/.local/bin/tmux-sesh-picker #{q:pane_current_path}"
bind -N "Switch to the last session" BSpace switch-client -l

bind -N "Kill a session with fzf" S display-popup -k -E "\
    (tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' | grep '^\*'; \
     tmux list-sessions -F '#{?session_attached,* ,  }#{session_name}' | grep -v '^\*') |\
    fzf --reverse --header kill-session |\
    sed 's/^[* ] *//' |\
    xargs -r tmux kill-session -t"

# Window management
bind -r -N "Switch to the last window" Tab last-window
bind -N "Create a window in the current directory" c new-window -c "#{pane_current_path}"
bind -N "Switch to the next window" C-n next-window
bind -r -N "Move the current window left" < swap-window -d -t -1
bind -r -N "Move the current window right" > swap-window -d -t +1

bind -N "Kill a window with fzf" W display-popup -k -E "\
    (tmux list-windows -F '#{?window_active,* ,  }#{window_index} #{window_name}' | grep '^\*'; \
     tmux list-windows -F '#{?window_active,* ,  }#{window_index} #{window_name}' | grep -v '^\*') |\
    fzf --reverse --header kill-window |\
    sed 's/^[* ] *//' | cut -d' ' -f1 |\
    xargs -r tmux kill-window -t"

# Pane management
bind -N "Focus the pane on the left" h select-pane -L
bind -N "Focus the pane below" j select-pane -D
bind -N "Focus the pane above" k select-pane -U
bind -N "Focus the pane on the right" l select-pane -R
bind -N "Focus the pane on the left" C-h select-pane -L
bind -N "Focus the pane below" C-j select-pane -D
bind -N "Focus the pane above" C-k select-pane -U
bind -N "Focus the pane on the right" C-l select-pane -R

bind -r -N "Resize the pane left" H resize-pane -L 5
bind -r -N "Resize the pane down" J resize-pane -D 5
bind -r -N "Resize the pane up" K resize-pane -U 5
bind -r -N "Resize the pane right" L resize-pane -R 5

bind -N "Split the pane to the right" | split-window -h -c "#{pane_current_path}"
bind -N "Split the pane to the left" \\ split-window -fh -c "#{pane_current_path}"
bind -N "Split the pane below" - split-window -v -c "#{pane_current_path}"
bind -N "Split the pane above" _ split-window -fv -c "#{pane_current_path}"
bind -N "Split the pane horizontally" % split-window -h -c "#{pane_current_path}"
bind -N "Split the pane vertically" '"' split-window -v -c "#{pane_current_path}"
bind -N "Toggle synchronized input" = setw synchronize-panes

# Copy mode
bind -N "Enter copy mode" v copy-mode
bind -N "Choose a paste buffer" P choose-buffer
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi g send-keys -X top-line
bind -T copy-mode-vi G send-keys -X bottom-line

# Clipboard integration
bind -N "Copy the tmux buffer to the clipboard" C-c run "tmux save-buffer - | xsel -i -b"
bind -N "Paste from the clipboard" C-v run "tmux set-buffer \"$(xsel -o -b)\"; tmux paste-buffer"
bind -N "Copy the current pane directory" Y run-shell 'tmux set-buffer -- #{q:pane_current_path} && printf %s #{q:pane_current_path} | xsel -i --clipboard && tmux display-message "PWD copied to clipboard"'

# Utilities
bind -N "Reload the tmux configuration" r source-file ~/.config/tmux/tmux.conf \; display "✓ Config reloaded!"
bind -N "Refresh the desktop environment" R run-shell 'eval $(tmux show-environment -s DBUS_SESSION_BUS_ADDRESS); eval $(tmux show-environment -s DISPLAY); tmux display-message "✓ Environment refreshed"'
bind -N "Toggle the status bar" b set status

# Popups
bind -N "Open a shell popup" C-p display-popup -k -E -w 80% -h 80% -d "#{pane_current_path}"
bind -N "Open btm in a popup" B display-popup -k -E -w 90% -h 90% "btm"
