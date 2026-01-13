#!/bin/bash
set -euo pipefail

# ============================================================================
# Proxy Toggle Script - Enhanced Version 2.0.0
# ============================================================================
# Description: System-wide proxy configuration management tool
# Author: Enhanced by Claude Code
# Date: 2025-12-24
# ============================================================================

# Script information
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration file paths
readonly ENV_FILE="/etc/environment"
readonly APT_PROXY_FILE="/etc/apt/apt.conf.d/95proxies"
readonly PROFILE_SCRIPT="/etc/profile.d/proxy.sh"
readonly ZSHRC_FILE="/etc/zsh/zshrc"
# User-level files (resolved dynamically per invoking user)
readonly USER_PROXY_ENV_BASENAME=".proxy_env"
readonly USER_ZSHRC_BASENAME=".zshrc"
readonly USER_BASHRC_BASENAME=".bashrc"
readonly MANAGED_TAG="# Proxy settings (managed by proxy-toggle)"
readonly BACKUP_DIR="/var/backups/proxy-toggle"
readonly LOG_FILE="/var/log/proxy-toggle.log"

# Default proxy settings
readonly DEFAULT_IP="127.0.0.1"
readonly DEFAULT_PORT="7890"
readonly DEFAULT_NO_PROXY="10.10.0.0/24,localhost,127.0.0.1,localaddress,.localdomain.com"

# ============================================================================
# Logging Functions
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

    # Log to file only
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE" 2>/dev/null || true
}

log_info() {
    log "INFO" "$@"
}

log_error() {
    log "ERROR" "$@"
    # Output to stderr only once
    echo "ERROR: $*" >&2
}

log_warn() {
    log "WARN" "$@"
    echo "WARN: $*" >&2
}

# ============================================================================
# Input Validation Functions
# ============================================================================

# Sanitize input to prevent command injection
sanitize_input() {
    local input="$1"
    # Remove all special characters except alphanumeric, dots, commas, colons, hyphens, underscores, slashes, and asterisks
    echo "$input" | sed 's/[^a-zA-Z0-9._,:\/\*-]//g'
}

# Validate IP address
validate_ip() {
    local ip="$1"
    local IFS='.'
    local -a octets

    read -ra octets <<< "$ip"

    # Check if we have exactly 4 octets
    if [[ ${#octets[@]} -ne 4 ]]; then
        log_error "Invalid IP address format: $ip (must have 4 octets)"
        return 1
    fi

    # Validate each octet
    for octet in "${octets[@]}"; do
        # Check if octet is numeric
        if [[ ! "$octet" =~ ^[0-9]+$ ]]; then
            log_error "Invalid IP address: $ip (non-numeric octet: $octet)"
            return 1
        fi

        # Check if octet is in valid range (0-255)
        if ((octet < 0 || octet > 255)); then
            log_error "Invalid IP address: $ip (octet out of range: $octet)"
            return 1
        fi
    done

    return 0
}

# Validate port number
validate_port() {
    local port="$1"

    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        log_error "Invalid port number: $port (must be numeric)"
        return 1
    fi

    if ((port < 1 || port > 65535)); then
        log_error "Invalid port number: $port (must be between 1-65535)"
        return 1
    fi

    return 0
}

# ============================================================================
# Utility Functions
# ============================================================================

# Detect installed shells on the system
detect_shells() {
    local shells=()

    # Check for bash
    if [[ -f "/etc/bash.bashrc" ]]; then
        shells+=("bash")
    fi

    # Check for zsh
    if [[ -f "$ZSHRC_FILE" ]] || command -v zsh &>/dev/null; then
        shells+=("zsh")
    fi

    echo "${shells[@]}"
}

# Get shell config file path
get_shell_config_file() {
    local shell_type="$1"

    case "$shell_type" in
        bash)
            echo "/etc/bash.bashrc"
            ;;
        zsh)
            echo "$ZSHRC_FILE"
            ;;
        *)
            return 1
            ;;
    esac
}

# Get shell config comment marker
get_shell_comment() {
    local shell_type="$1"

    case "$shell_type" in
        bash)
            echo "# Source proxy settings for non-login shells"
            ;;
        zsh)
            echo "# Source proxy settings for zsh"
            ;;
        *)
            return 1
            ;;
    esac
}

