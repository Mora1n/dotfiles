#!/bin/bash

# Root check
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: Run as root" >&2
  exit 1
fi

# Default proxy settings
DEFAULT_IP="127.0.0.1"
DEFAULT_PORT="7890"
DEFAULT_NO_PROXY="10.10.0.0/24,localhost,127.0.0.1,localaddress,.localdomain.com"

# Show usage help
show_help() {
  echo "Usage:"
  echo "  $0 on [--ip <ip>] [--port <port>] [--no-proxy <additional_no_proxy>]"
  echo "  $0 off"
  echo "  $0 --help | -h"
  echo ""
  echo "Legacy usage (still supported):"
  echo "  $0 [<ip> <port> [<additional_no_proxy>]]        Enable proxy with positional args"
  echo ""
  echo "Commands:"
  echo "  on      Enable proxy (default: ${DEFAULT_IP}:${DEFAULT_PORT})"
  echo "  off     Disable proxy"
  echo ""
  echo "Options:"
  echo "  --ip <ip>                    Proxy IP address (default: ${DEFAULT_IP})"
  echo "  --port <port>               Proxy port (default: ${DEFAULT_PORT})"
  echo "  --no-proxy <domains>        Additional no-proxy domains/IPs"
  echo "  --help, -h                  Show this help message"
  echo ""
  echo "Note: additional_no_proxy will be appended to default no_proxy list:"
  echo "      Default: ${DEFAULT_NO_PROXY}"
  echo ""
  echo "Examples:"
  echo "  $0 on                                           Use default proxy settings"
  echo "  $0 on --ip 192.168.1.1 --port 8080            Use custom proxy (keyword args)"
  echo "  $0 on --ip 127.0.0.1 --port 7890 --no-proxy '*.example.com,10.0.0.0/8'"
  echo "  $0 127.0.0.1 7890 'excalidraw.local'          Legacy format (no 'on' needed)"
  echo "  $0 192.168.1.1 8080                            Legacy format"
  echo "  $0 off                                          Disable proxy"
  exit 0
}

# Validate proxy parameters
validate_proxy_params() {
  local ip="$1"
  local port="$2"

  if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IP address format" >&2
    return 1
  fi

  if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "Error: Invalid port number (1-65535)" >&2
    return 1
  fi

  return 0
}

# Apply proxy settings immediately to current session
apply_proxy_immediately() {
  local IP="$1"
  local PORT="$2"
  local NO_PROXY="$3"

  # Set environment variables for current session
  export http_proxy="http://${IP}:${PORT}/"
  export https_proxy="http://${IP}:${PORT}/"
  export ftp_proxy="http://${IP}:${PORT}/"
  export no_proxy="${NO_PROXY}"
  export HTTP_PROXY="http://${IP}:${PORT}/"
  export HTTPS_PROXY="http://${IP}:${PORT}/"
  export FTP_PROXY="http://${IP}:${PORT}/"
  export NO_PROXY="${NO_PROXY}"
}

# Remove proxy settings immediately from current session
remove_proxy_immediately() {
  unset http_proxy https_proxy ftp_proxy no_proxy
  unset HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY
}

# Backup configuration files
backup_configs() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  [ -f /etc/environment ] && cp /etc/environment "/etc/environment.backup.$timestamp"
  [ -f /etc/apt/apt.conf.d/95proxies ] && cp /etc/apt/apt.conf.d/95proxies "/etc/apt/apt.conf.d/95proxies.backup.$timestamp"
}

