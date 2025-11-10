#!/usr/bin/env bash
# check-system.sh - System verification for installation
# Part of the modular dotfiles installation system
# Verifies Arch Linux and checks required dependencies

# Run preflight system checks
run_system_checks() {
    print_step 1 6 "Checking system requirements"

    # Check if running Arch Linux
    if ! is_arch_linux; then
        print_error "This installer is designed for Arch Linux only"
        print_info "Detected OS: $(uname -s)"
        if [ -f /etc/os-release ]; then
            print_info "Distribution: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
        fi
        log_error "System check failed: Not running Arch Linux"
        exit 1
    fi

    print_success "Running on Arch Linux"
    log_info "System check passed: Arch Linux detected"

    # Check for required base commands
    local required_commands=("git" "curl" "sudo" "pacman")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        print_error "Missing required commands: ${missing_commands[*]}"
        print_info "Install with: sudo pacman -S ${missing_commands[*]}"
        log_error "System check failed: Missing commands: ${missing_commands[*]}"
        exit 1
    fi

    print_success "All required commands found"
    log_info "System check passed: All required commands available"

    # Check for jq (needed for state management)
    if ! command -v jq &>/dev/null; then
        print_warning "jq not found - installing for state management"
        log_info "Installing jq for state management"
        sudo pacman -S --noconfirm jq
        print_success "Installed jq"
    else
        print_success "jq is available"
    fi

    # Check for internet connectivity
    print_info "Checking internet connectivity..."
    if ! ping -c 1 archlinux.org &>/dev/null && ! ping -c 1 8.8.8.8 &>/dev/null; then
        print_warning "No internet connectivity detected"
        print_info "Internet is required for package installation"
        log_warning "System check: No internet connectivity"

        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Internet connectivity confirmed"
        log_info "System check passed: Internet connectivity available"
    fi

    echo ""
}