# Generate proxy URL
get_proxy_url() {
    local ip="$1"
    local port="$2"
    # Do NOT add trailing slash: some apps (e.g., Claude) mis-handle it
    echo "http://${ip}:${port}"
}

# Generate environment variables configuration
generate_proxy_env_vars() {
    local proxy_url="$1"
    local no_proxy="$2"

    cat <<EOF
# Proxy Settings
http_proxy="${proxy_url}"
https_proxy="${proxy_url}"
ftp_proxy="${proxy_url}"
no_proxy="${no_proxy}"
HTTP_PROXY="${proxy_url}"
HTTPS_PROXY="${proxy_url}"
FTP_PROXY="${proxy_url}"
NO_PROXY="${no_proxy}"
ALL_PROXY="${proxy_url}"
all_proxy="${proxy_url}"
EOF
}

# ============================================================================
# Backup and Restore Functions
# ============================================================================

# Create backup directory if it doesn't exist
ensure_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR" || {
            log_error "Failed to create backup directory: $BACKUP_DIR"
            return 1
        }
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    return 0
}

# Backup configuration files
backup_configs() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    ensure_backup_dir || return 1

    log_info "Creating backup with timestamp: $timestamp"

    # Backup /etc/environment
    if [[ -f "$ENV_FILE" ]]; then
        cp "$ENV_FILE" "${BACKUP_DIR}/environment.backup.${timestamp}" || {
            log_error "Failed to backup $ENV_FILE"
            return 1
        }
        log_info "Backed up: $ENV_FILE"
    fi

    # Backup APT proxy config
    if [[ -f "$APT_PROXY_FILE" ]]; then
        cp "$APT_PROXY_FILE" "${BACKUP_DIR}/95proxies.backup.${timestamp}" || {
            log_error "Failed to backup $APT_PROXY_FILE"
            return 1
        }
        log_info "Backed up: $APT_PROXY_FILE"
    fi

    # Backup profile script
    if [[ -f "$PROFILE_SCRIPT" ]]; then
        cp "$PROFILE_SCRIPT" "${BACKUP_DIR}/proxy.sh.backup.${timestamp}" || {
            log_error "Failed to backup $PROFILE_SCRIPT"
            return 1
        }
        log_info "Backed up: $PROFILE_SCRIPT"
    fi

    # Backup shell config files
    local shells
    shells=($(detect_shells))
    for shell in "${shells[@]}"; do
        local config_file
        config_file=$(get_shell_config_file "$shell")
        if [[ -f "$config_file" ]]; then
            local backup_name
            backup_name=$(basename "$config_file")
            cp "$config_file" "${BACKUP_DIR}/${backup_name}.backup.${timestamp}" || {
                log_warn "Failed to backup $config_file"
            }
            log_info "Backed up: $config_file"
        fi
    done

    return 0
}

# Restore from most recent backup
restore_from_backup() {
    log_warn "Attempting to restore from backup..."

    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_error "Backup directory does not exist: $BACKUP_DIR"
        return 1
    fi

    # Find most recent backup
    local latest_env
    latest_env=$(find "$BACKUP_DIR" -name "environment.backup.*" -type f 2>/dev/null | sort -r | head -n 1)

    if [[ -n "$latest_env" ]]; then
        cp "$latest_env" "$ENV_FILE" || {
            log_error "Failed to restore $ENV_FILE"
            return 1
        }
        log_info "Restored: $ENV_FILE from $latest_env"
    fi

    return 0
}

# Clean up old backups (keep last 3 days or max 3 files)
cleanup_old_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi

    log_info "Cleaning up old backups..."

    # Delete backups older than 3 days
    find "$BACKUP_DIR" -name "*.backup.*" -type f -mtime +3 -delete 2>/dev/null || true

    # Keep only the 3 most recent backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -name "*.backup.*" -type f 2>/dev/null | wc -l)

    if ((backup_count > 3)); then
        find "$BACKUP_DIR" -name "*.backup.*" -type f -printf '%T@ %p\n' 2>/dev/null | \
            sort -n | head -n -3 | cut -d' ' -f2- | xargs -r rm -f
        log_info "Cleaned up old backups (kept 3 most recent)"
    fi

    return 0
}

