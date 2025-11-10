#!/usr/bin/env bash
# install.sh - Modular Dotfiles Installation Orchestrator
# Part of the modular dotfiles installation system

# Exit on error (will be enhanced by trap-errors.sh)
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library modules (must be done in order)
source "$SCRIPT_DIR/install/lib/colors.sh"
source "$SCRIPT_DIR/install/lib/tui.sh"
source "$SCRIPT_DIR/install/lib/utils.sh"
source "$SCRIPT_DIR/install/lib/logging.sh"
source "$SCRIPT_DIR/install/lib/state.sh"

# Source preflight modules
source "$SCRIPT_DIR/install/preflight/trap-errors.sh"
source "$SCRIPT_DIR/install/preflight/check-system.sh"
source "$SCRIPT_DIR/install/preflight/repositories.sh"
source "$SCRIPT_DIR/install/preflight/mirrorlist.sh"
source "$SCRIPT_DIR/install/preflight/conflicts.sh"
source "$SCRIPT_DIR/install/preflight/migrations.sh"

# Source package modules
source "$SCRIPT_DIR/install/packages/utils.sh"
source "$SCRIPT_DIR/install/packages/core.sh"
source "$SCRIPT_DIR/install/packages/hypr-ecosystem.sh"
source "$SCRIPT_DIR/install/packages/theming.sh"
source "$SCRIPT_DIR/install/packages/development.sh"
source "$SCRIPT_DIR/install/packages/productivity.sh"
source "$SCRIPT_DIR/install/packages/aur.sh"

# Source config modules
source "$SCRIPT_DIR/install/config/hyprland.sh"
source "$SCRIPT_DIR/install/config/waybar.sh"
source "$SCRIPT_DIR/install/config/kitty.sh"
source "$SCRIPT_DIR/install/config/neovim.sh"
source "$SCRIPT_DIR/install/config/starship.sh"
source "$SCRIPT_DIR/install/config/bash.sh"
source "$SCRIPT_DIR/install/config/misc-configs.sh"

# Configuration variables (can be overridden by config file or flags)
FORCE=false
SKIP_PACKAGES=false
SHOW_TUI=true
DRY_RUN=false
RESUME=false
RESET=false
CONFIG_FILE=""

#############################################################################
# PACKAGE INSTALLATION (Modular)
#############################################################################
# Package installation functions have been moved to modular scripts:
#   - install/packages/utils.sh       - Shared utilities (install_package_file, install_yay, etc.)
#   - install/packages/core.sh        - Core packages (install_core_packages)
#   - install/packages/hypr-ecosystem.sh - Hypr tools (install_hypr_ecosystem_packages)
#   - install/packages/theming.sh     - Theming packages (install_theming_packages)
#   - install/packages/development.sh - Development tools (install_development_packages)
#   - install/packages/productivity.sh - Productivity apps (install_productivity_packages)
#   - install/packages/aur.sh         - AUR packages (install_aur_packages)
#
# These modules are sourced at the top of this script and provide individual
# package installation functions that are called by install_all_packages() below.
#############################################################################

#############################################################################
# POST-INSTALLATION UTILITIES
#############################################################################
# NOTE: LazyVim installation has been moved to install/config/neovim.sh
# and is now part of the configuration deployment phase.
#############################################################################

# Setup Catppuccin wallpaper collection
setup_wallpapers() {
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup wallpaper collection"
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
            return 1
        fi
        print_success "Wallpaper collection downloaded"
    else
        print_info "Wallpaper collection already exists"
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
    return 0
}

#############################################################################
# MAIN INSTALLATION FUNCTIONS
#############################################################################

# Run preflight checks
run_preflight() {
    log_phase_start "Preflight"

    run_system_checks
    check_repositories
    check_mirrorlist
    sync_package_database
    resolve_conflicts
    run_migrations

    log_phase_end "Preflight" "success"
    print_success "Preflight checks complete"
    echo ""
}

