#!/usr/bin/env sh

session="$(
    tmux list-sessions -F '#{session_name}' 2>/dev/null |
        awk '
            /^[0-9]+$/ { used[$1] = 1 }
            END {
                session = 0
                while (used[session]) {
                    session++
                }
                print session
            }
        '
)"

# Create a dedicated session for this terminal and keep it after detach.
exec tmux new-session -d -s "$session" \; attach-session -t "$session"
