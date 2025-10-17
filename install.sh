#!/usr/bin/env bash

# Dotfiles Installation Script
# Installs configuration files to their proper locations

set -e  # Exit on error

# Colors for output (defined early for error trap)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Catppuccin Frappe colors for TUI
FRAPPE_ROSEWATER='\033[38;2;242;213;207m'
FRAPPE_FLAMINGO='\033[38;2;238;190;190m'
FRAPPE_PINK='\033[38;2;244;184;228m'
FRAPPE_MAUVE='\033[38;2;202;158;230m'
FRAPPE_RED='\033[38;2;231;130;132m'
FRAPPE_MAROON='\033[38;2;234;153;156m'
FRAPPE_PEACH='\033[38;2;239;159;118m'
FRAPPE_YELLOW='\033[38;2;229;200;144m'
FRAPPE_GREEN='\033[38;2;166;209;137m'
FRAPPE_TEAL='\033[38;2;129;200;190m'
FRAPPE_SKY='\033[38;2;153;209;219m'
FRAPPE_SAPPHIRE='\033[38;2;133;193;220m'
FRAPPE_BLUE='\033[38;2;140;170;238m'
FRAPPE_LAVENDER='\033[38;2;186;187;241m'
FRAPPE_TEXT='\033[38;2;198;208;245m'
FRAPPE_SUBTEXT1='\033[38;2;181;191;226m'
FRAPPE_BASE='\033[38;2;48;52;70m'

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

# Terminal width for formatting
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

