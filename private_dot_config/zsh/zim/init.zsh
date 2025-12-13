# FILE AUTOMATICALLY GENERATED FROM /home/morain/.config/zsh/zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source "${HOME}/.config/zsh/zim/zimfw.zsh" "${@}" }
fpath=("${HOME}/.config/zsh/zim/modules/git/functions" "${HOME}/.config/zsh/zim/modules/utility/functions" "${HOME}/.config/zsh/zim/modules/zsh-completions/src" "${HOME}/.config/zsh/zim/modules/completion/functions" ${fpath})
autoload -Uz -- git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw
source "${HOME}/.config/zsh/zim/modules/environment/init.zsh"
source "${HOME}/.config/zsh/zim/modules/git/init.zsh"
source "${HOME}/.config/zsh/zim/modules/input/init.zsh"
source "${HOME}/.config/zsh/zim/modules/termtitle/init.zsh"
source "${HOME}/.config/zsh/zim/modules/utility/init.zsh"
source "${HOME}/.config/zsh/zim/modules/fzf/init.zsh"
source "${HOME}/.config/zsh/zim/modules/zim-zoxide/init.zsh"
source "${HOME}/.config/zsh/zim/modules/completion/init.zsh"
source "${HOME}/.config/zsh/zim/modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "${HOME}/.config/zsh/zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "${HOME}/.config/zsh/zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
