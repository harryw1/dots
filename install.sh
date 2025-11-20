#!/usr/bin/env bash
# install.sh - Modular Dotfiles Installation Orchestrator
# Part of the modular dotfiles installation system

# Exit on error (will be enhanced by trap-errors.sh)
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library modules (must be done in order)
source "$SCRIPT_DIR/install/lib/colors.sh"
source "$SCRIPT_DIR/install/lib/gum_theme.sh"
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
source "$SCRIPT_DIR/install/packages/theming.sh"
source "$SCRIPT_DIR/install/packages/development.sh"
source "$SCRIPT_DIR/install/packages/tui.sh"
source "$SCRIPT_DIR/install/packages/gui-essential.sh"
source "$SCRIPT_DIR/install/packages/gui-browsers.sh"
source "$SCRIPT_DIR/install/packages/gui-productivity.sh"
source "$SCRIPT_DIR/install/packages/gui-communication.sh"
source "$SCRIPT_DIR/install/packages/aur.sh"

# Source config modules
source "$SCRIPT_DIR/install/config/hyprland.sh"
source "$SCRIPT_DIR/install/config/waybar.sh"
source "$SCRIPT_DIR/install/config/kitty.sh"
source "$SCRIPT_DIR/install/config/neovim.sh"
source "$SCRIPT_DIR/install/config/starship.sh"
source "$SCRIPT_DIR/install/config/bash.sh"
source "$SCRIPT_DIR/install/config/zsh.sh"
source "$SCRIPT_DIR/install/config/misc-configs.sh"

# Source service modules
source "$SCRIPT_DIR/install/services/network.sh"
source "$SCRIPT_DIR/install/services/fingerprint.sh"
source "$SCRIPT_DIR/install/services/tailscale.sh"

# Source post-install modules
source "$SCRIPT_DIR/install/post-install/wallpapers.sh"
source "$SCRIPT_DIR/install/post-install/finalize.sh"

# Configuration variables (can be overridden by config file or flags)
FORCE=false
SKIP_PACKAGES=false
SHOW_TUI=true
DRY_RUN=false
RESUME=false
RESET=false
CONFIG_FILE=""

# GUI installation mode variables
INSTALL_MODE="tui-only"  # Default: TUI-only (headless compatible)
# Modes: tui-only, minimal-gui, full
INSTALL_GUI_ESSENTIAL=false
INSTALL_GUI_BROWSERS=false
INSTALL_GUI_PRODUCTIVITY=false
INSTALL_GUI_COMMUNICATION=false

# Auto-detect non-interactive context (e.g., curl | bash)
# If stdin is not a terminal, disable interactive features
if [ ! -t 0 ]; then
    SHOW_TUI=false
    FORCE=true
    print_info "Non-interactive context detected (stdin not a tty)"
    print_info "Automatically enabling: --no-tui --force"
fi

#############################################################################
# PACKAGE INSTALLATION (Modular)
#############################################################################
# Package installation functions have been moved to modular scripts:
#   - install/packages/utils.sh            - Shared utilities (install_package_file, install_yay, etc.)
#   - install/packages/core.sh             - Core packages (install_core_packages) - TUI/headless compatible
#   - install/packages/theming.sh          - Theming packages (install_theming_packages)
#   - install/packages/development.sh      - Development tools (install_development_packages)
#   - install/packages/tui.sh              - TUI applications (install_tui_packages)
#   - install/packages/gui-essential.sh    - Essential GUI (install_gui_essential_packages)
#   - install/packages/gui-browsers.sh     - Web browsers (install_gui_browsers_packages)
#   - install/packages/gui-productivity.sh - Productivity apps (install_gui_productivity_packages)
#   - install/packages/gui-communication.sh - Communication apps (install_gui_communication_packages)
#   - install/packages/aur.sh              - AUR packages (install_aur_packages)
#
# These modules are sourced at the top of this script and provide individual
# package installation functions that are called by install_all_packages() below.
#############################################################################

