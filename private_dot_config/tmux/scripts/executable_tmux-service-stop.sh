#!/usr/bin/env bash

set -u

SAFE_SAVE_SCRIPT="/home/morain/.config/tmux/scripts/resurrect-safe-save.sh"

main() {
    local save_status=0

    if ! tmux list-sessions -F '#{session_name}' >/dev/null 2>&1; then
        exit 0
    fi

    "$SAFE_SAVE_SCRIPT" quiet || save_status=$?
    tmux kill-server
    exit "$save_status"
}

main "$@"
