#!/usr/bin/env bash
# mirrorlist.sh - Mirrorlist optimization and database sync
# Part of the modular dotfiles installation system
# Ensures fast mirrors and up-to-date package databases

# Check and optimize mirrorlist
check_mirrorlist() {
    print_step 3 6 "Optimizing package mirrors"

    print_info "Checking mirrorlist configuration..."
    log_info "Checking mirrorlist configuration"

    # Count active mirrors
    local mirror_count=$(grep -c "^Server" /etc/pacman.d/mirrorlist 2>/dev/null || echo "0")

    if [ "$mirror_count" -lt 3 ]; then
        print_warning "Only $mirror_count mirrors found in mirrorlist"
        log_warning "Only $mirror_count active mirrors found"
        print_info "Attempting to generate a fresh mirrorlist..."

        # Check if reflector is installed
        if ! command -v reflector &> /dev/null; then
            print_info "Installing reflector to generate mirrorlist..."
            log_info "Installing reflector"
            if ! sudo pacman -Sy --noconfirm reflector; then
                print_warning "Could not install reflector, using existing mirrorlist"
                log_warning "Failed to install reflector"
                return 0
            fi
        fi

        # Backup existing mirrorlist
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
        log_info "Backed up existing mirrorlist"

        # Generate new mirrorlist
        print_info "Generating optimized mirrorlist (this may take a minute)..."
        log_info "Running reflector to generate optimized mirrorlist"
        if sudo reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist; then
            print_success "Generated fresh mirrorlist with fast mirrors"
            log_success "Successfully generated optimized mirrorlist"
        else
            print_warning "Failed to generate mirrorlist, restoring backup"
            log_error "Reflector failed, restoring backup mirrorlist"
            sudo mv /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist
        fi
    else
        print_success "Mirrorlist has $mirror_count active mirrors"
        log_info "Mirrorlist check passed: $mirror_count active mirrors"
    fi

    echo ""
    return 0
}

# Sync package databases
sync_package_database() {
    print_step 4 6 "Syncing package databases"

    print_info "Syncing package databases to ensure latest versions..."
    log_info "Syncing package databases"

    # Force refresh all package databases
    if ! sudo pacman -Syy --noconfirm; then
        print_error "Failed to sync package database"
        log_error "Failed to sync package database"
        return 1
    fi

    print_success "Package database synced - will install latest versions"
    log_success "Package database synced successfully"
    echo ""
    return 0
}
