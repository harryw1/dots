#!/usr/bin/env bash

# Dotfiles Installation Script
# Installs configuration files to their proper locations

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup of existing config
backup_if_exists() {
    local target="$1"
    local name="$2"

    if [ -e "$target" ]; then
        print_warning "Existing $name configuration found"
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        print_info "Backed up to: $BACKUP_DIR/$(basename "$target")"
        return 0
    fi
    return 1
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -L "$target" ]; then
        local current_source="$(readlink "$target")"
        if [ "$current_source" = "$source" ]; then
            print_info "$name already linked correctly"
            return 0
        else
            print_warning "$name symlink exists but points to different location"
            backup_if_exists "$target" "$name"
        fi
    elif [ -e "$target" ]; then
        backup_if_exists "$target" "$name"
    fi

    ln -sf "$source" "$target"
    print_success "Linked $name: $target -> $source"
}

# Check if running Arch Linux
is_arch_linux() {
    [ -f /etc/arch-release ]
}

# Check if extra repository is enabled
check_repositories() {
    print_info "Checking repository configuration..."

    # Check if extra repository is enabled
    if ! grep -q "^\[extra\]" /etc/pacman.conf; then
        print_warning "'extra' repository not found in /etc/pacman.conf"
        print_info "Attempting to enable 'extra' repository..."

        # Backup pacman.conf
        sudo cp /etc/pacman.conf /etc/pacman.conf.backup

        # Check if it exists but is commented
        if grep -q "^#\[extra\]" /etc/pacman.conf; then
            print_info "Uncommenting 'extra' repository..."
            sudo sed -i '/^#\[extra\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
        else
            print_warning "'extra' repository section not found in config"
            print_info "Please ensure your /etc/pacman.conf includes the 'extra' repository"
            return 1
        fi
    fi

    # Check if core repository is enabled
    if ! grep -q "^\[core\]" /etc/pacman.conf; then
        print_warning "'core' repository not properly configured"
        return 1
    fi

    print_success "Repository configuration verified"
    return 0
}

# Check and setup mirrorlist
check_mirrorlist() {
    print_info "Checking mirrorlist configuration..."

    # Count active mirrors
    local mirror_count=$(grep -c "^Server" /etc/pacman.d/mirrorlist 2>/dev/null || echo "0")

    if [ "$mirror_count" -lt 3 ]; then
        print_warning "Only $mirror_count mirrors found in mirrorlist"
        print_info "Attempting to generate a fresh mirrorlist..."

        # Check if reflector is installed
        if ! command -v reflector &> /dev/null; then
            print_info "Installing reflector to generate mirrorlist..."
            if ! sudo pacman -Sy --noconfirm reflector; then
                print_warning "Could not install reflector, using existing mirrorlist"
                return 0
            fi
        fi

        # Backup existing mirrorlist
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

        # Generate new mirrorlist
        print_info "Generating optimized mirrorlist (this may take a minute)..."
        if sudo reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist; then
            print_success "Generated fresh mirrorlist with fast mirrors"
        else
            print_warning "Failed to generate mirrorlist, restoring backup"
            sudo mv /etc/pacman.d/mirrorlist.backup /etc/pacman.d/mirrorlist
        fi
    else
        print_success "Mirrorlist has $mirror_count active mirrors"
    fi

    return 0
}

# Sync package databases to ensure latest versions
sync_package_database() {
    print_info "Syncing package databases to ensure latest versions..."

    # Force refresh all package databases
    if ! sudo pacman -Syy --noconfirm; then
        print_error "Failed to sync package database"
        return 1
    fi

    print_success "Package database synced - will install latest versions"
}

# Resolve package conflicts by removing conflicting packages
resolve_conflicts() {
    print_info "Checking for package conflicts..."

    # PulseAudio vs PipeWire conflict
    if pacman -Qq pulseaudio &> /dev/null || pacman -Qq pulseaudio-alsa &> /dev/null; then
        print_warning "PulseAudio detected - replacing with PipeWire"
        print_info "Removing PulseAudio packages..."
        sudo pacman -Rdd --noconfirm pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-jack pulseaudio-equalizer 2>/dev/null || true
        print_success "PulseAudio removed"
    fi

    print_success "Conflict resolution complete"
}

