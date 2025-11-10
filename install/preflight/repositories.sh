#!/usr/bin/env bash
# repositories.sh - Repository configuration verification
# Part of the modular dotfiles installation system
# Ensures pacman repositories are properly configured

# Check and configure pacman repositories
check_repositories() {
    print_step 2 6 "Verifying repository configuration"

    print_info "Checking repository configuration..."
    log_info "Checking pacman repository configuration"

    # Check if extra repository is enabled
    if ! grep -q "^\[extra\]" /etc/pacman.conf; then
        print_warning "'extra' repository not found in /etc/pacman.conf"
        log_warning "Extra repository not enabled"
        print_info "Attempting to enable 'extra' repository..."

        # Backup pacman.conf
        sudo cp /etc/pacman.conf /etc/pacman.conf.backup
        log_info "Backed up /etc/pacman.conf"

        # Check if it exists but is commented
        if grep -q "^#\[extra\]" /etc/pacman.conf; then
            print_info "Uncommenting 'extra' repository..."
            sudo sed -i '/^#\[extra\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
            log_info "Enabled extra repository"
        else
            print_warning "'extra' repository section not found in config"
            print_info "Please ensure your /etc/pacman.conf includes the 'extra' repository"
            log_error "Extra repository section not found in pacman.conf"
            return 1
        fi
    fi

    # Check if core repository is enabled
    if ! grep -q "^\[core\]" /etc/pacman.conf; then
        print_warning "'core' repository not properly configured"
        log_error "Core repository not enabled"
        return 1
    fi

    print_success "Repository configuration verified"
    log_info "Repository configuration check passed"
    echo ""
    return 0
}