# ============================================================================
# Proxy Application Functions
# ============================================================================

# Apply proxy settings to current session
apply_proxy_to_session() {
    local proxy_url="$1"
    local no_proxy="$2"

    export http_proxy="$proxy_url"
    export https_proxy="$proxy_url"
    export ftp_proxy="$proxy_url"
    export no_proxy="$no_proxy"
    export HTTP_PROXY="$proxy_url"
    export HTTPS_PROXY="$proxy_url"
    export FTP_PROXY="$proxy_url"
    export NO_PROXY="$no_proxy"
    export ALL_PROXY="$proxy_url"
    export all_proxy="$proxy_url"

    log_info "Applied proxy to current session"
}

# Remove proxy settings from current session
remove_proxy_from_session() {
    unset http_proxy https_proxy ftp_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY ALL_PROXY all_proxy

    log_info "Removed proxy from current session"
}

# ============================================================================
# Enable Proxy Function
# ============================================================================

enable_proxy() {
    local ip="${1:-$DEFAULT_IP}"
    local port="${2:-$DEFAULT_PORT}"
    local additional_no_proxy="$3"
    local no_proxy="$DEFAULT_NO_PROXY"

    log_info "Enabling proxy: ${ip}:${port}"

    # Sanitize additional_no_proxy input
    if [[ -n "$additional_no_proxy" ]]; then
        additional_no_proxy=$(sanitize_input "$additional_no_proxy")
        no_proxy="${DEFAULT_NO_PROXY},${additional_no_proxy}"
        log_info "Additional no_proxy: $additional_no_proxy"
    fi

    # Validate parameters
    if ! validate_ip "$ip"; then
        return 1
    fi

    if ! validate_port "$port"; then
        return 1
    fi

    # Create backup
    if ! backup_configs; then
        log_error "Backup failed, aborting"
        return 1
    fi

    # Generate proxy URL
    local proxy_url
    proxy_url=$(get_proxy_url "$ip" "$port")

    # Update /etc/environment with error handling
    if ! update_environment_file "$proxy_url" "$no_proxy"; then
        log_error "Failed to update environment file, rolling back"
        restore_from_backup
        return 1
    fi

    # Update APT configuration
    if ! update_apt_config "$proxy_url"; then
        log_error "Failed to update APT config, rolling back"
        restore_from_backup
        return 1
    fi

    # Update profile script
    if ! update_profile_script "$proxy_url" "$no_proxy"; then
        log_error "Failed to update profile script, rolling back"
        restore_from_backup
        return 1
    fi

    # Backup user rc then apply to current session
    backup_user_shell_configs || true
    # Apply to current session
    apply_proxy_to_session "$proxy_url" "$no_proxy"

    # Ensure user-level rc files source the profile for interactive shells
    update_user_shell_configs || true

    # Set systemd --user environment so GUI/new apps inherit
    set_systemd_user_proxy_env "$proxy_url" "$no_proxy" || true

    # Clean up old backups
    cleanup_old_backups

    log_info "Proxy enabled successfully"
    echo "Proxy configured successfully:"
    echo "  IP: ${ip}"
    echo "  Port: ${port}"
    echo "  No-proxy: ${no_proxy}"
    echo "✓ Applied to current session immediately"
    echo "ℹ New sessions will inherit these settings automatically"

    return 0
}

# Update /etc/environment file
update_environment_file() {
    local proxy_url="$1"
    local no_proxy="$2"
    local tmp_file

    tmp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }

    # Remove old proxy settings and add new ones
    {
        grep -vE '^(http[s]?_proxy|ftp_proxy|no_proxy|HTTP[S]?_PROXY|FTP_PROXY|NO_PROXY|ALL_PROXY|all_proxy)=' "$ENV_FILE" 2>/dev/null || true
        generate_proxy_env_vars "$proxy_url" "$no_proxy"
    } > "$tmp_file"

    # Atomic replace
    if ! mv "$tmp_file" "$ENV_FILE"; then
        rm -f "$tmp_file"
        return 1
    fi

    log_info "Updated: $ENV_FILE"
    return 0
}

