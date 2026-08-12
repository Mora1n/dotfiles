#!/usr/bin/env bash

set -u

PLUGIN_DIR="/home/morain/.config/tmux/plugins/tmux-resurrect/scripts"
CURRENT_DIR="$PLUGIN_DIR"

source "$CURRENT_DIR/variables.sh"
source "$CURRENT_DIR/helpers.sh"

show_output() {
    [ "${1:-}" != "quiet" ]
}

snapshot_valid() {
    local snapshot_path="$1"
    [ -n "$snapshot_path" ] &&
        [ -f "$snapshot_path" ] &&
        [ -s "$snapshot_path" ] &&
        grep -Eq '^(pane|window)	' "$snapshot_path"
}

display_tmux_message() {
    local message="$1"
    if [ -n "${TMUX:-}" ]; then
        tmux display-message "$message"
    else
        printf '%s\n' "$message" >&2
    fi
}

restore_last_symlink() {
    local last_file="$1"
    local previous_target="$2"

    if [ -n "$previous_target" ]; then
        ln -fs "$previous_target" "$last_file"
    else
        rm -f "$last_file"
    fi
}

main() {
    local script_output="${1:-}"
    local last_file previous_target="" previous_snapshot=""
    local save_status=0

    if ! tmux list-sessions -F '#{session_name}' >/dev/null 2>&1; then
        if show_output "$script_output"; then
            display_tmux_message "Tmux save skipped: no running server"
        fi
        exit 0
    fi

    last_file="$(last_resurrect_file)"
    if [ -L "$last_file" ]; then
        previous_target="$(readlink "$last_file")"
        previous_snapshot="$(readlink -f "$last_file" 2>/dev/null || true)"
    fi

    "$CURRENT_DIR/save.sh" "$@" || save_status=$?

    local current_snapshot=""
    current_snapshot="$(readlink -f "$last_file" 2>/dev/null || true)"
    if [ "$save_status" -eq 0 ] && snapshot_valid "$current_snapshot"; then
        exit 0
    fi

    if [ -n "$current_snapshot" ] &&
        [ -f "$current_snapshot" ] &&
        [ "$current_snapshot" != "$previous_snapshot" ]; then
        rm -f "$current_snapshot"
    fi

    if snapshot_valid "$previous_snapshot"; then
        restore_last_symlink "$last_file" "$previous_target"
    else
        restore_last_symlink "$last_file" ""
    fi

    if show_output "$script_output"; then
        display_tmux_message "Tmux save failed: invalid snapshot was discarded"
    fi
    if [ "$save_status" -ne 0 ]; then
        exit "$save_status"
    fi
    exit 1
}

main "$@"
