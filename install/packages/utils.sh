#!/usr/bin/env bash
# utils.sh - Shared package installation utilities
# Part of the modular dotfiles installation system

# Requires: tui.sh, logging.sh for output functions

# Install packages from a package list file
# Usage: install_package_file "path/to/packages.txt" "description"
install_package_file() {
    local package_file="$1"
    local description="$2"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install $description from $package_file"
        return 0
    fi

    if [ ! -f "$package_file" ]; then
        print_warning "Package file not found: $package_file"
        log_warning "Package file not found: $package_file"
        return 1
    fi

    print_info "Installing $description..."
    log_info "Installing $description from $package_file"

    # Count packages (excluding comments and empty lines)
    local package_count=$(grep -v '^#' "$package_file" | grep -v '^$' | wc -l)
    print_info "Found $package_count packages to install"

    # Install with pacman, using --ask=4 to auto-remove conflicting packages
    # Strip inline comments and trailing whitespace from package names
    if ! sudo pacman -S --needed --noconfirm --ask=4 - < <(grep -v '^#' "$package_file" | grep -v '^$' | sed 's/#.*//' | sed 's/[[:space:]]*$//'); then
        print_error "Failed to install some packages from $description"
        log_error "Failed to install packages from $description"
        return 1
    fi

    print_success "Installed $description"
    log_success "Installed $description"
    return 0
}

# Install yay AUR helper if not present
install_yay() {
    # Check if an AUR helper is already installed
    if command -v yay &> /dev/null || command -v paru &> /dev/null; then
        print_info "AUR helper already installed"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install yay AUR helper"
        return 0
    fi

    print_info "Installing yay AUR helper..."
    log_info "Installing yay AUR helper"

    # Check for required dependencies
    if ! command -v git &> /dev/null; then
        print_info "Installing base-devel and git (required for building yay)..."
        if ! sudo pacman -S --needed --noconfirm base-devel git; then
            print_error "Failed to install base-devel and git"
            log_error "Failed to install base-devel and git"
            return 1
        fi
    fi

    # Clone and build yay in /tmp
    local yay_build_dir="/tmp/yay-build-$$"
    mkdir -p "$yay_build_dir"

    print_info "Cloning yay repository..."
    if ! git clone https://aur.archlinux.org/yay.git "$yay_build_dir"; then
        print_error "Failed to clone yay repository"
        log_error "Failed to clone yay repository"
        rm -rf "$yay_build_dir"
        return 1
    fi

    print_info "Building and installing yay..."
    cd "$yay_build_dir"
    if ! makepkg -si --noconfirm; then
        print_error "Failed to build yay"
        log_error "Failed to build yay"
        cd - > /dev/null
        rm -rf "$yay_build_dir"
        return 1
    fi

    cd - > /dev/null
    rm -rf "$yay_build_dir"

    print_success "yay installed successfully"
    log_success "yay installed successfully"
    return 0
}

# Install packages from AUR using yay or paru
# Usage: install_aur_package_file "path/to/aur.txt" "description"
install_aur_package_file() {
    local package_file="$1"
    local description="${2:-AUR packages}"

    if [ ! -f "$package_file" ]; then
        print_info "No $description file found, skipping"
        return 0
    fi

    # Install yay if needed
    if ! install_yay; then
        print_warning "Could not install AUR helper"
        print_info "Install yay or paru manually, then run:"
        print_info "  yay -S --needed - < $package_file"
        return 0
    fi

    # Check for AUR helper
    local aur_helper=""
    if command -v yay &> /dev/null; then
        aur_helper="yay"
    elif command -v paru &> /dev/null; then
        aur_helper="paru"
    else
        print_warning "No AUR helper found (yay or paru)"
        print_info "Skipping $description. Install an AUR helper and run manually:"
        print_info "  yay -S --needed - < $package_file"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install $description using $aur_helper"
        return 0
    fi

    print_info "Installing $description using $aur_helper..."
    log_info "Installing $description using $aur_helper"
    local package_count=$(grep -v '^#' "$package_file" | grep -v '^$' | wc -l)
    print_info "Found $package_count AUR packages to install"

    # Strip inline comments and trailing whitespace from package names
    if ! $aur_helper -S --needed --noconfirm - < <(grep -v '^#' "$package_file" | grep -v '^$' | sed 's/#.*//' | sed 's/[[:space:]]*$//'); then
        print_warning "Failed to install some $description"
        log_warning "Failed to install some $description"
        return 1
    fi

    print_success "Installed $description"
    log_success "Installed $description"
    return 0
}

# Check if package installation should be skipped
should_skip_packages() {
    if [ "${SKIP_PACKAGES:-false}" = true ]; then
        print_info "Skipping package installation (--skip-packages flag)"
        return 0  # true, should skip
    fi
    return 1  # false, don't skip
}

# Verify package installation
verify_package_installed() {
    local package="$1"
    if pacman -Qi "$package" &> /dev/null; then
        return 0
    fi
    return 1
}
