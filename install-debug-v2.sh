#!/usr/bin/env bash

# DEBUG VERSION 2 - Test full installation flow
# This version tracks what happens after pressing Enter

# Enable debugging
exec 2> >(tee -a "install-debug-v2.log" >&2)

echo "=== DEBUG V2 STARTED ===" | tee -a install-debug-v2.log
echo "Time: $(date)" | tee -a install-debug-v2.log
echo "PWD: $(pwd)" | tee -a install-debug-v2.log
echo "Running on: $(uname -a)" | tee -a install-debug-v2.log

set -e  # Exit on error

# Source the original install.sh to get all functions
source ./install.sh

# Override main() to add debug logging
main() {
    echo "[DEBUG V2] main() started" | tee -a install-debug-v2.log
    local total_steps=10
    local current_step=0

    # Show welcome screen
    if [ "$SHOW_TUI" = true ]; then
        echo "[DEBUG V2] Calling show_welcome" | tee -a install-debug-v2.log
        show_welcome
        echo "[DEBUG V2] After show_welcome" | tee -a install-debug-v2.log

        echo -n "Press Enter to continue or Ctrl+C to cancel..."
        echo "[DEBUG V2] Waiting for read..." | tee -a install-debug-v2.log
        read -r
        echo "[DEBUG V2] Read completed, user pressed Enter" | tee -a install-debug-v2.log
        echo ""
    fi

    echo "[DEBUG V2] Checking is_arch_linux" | tee -a install-debug-v2.log
    if is_arch_linux; then
        echo "[DEBUG V2] IS Arch Linux - will proceed with installation" | tee -a install-debug-v2.log
    else
        echo "[DEBUG V2] NOT Arch Linux - skipping package installation" | tee -a install-debug-v2.log
        echo "[DEBUG V2] /etc/arch-release exists: $([ -f /etc/arch-release ] && echo 'YES' || echo 'NO')" | tee -a install-debug-v2.log
    fi

    # Install packages unless explicitly skipped
    echo "[DEBUG V2] SKIP_PACKAGES=$SKIP_PACKAGES" | tee -a install-debug-v2.log

    if [ "$SKIP_PACKAGES" = false ]; then
        echo "[DEBUG V2] Package installation NOT skipped" | tee -a install-debug-v2.log

        if is_arch_linux; then
            echo "[DEBUG V2] Starting package installation steps" | tee -a install-debug-v2.log

            ((current_step++))
            print_step $current_step $total_steps "Checking repository configuration"
            echo "[DEBUG V2] About to call check_repositories" | tee -a install-debug-v2.log
            check_repositories || return 1
            echo "[DEBUG V2] check_repositories completed" | tee -a install-debug-v2.log

            ((current_step++))
            print_step $current_step $total_steps "Optimizing mirrorlist"
            echo "[DEBUG V2] About to call check_mirrorlist" | tee -a install-debug-v2.log
            check_mirrorlist
            echo "[DEBUG V2] check_mirrorlist completed" | tee -a install-debug-v2.log

            echo "[DEBUG V2] Package installation steps completed" | tee -a install-debug-v2.log
        else
            print_warning "Not running Arch Linux - skipping package installation"
            echo "[DEBUG V2] Arch check failed, skipped packages" | tee -a install-debug-v2.log
        fi
    else
        print_info "Skipping package installation (--skip-packages flag used)"
        echo "[DEBUG V2] Packages explicitly skipped via flag" | tee -a install-debug-v2.log
    fi

    echo "[DEBUG V2] Proceeding to symlink creation" | tee -a install-debug-v2.log

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    ((current_step++))
    print_step $current_step $total_steps "Creating configuration symlinks"

    # Install Hyprland configuration
    if [ -d "$DOTFILES_DIR/hyprland" ]; then
        echo "[DEBUG V2] Creating Hyprland symlink" | tee -a install-debug-v2.log
        create_symlink "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr" "Hyprland"
    else
        print_warning "Hyprland configuration directory not found, skipping"
    fi

    echo "[DEBUG V2] Installation complete!" | tee -a install-debug-v2.log
    echo ""
    echo "=== DEBUG V2 LOG SAVED TO: install-debug-v2.log ==="
}

# Run with debug
echo "[DEBUG V2] About to call main()" | tee -a install-debug-v2.log
main
echo "[DEBUG V2] main() returned" | tee -a install-debug-v2.log