# Install all packages
install_all_packages() {
    log_phase_start "Package Installation"

    print_step 7 15 "Installing packages"

    # Call modular package installation functions
    install_core_packages
    install_hypr_ecosystem_packages
    install_theming_packages
    install_development_packages
    install_productivity_packages
    install_aur_packages

    log_phase_end "Package Installation" "success"
    print_success "Package installation complete"
    echo ""
}

# Deploy all configuration files
deploy_configurations() {
    log_phase_start "Configuration Deployment"

    print_step 8 15 "Deploying configuration files"

    # Call modular config deployment functions
    deploy_hyprland_config
    deploy_waybar_config
    deploy_kitty_config
    deploy_neovim_config
    deploy_starship_config
    deploy_bash_config
    deploy_misc_configs

    log_phase_end "Configuration Deployment" "success"
    print_success "Configuration deployment complete"
    echo ""
}

# Setup services
setup_services() {
    log_phase_start "Service Configuration"

    print_step 9 15 "Configuring system services"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would setup services"
        return 0
    fi

    # Set up Tailscale
    if command -v tailscale &> /dev/null; then
        print_info "Setting up Tailscale..."
        if sudo systemctl enable tailscaled 2>/dev/null; then
            print_success "Tailscale service enabled"
        fi

        # Install tsui if not present
        if ! command -v tsui &> /dev/null; then
            print_info "Installing tsui (Tailscale TUI)..."
            TSUI_URL="https://github.com/neuralinkcorp/tsui/releases/latest/download/tsui-linux-amd64"
            TSUI_TMP="/tmp/tsui-linux-amd64"

            if curl -sL "$TSUI_URL" -o "$TSUI_TMP" 2>/dev/null; then
                chmod +x "$TSUI_TMP"
                if sudo mv "$TSUI_TMP" /usr/local/bin/tsui 2>/dev/null; then
                    print_success "tsui installed"
                fi
            fi
        fi
    fi

    # Set up fingerprint authentication
    if command -v fprintd-enroll &> /dev/null; then
        print_info "Setting up fingerprint authentication..."

        # Backup and install PAM configs
        for pam_file in sudo system-local-login polkit-1; do
            if [ -f "/etc/pam.d/$pam_file" ]; then
                if [ ! -f "/etc/pam.d/${pam_file}.backup-pre-fprintd" ]; then
                    sudo cp "/etc/pam.d/$pam_file" "/etc/pam.d/${pam_file}.backup-pre-fprintd" 2>/dev/null
                fi
            fi
        done

        if [ -d "$DOTFILES_DIR/fprintd/pam-configs" ]; then
            for pam_file in sudo system-local-login polkit-1; do
                if [ -f "$DOTFILES_DIR/fprintd/pam-configs/$pam_file" ]; then
                    sudo cp "$DOTFILES_DIR/fprintd/pam-configs/$pam_file" "/etc/pam.d/$pam_file" 2>/dev/null && \
                        print_success "Installed fingerprint auth for $pam_file"
                fi
            done
        fi
    fi

    # Set up iwd
    if command -v iwctl &> /dev/null; then
        print_info "Setting up iwd network management..."

        # Disable NetworkManager if running
        if systemctl is-active --quiet NetworkManager 2>/dev/null; then
            print_info "Disabling NetworkManager in favor of iwd..."
            sudo systemctl disable --now NetworkManager 2>/dev/null && \
                print_success "NetworkManager disabled"
        fi

        # Enable iwd
        if sudo systemctl enable --now iwd 2>/dev/null; then
            print_success "iwd service enabled"
        fi
    fi

    log_phase_end "Service Configuration" "success"
    print_success "Service configuration complete"
    echo ""
}

# Post-installation tasks
post_install_tasks() {
    log_phase_start "Post-Installation"

    print_step 10 15 "Running post-installation tasks"

    # Setup wallpaper collection
    setup_wallpapers

    # NOTE: LazyVim setup is now handled during config deployment
    # (see install/config/neovim.sh - deploy_neovim_config)

    log_phase_end "Post-Installation" "success"
    print_success "Post-installation complete"
    echo ""
}

