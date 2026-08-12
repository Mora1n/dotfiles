# Enhanced apt completion configuration
# Fixes package name completion issues for commands like 'sudo apt remove'
#
# This file overrides/extends the system default apt completion (/usr/share/fish/completions/apt.fish)
# Primary goal: resolve the issue where 'sudo apt remove' cannot complete package names

# Define subcommands that require installed package completion
set -l installed_pkg_subcmds remove purge autoremove autopurge

# Define subcommands that require available package completion
set -l available_pkg_subcmds install reinstall upgrade full-upgrade show search changelog policy depends rdepends download build-dep

# Check if command is after sudo
function __apt_is_after_sudo
    set -l cmd (commandline -opc)
    contains sudo $cmd
end

# Get list of installed packages (with descriptions)
function __apt_installed_packages
    set -l search_term (commandline -ct)
    if test -z "$search_term"
        # Show limited results when no input to improve speed
        dpkg-query -W -f='${Package}\t${binary:Summary}\n' 2>/dev/null | head -n 200
    else
        # Filter results when there's input
        dpkg-query -W -f='${Package}\t${binary:Summary}\n' 2>/dev/null | string match -r -i ".*$search_term.*"
    end
end

# Get list of available packages
function __apt_available_packages
    set -l search_term (commandline -ct)
    # Use apt-cache pkgnames for fast package name lookup, much faster than parsing apt-cache show
    apt-cache --no-generate pkgnames "$search_term" 2>/dev/null | head -n 150
end

# === Completions for direct apt commands ===

# Provide installed package completion for remove/purge etc.
complete -c apt -n "__fish_seen_subcommand_from $installed_pkg_subcmds" -f -a '(__apt_installed_packages)'

# Provide available package completion for install etc.
complete -c apt -n "__fish_seen_subcommand_from $available_pkg_subcmds" -f -a '(__apt_available_packages)'

# === Completions for sudo apt commands ===

# Complete installed packages for sudo apt remove/purge
complete -c sudo -n "__fish_seen_subcommand_from apt; and __fish_seen_subcommand_from $installed_pkg_subcmds" -f -a '(__apt_installed_packages)'

# Complete available packages for sudo apt install etc.
complete -c sudo -n "__fish_seen_subcommand_from apt; and __fish_seen_subcommand_from $available_pkg_subcmds" -f -a '(__apt_available_packages)'

# === Completions for apt-get commands (many users still use apt-get) ===

# Complete installed packages for apt-get remove/purge
complete -c apt-get -n "__fish_seen_subcommand_from remove purge autoremove" -f -a '(__apt_installed_packages)'

# Complete available packages for apt-get install
complete -c apt-get -n "__fish_seen_subcommand_from install reinstall upgrade build-dep" -f -a '(__apt_available_packages)'

# Completions for sudo apt-get
complete -c sudo -n "__fish_seen_subcommand_from apt-get; and __fish_seen_subcommand_from remove purge autoremove" -f -a '(__apt_installed_packages)'
complete -c sudo -n "__fish_seen_subcommand_from apt-get; and __fish_seen_subcommand_from install reinstall upgrade build-dep" -f -a '(__apt_available_packages)'
