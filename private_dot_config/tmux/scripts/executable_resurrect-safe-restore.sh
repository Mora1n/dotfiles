#!/usr/bin/env bash

set -u

PLUGIN_DIR="/home/morain/.config/tmux/plugins/tmux-resurrect/scripts"
CURRENT_DIR="$PLUGIN_DIR"

source "$CURRENT_DIR/variables.sh"
source "$CURRENT_DIR/helpers.sh"

snapshot_valid() {
    local snapshot_path="$1"
    [ -n "$snapshot_path" ] &&
        [ -f "$snapshot_path" ] &&
        [ -s "$snapshot_path" ] &&
        grep -Eq '^(pane|window)	' "$snapshot_path"
}

latest_valid_snapshot() {
    local snapshot_path

    local sorted_snapshots=()
    while IFS= read -r snapshot_path; do
        sorted_snapshots+=("$snapshot_path")
    done < <(ls -t "$(resurrect_dir)"/${RESURRECT_FILE_PREFIX}_*.${RESURRECT_FILE_EXTENSION} 2>/dev/null)

    for snapshot_path in "${sorted_snapshots[@]}"; do
        if snapshot_valid "$snapshot_path"; then
            printf '%s\n' "$snapshot_path"
            return 0
        fi
    done

    return 1
}

display_tmux_message() {
    local message="$1"
    if [ -n "${TMUX:-}" ]; then
        tmux display-message "$message"
    else
        printf '%s\n' "$message" >&2
    fi
}

main() {
    local last_file current_snapshot latest_snapshot hint=""

    last_file="$(last_resurrect_file)"
    current_snapshot="$(readlink -f "$last_file" 2>/dev/null || true)"
    if snapshot_valid "$current_snapshot"; then
        exec "$CURRENT_DIR/restore.sh"
    fi

    latest_snapshot="$(latest_valid_snapshot 2>/dev/null || true)"
    if [ -n "$latest_snapshot" ]; then
        hint="; latest valid snapshot: $(basename "$latest_snapshot")"
    fi

    display_tmux_message "Tmux restore skipped: last snapshot is empty or invalid${hint}"
    exit 1
}

main "$@"