#############################################################################
# UTILITIES (Modular)
#############################################################################
# Service and post-installation functions have been moved to modular scripts:
#   - install/services/network.sh      - iwd network management
#   - install/services/fingerprint.sh  - fprintd authentication
#   - install/services/tailscale.sh    - Tailscale VPN service
#   - install/post-install/wallpapers.sh - Catppuccin wallpaper collection
#   - install/post-install/finalize.sh  - Final checks and summary
#
# NOTE: LazyVim installation has been moved to install/config/neovim.sh
# and is now part of the configuration deployment phase.
#############################################################################

#############################################################################
# GUI SELECTION PROMPTS
#############################################################################

# Prompt user for GUI component selection (interactive mode only)
prompt_gui_selection() {
    # Skip if in force/non-interactive mode
    if [ "$FORCE" = true ]; then
        return 0
    fi

    echo ""
    print_step 1 2 "GUI Component Selection"
    echo ""

    print_info "This installer defaults to a TUI-only system (headless compatible)."
    print_info "GUI components (Hyprland, Waybar, etc.) are optional."
    echo ""

    # Use gum choose for selection
    local CHOICES
    CHOICES=$(gum choose --no-limit --header "Select Components to Install" "Hyprland GUI (Waybar, etc)" "Web Browser (Firefox)" "Productivity Suite (LibreOffice)" "Communication Apps (Discord, Slack)")

    if [[ "$CHOICES" == *"Hyprland GUI"* ]]; then
        INSTALL_GUI_ESSENTIAL=true
        INSTALL_MODE="minimal-gui"
        print_success "Selected: Essential GUI components"
    fi

    if [[ "$CHOICES" == *"Web Browser"* ]]; then
        INSTALL_GUI_BROWSERS=true
        print_success "Selected: Web Browser"
    fi

    if [[ "$CHOICES" == *"Productivity Suite"* ]]; then
        INSTALL_GUI_PRODUCTIVITY=true
        print_success "Selected: Productivity Suite"
    fi

    if [[ "$CHOICES" == *"Communication Apps"* ]]; then
        INSTALL_GUI_COMMUNICATION=true
        print_success "Selected: Communication Apps"
    fi

    if [ "$INSTALL_GUI_ESSENTIAL" = false ] && [ "$INSTALL_GUI_BROWSERS" = false ] && [ "$INSTALL_GUI_PRODUCTIVITY" = false ] && [ "$INSTALL_GUI_COMMUNICATION" = false ]; then
        INSTALL_MODE="tui-only"
        print_info "No GUI components selected (TUI-only mode)"
    fi
    echo ""
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

    # Install core packages (always - TUI tools, audio, network)
    install_core_packages

    # Install theming packages (needed for consistent appearance)
    install_theming_packages

    # Install development tools (always - Neovim, compilers, etc.)
    install_development_packages

    # Install TUI applications (always - yazi, lazygit, btop, etc.)
    install_tui_packages

    # Install GUI packages conditionally
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        install_gui_essential_packages
        install_gui_essential_aur_packages
    fi

    if [ "$INSTALL_GUI_BROWSERS" = true ]; then
        install_gui_browsers_packages
    fi

    if [ "$INSTALL_GUI_PRODUCTIVITY" = true ]; then
        install_gui_productivity_packages
    fi

    if [ "$INSTALL_GUI_COMMUNICATION" = true ]; then
        install_gui_communication_packages
    fi

    # Install base AUR packages (always - themes, TUI tools)
    install_aur_packages

    log_phase_end "Package Installation" "success"
    print_success "Package installation complete"
    echo ""
}