# TUI Helper Functions
# Function to strip ANSI codes for length calculation
strip_ansi() {
    echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

draw_box() {
    local title="$1"
    local width=${2:-60}

    # Top border
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╔"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo -e "╗${NC}"

    # Title (if provided)
    if [ -n "$title" ]; then
        # Strip ANSI codes to calculate visible length
        local visible_title=$(strip_ansi "$title")
        local title_len=${#visible_title}
        # Account for: ║ (1) + title + ║ (1) = title_len + 2
        local padding=$(( (width - title_len - 2) / 2 ))
        local right_padding=$(( width - title_len - padding - 2 ))

        echo -en "${FRAPPE_LAVENDER}║${NC}"
        printf ' %.0s' $(seq 1 $padding)
        echo -en "${BOLD}${FRAPPE_MAUVE}${title}${NC}"
        printf ' %.0s' $(seq 1 $right_padding)
        echo -e "${FRAPPE_LAVENDER}║${NC}"

        # Separator
        echo -en "${FRAPPE_LAVENDER}"
        echo -n "╠"
        printf '═%.0s' $(seq 1 $((width - 2)))
        echo -e "╣${NC}"
    fi
}

draw_box_line() {
    local text="$1"
    local width=${2:-60}
    local color=${3:-$FRAPPE_TEXT}

    # Strip ANSI codes to get actual visible text length
    local visible_text=$(strip_ansi "$text")
    local text_length=${#visible_text}

    # Calculate padding: width - text_length - 4 (for "║ " and " ║" = 4 chars total)
    local padding=$((width - text_length - 4))

    # Print the line
    echo -en "${FRAPPE_LAVENDER}║${NC} "
    echo -en "${text}"
    if [ $padding -gt 0 ]; then
        printf ' %.0s' $(seq 1 $padding)
    fi
    echo -e " ${FRAPPE_LAVENDER}║${NC}"
}

draw_box_bottom() {
    local width=${1:-60}
    echo -en "${FRAPPE_LAVENDER}"
    echo -n "╚"
    printf '═%.0s' $(seq 1 $((width - 2)))
    echo -e "╝${NC}"
}

draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    echo -en "${FRAPPE_LAVENDER}["
    echo -en "${FRAPPE_GREEN}"
    printf '█%.0s' $(seq 1 $filled)
    echo -en "${FRAPPE_BASE}"
    printf '░%.0s' $(seq 1 $empty)
    echo -en "${FRAPPE_LAVENDER}]${NC} ${FRAPPE_YELLOW}${percent}%%${NC}"
}

print_step() {
    local step_num=$1
    local total_steps=$2
    local description="$3"

    echo ""
    echo -e "${FRAPPE_SAPPHIRE}╭─${NC} ${BOLD}${FRAPPE_MAUVE}Step ${step_num}/${total_steps}${NC} ${FRAPPE_LAVENDER}─${NC}"
    echo -e "${FRAPPE_SAPPHIRE}│${NC}  ${FRAPPE_TEXT}${description}${NC}"
    echo -e "${FRAPPE_SAPPHIRE}╰─${NC}"
    echo ""
}

show_welcome() {
    clear

    # Calculate box width based on ASCII art (longest line is ~69 chars)
    local ascii_width=69
    local box_width=$((ascii_width + 17))  # Add padding for margins

    echo ""
    draw_box "Hyprland Dotfiles Installer" $box_width
    draw_box_line "" $box_width

    # HYPRLAND ASCII art - colors handled by draw_box_line
    draw_box_line "${FRAPPE_MAUVE}  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗${NC}" $box_width
    draw_box_line "${FRAPPE_MAUVE}  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗${NC}" $box_width
    draw_box_line "${FRAPPE_BLUE}  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║${NC}" $box_width
    draw_box_line "${FRAPPE_BLUE}  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║${NC}" $box_width
    draw_box_line "${FRAPPE_SAPPHIRE}  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝${NC}" $box_width
    draw_box_line "${FRAPPE_SAPPHIRE}  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "Catppuccin Frappe Theme • Modular Configuration" $box_width
    draw_box_line "" $box_width
    draw_box_line "${FRAPPE_PEACH}This installer will:${NC}" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Install all required packages" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Set up Hyprland, Waybar, Kitty, and more" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Configure Neovim with LazyVim" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Install Catppuccin wallpaper collection" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Create backups of existing configs" $box_width
    draw_box_line "" $box_width
    draw_box_line "${FRAPPE_YELLOW}⚠  ${FRAPPE_TEXT}Requires Arch Linux${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""
}

# Print functions (updated with TUI colors)
print_info() {
    echo -e "${FRAPPE_BLUE}●${NC} $1"
}

print_success() {
    echo -e "${FRAPPE_GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${FRAPPE_YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${FRAPPE_RED}✗${NC} $1"
}

# Set up error trap now that print_error is defined
trap 'echo ""; print_error "Installation failed at line $LINENO"; echo "Command: $BASH_COMMAND"; exit 1' ERR

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
    # Strip inline comments and trailing whitespace from package names
    if ! sudo pacman -S --needed --noconfirm --ask=4 - < <(grep -v '^#' "$package_file" | grep -v '^$' | sed 's/#.*//' | sed 's/[[:space:]]*$//'); then
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

    # Strip inline comments and trailing whitespace from package names
    if ! $aur_helper -S --needed --noconfirm - < <(grep -v '^#' "$package_file" | grep -v '^$' | sed 's/#.*//' | sed 's/[[:space:]]*$//'); then
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
        cat > "$HOME/.config/waypaper/config.ini" << EOF
[Settings]
language = en
folder = $HOME/.local/share/catppuccin-wallpapers/frappe
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

# Main installation
main() {
    local total_steps=10
    local current_step=0

    # Show welcome screen
    if [ "$SHOW_TUI" = true ]; then
        show_welcome
        echo -n "Press Enter to continue or Ctrl+C to cancel..."
        read -r
        echo ""
        echo ""
        print_info "Starting installation..."
        echo ""
    fi

    # Install packages unless explicitly skipped
    if [ "$SKIP_PACKAGES" = false ]; then
        if is_arch_linux; then
            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Checking repository configuration"
            check_repositories || return 1

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Optimizing mirrorlist"
            check_mirrorlist

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Syncing package databases"
            sync_package_database

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Resolving package conflicts"
            resolve_conflicts

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Installing core packages"
            install_packages "$PACKAGES_DIR/core.txt" "core packages"

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Installing Hypr ecosystem packages"
            install_packages "$PACKAGES_DIR/hypr-ecosystem.txt" "Hypr ecosystem packages"

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Installing theming packages"
            install_packages "$PACKAGES_DIR/theming.txt" "theming packages"

            current_step=$((current_step + 1))
            print_step $current_step $total_steps "Installing development packages"
            install_packages "$PACKAGES_DIR/development.txt" "development packages"

            print_step $current_step $total_steps "Installing productivity packages"
            install_packages "$PACKAGES_DIR/productivity.txt" "productivity packages"

            print_step $current_step $total_steps "Installing AUR packages"
            install_aur_packages

            # Setup wallpapers after all packages are installed
            print_step $current_step $total_steps "Setting up Catppuccin wallpaper collection"
            setup_wallpapers
        else
            print_warning "Not running Arch Linux - skipping package installation"
        fi
    else
        print_info "Skipping package installation (--skip-packages flag used)"
    fi

    # Adjust step counter if packages were skipped
    if [ "$SKIP_PACKAGES" = true ]; then
        current_step=0
        total_steps=7
    fi

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    current_step=$((current_step + 1))
    print_step $current_step $total_steps "Creating configuration symlinks"

    # Install Hyprland configuration
    if [ -d "$DOTFILES_DIR/hyprland" ]; then
        create_symlink "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr" "Hyprland"
    else
        print_warning "Hyprland configuration directory not found, skipping"
    fi

    # Install Waybar configuration
    if [ -d "$DOTFILES_DIR/waybar" ]; then
        create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "Waybar"
    else
        print_warning "Waybar configuration directory not found, skipping"
    fi

    # Install Kitty configuration
    if [ -d "$DOTFILES_DIR/kitty" ]; then
        create_symlink "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty" "Kitty"
    else
        print_warning "Kitty configuration directory not found, skipping"
    fi

    # Install Rofi configuration
    if [ -d "$DOTFILES_DIR/rofi" ]; then
        create_symlink "$DOTFILES_DIR/rofi" "$CONFIG_DIR/rofi" "Rofi"
    else
        print_warning "Rofi configuration directory not found, skipping"
    fi

    # Install Mako configuration
    if [ -d "$DOTFILES_DIR/mako" ]; then
        create_symlink "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" "Mako"
    else
        print_warning "Mako configuration directory not found, skipping"
    fi

    # Install Zathura configuration
    if [ -d "$DOTFILES_DIR/zathura" ]; then
        create_symlink "$DOTFILES_DIR/zathura" "$CONFIG_DIR/zathura" "Zathura"
    else
        print_warning "Zathura configuration directory not found, skipping"
    fi

    # Install Starship configuration
    if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
        create_symlink "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml" "Starship"

        # Configure Starship in shell RC files
        if command -v starship &> /dev/null; then
            print_info "Setting up Starship shell integration..."

            # Setup for bash
            if [ -f "$HOME/.bashrc" ]; then
                if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
                    echo '' >> "$HOME/.bashrc"
                    echo '# Starship prompt' >> "$HOME/.bashrc"
                    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
                    print_success "Added Starship initialization to .bashrc"
                else
                    print_info "Starship already configured in .bashrc"
                fi
            fi

            # Setup for zsh
            if [ -f "$HOME/.zshrc" ]; then
                if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
                    echo '' >> "$HOME/.zshrc"
                    echo '# Starship prompt' >> "$HOME/.zshrc"
                    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
                    print_success "Added Starship initialization to .zshrc"
                else
                    print_info "Starship already configured in .zshrc"
                fi
            fi
        else
            print_warning "Starship not installed - run with packages to enable shell integration"
        fi
    else
        print_warning "Starship configuration file not found, skipping"
    fi

    current_step=$((current_step + 1))
    print_step $current_step $total_steps "Setting up Neovim with LazyVim"
    install_lazyvim

    # Create wallpapers directory
    mkdir -p "$HOME/.config/hypr/wallpapers"

    # Final summary
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

    if [ "$SKIP_PACKAGES" = false ]; then
        draw_box_line "  ${FRAPPE_TEXT}1. Browse and select a wallpaper:${NC}" $box_width
        draw_box_line "     ${FRAPPE_BLUE}waypaper${NC}" $box_width
        draw_box_line "" $box_width
        draw_box_line "  ${FRAPPE_TEXT}2. Reload your shell to enable Starship prompt:${NC}" $box_width
        draw_box_line "     ${FRAPPE_BLUE}source ~/.bashrc${NC} ${FRAPPE_SUBTEXT1}(or ~/.zshrc)${NC}" $box_width
        draw_box_line "" $box_width
        draw_box_line "  ${FRAPPE_TEXT}3. Configure Firefox dark mode:${NC}" $box_width
        draw_box_line "     ${FRAPPE_SUBTEXT1}about:preferences → Website appearance → Dark${NC}" $box_width
        draw_box_line "" $box_width
        draw_box_line "  ${FRAPPE_TEXT}4. Log out and log back in to apply GTK theme${NC}" $box_width
    else
        draw_box_line "  ${FRAPPE_TEXT}1. Install packages: ${FRAPPE_BLUE}./install.sh${NC}" $box_width
        draw_box_line "  ${FRAPPE_TEXT}2. Set up wallpaper and theme${NC}" $box_width
    fi

    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_SAPPHIRE}Reload Hyprland:${NC} ${FRAPPE_BLUE}hyprctl reload${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
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
    local box_width=70
    echo ""
    draw_box "Hyprland Dotfiles Installer - Help" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Usage:${NC}" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./install.sh${NC} ${FRAPPE_TEXT}[OPTIONS]${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Options:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-h, --help${NC}           Show this help message" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-f, --force${NC}          Skip confirmation prompts" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-packages${NC}      Skip package installation" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--no-tui${NC}             Disable TUI welcome screen" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Default Behavior:${NC}" $box_width
    draw_box_line "    The installer will ${BOLD}automatically${NC} install:" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} All required packages (Arch Linux only)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} Configuration symlinks to ~/.config/" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} LazyVim with Catppuccin Frappe theme" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} Catppuccin wallpaper collection" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Package Categories:${NC}" $box_width
    draw_box_line "    ${FRAPPE_PEACH}core.txt${NC}             Required Hyprland packages" $box_width
    draw_box_line "    ${FRAPPE_PEACH}hypr-ecosystem.txt${NC}   Hypr tools (hyprpaper, hypridle)" $box_width
    draw_box_line "    ${FRAPPE_PEACH}theming.txt${NC}          Fonts, icons, cursors" $box_width
    draw_box_line "    ${FRAPPE_PEACH}development.txt${NC}      Python, C++, Node.js, Neovim" $box_width
    draw_box_line "    ${FRAPPE_PEACH}productivity.txt${NC}     LibreOffice, PDF viewer, etc." $box_width
    draw_box_line "    ${FRAPPE_PEACH}aur.txt${NC}              AUR packages (VS Code, themes)" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_YELLOW}⚠${NC}  Backups: ~/.config-backup-TIMESTAMP/" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""
}

# Parse arguments
FORCE=false
SKIP_PACKAGES=false
SHOW_TUI=true

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
        *)
            print_error "Unknown option: $1"
            echo ""
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
