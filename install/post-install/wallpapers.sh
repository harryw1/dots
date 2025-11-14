#!/usr/bin/env bash
# wallpapers.sh - Catppuccin wallpaper collection setup
# Part of the modular dotfiles installation system
# Downloads and configures Catppuccin Frappe wallpaper collection with waypaper

# This script is sourced by install.sh, not executed directly
# Requires: lib/utils.sh, lib/tui.sh, lib/logging.sh, lib/state.sh

setup_wallpapers() {
    local phase_name="post-install/wallpapers"

    # Check if phase already completed
    if state_phase_completed "$phase_name"; then
        print_info "Wallpaper collection already setup"
        return 0
    fi

    log_phase_start "$phase_name"
    print_step 1 2 "Setting up wallpaper collection"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup wallpaper collection"
        log_phase_skip "$phase_name" "Dry run"
        return 0
    fi

    print_info "Setting up Catppuccin wallpaper collection..."
    log_info "Setting up wallpaper collection"

    local wallpaper_dir="$HOME/.local/share/catppuccin-wallpapers"

    # Clone wallpaper collection if not already present
    if [ ! -d "$wallpaper_dir" ]; then
        print_info "Downloading Catppuccin wallpaper collection..."
        if ! git clone https://github.com/42Willow/wallpapers "$wallpaper_dir"; then
            print_warning "Failed to clone wallpaper collection"
            log_warning "Failed to clone wallpaper collection"
            log_phase_end "$phase_name" "warning"
            # Still mark as complete so we don't retry endlessly
            state_mark_phase_complete "$phase_name"
            return 1
        fi
        print_success "Wallpaper collection downloaded"
        log_success "Wallpaper collection downloaded to $wallpaper_dir"
    else
        print_info "Wallpaper collection already exists"
        log_info "Wallpaper collection already exists at $wallpaper_dir"
    fi

    # Copy some default Frappe wallpapers to Hyprland config
    mkdir -p "$HOME/.config/hypr/wallpapers"
    if [ -d "$wallpaper_dir/frappe" ]; then
        # Copy up to 3 wallpapers as defaults
        local count=0
        shopt -s nullglob  # Don't expand if no matches
        for wallpaper in "$wallpaper_dir/frappe"/*.png "$wallpaper_dir/frappe"/*.jpg; do
            [ -f "$wallpaper" ] || continue
            cp "$wallpaper" "$HOME/.config/hypr/wallpapers/"
            ((count++))
            [ $count -ge 3 ] && break
        done
        shopt -u nullglob  # Restore default behavior
        print_success "Copied $count default wallpapers"
        log_success "Copied $count default wallpapers to ~/.config/hypr/wallpapers/"
    fi

    # Setup waypaper config
    print_info "Configuring waypaper..."
    mkdir -p "$HOME/.config/waypaper"
    cat > "$HOME/.config/waypaper/config.ini" << EOF
[Settings]
folder = $wallpaper_dir/frappe
wallpaper =
backend = hyprpaper
monitors = All
fill = fill
sort = name
color = #0F111A
subfolders = False
number_of_columns = 3
swww_transition_type = any
swww_transition_step = 90
swww_transition_angle = 0
swww_transition_duration = 2
EOF

    print_success "Wallpaper setup complete"
    log_success "Wallpaper setup complete"
    print_info "Browse wallpapers with: waypaper"

    # Mark phase complete
    state_mark_phase_complete "$phase_name"
    log_phase_end "$phase_name" "success"

    return 0
}

# Auto-execute if not in dry-run planning mode
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Being sourced, define function only
    :
else
    # Being executed directly (shouldn't happen, but handle gracefully)
    echo "This script should be sourced by install.sh, not executed directly"
    exit 1
fi