# Install packages from a package list file
install_packages() {
    local package_file="$1"
    local description="$2"

    if [ ! -f "$package_file" ]; then
        print_warning "Package file not found: $package_file"
        return 1
    fi

    print_info "Installing $description..."

    # Count packages (excluding comments and empty lines)
    local package_count=$(grep -v '^#' "$package_file" | grep -v '^$' | wc -l)
    print_info "Found $package_count packages to install"

    # Install with pacman, using --ask=4 to auto-remove conflicting packages
    if ! sudo pacman -S --needed --noconfirm --ask=4 - < <(grep -v '^#' "$package_file" | grep -v '^$'); then
        print_error "Failed to install some packages from $description"
        return 1
    fi

    print_success "Installed $description"
    return 0
}

# Install yay AUR helper if not present
install_yay() {
    # Check if an AUR helper is already installed
    if command -v yay &> /dev/null || command -v paru &> /dev/null; then
        return 0
    fi

    print_info "Installing yay AUR helper..."

    # Check for required dependencies
    if ! command -v git &> /dev/null || ! command -v base-devel &> /dev/null; then
        print_info "Installing base-devel and git (required for building yay)..."
        if ! sudo pacman -S --needed --noconfirm base-devel git; then
            print_error "Failed to install base-devel and git"
            return 1
        fi
    fi

    # Clone and build yay in /tmp
    local yay_build_dir="/tmp/yay-build-$$"
    mkdir -p "$yay_build_dir"

    print_info "Cloning yay repository..."
    if ! git clone https://aur.archlinux.org/yay.git "$yay_build_dir"; then
        print_error "Failed to clone yay repository"
        rm -rf "$yay_build_dir"
        return 1
    fi

    print_info "Building and installing yay..."
    cd "$yay_build_dir"
    if ! makepkg -si --noconfirm; then
        print_error "Failed to build yay"
        cd - > /dev/null
        rm -rf "$yay_build_dir"
        return 1
    fi

    cd - > /dev/null
    rm -rf "$yay_build_dir"

    print_success "yay installed successfully"
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

    print_info "Installing AUR packages using $aur_helper..."
    local package_count=$(grep -v '^#' "$package_file" | grep -v '^$' | wc -l)
    print_info "Found $package_count AUR packages to install"

    if ! $aur_helper -S --needed --noconfirm - < <(grep -v '^#' "$package_file" | grep -v '^$'); then
        print_warning "Failed to install some AUR packages"
        return 1
    fi

    print_success "Installed AUR packages"
    return 0
}

# Install LazyVim with custom theme configuration
install_lazyvim() {
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim not installed - skipping LazyVim setup"
        return 0
    fi

    local nvim_config="$HOME/.config/nvim"
    local nvim_data="$HOME/.local/share/nvim"
    local nvim_state="$HOME/.local/state/nvim"
    local nvim_cache="$HOME/.cache/nvim"

    print_info "Setting up LazyVim with Catppuccin Frappe theme..."

    # Backup existing Neovim configuration if it exists
    if [ -d "$nvim_config" ] || [ -d "$nvim_data" ]; then
        local backup_suffix="nvim-backup-$(date +%Y%m%d-%H%M%S)"
        print_warning "Existing Neovim configuration found"

        [ -d "$nvim_config" ] && mv "$nvim_config" "$HOME/.config/$backup_suffix"
        [ -d "$nvim_data" ] && mv "$nvim_data" "$HOME/.local/share/$backup_suffix"
        [ -d "$nvim_state" ] && mv "$nvim_state" "$HOME/.local/state/$backup_suffix"
        [ -d "$nvim_cache" ] && mv "$nvim_cache" "$HOME/.cache/$backup_suffix"

        print_info "Backed up existing Neovim config to $backup_suffix"
    fi

    # Clone LazyVim starter template
    print_info "Cloning LazyVim starter template..."
    if ! git clone https://github.com/LazyVim/starter "$nvim_config"; then
        print_error "Failed to clone LazyVim starter"
        return 1
    fi

    # Remove .git directory so it becomes the user's own repo
    rm -rf "$nvim_config/.git"

    # Apply our custom configurations (Catppuccin theme + font settings)
    if [ -d "$DOTFILES_DIR/nvim/lua" ]; then
        print_info "Applying Catppuccin Frappe theme and custom settings..."
        cp -r "$DOTFILES_DIR/nvim/lua/"* "$nvim_config/lua/"
        print_success "Custom configurations applied"
    fi

    print_success "LazyVim installed with Catppuccin Frappe theme!"
    echo ""
    print_info "Next: Launch Neovim to complete setup (plugins will auto-install)"
    echo "  $ nvim"
    echo ""
}

