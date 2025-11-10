#!/usr/bin/env bash
# logging.sh - Logging system for dotfiles installation
# Part of the modular dotfiles installation system
# Provides timestamped log files for debugging

# Log directory
LOG_DIR="$HOME/.local/state/dots/logs"
LOG_FILE=""

# Initialize logging system
logging_init() {
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Create timestamped log file
    local timestamp=$(date +%Y%m%d-%H%M%S)
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
        echo "  Hostname: $(hostname)"
        if [ -f /etc/os-release ]; then
            echo "  Distribution: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
        fi
        echo ""
        echo "Environment:"
        echo "  HOME: $HOME"
        echo "  USER: $USER"
        echo "  SHELL: $SHELL"
        echo "  PWD: $PWD"
        echo ""
        echo "================================================================================\n"
    } >> "$LOG_FILE"
}

# Log a message to the log file
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

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
        local log_count=$(ls -1 "$LOG_DIR"/install-*.log 2>/dev/null | wc -l)

        if [ "$log_count" -gt "$keep_count" ]; then
            # Remove oldest logs, keep only $keep_count most recent
            ls -1t "$LOG_DIR"/install-*.log | tail -n +$((keep_count + 1)) | xargs rm -f
            log_info "Cleaned up old log files (kept $keep_count most recent)"
        fi
    fi
}
