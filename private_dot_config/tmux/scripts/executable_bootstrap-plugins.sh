#!/usr/bin/env bash

set -euo pipefail

for command_name in git tmux; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'tmux plugin bootstrap: required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
done

tmux_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
plugin_dir="$tmux_dir/plugins"
tpm_dir="$plugin_dir/tpm"

mkdir -p "$plugin_dir"

if [[ -e "$tpm_dir" && ! -d "$tpm_dir/.git" ]]; then
  printf 'tmux plugin bootstrap: %s exists but is not a Git checkout\n' "$tpm_dir" >&2
  exit 1
fi

if [[ ! -d "$tpm_dir/.git" ]]; then
  git clone https://github.com/tmux-plugins/tpm.git "$tpm_dir"
fi

tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_dir/"
"$tpm_dir/bin/install_plugins"
