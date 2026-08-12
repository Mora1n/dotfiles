if status is-interactive
    # Commands to run in interactive sessions can go here

    # Starship.rs
    starship init fish | source

    # eza aliases
    alias l='eza'
    alias la='eza -a'
    alias ll='eza -l'

    # no welcome message
    set fish_greeting ""

    # vi mode
    fish_vi_key_bindings

    # sing-box completion (auto-loaded from ~/.config/fish/completions/sing-box.fish)

end