# Update APT proxy configuration
update_apt_config() {
    local proxy_url="$1"

    cat > "$APT_PROXY_FILE" <<EOF
Acquire::http::proxy "${proxy_url}";
Acquire::https::proxy "${proxy_url}";
Acquire::ftp::proxy "ftp://${proxy_url#http://}";
EOF

    if [[ $? -ne 0 ]]; then
        log_error "Failed to write APT config"
        return 1
    fi

    log_info "Updated: $APT_PROXY_FILE"
    return 0
}

# Update shell config file to source proxy script (unified function)
update_shell_config() {
    local shell_type="$1"
    local config_file
    local source_line
    local source_cmd="[ -f \"$PROFILE_SCRIPT\" ] && . \"$PROFILE_SCRIPT\""

    config_file=$(get_shell_config_file "$shell_type")
    if [[ $? -ne 0 ]]; then
        log_warn "Unknown shell type: $shell_type"
        return 0
    fi

    # Ensure config file exists
    if [[ ! -f "$config_file" ]]; then
        if ! touch "$config_file" 2>/dev/null; then
            log_warn "$shell_type config file not found and cannot create: $config_file"
            return 0
        fi
        log_info "Created $config_file"
    fi

    source_line=$(get_shell_comment "$shell_type")

    # Check if already configured
    if grep -qF "$PROFILE_SCRIPT" "$config_file" 2>/dev/null; then
        log_info "$shell_type already configured for proxy script"
        return 0
    fi

    # Append source command
    {
        echo ""
        echo "$source_line"
        echo "$source_cmd"
    } >> "$config_file"

    if [[ $? -ne 0 ]]; then
        log_error "Failed to update $config_file"
        return 1
    fi

    log_info "Updated: $config_file to source proxy script"
    return 0
}

# Remove proxy script sourcing from shell config (unified function)
remove_shell_config() {
    local shell_type="$1"
    local config_file
    local source_line

    config_file=$(get_shell_config_file "$shell_type")
    if [[ $? -ne 0 ]] || [[ ! -f "$config_file" ]]; then
        return 0
    fi

    source_line=$(get_shell_comment "$shell_type")

    # Remove lines related to proxy script
    local tmp_file
    tmp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }

    grep -vF "$PROFILE_SCRIPT" "$config_file" | \
    grep -vF "$source_line" > "$tmp_file"

    if ! mv "$tmp_file" "$config_file"; then
        rm -f "$tmp_file"
        log_error "Failed to update $config_file"
        return 1
    fi

    log_info "Cleaned: $config_file"
    return 0
}