# Enable proxy function
enable_proxy() {
  local IP="${1:-$DEFAULT_IP}"
  local PORT="${2:-$DEFAULT_PORT}"
  local ADDITIONAL_NO_PROXY="$3"
  local NO_PROXY="$DEFAULT_NO_PROXY"

  # Append additional no_proxy if provided
  if [ -n "$ADDITIONAL_NO_PROXY" ]; then
    NO_PROXY="${DEFAULT_NO_PROXY},${ADDITIONAL_NO_PROXY}"
  fi

  # Validate parameters
  if ! validate_proxy_params "$IP" "$PORT"; then
    exit 1
  fi

  # Create backup
  backup_configs

  # Update environment variables
  {
    grep -vE '^(http[s]?_proxy|ftp_proxy|no_proxy|HTTP[S]?_PROXY|FTP_PROXY|NO_PROXY)=' /etc/environment 2>/dev/null || true
    echo "# Proxy Settings"
    echo "http_proxy=\"http://${IP}:${PORT}/\""
    echo "https_proxy=\"http://${IP}:${PORT}/\""
    echo "ftp_proxy=\"http://${IP}:${PORT}/\""
    echo "no_proxy=\"${NO_PROXY}\""
    echo "HTTP_PROXY=\"http://${IP}:${PORT}/\""
    echo "HTTPS_PROXY=\"http://${IP}:${PORT}/\""
    echo "FTP_PROXY=\"http://${IP}:${PORT}/\""
    echo "NO_PROXY=\"${NO_PROXY}\""
  } > /etc/environment.tmp && mv /etc/environment.tmp /etc/environment

  # Configure APT proxy
  cat << EOF > /etc/apt/apt.conf.d/95proxies
Acquire::http::proxy "http://${IP}:${PORT}/";
Acquire::https::proxy "http://${IP}:${PORT}/";
Acquire::ftp::proxy "ftp://${IP}:${PORT}/";
EOF

  # Create profile script
  cat << EOF > /etc/profile.d/proxy.sh
export http_proxy="http://${IP}:${PORT}/"
export https_proxy="http://${IP}:${PORT}/"
export ftp_proxy="http://${IP}:${PORT}/"
export no_proxy="${NO_PROXY}"
EOF

  echo "Proxy configured successfully:"
  echo "  IP: ${IP}"
  echo "  Port: ${PORT}"
  echo "  No-proxy: ${NO_PROXY}"
  if [ -n "$ADDITIONAL_NO_PROXY" ]; then
    echo "  Additional no-proxy: ${ADDITIONAL_NO_PROXY}"
  fi

  # Apply settings immediately to current session
  apply_proxy_immediately "$IP" "$PORT" "$NO_PROXY"

  echo "✓ Applied to current session immediately"
  echo "ℹ New sessions will inherit these settings automatically"
}

# Disable proxy function
disable_proxy() {
  # Create backup
  backup_configs

  # Clean environment file
  if [ -f /etc/environment ]; then
    sed -i '/^# Proxy Settings/,/^NO_PROXY=/d' /etc/environment 2>/dev/null
  fi

  # Remove config files
  rm -f /etc/apt/apt.conf.d/95proxies 2>/dev/null
  rm -f /etc/profile.d/proxy.sh 2>/dev/null

  # Remove settings immediately from current session
  remove_proxy_immediately

  echo "Proxy disabled successfully"
  echo "✓ Removed from current session immediately"
  echo "ℹ New sessions will not have proxy settings"
}

# Parse command line arguments
parse_args() {
  local command=""
  local ip=""
  local port=""
  local no_proxy=""

  # Handle help first
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
  fi

  # Check if first argument is a command or IP address (for legacy support)
  if [[ "$1" == "on" || "$1" == "off" ]]; then
    # New format with explicit command
    command="$1"
    shift

    # Check if next arguments are keyword args or positional args
    if [[ "$1" =~ ^-- ]] || [[ $# -eq 0 ]]; then
      # Keyword arguments or no additional args
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
            echo "Error: Unknown argument '$1'" >&2
            show_help
            ;;
        esac
      done
    else
      # Positional arguments after 'on' command
      ip="$1"
      port="$2"
      no_proxy="$3"
    fi
  elif [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    # Legacy format: IP address as first argument means "on" command
    command="on"
    ip="$1"
    port="$2"
    no_proxy="$3"
  elif [[ -z "$1" ]]; then
    echo "Error: No command or arguments specified" >&2
    show_help
  else
    echo "Error: Unknown command '$1'" >&2
    show_help
  fi

  # Execute command
  case "$command" in
    on)
      enable_proxy "$ip" "$port" "$no_proxy"
      ;;
    off)
      disable_proxy
      ;;
    *)
      echo "Error: Unknown command '$command'" >&2
      show_help
      ;;
  esac
}

# Main command handler
parse_args "$@"
