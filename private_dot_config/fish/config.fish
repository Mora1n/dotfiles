if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # eza aliases
    alias l='eza'
    alias la='eza -a'
    alias ll='eza -l'

    # no welcome message
    set fish_greeting ""

end