# Update all detected shells
update_all_shells() {
    local shells
    shells=($(detect_shells))

    if [[ ${#shells[@]} -eq 0 ]]; then
        log_warn "No supported shells detected"
        return 0
    fi

    log_info "Detected shells: ${shells[*]}"

    for shell in "${shells[@]}"; do
        update_shell_config "$shell" || log_warn "Failed to update $shell config"
    done

    return 0
}

# ============================================================================
# User-level RC update helpers (ensure new terminals inherit proxy)
# ============================================================================

get_target_user() {
    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        echo "$SUDO_USER"
    else
        # best-effort fallback
        local ln
        ln=$(logname 2>/dev/null || true)
        if [[ -n "$ln" && "$ln" != "root" ]]; then
            echo "$ln"
        fi
    fi
}

get_user_home() {
    local user="$1"
    getent passwd "$user" | awk -F: '{print $6}'
}

get_user_shell_name() {
    local user="$1"
    basename "$(getent passwd "$user" | awk -F: '{print $7}')"
}

update_user_rc_file() {
    local user="$1"
    local rc_file="$2"
    local created="0"
    local old_mode

    old_mode=$(stat -c %a "$rc_file" 2>/dev/null || echo 0644)

    if [[ ! -f "$rc_file" ]]; then
        if ! install -m 0644 /dev/null "$rc_file" 2>/dev/null; then
            log_warn "Cannot create user rc file: $rc_file"
            return 0
        fi
        created="1"
    fi

    # Idempotent: if already contains our tag or profile path, skip
    if grep -qF "$MANAGED_TAG" "$rc_file" 2>/dev/null || grep -qF "$PROFILE_SCRIPT" "$rc_file" 2>/dev/null; then
        [[ "$created" == "1" ]] && log_info "Created and already had proxy lines: $rc_file"
        return 0
    fi

    {
        echo ""
        echo "$MANAGED_TAG"
        echo "[ -f \"$PROFILE_SCRIPT\" ] && . \"$PROFILE_SCRIPT\""
    } >> "$rc_file"

    log_info "Updated user rc: $rc_file"

    # Ensure ownership and permissions (even if file existed)
    if [[ -n "$user" ]]; then
        chown "$user":"$user" "$rc_file" 2>/dev/null || true
        chmod "$old_mode" "$rc_file" 2>/dev/null || true
    fi
}

remove_user_rc_file() {
    local user="$1"
    local rc_file="$2"
    [[ -f "$rc_file" ]] || return 0

    local tmp
    tmp=$(mktemp) || return 1
    local old_mode
    old_mode=$(stat -c %a "$rc_file" 2>/dev/null || echo 0644)

    # Remove empty line before tag, managed tag line, and the following source line
    awk -v tag="$MANAGED_TAG" '
        skip{skip=0; next}
        index($0, tag){
            # Found tag line, check if previous line was empty
            if (prev_empty) {
                # Remove the empty line we stored
                lines_count--
            }
            skip=1
            next
        }
        {
            # Store current line
            lines[lines_count++] = $0
            # Track if current line is empty
            prev_empty = (length($0) == 0)
        }
        END {
            for (i=0; i<lines_count; i++) {
                print lines[i]
            }
        }
    ' "$rc_file" > "$tmp"
    if mv "$tmp" "$rc_file" 2>/dev/null; then
        # Restore ownership/permissions
        if [[ -n "$user" ]]; then
            chown "$user":"$user" "$rc_file" 2>/dev/null || true
            chmod "$old_mode" "$rc_file" 2>/dev/null || true
        fi
        log_info "Cleaned user rc: $rc_file"
    else
        rm -f "$tmp"
        log_warn "Failed cleaning user rc: $rc_file"
    fi
}

update_user_shell_configs() {
    local user
    user="$(get_target_user)"
    [[ -n "$user" ]] || return 0

    local home
    home="$(get_user_home "$user")"
    [[ -n "$home" && -d "$home" ]] || return 0

    local shell_name
    shell_name="$(get_user_shell_name "$user")"

    case "$shell_name" in
        zsh)
            update_user_rc_file "$user" "$home/$USER_ZSHRC_BASENAME"
            ;;
        bash|sh)
            update_user_rc_file "$user" "$home/$USER_BASHRC_BASENAME"
            ;;
        *)
            # default: try both common shells
            update_user_rc_file "$user" "$home/$USER_ZSHRC_BASENAME"
            update_user_rc_file "$user" "$home/$USER_BASHRC_BASENAME"
            ;;
    esac
}

remove_user_shell_configs() {
    local user
    user="$(get_target_user)"
    [[ -n "$user" ]] || return 0

    local home
    home="$(get_user_home "$user")"
    [[ -n "$home" && -d "$home" ]] || return 0

    remove_user_rc_file "$user" "$home/$USER_ZSHRC_BASENAME"
    remove_user_rc_file "$user" "$home/$USER_BASHRC_BASENAME"

}

# Backup user rc files before modifications
backup_user_shell_configs() {
    local user
    user="$(get_target_user)"
    [[ -n "$user" ]] || return 0

    local home
    home="$(get_user_home "$user")"
    [[ -n "$home" && -d "$home" ]] || return 0

    ensure_backup_dir || return 0
    local ts
    ts=$(date +%Y%m%d_%H%M%S)

    for f in "$home/$USER_ZSHRC_BASENAME" "$home/$USER_BASHRC_BASENAME"; do
        if [[ -f "$f" ]]; then
            cp -a "$f" "$BACKUP_DIR/$(basename "$f").${user}.backup.${ts}" 2>/dev/null && \
                log_info "Backed up user rc: $f" || true
        fi
    done
}