# Show final summary
show_final_summary() {
    echo ""
    echo ""
    local box_width=70
    draw_box "Installation Complete!" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} All packages installed" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Configurations symlinked to ~/.config/" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} LazyVim configured with Catppuccin Frappe" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Wallpaper collection downloaded" $box_width

    if [ -d "$BACKUP_DIR" ]; then
        draw_box_line "" $box_width
        draw_box_line "  ${FRAPPE_YELLOW}📦${NC} Backups: $BACKUP_DIR" $box_width
    fi

    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_PEACH}Next Steps:${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}1. Browse and select a wallpaper:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}waypaper${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}2. Reload your shell:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}source ~/.bashrc${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}3. Reload Hyprland:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}hyprctl reload${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""

    logging_print_location
}

# Check system before starting
check_system() {
    if ! command -v hyprctl &> /dev/null; then
        print_warning "hyprctl not found - Hyprland may not be installed"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
}

# Show help
show_help() {
    local box_width=80
    echo ""
    draw_box "Hyprland Dotfiles Installer - Help" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Usage:${NC}" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./install.sh${NC} ${FRAPPE_TEXT}[OPTIONS]${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Options:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-h, --help${NC}              Show this help message" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-f, --force${NC}             Skip confirmation prompts" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-packages${NC}         Skip package installation" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--no-tui${NC}                Disable TUI welcome screen" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--dry-run${NC}               Show what would be done without doing it" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--resume${NC}                Resume from last failed phase" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--reset${NC}                 Reset state and start fresh" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--config FILE${NC}           Use custom configuration file" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Package Categories:${NC}" $box_width
    draw_box_line "    ${FRAPPE_PEACH}core.txt${NC}                Required Hyprland packages" $box_width
    draw_box_line "    ${FRAPPE_PEACH}hypr-ecosystem.txt${NC}      Hypr tools" $box_width
    draw_box_line "    ${FRAPPE_PEACH}theming.txt${NC}             Fonts, icons, cursors" $box_width
    draw_box_line "    ${FRAPPE_PEACH}development.txt${NC}         Python, C++, Node.js, Neovim" $box_width
    draw_box_line "    ${FRAPPE_PEACH}productivity.txt${NC}        LibreOffice, PDF viewer" $box_width
    draw_box_line "    ${FRAPPE_PEACH}aur.txt${NC}                 AUR packages" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_YELLOW}⚠${NC}  Logs: ~/.local/state/dots/logs/" $box_width
    draw_box_line "  ${FRAPPE_YELLOW}⚠${NC}  State: ~/.local/state/dots/install-state.json" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""
}

#############################################################################
# ARGUMENT PARSING AND MAIN EXECUTION
#############################################################################

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        --no-tui)
            SHOW_TUI=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --resume)
            RESUME=true
            shift
            ;;
        --reset)
            RESET=true
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Load configuration file if specified
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Initialize state and logging
state_init
logging_init

# Handle reset
if [ "$RESET" = true ]; then
    state_reset
fi

# Show welcome screen
if [ "$SHOW_TUI" = true ] && [ "$RESUME" = false ]; then
    show_welcome
    echo -n "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    echo ""
fi

# Check if resume is requested
if [ "$RESUME" = true ]; then
    if ! state_can_resume; then
        print_error "No installation to resume"
        exit 1
    fi
    print_info "Resuming from last phase..."
    state_print_summary
    echo ""
fi

# Run system check unless forced
if [ "$FORCE" = false ]; then
    check_system
fi

# Main installation flow
print_info "Starting installation..."
echo ""

# Run preflight
run_preflight

# Install packages unless skipped
if [ "$SKIP_PACKAGES" = false ]; then
    if is_arch_linux; then
        install_all_packages
    else
        print_warning "Not running Arch Linux - skipping package installation"
    fi
else
    print_info "Skipping package installation (--skip-packages flag used)"
fi

# Deploy configurations
deploy_configurations

# Setup services
setup_services

# Post-installation
post_install_tasks

# Mark installation as complete
state_mark_complete

# Show final summary
show_final_summary
