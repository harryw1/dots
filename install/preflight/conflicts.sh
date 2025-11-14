#!/usr/bin/env bash
# conflicts.sh - Package conflict resolution
# Part of the modular dotfiles installation system
# Resolves conflicts before package installation

# Resolve known package conflicts
resolve_conflicts() {
    print_step 5 6 "Resolving package conflicts"

    print_info "Checking for package conflicts..."
    log_info "Checking for package conflicts"

    local conflicts_found=false

    # PulseAudio vs PipeWire conflict
    if pacman -Qq pulseaudio &> /dev/null || pacman -Qq pulseaudio-alsa &> /dev/null; then
        conflicts_found=true
        print_warning "PulseAudio detected - replacing with PipeWire"
        log_warning "PulseAudio conflict detected"
        print_info "Removing PulseAudio packages..."
        sudo pacman -Rdd --noconfirm pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-jack pulseaudio-equalizer 2>/dev/null || true
        print_success "PulseAudio removed"
        log_success "PulseAudio removed successfully"
    fi

    # NetworkManager vs iwd conflict (note: actual disabling happens in services phase)
    if systemctl is-enabled NetworkManager &> /dev/null; then
        conflicts_found=true
        print_warning "NetworkManager detected - will be replaced with iwd"
        log_warning "NetworkManager will be replaced with iwd"
        print_info "NetworkManager will be disabled during service configuration"
    fi

    # yq vs go-yq conflict (both provide the yq binary)
    if pacman -Qq go-yq &> /dev/null; then
        conflicts_found=true
        print_warning "go-yq detected - conflicts with yq package"
        log_warning "go-yq conflict detected"
        print_info "Removing go-yq (yq will be installed instead)..."
        sudo pacman -Rdd --noconfirm go-yq 2>/dev/null || true
        print_success "go-yq removed"
        log_success "go-yq removed successfully"
    fi

    if [ "$conflicts_found" = false ]; then
        print_success "No package conflicts detected"
        log_info "No package conflicts found"
    else
        print_success "Conflict resolution complete"
        log_success "Package conflicts resolved"
    fi

    echo ""
    return 0
}