# ============================================================================
# Systemd user environment helpers (affects GUI apps and new processes)
# ============================================================================

set_systemd_user_proxy_env() {
    local proxy_url="$1"
    local no_proxy="$2"

    local user
    user="$(get_target_user)"
    [[ -n "$user" ]] || return 0

    if ! command -v systemctl >/dev/null 2>&1; then
        log_warn "systemctl not found; skipping user systemd env"
        return 0
    fi

    local cmd=("systemctl" "--user" "set-environment"
        "http_proxy=${proxy_url}" "https_proxy=${proxy_url}" "ftp_proxy=${proxy_url}" "no_proxy=${no_proxy}"
        "HTTP_PROXY=${proxy_url}" "HTTPS_PROXY=${proxy_url}" "FTP_PROXY=${proxy_url}" "NO_PROXY=${no_proxy}"
        "ALL_PROXY=${proxy_url}" "all_proxy=${proxy_url}")

    if su -s /bin/sh -c "${cmd[*]}" "$user" 2>/dev/null; then
        log_info "Set systemd user environment for $user"
    else
        log_warn "Failed to set systemd user environment for $user"
    fi
}

unset_systemd_user_proxy_env() {
    local user
    user="$(get_target_user)"
    [[ -n "$user" ]] || return 0

    if ! command -v systemctl >/dev/null 2>&1; then
        return 0
    fi

    local cmd=("systemctl" "--user" "unset-environment"
        http_proxy https_proxy ftp_proxy no_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY ALL_PROXY all_proxy)

    su -s /bin/sh -c "${cmd[*]}" "$user" 2>/dev/null && \
        log_info "Unset systemd user environment for $user" || true
}

# Remove proxy config from all detected shells
remove_all_shells() {
    local shells
    shells=($(detect_shells))

    for shell in "${shells[@]}"; do
        remove_shell_config "$shell" || log_warn "Failed to clean $shell config"
    done

    return 0
}

# Update profile script
update_profile_script() {
    local proxy_url="$1"
    local no_proxy="$2"

    cat > "$PROFILE_SCRIPT" <<EOF
# Proxy settings - auto-loaded for all shells
export http_proxy="${proxy_url}"
export https_proxy="${proxy_url}"
export ftp_proxy="${proxy_url}"
export no_proxy="${no_proxy}"
export HTTP_PROXY="${proxy_url}"
export HTTPS_PROXY="${proxy_url}"
export FTP_PROXY="${proxy_url}"
export NO_PROXY="${no_proxy}"
export ALL_PROXY="${proxy_url}"
export all_proxy="${proxy_url}"
EOF

    if [[ $? -ne 0 ]]; then
        log_error "Failed to write profile script"
        return 1
    fi

    log_info "Updated: $PROFILE_SCRIPT"

    # Update all detected shell configs
    update_all_shells

    return 0
}

# ============================================================================
# Disable Proxy Function
# ============================================================================

disable_proxy() {
    log_info "Disabling proxy"

    # Create backup
    backup_configs || log_warn "Backup failed, continuing anyway"

    # Backup user rc before cleaning
    backup_user_shell_configs || true

    # Clean /etc/environment
    if [[ -f "$ENV_FILE" ]]; then
        local tmp_file
        tmp_file=$(mktemp) || {
            log_error "Failed to create temporary file"
            return 1
        }

        grep -vE '^(# Proxy Settings|http[s]?_proxy|ftp_proxy|no_proxy|HTTP[S]?_PROXY|FTP_PROXY|NO_PROXY|ALL_PROXY|all_proxy)=' "$ENV_FILE" 2>/dev/null > "$tmp_file" || true

        if ! mv "$tmp_file" "$ENV_FILE"; then
            rm -f "$tmp_file"
            log_error "Failed to update $ENV_FILE"
            return 1
        fi

        log_info "Cleaned: $ENV_FILE"
    fi

    # Remove APT config
    if [[ -f "$APT_PROXY_FILE" ]]; then
        rm -f "$APT_PROXY_FILE" && log_info "Removed: $APT_PROXY_FILE"
    fi

    # Remove profile script
    if [[ -f "$PROFILE_SCRIPT" ]]; then
        rm -f "$PROFILE_SCRIPT" && log_info "Removed: $PROFILE_SCRIPT"
    fi

    # Remove shell configs for all detected shells
    remove_all_shells

    # Clean user-level rc files
    remove_user_shell_configs || true

    # Unset systemd --user environment
    unset_systemd_user_proxy_env || true

    # Remove from current session
    remove_proxy_from_session

    log_info "Proxy disabled successfully"
    echo "Proxy disabled successfully"
    echo "✓ Removed from current session immediately"
    echo "ℹ New sessions will not have proxy settings"

    return 0
}

