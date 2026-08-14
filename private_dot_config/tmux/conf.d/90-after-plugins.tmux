# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Plugin-After Overrides
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

unbind C-s
unbind C-r
unbind u
unbind y
bind -N "Switch to the last session" BSpace switch-client -l
set -g @resurrect-save-script-path "/home/morain/.config/tmux/scripts/resurrect-safe-save.sh"
set -g @resurrect-restore-script-path "/home/morain/.config/tmux/scripts/resurrect-safe-restore.sh"
bind -N "Save tmux sessions" C-s run-shell "~/.config/tmux/scripts/resurrect-safe-save.sh"
bind -N "Restore tmux sessions" C-r run-shell "~/.config/tmux/scripts/resurrect-safe-restore.sh"

# Extrakto replaces the URL and line-copy plugins with one searchable interface.
bind -N "Extract text, paths, and URLs" u run-shell '~/.config/tmux/plugins/extrakto/scripts/open.sh "#{pane_id}" all'
bind -N "Extract complete lines" y run-shell '~/.config/tmux/plugins/extrakto/scripts/open.sh "#{pane_id}" line'

# Continuum 自动保存触发器:
# continuum 启动时把 #(continuum_save.sh) 注入 status-right,靠状态栏刷新触发定时保存,
# 但 dracula 主题加载时会清空并重建 status-right,把该钩子抹掉。
# 这里在所有插件(含 dracula)加载后重新追加钩子。脚本无 stdout 输出,不显示文字;
# 状态栏每次刷新即调用,脚本内部按 @continuum-save-interval(30 分钟)判断是否真正保存。
set -ga status-right "#(~/.config/tmux/plugins/tmux-continuum/scripts/continuum_save.sh)"

# Keep the viewport anchored after keyboard copy actions.
unbind -T copy-mode-vi M-y
unbind -T copy-mode M-y
unbind -T copy-mode-vi Y
unbind -T copy-mode Y

bind -T copy-mode-vi Enter send-keys -X copy-pipe-no-clear
bind -T copy-mode-vi ! send-keys -X copy-pipe-no-clear "tr -d '\n' | xsel -i --clipboard"
bind -T copy-mode-vi y send-keys -X copy-pipe "xsel -i --clipboard"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe "xsel -i --clipboard"
bind -T copy-mode-vi DoubleClick1Pane select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
bind -T copy-mode-vi TripleClick1Pane select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe
bind -T copy-mode-vi C-j send-keys -X copy-pipe-no-clear

bind -T copy-mode ! send-keys -X copy-pipe-no-clear "tr -d '\n' | xsel -i --clipboard"
bind -T copy-mode y send-keys -X copy-pipe-no-clear "xsel -i --clipboard"
bind -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe "xsel -i --clipboard"
bind -T copy-mode DoubleClick1Pane select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
bind -T copy-mode TripleClick1Pane select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe
bind -T copy-mode M-w send-keys -X copy-pipe-no-clear
bind -T copy-mode C-k send-keys -X copy-pipe-end-of-line
bind -T copy-mode C-w send-keys -X copy-pipe-no-clear

bind -T root DoubleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" "send-keys -M" "copy-mode -H \\; send-keys -X select-word \\; run-shell -d 0.3 \\; send-keys -X copy-pipe"
bind -T root TripleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" "send-keys -M" "copy-mode -H \\; send-keys -X select-line \\; run-shell -d 0.3 \\; send-keys -X copy-pipe"