# Deploy all configuration files
deploy_configurations() {
    log_phase_start "Configuration Deployment"

    print_step 8 15 "Deploying configuration files"

    # Always deploy TUI-safe configs (including Kitty - it's a terminal, not a GUI app)
    deploy_neovim_config
    deploy_starship_config
    deploy_bash_config
    deploy_zsh_config  # Zsh configuration with menu selection
    deploy_kitty_config  # Kitty is a terminal emulator, works in TUI mode
    deploy_misc_configs  # Handles TUI/GUI split internally

    # Deploy GUI configs only if GUI mode enabled
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        deploy_hyprland_config
        deploy_waybar_config
        log_phase_end "Configuration Deployment" "success"
        print_success "Configuration deployment complete (TUI + GUI)"
    else
        log_phase_end "Configuration Deployment" "success"
        print_success "Configuration deployment complete (TUI-only)"
    fi

    echo ""
}

# Setup services
setup_services() {
    log_phase_start "Service Configuration"

    print_step 9 15 "Configuring system services"

    # Call modular service setup functions
    setup_network_service
    setup_fingerprint_service
    setup_tailscale_service

    log_phase_end "Service Configuration" "success"
    print_success "Service configuration complete"
    echo ""
}

# Post-installation tasks
post_install_tasks() {
    log_phase_start "Post-Installation"

    print_step 10 15 "Running post-installation tasks"

    # Call modular post-install functions
    setup_wallpapers
    finalize_installation

    # NOTE: LazyVim setup is now handled during config deployment
    # (see install/config/neovim.sh - deploy_neovim_config)

    log_phase_end "Post-Installation" "success"
    print_success "Post-installation complete"
    echo ""
}

# Show final summary
show_gui_next_steps() {
    local box_width=70
    # GUI-specific next steps
    draw_box_line "  ${FRAPPE_TEXT}1. Browse and select a wallpaper:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}waypaper${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}2. Reload your shell:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}source ~/.bashrc${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}3. Reload Hyprland:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}hyprctl reload${NC}" $box_width
    draw_box_line "" $box_width
}

show_tui_next_steps() {
    local box_width=70
    # TUI-specific next steps
    draw_box_line "  ${FRAPPE_TEXT}1. Reload your shell to apply changes:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}source ~/.bashrc${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}2. Explore TUI applications:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}yazi${NC}       - File manager" $box_width
    draw_box_line "     ${FRAPPE_BLUE}lazygit${NC}    - Git interface" $box_width
    draw_box_line "     ${FRAPPE_BLUE}btop${NC}       - System monitor" $box_width
    draw_box_line "     ${FRAPPE_BLUE}nvim${NC}       - Text editor" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}3. Connect to WiFi:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}impala${NC}     - WiFi manager TUI" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}4. To add GUI later, run:${NC}" $box_width
    draw_box_line "     ${FRAPPE_BLUE}./install.sh --full${NC}" $box_width
    draw_box_line "" $box_width
}

show_final_summary() {
    echo ""
    echo ""
    local box_width=70
    draw_box "Installation Complete!" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} All packages installed" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Configurations symlinked to ~/.config/" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} LazyVim configured with Catppuccin Frappe" $box_width

    # Only mention wallpapers if GUI installed
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        draw_box_line "  ${FRAPPE_GREEN}✓${NC} Wallpaper collection downloaded" $box_width
    fi

    if [ -d "$BACKUP_DIR" ]; then
        draw_box_line "" $box_width
        draw_box_line "  ${FRAPPE_YELLOW}📦${NC} Backups: $BACKUP_DIR" $box_width
    fi

    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_PEACH}Next Steps:${NC}" $box_width
    draw_box_line "" $box_width

    # Show appropriate next steps based on installation mode
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        show_gui_next_steps
    else
        show_tui_next_steps
    fi

    draw_box_bottom $box_width
    echo ""

    logging_print_location
}