# ============================================================================
# Status Query Function
# ============================================================================

show_status() {
    echo "代理状态："
    echo ""

    if [[ -f "$ENV_FILE" ]] && grep -q "^http_proxy=" "$ENV_FILE" 2>/dev/null; then
        echo "✓ 状态: 已启用"
        echo ""

        local proxy_url
        proxy_url=$(grep "^http_proxy=" "$ENV_FILE" | cut -d'"' -f2)
        echo "  代理地址: $proxy_url"

        local no_proxy_val
        no_proxy_val=$(grep "^no_proxy=" "$ENV_FILE" | cut -d'"' -f2)
        echo "  No-proxy: $no_proxy_val"
        echo ""

        # Check system configs
        echo "系统配置:"
        if [[ -f "$APT_PROXY_FILE" ]]; then
            echo "  ✓ APT 代理: 已配置"
        else
            echo "  ✗ APT 代理: 未配置"
        fi

        if [[ -f "$PROFILE_SCRIPT" ]]; then
            echo "  ✓ Profile 脚本: 已配置"
        else
            echo "  ✗ Profile 脚本: 未配置"
        fi
        echo ""

        # Check shell configs
        echo "Shell 配置:"
        local shells
        shells=($(detect_shells))
        for shell in "${shells[@]}"; do
            local config_file
            config_file=$(get_shell_config_file "$shell")
            if grep -qF "$PROFILE_SCRIPT" "$config_file" 2>/dev/null; then
                echo "  ✓ $shell: 已配置"
            else
                echo "  ✗ $shell: 未配置"
            fi
        done
    else
        echo "✗ 状态: 已禁用"
    fi

    return 0
}

# ============================================================================
# Test Proxy Function
# ============================================================================

test_proxy() {
    local ip="${1:-}"
    local port="${2:-}"
    local test_url="${3:-http://www.google.com}"

    # If no parameters, try to get from current config
    if [[ -z "$ip" || -z "$port" ]]; then
        if [[ -f "$ENV_FILE" ]] && grep -q "^http_proxy=" "$ENV_FILE" 2>/dev/null; then
            local proxy_url
            proxy_url=$(grep "^http_proxy=" "$ENV_FILE" | cut -d'"' -f2)
            # Extract IP and port from URL
            ip=$(echo "$proxy_url" | sed -n 's|http://\([^:]*\):.*|\1|p')
            port=$(echo "$proxy_url" | sed -n 's|http://[^:]*:\([0-9]*\)/\?|\1|p')
        else
            log_error "未配置代理且未提供参数"
            echo "错误: 未配置代理且未提供参数" >&2
            return 1
        fi
    fi

    echo "测试代理连接: ${ip}:${port}"
    echo "测试 URL: ${test_url}"

    if ! command -v curl &>/dev/null; then
        log_warn "curl 未安装，无法测试代理"
        echo "警告: curl 未安装，无法测试代理"
        return 2
    fi

    if curl -x "http://${ip}:${port}" -s --connect-timeout 5 \
       "${test_url}" >/dev/null 2>&1; then
        echo "✓ 代理连接成功"
        log_info "Proxy test successful: ${ip}:${port} -> ${test_url}"
        return 0
    else
        echo "✗ 代理连接失败"
        log_error "Proxy test failed: ${ip}:${port} -> ${test_url}"
        return 1
    fi
}