# Setup Catppuccin wallpaper collection
setup_wallpapers() {
    print_info "Setting up Catppuccin wallpaper collection..."

    local wallpaper_collection_dir="$HOME/.local/share/catppuccin-wallpapers"
    local hypr_wallpapers_dir="$HOME/.config/hypr/wallpapers"

    # Clone Catppuccin wallpaper collection (organized by variant)
    if [ ! -d "$wallpaper_collection_dir" ]; then
        print_info "Cloning Catppuccin wallpaper collection (this may take a minute)..."
        if git clone --depth 1 https://github.com/42Willow/wallpapers "$wallpaper_collection_dir" 2>/dev/null; then
            print_success "Wallpaper collection cloned to $wallpaper_collection_dir"
        else
            print_warning "Failed to clone wallpaper collection"
            print_info "You can clone manually: git clone https://github.com/42Willow/wallpapers ~/.local/share/catppuccin-wallpapers"
            return 1
        fi
    else
        print_info "Wallpaper collection already exists at $wallpaper_collection_dir"
    fi

    # Create hyprpaper wallpapers directory
    mkdir -p "$hypr_wallpapers_dir"

    # Copy 2-3 default Frappe wallpapers for immediate use
    if [ -d "$wallpaper_collection_dir/frappe" ]; then
        print_info "Copying default Frappe wallpapers..."
        local copied=0
        find "$wallpaper_collection_dir/frappe" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | head -3 | \
        while read wallpaper; do
            cp "$wallpaper" "$hypr_wallpapers_dir/" && copied=$((copied + 1))
        done

        # Count wallpapers in collection
        local total_wallpapers=$(find "$wallpaper_collection_dir/frappe" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | wc -l)
        print_success "Copied 3 default wallpapers ($total_wallpapers available in collection)"
    else
        print_warning "Frappe wallpapers not found in collection"
    fi

    # Create waypaper config directory
    mkdir -p "$HOME/.config/waypaper"

    # Create basic waypaper config if it doesn't exist
    if [ ! -f "$HOME/.config/waypaper/config.ini" ]; then
        cat > "$HOME/.config/waypaper/config.ini" << 'EOF'
[Settings]
language = en
folder = ~/.local/share/catppuccin-wallpapers/frappe
backend = hyprpaper
monitors = all
wallpaper =
fill = fill
sort = name
color = #303446
subfolders = False
show_hidden = False
show_gifs_only = False
post_command =
number_of_columns = 3
swww_transition_type =
swww_transition_step = 90
swww_transition_angle = 0
swww_transition_duration = 2
EOF
        print_success "Created waypaper configuration"
    fi

    print_success "Wallpaper setup complete!"
    echo ""
    print_info "Wallpaper collection: $wallpaper_collection_dir"
    print_info "Browse wallpapers with: waypaper"
    echo ""
}

