# fzf configuration for fish shell
# Auto-loaded from conf.d directory

# Initialize fzf key bindings
# This provides:
# - Ctrl+R: Search command history
# - Ctrl+T: Search files and insert into command line
# - Alt+C: Search directories and cd into them
fzf --fish | source

# fzf default options - Dracula theme colors matching your fish theme
set -gx FZF_DEFAULT_OPTS "\
--height 60% \
--layout=reverse \
--border \
--inline-info \
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# Use fd instead of find for better performance (if available)
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
end

# Preview file content using bat (if available) or cat
if type -q bat
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
else
    set -gx FZF_CTRL_T_OPTS "--preview 'cat {}'"
end

# Preview directory content using eza or ls
if type -q eza
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --color=always {}'"
else
    set -gx FZF_ALT_C_OPTS "--preview 'ls -la {}'"
end