# ============================================================================
# Help Function
# ============================================================================

show_help() {
    cat <<EOF
用法:
  $SCRIPT_NAME on [--ip <ip>] [--port <port>] [--no-proxy <additional_no_proxy>]
  $SCRIPT_NAME off
  $SCRIPT_NAME status
  $SCRIPT_NAME test [<ip> <port>]
  $SCRIPT_NAME restore
  $SCRIPT_NAME --help | -h

传统用法（仍然支持）:
  $SCRIPT_NAME [<ip> <port> [<additional_no_proxy>]]        使用位置参数启用代理

命令:
  on          启用代理（默认: ${DEFAULT_IP}:${DEFAULT_PORT}）
  off         禁用代理
  status      显示当前代理状态
  test        测试代理连接性
  restore     从最近的备份恢复配置

选项:
  --ip <ip>                    代理 IP 地址（默认: ${DEFAULT_IP}）
  --port <port>               代理端口（默认: ${DEFAULT_PORT}）
  --no-proxy <domains>        额外的 no-proxy 域名/IP
  --help, -h                  显示此帮助信息

注意: additional_no_proxy 将追加到默认 no_proxy 列表:
      默认: ${DEFAULT_NO_PROXY}

示例:
  $SCRIPT_NAME on                                           使用默认代理设置
  $SCRIPT_NAME on --ip 192.168.1.1 --port 8080            使用自定义代理
  $SCRIPT_NAME on --ip 127.0.0.1 --port 7890 --no-proxy '*.example.com,10.0.0.0/8'
  $SCRIPT_NAME 127.0.0.1 7890 'excalidraw.local'          传统格式
  $SCRIPT_NAME off                                          禁用代理
  $SCRIPT_NAME status                                       查看代理状态
  $SCRIPT_NAME test                                         测试当前代理
  $SCRIPT_NAME restore                                      恢复备份

版本: $SCRIPT_VERSION
日志文件: $LOG_FILE
备份目录: $BACKUP_DIR
EOF
    exit 0
}

# ============================================================================
# Root Check
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "This script must be run as root"
        echo "Error: Run as root" >&2
        exit 1
    fi
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_args() {
    local command=""
    local ip=""
    local port=""
    local no_proxy=""

    # Handle help first
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
    fi

    # Handle empty arguments
    if [[ $# -eq 0 ]]; then
        log_error "No command or arguments specified"
        show_help
    fi

    # Check if first argument is a command
    case "$1" in
        on|off|status|test|restore)
            command="$1"
            shift
            ;;
        *)
            # Check if it's an IP address (legacy format)
            if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                command="on"
                ip="$1"
                port="$2"
                no_proxy="$3"
            else
                log_error "Unknown command: $1"
                show_help
            fi
            ;;
    esac

    # Parse command-specific arguments
    if [[ "$command" == "on" && -z "$ip" ]]; then
        # Parse keyword arguments for 'on' command
        while [[ $# -gt 0 ]]; do
            case $1 in
                --ip)
                    ip="$2"
                    shift 2
                    ;;
                --port)
                    port="$2"
                    shift 2
                    ;;
                --no-proxy)
                    no_proxy="$2"
                    shift 2
                    ;;
                --help|-h)
                    show_help
                    ;;
                *)
                    log_error "Unknown argument: $1"
                    show_help
                    ;;
            esac
        done
    elif [[ "$command" == "test" ]]; then
        # Test command can have optional IP, port, and URL
        ip="${1:-}"
        port="${2:-}"
        local test_url="${3:-}"
        shift 3 2>/dev/null || true
    fi

    # Execute command
    case "$command" in
        on)
            enable_proxy "$ip" "$port" "$no_proxy"
            ;;
        off)
            disable_proxy
            ;;
        status)
            show_status
            ;;
        test)
            test_proxy "$ip" "$port" "$test_url"
            ;;
        restore)
            restore_from_backup
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            ;;
    esac
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    # Show help without root check
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
    fi

    # Check if running as root for all other commands
    check_root

    # Parse and execute arguments
    parse_args "$@"
}

# Execute main function
main "$@"