# Interactive package installation
install_packages_interactive() {
    if ! is_arch_linux; then
        print_warning "Not running Arch Linux - skipping package installation"
        return 0
    fi

    # Check and fix repository configuration
    check_repositories || return 1

    # Check and optimize mirrorlist
    check_mirrorlist

    # Sync package database to ensure latest versions
    sync_package_database

    # Resolve conflicts before interactive menu
    resolve_conflicts

    echo ""
    print_info "Package Installation"
    echo ""
    echo "Available package groups:"
    echo "  1. Core packages (required for Hyprland)"
    echo "  2. Hypr ecosystem (hyprpaper, hypridle, hyprlock, etc.)"
    echo "  3. Theming (fonts, icons, cursors)"
    echo "  4. Development tools (Python, C++, build tools)"
    echo "  5. Productivity (LibreOffice, PDF viewer, etc.)"
    echo "  6. AUR packages (requires yay or paru)"
    echo "  A. All of the above"
    echo "  S. Skip package installation"
    echo ""

    read -p "Select option (1-6, A, S): " -n 1 -r
    echo
    echo ""

    case $REPLY in
        1)
            install_packages "$PACKAGES_DIR/core.txt" "core packages"
            ;;
        2)
            install_packages "$PACKAGES_DIR/hypr-ecosystem.txt" "Hypr ecosystem packages"
            ;;
        3)
            install_packages "$PACKAGES_DIR/theming.txt" "theming packages"
            ;;
        4)
            install_packages "$PACKAGES_DIR/development.txt" "development packages"
            ;;
        5)
            install_packages "$PACKAGES_DIR/productivity.txt" "productivity packages"
            ;;
        6)
            install_aur_packages
            ;;
        A|a)
            install_packages "$PACKAGES_DIR/core.txt" "core packages"
            install_packages "$PACKAGES_DIR/hypr-ecosystem.txt" "Hypr ecosystem packages"
            install_packages "$PACKAGES_DIR/theming.txt" "theming packages"
            install_packages "$PACKAGES_DIR/development.txt" "development packages"
            install_packages "$PACKAGES_DIR/productivity.txt" "productivity packages"
            install_aur_packages
            ;;
        S|s)
            print_info "Skipping package installation"
            ;;
        *)
            print_error "Invalid option"
            return 1
            ;;
    esac

    echo ""
}

