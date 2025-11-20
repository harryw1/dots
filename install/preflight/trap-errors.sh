#!/usr/bin/env bash
# trap-errors.sh - Error handling and recovery for installation
# Part of the modular dotfiles installation system
# Sets up error traps and provides recovery suggestions

# This script should be sourced early in the installation process

# Error trap function
catch_errors() {
    local exit_code=$?
    local line_number=$1
    local bash_command=$2

    echo ""
    print_error "Installation failed at line $line_number"
    print_error "Command: $bash_command"
    print_error "Exit code: $exit_code"
    echo ""

    # Save error state if state management is available
    if declare -f state_mark_phase_failed &>/dev/null; then
        local current_phase
        current_phase=$(state_get_current_phase)
        if [ -n "$current_phase" ]; then
            state_mark_phase_failed "$current_phase"
        fi
    fi

    # Show recovery options
    cat << EOF
${FRAPPE_YELLOW}Recovery options:${NC}
  1. Fix the issue and resume: ${FRAPPE_GREEN}./install.sh --resume${NC}
  2. View detailed logs: ${FRAPPE_BLUE}less $(logging_get_file 2>/dev/null || echo "\$HOME/.local/state/dots/logs/install-*.log")${NC}
  3. Reset and start fresh: ${FRAPPE_PEACH}./install.sh --reset${NC}
  4. Get help: ${FRAPPE_MAUVE}https://github.com/harryw1/dots/issues${NC}

EOF

    # Log the error
    if declare -f log_error &>/dev/null; then
        log_error "Installation failed at line $line_number: $bash_command (exit code: $exit_code)"
    fi

    exit $exit_code
}

# Set up error trap
# This will catch any command that exits with non-zero status
trap 'catch_errors ${LINENO} "$BASH_COMMAND"' ERR

# Also handle script interruption (Ctrl+C)
trap_interrupt() {
    echo ""
    print_warning "Installation interrupted by user"

    # Save state
    if declare -f state_get_current_phase &>/dev/null; then
        local current_phase
        current_phase=$(state_get_current_phase)
        if [ -n "$current_phase" ]; then
            print_info "Progress saved. Resume with: ./install.sh --resume"
        fi
    fi

    exit 130
}

trap trap_interrupt INT TERM

# Enable strict error handling
set -euo pipefail

# Optionally log all commands (useful for debugging)
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi
