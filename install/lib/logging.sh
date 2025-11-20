#!/usr/bin/env bash
# logging.sh - Logging system for dotfiles installation
# Part of the modular dotfiles installation system
# Provides timestamped log files for debugging and troubleshooting

# Requires: Basic utilities (date, mkdir, cat, echo, grep, uname, hostname)

# Log directory and file
LOG_DIR="$HOME/.local/state/dots/logs"
LOG_FILE=""

#############################################################################
# LOGGING INITIALIZATION
#############################################################################

# Initialize the logging system
#
# Creates the log directory and a timestamped log file. The log file includes
# a header with system information (OS, kernel, architecture, hostname, etc.)
# to aid in troubleshooting.
#
# Log file naming: install-YYYYMMDD-HHMMSS.log
# Location: ~/.local/state/dots/logs/
#
# Sets the global LOG_FILE variable to the created log file path.
#
# Example:
#   logging_init
logging_init() {
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Create timestamped log file
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    LOG_FILE="$LOG_DIR/install-$timestamp.log"

    # Create log file with header
    cat > "$LOG_FILE" << EOF
================================================================================
Dotfiles Installation Log
Started: $(date)
================================================================================

EOF

    # Log system information
    {
        echo "System Information:"
        echo "  OS: $(uname -s)"
        echo "  Kernel: $(uname -r)"
        echo "  Architecture: $(uname -m)"
        echo "  Hostname: $(hostname 2>/dev/null || echo 'unknown')"
        if [ -f /etc/os-release ]; then
            echo "  Distribution: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
        fi
        echo ""
        echo "Environment:"
        echo "  HOME: ${HOME:-unknown}"
        echo "  USER: ${USER:-$(whoami 2>/dev/null || echo 'unknown')}"
        echo "  SHELL: ${SHELL:-unknown}"
        echo "  PWD: ${PWD:-unknown}"
        echo ""
        printf "================================================================================\n"
    } >> "$LOG_FILE"
}

#############################################################################
# LOGGING FUNCTIONS
#############################################################################

# Log a message with timestamp and level to the log file
#
# Arguments:
#   $1 - Log level (INFO, ERROR, WARNING, etc.)
#   $2 - Message to log
#
# Format: [YYYY-MM-DD HH:MM:SS] [LEVEL] message
#
# Example:
#   log_message "INFO" "Installation started"
#   log_message "ERROR" "Package installation failed"
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Log info message
log_info() {
    log_message "INFO" "$1"
}

# Log warning message
log_warning() {
    log_message "WARN" "$1"
}

# Log error message
log_error() {
    log_message "ERROR" "$1"
}

# Log success message
log_success() {
    log_message "SUCCESS" "$1"
}

# Log command execution
log_command() {
    local command="$1"
    log_message "CMD" "$command"
}

# Log phase start
log_phase_start() {
    local phase="$1"
    {
        echo ""
        echo "================================================================================"
        echo "PHASE START: $phase"
        echo "Time: $(date)"
        echo "================================================================================"
        echo ""
    } >> "$LOG_FILE"
}

# Log phase end
log_phase_end() {
    local phase="$1"
    local status="$2"  # "success" or "failed"
    {
        echo ""
        echo "================================================================================"
        echo "PHASE END: $phase - $status"
        echo "Time: $(date)"
        echo "================================================================================"
        echo ""
    } >> "$LOG_FILE"
}

# Log phase skip
log_phase_skip() {
    local phase="$1"
    local reason="${2:-Skipped}"
    {
        echo ""
        echo "================================================================================"
        echo "PHASE SKIPPED: $phase - $reason"
        echo "Time: $(date)"
        echo "================================================================================"
        echo ""
    } >> "$LOG_FILE"
}

# Setup log file output redirection
# This will tee all output to both console and log file
logging_setup_tee() {
    if [ -n "$LOG_FILE" ]; then
        # Backup original file descriptors
        exec 3>&1 4>&2

        # Redirect stdout and stderr to tee
        exec 1> >(tee -a "$LOG_FILE")
        exec 2> >(tee -a "$LOG_FILE" >&2)
    fi
}

# Get the current log file path
logging_get_file() {
    echo "$LOG_FILE"
}

# Print log file location to user
logging_print_location() {
    if [ -n "$LOG_FILE" ]; then
        print_info "Log file: $LOG_FILE"
    fi
}

# Clean old log files (keep last N logs)
logging_cleanup_old() {
    local keep_count=${1:-10}  # Default: keep last 10 logs

    if [ -d "$LOG_DIR" ]; then
        # Count log files
        local log_count
        log_count=$(find "$LOG_DIR" -name "install-*.log" | wc -l)

        if [ "$log_count" -gt "$keep_count" ]; then
            # Remove oldest logs, keep only $keep_count most recent
            # Using find to get files, sort by modification time, and delete
            find "$LOG_DIR" -name "install-*.log" -printf "%T@ %p\n" | \
                sort -nr | \
                tail -n "+$((keep_count + 1))" | \
                cut -d' ' -f2- | \
                xargs rm -f
            log_info "Cleaned up old log files (kept $keep_count most recent)"
        fi
    fi
}