# Main installation
main() {
    print_info "Starting dotfiles installation from: $DOTFILES_DIR"
    echo ""

    # Install packages if requested
    if [ "$INSTALL_PACKAGES" = true ]; then
        if [ "$SKIP_INTERACTIVE" = true ]; then
            # Non-interactive: install all packages
            if is_arch_linux; then
                # Check and fix repository configuration
                check_repositories || return 1

                # Check and optimize mirrorlist
                check_mirrorlist

                sync_package_database
                resolve_conflicts
                install_packages "$PACKAGES_DIR/core.txt" "core packages"
                install_packages "$PACKAGES_DIR/hypr-ecosystem.txt" "Hypr ecosystem packages"
                install_packages "$PACKAGES_DIR/theming.txt" "theming packages"
                install_packages "$PACKAGES_DIR/development.txt" "development packages"
                install_packages "$PACKAGES_DIR/productivity.txt" "productivity packages"
                install_aur_packages

                # Setup wallpapers after all packages are installed
                setup_wallpapers
            else
                print_warning "Not running Arch Linux - skipping package installation"
            fi
        else
            # Interactive package selection
            install_packages_interactive
        fi
    fi

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    # Install Hyprland configuration
    if [ -d "$DOTFILES_DIR/hyprland" ]; then
        print_info "Installing Hyprland configuration..."
        create_symlink "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr" "Hyprland"
        echo ""
    else
        print_warning "Hyprland configuration directory not found, skipping"
        echo ""
    fi

    # Install Waybar configuration
    if [ -d "$DOTFILES_DIR/waybar" ]; then
        print_info "Installing Waybar configuration..."
        create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "Waybar"
        echo ""
    else
        print_warning "Waybar configuration directory not found, skipping"
        echo ""
    fi

    # Install Kitty configuration
    if [ -d "$DOTFILES_DIR/kitty" ]; then
        print_info "Installing Kitty configuration..."
        create_symlink "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty" "Kitty"
        echo ""
    else
        print_warning "Kitty configuration directory not found, skipping"
        echo ""
    fi

    # Install Rofi configuration
    if [ -d "$DOTFILES_DIR/rofi" ]; then
        print_info "Installing Rofi configuration..."
        create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "Rofi"
        echo ""
    else
        print_warning "Rofi configuration directory not found, skipping"
        echo ""
    fi

    # Install Mako configuration
    if [ -d "$DOTFILES_DIR/mako" ]; then
        print_info "Installing Mako configuration..."
        create_symlink "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" "Mako"
        echo ""
    else
        print_warning "Mako configuration directory not found, skipping"
        echo ""
    fi

    # Install Zathura configuration
    if [ -d "$DOTFILES_DIR/zathura" ]; then
        print_info "Installing Zathura configuration..."
        create_symlink "$DOTFILES_DIR/zathura" "$CONFIG_DIR/zathura" "Zathura"
        echo ""
    else
        print_warning "Zathura configuration directory not found, skipping"
        echo ""
    fi

    # Install LazyVim with custom theme
    install_lazyvim

    # Create wallpapers directory
    mkdir -p "$HOME/.config/hypr/wallpapers"

    # Summary
    echo ""
    print_success "Installation complete!"

    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        print_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""
    print_info "Next steps:"
    if [ "$INSTALL_PACKAGES" != true ]; then
        echo "  1. Install required dependencies: ./install.sh --packages-all"
        echo "     Or manually: see packages/ directory"
        echo "  2. Set up a wallpaper (see ~/.config/hypr/wallpapers/README.md)"
        echo "  3. Configure Firefox dark mode: about:preferences → General → Website appearance → Dark"
        echo "  4. Adjust monitor configuration in ~/.config/hypr/conf/monitors.conf"
        echo "  5. Reload Hyprland: hyprctl reload (or log out and back in)"
    else
        echo "  === Post-Installation Setup ==="
        echo ""
        echo "  Essential setup (do these now):"
        echo "  1. Browse and select a wallpaper:"
        echo "     GUI: Run 'waypaper' to browse the Catppuccin collection"
        echo "     Collection: ~/.local/share/catppuccin-wallpapers/frappe/"
        echo "     See also: ~/.config/hypr/wallpapers/README.md"
        echo ""
        echo "  2. Configure Firefox dark mode manually:"
        echo "     Open Firefox → about:preferences → General → Website appearance → Choose 'Dark'"
        echo ""
        echo "  3. Apply GTK theme (for Thunar, LibreOffice dark mode):"
        echo "     Log out and log back in to Hyprland for GTK theme to apply"
        echo ""
        echo "  Optional customization:"
        echo "  - Adjust monitor scaling: ~/.config/hypr/conf/monitors.conf"
        echo "  - Customize keybindings: ~/.config/hypr/conf/keybinds.conf"
        echo "  - Adjust animations: ~/.config/hypr/conf/animations.conf"
        echo ""
        echo "  To apply changes: hyprctl reload (or log out/in for theme changes)"
    fi
    echo ""
}

# Check if running on a system with Hyprland available
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
    cat << EOF
Dotfiles Installation Script

Usage: ./install.sh [OPTIONS]

Options:
    -h, --help          Show this help message
    -f, --force         Skip confirmation prompts
    -p, --packages      Install packages from packages/ directory (interactive)
    --packages-all      Install all packages non-interactively (Arch Linux only)
    --skip-packages     Skip package installation

This script will:
    1. Optionally install required packages (Arch Linux only)
    2. Backup any existing configurations
    3. Create symlinks from this repository to ~/.config/
    4. Preserve your ability to update configs via git

Package Installation:
    Packages are organized in packages/ directory:
    - core.txt           : Required Hyprland packages
    - hypr-ecosystem.txt : Optional Hypr tools
    - theming.txt        : Fonts, icons, cursors
    - development.txt    : Python, C++, build tools
    - productivity.txt   : Office and productivity tools
    - aur.txt            : AUR packages (requires yay or paru)

    Install manually:
        pacman -S --needed - < packages/core.txt
        yay -S --needed - < packages/aur.txt

Backups are stored in ~/.config-backup-TIMESTAMP/
EOF
}

# Parse arguments
FORCE=false
INSTALL_PACKAGES=false
SKIP_INTERACTIVE=false

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
        -p|--packages)
            INSTALL_PACKAGES=true
            shift
            ;;
        --packages-all)
            INSTALL_PACKAGES=true
            SKIP_INTERACTIVE=true
            shift
            ;;
        --skip-packages)
            INSTALL_PACKAGES=false
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run installation
if [ "$FORCE" = false ]; then
    check_system
fi

main
