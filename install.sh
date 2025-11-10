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

# Configuration variables (can be overridden by config file or flags)
FORCE=false
SKIP_PACKAGES=false
SHOW_TUI=true
DRY_RUN=false
RESUME=false
RESET=false
CONFIG_FILE=""

#############################################################################
# PACKAGE INSTALLATION FUNCTIONS (Not yet modular - future increment)
#############################################################################

# Install packages from a package list file
install_packages() {
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

# Install AUR packages
install_aur_packages() {
    local package_file="$PACKAGES_DIR/aur.txt"

    if [ ! -f "$package_file" ]; then
        print_info "No AUR packages file found, skipping"
        return 0
    fi

    # Install yay if needed
    if ! install_yay; then
        print_warning "Could not install AUR helper"
        print_info "Install yay or paru manually, then run:"
        print_info "  yay -S --needed - < packages/aur.txt"
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
        print_info "Skipping AUR packages. Install an AUR helper and run manually:"
        print_info "  yay -S --needed - < packages/aur.txt"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install AUR packages using $aur_helper"
        return 0
    fi

    print_info "Installing AUR packages using $aur_helper..."
    log_info "Installing AUR packages using $aur_helper"
    local package_count=$(grep -v '^#' "$package_file" | grep -v '^$' | wc -l)
    print_info "Found $package_count AUR packages to install"

    # Strip inline comments and trailing whitespace from package names
    if ! $aur_helper -S --needed --noconfirm - < <(grep -v '^#' "$package_file" | grep -v '^$' | sed 's/#.*//' | sed 's/[[:space:]]*$//'); then
        print_warning "Failed to install some AUR packages"
        log_warning "Failed to install some AUR packages"
        return 1
    fi

    print_success "Installed AUR packages"
    log_success "Installed AUR packages"
    return 0
}

# Install LazyVim with custom theme configuration
install_lazyvim() {
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim not installed - skipping LazyVim setup"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install LazyVim"
        return 0
    fi

    print_info "Setting up LazyVim..."
    log_info "Setting up LazyVim"

    local nvim_config="$HOME/.config/nvim"

    # Backup existing config if present
    if [ -d "$nvim_config" ]; then
        backup_if_exists "$nvim_config" "Neovim configuration"
    fi

    # Clone LazyVim starter
    print_info "Cloning LazyVim starter template..."
    if ! git clone https://github.com/LazyVim/starter "$nvim_config"; then
        print_error "Failed to clone LazyVim starter"
        log_error "Failed to clone LazyVim starter"
        return 1
    fi

    # Remove .git directory so it becomes part of your dotfiles
    rm -rf "$nvim_config/.git"

    # Symlink custom configuration files from dotfiles
    print_info "Symlinking custom LazyVim configurations..."
    local nvim_custom_dir="$DOTFILES_DIR/nvim/lua"
    if [ -d "$nvim_custom_dir" ]; then
        # Create necessary directories
        mkdir -p "$nvim_config/lua/config"
        mkdir -p "$nvim_config/lua/plugins"

        # Symlink individual files from nvim/lua/config
        if [ -d "$nvim_custom_dir/config" ]; then
            for file in "$nvim_custom_dir/config"/*; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file")
                    create_symlink "$file" "$nvim_config/lua/config/$filename" "Neovim config: $filename"
                fi
            done
        fi

        # Symlink individual files from nvim/lua/plugins
        if [ -d "$nvim_custom_dir/plugins" ]; then
            for file in "$nvim_custom_dir/plugins"/*; do
                if [ -f "$file" ]; then
                    local filename=$(basename "$file")
                    create_symlink "$file" "$nvim_config/lua/plugins/$filename" "Neovim plugin: $filename"
                fi
            done
        fi
    fi

    print_success "LazyVim setup complete"
    log_success "LazyVim setup complete"
    print_info "Open Neovim and LazyVim will automatically install plugins"
    return 0
}

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

    install_packages "$PACKAGES_DIR/core.txt" "core packages"
    install_packages "$PACKAGES_DIR/hypr-ecosystem.txt" "Hypr ecosystem packages"
    install_packages "$PACKAGES_DIR/theming.txt" "theming packages"
    install_packages "$PACKAGES_DIR/development.txt" "development packages"
    install_packages "$PACKAGES_DIR/productivity.txt" "productivity packages"
    install_aur_packages

    log_phase_end "Package Installation" "success"
    print_success "Package installation complete"
    echo ""
}

# Deploy all configuration files
deploy_configurations() {
    log_phase_start "Configuration Deployment"

    print_step 8 15 "Deploying configuration files"

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would deploy all configurations"
        return 0
    fi

    # Install Hyprland configuration
    if [ -d "$DOTFILES_DIR/hyprland" ]; then
        create_symlink "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr" "Hyprland"
    fi

    # Install Waybar configuration
    if [ -d "$DOTFILES_DIR/waybar" ]; then
        create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "Waybar"
    fi

    # Install Kitty configuration
    if [ -d "$DOTFILES_DIR/kitty" ]; then
        create_symlink "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty" "Kitty"
    fi

    # Install Rofi configuration
    if [ -d "$DOTFILES_DIR/rofi" ]; then
        create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "Rofi"
    fi

    # Install Mako configuration
    if [ -d "$DOTFILES_DIR/mako" ]; then
        create_symlink "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" "Mako"
    fi

    # Install Zathura configuration
    if [ -d "$DOTFILES_DIR/zathura" ]; then
        create_symlink "$DOTFILES_DIR/zathura" "$CONFIG_DIR/zathura" "Zathura"
    fi

    # Install wlogout configuration
    if [ -d "$DOTFILES_DIR/wlogout" ]; then
        create_symlink "$DOTFILES_DIR/wlogout" "$CONFIG_DIR/wlogout" "wlogout"
    fi

    # Install btop configuration
    if [ -d "$DOTFILES_DIR/btop" ]; then
        create_symlink "$DOTFILES_DIR/btop" "$CONFIG_DIR/btop" "btop"
    fi

    # Install Starship configuration
    if command -v starship &> /dev/null; then
        print_info "Installing Starship Catppuccin Frappe preset..."

        # Backup existing config if present
        if [ -f "$CONFIG_DIR/starship.toml" ]; then
            backup_if_exists "$CONFIG_DIR/starship.toml" "Starship configuration"
        fi

        # Install the official Catppuccin Powerline preset
        if starship preset catppuccin-powerline -o "$CONFIG_DIR/starship.toml"; then
            print_success "Installed Starship preset"

            # Update the palette to use Frappe variant
            if [ -f "$CONFIG_DIR/starship.toml" ]; then
                if grep -q "palette = 'catppuccin_mocha'" "$CONFIG_DIR/starship.toml" 2>/dev/null; then
                    sed -i "s/palette = 'catppuccin_mocha'/palette = 'catppuccin_frappe'/" "$CONFIG_DIR/starship.toml"
                    print_success "Configured Catppuccin Frappe theme"
                fi
            fi
        else
            print_warning "Failed to install Starship preset, trying manual symlink..."
            if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
                create_symlink "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml" "Starship"
            fi
        fi

        # Configure Starship in shell RC files
        print_info "Setting up Starship shell integration..."

        # Setup for bash
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
                echo '' >> "$HOME/.bashrc"
                echo '# Starship prompt' >> "$HOME/.bashrc"
                echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
                print_success "Added Starship initialization to .bashrc"
            fi
        fi

        # Setup for zsh
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
                echo '' >> "$HOME/.zshrc"
                echo '# Starship prompt' >> "$HOME/.zshrc"
                echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
                print_success "Added Starship initialization to .zshrc"
            fi
        fi
    fi

    # Install Bash aliases
    if [ -f "$DOTFILES_DIR/bash/.bash_aliases" ]; then
        print_info "Setting up bash aliases..."
        create_symlink "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases" "Bash aliases"

        # Add source command to .bashrc if needed
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q '\.bash_aliases' "$HOME/.bashrc"; then
                echo '' >> "$HOME/.bashrc"
                echo '# Load custom bash aliases' >> "$HOME/.bashrc"
                echo 'if [ -f ~/.bash_aliases ]; then' >> "$HOME/.bashrc"
                echo '    . ~/.bash_aliases' >> "$HOME/.bashrc"
                echo 'fi' >> "$HOME/.bashrc"
                print_success "Added bash aliases to .bashrc"
            fi
        fi

        # Do the same for .zshrc
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q '\.bash_aliases' "$HOME/.zshrc"; then
                echo '' >> "$HOME/.zshrc"
                echo '# Load custom bash aliases' >> "$HOME/.zshrc"
                echo 'if [ -f ~/.bash_aliases ]; then' >> "$HOME/.zshrc"
                echo '    . ~/.bash_aliases' >> "$HOME/.zshrc"
                echo 'fi' >> "$HOME/.zshrc"
                print_success "Added bash aliases to .zshrc"
            fi
        fi
    fi

    # Install SDDM configuration
    if [ -f "$DOTFILES_DIR/sddm/theme.conf" ]; then
        print_info "Setting up SDDM theme configuration..."
        if sudo mkdir -p /etc/sddm.conf.d 2>/dev/null; then
            if sudo ln -sf "$DOTFILES_DIR/sddm/theme.conf" /etc/sddm.conf.d/theme.conf 2>/dev/null; then
                print_success "Linked SDDM theme configuration"
            else
                print_warning "Failed to create SDDM config symlink (may need sudo)"
            fi
        fi
    fi

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

    setup_wallpapers
    install_lazyvim

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