# Check system before starting
check_system() {
    # Only check for Hyprland if GUI mode is enabled
    if [ "$INSTALL_GUI_ESSENTIAL" = true ]; then
        if ! command -v hyprctl &> /dev/null; then
            print_warning "hyprctl not found - Hyprland may not be installed"
            if [ "$FORCE" = true ]; then
                print_info "Continuing anyway (--force mode)"
            else
                if ! gum confirm "hyprctl not found. Continue anyway?"; then
                    print_info "Installation cancelled"
                    exit 0
                fi
            fi
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
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Installation Modes:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--gui${NC}                   Prompt for GUI components (interactive)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--minimal${NC}               TUI-only install (no GUI, headless compatible)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--full${NC}                  Install everything (all GUI components)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--headless${NC}              Same as --minimal (alias)" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Other Options:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-packages${NC}         Skip package installation" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--no-tui${NC}                Disable TUI welcome screen" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--dry-run${NC}               Show what would be done without doing it" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--resume${NC}                Resume from last failed phase" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--reset${NC}                 Reset state and start fresh" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--config FILE${NC}           Use custom configuration file" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Package Categories (TUI-first):${NC}" $box_width
    draw_box_line "    ${FRAPPE_PEACH}core.txt${NC}                Core system (headless compatible)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}tui.txt${NC}                 TUI applications (yazi, lazygit, btop)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}development.txt${NC}         Development tools (Neovim, compilers)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}theming.txt${NC}             Fonts, icons, cursors" $box_width
    draw_box_line "    ${FRAPPE_PEACH}gui-essential.txt${NC}       Essential GUI (Hyprland, Waybar)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}gui-browsers.txt${NC}        Web browsers (Firefox)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}gui-productivity.txt${NC}    Office suite (LibreOffice)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}gui-communication.txt${NC}   Chat apps (Discord, Slack)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}aur.txt${NC}                 Core AUR packages (themes, TUI tools)" $box_width
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

# First pass: Extract --config flag to know which config file to load
# We need to do this first so we can load the config before parsing other flags
ORIGINAL_ARGS=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Load configuration file (if specified or if install.conf exists)
# This must happen BEFORE parsing other CLI flags so CLI flags can override config
if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    print_info "Loading configuration from: $CONFIG_FILE"
    source "$CONFIG_FILE"
elif [ -f "$SCRIPT_DIR/install.conf" ]; then
    print_info "Loading configuration from: install.conf"
    source "$SCRIPT_DIR/install.conf"
fi

# Second pass: Parse all command line arguments to override config file settings
set -- "${ORIGINAL_ARGS[@]}"
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
        --gui)
            # Interactive GUI selection mode
            INSTALL_MODE="interactive"
            shift
            ;;
        --minimal|--headless)
            # TUI-only mode (headless compatible)
            INSTALL_MODE="tui-only"
            INSTALL_GUI_ESSENTIAL=false
            INSTALL_GUI_BROWSERS=false
            INSTALL_GUI_PRODUCTIVITY=false
            INSTALL_GUI_COMMUNICATION=false
            shift
            ;;
        --full)
            # Install everything mode
            INSTALL_MODE="full"
            INSTALL_GUI_ESSENTIAL=true
            INSTALL_GUI_BROWSERS=true
            INSTALL_GUI_PRODUCTIVITY=true
            INSTALL_GUI_COMMUNICATION=true
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
            # Already handled in first pass
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

# Handle reset BEFORE initializing state
# This ensures state_init creates a fresh state after reset
if [ "$RESET" = true ]; then
    print_info "Resetting installation state..."
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
        print_success "State reset complete"
    else
        print_info "No existing state to reset"
    fi
fi

# Initialize state and logging
state_init
logging_init

# Show welcome screen
if [ "$SHOW_TUI" = true ] && [ "$RESUME" = false ]; then
    show_welcome
    # Gum style prompt
    gum confirm "Ready to start installation?" || exit 0
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

# Prompt for GUI selection if in interactive mode
if [ "$INSTALL_MODE" = "interactive" ] && [ "$SKIP_PACKAGES" = false ]; then
    prompt_gui_selection
fi

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
