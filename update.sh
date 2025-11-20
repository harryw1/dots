#!/usr/bin/env bash

# System Update Script
# Updates packages from all package managers (pacman, AUR)

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

# Terminal width for formatting
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

# Source theme configuration if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh" ]; then
    # Fallback for installed location
    source "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh"
fi

# Use the shared TUI functions if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/install/lib/tui.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/install/lib/tui.sh"
else
    # Basic Fallback if TUI lib not found (should not happen in repo)
    print_info() { echo "● $1"; }
    print_success() { echo "✓ $1"; }
    print_warning() { echo "⚠ $1"; }
    print_error() { echo "✗ $1"; }
    print_step() { echo "Step $1/$2: $3"; }
    draw_box() { gum style --border double --padding "1 2" "$1"; }
    draw_box_line() { echo "$1"; }
    draw_box_bottom() { echo ""; }
fi

# Set up error trap
trap 'echo ""; print_error "Update failed at line $LINENO"; echo "Command: $BASH_COMMAND"; exit 1' ERR

# Check if running Arch Linux
is_arch_linux() {
    [ -f /etc/arch-release ]
}

# Update mirrorlist
update_mirrorlist() {
    print_info "Checking mirrorlist..."

    if [ "$AUTO_YES" = true ] || [ "$SKIP_MIRRORLIST" = true ]; then
        print_info "Skipping mirrorlist update"
        return 0
    fi

    echo ""
    if ! gum confirm "Update mirrorlist for faster downloads?"; then
        print_info "Skipping mirrorlist update"
        return 0
    fi

    # Check if reflector is installed
    if ! command -v reflector &> /dev/null; then
        print_info "Installing reflector..."
        if ! sudo pacman -S --noconfirm reflector; then
            print_warning "Could not install reflector, skipping mirrorlist update"
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
}

# Sync package databases
sync_databases() {
    print_info "Syncing package databases..."

    if ! sudo pacman -Syy --noconfirm; then
        print_error "Failed to sync package databases"
        return 1
    fi

    print_success "Package databases synced"
}

# Check for updates
check_updates() {
    print_info "Checking for available updates..."

    # Check official repositories
    local official_updates=$(checkupdates 2>/dev/null | wc -l || echo "0")

    # Check AUR updates
    local aur_updates=0
    if command -v yay &> /dev/null; then
        aur_updates=$(yay -Qua 2>/dev/null | wc -l || echo "0")
    elif command -v paru &> /dev/null; then
        aur_updates=$(paru -Qua 2>/dev/null | wc -l || echo "0")
    fi

    local total_updates=$((official_updates + aur_updates))

    echo ""
    gum style --border rounded --padding "1 2" --width 50 \
        "Update Summary" \
        "" \
        "Official repository packages: $official_updates" \
        "AUR packages: $aur_updates" \
        "" \
        "Total updates available: $total_updates"
    echo ""

    if [ "$total_updates" -eq 0 ]; then
        print_success "System is already up to date!"
        return 1
    fi

    return 0
}

# Update official packages
update_official() {
    print_info "Updating official repository packages..."

    if ! sudo pacman -Syu --noconfirm; then
        print_error "Failed to update official packages"
        return 1
    fi

    print_success "Official packages updated"
}

# Update AUR packages
update_aur() {
    # Check for AUR helper
    local aur_helper=""
    if command -v yay &> /dev/null; then
        aur_helper="yay"
    elif command -v paru &> /dev/null; then
        aur_helper="paru"
    else
        print_warning "No AUR helper found (yay or paru)"
        print_info "Skipping AUR package updates"
        return 0
    fi

    print_info "Updating AUR packages using $aur_helper..."

    if ! $aur_helper -Syu --noconfirm; then
        print_warning "Some AUR packages may have failed to update"
        return 1
    fi

    print_success "AUR packages updated"
}

# Clean package cache
clean_cache() {
    if [ "$AUTO_YES" = true ] || [ "$SKIP_CLEAN" = true ]; then
        print_info "Skipping package cache cleanup"
        return 0
    fi

    echo ""
    if ! gum confirm "Clean the package cache? (Removes old versions)"; then
        print_info "Skipping cache cleanup"
        return 0
    fi

    print_info "Cleaning package cache..."

    # Keep last 3 versions of each package
    if command -v paccache &> /dev/null; then
        sudo paccache -rk 3
        print_success "Package cache cleaned (kept last 3 versions)"
    else
        print_warning "paccache not found - install 'pacman-contrib' for cache cleaning"
    fi
}

# Remove orphaned packages
remove_orphans() {
    if [ "$AUTO_YES" = true ] || [ "$SKIP_ORPHANS" = true ]; then
        print_info "Skipping orphan removal"
        return 0
    fi

    # Check for orphaned packages
    local orphans=$(pacman -Qtdq 2>/dev/null)

    if [ -z "$orphans" ]; then
        print_success "No orphaned packages found"
        return 0
    fi

    local orphan_count=$(echo "$orphans" | wc -l)

    echo ""
    gum style --foreground "$COLOR_YELLOW" "Found $orphan_count orphaned packages"
    echo "$orphans"
    echo ""

    if ! gum confirm "Remove orphaned packages?"; then
        print_info "Keeping orphaned packages"
        return 0
    fi

    print_info "Removing orphaned packages..."
    if sudo pacman -Rns --noconfirm $orphans; then
        print_success "Removed $orphan_count orphaned packages"
    else
        print_warning "Failed to remove some orphaned packages"
    fi
}

# Check for .pacnew files
check_pacnew() {
    print_info "Checking for .pacnew configuration files..."

    local pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null)

    if [ -z "$pacnew_files" ]; then
        print_success "No .pacnew files found"
        return 0
    fi

    local pacnew_count=$(echo "$pacnew_files" | wc -l)

    echo ""
    print_warning "Found ${pacnew_count} .pacnew configuration files!"
    echo -e "${FRAPPE_SUBTEXT1}(These are new default configs that need manual review)${NC}"
    echo ""
    echo -e "${FRAPPE_SUBTEXT1}.pacnew files:${NC}"
    echo "$pacnew_files" | sed "s/^/  ${FRAPPE_YELLOW}• ${NC}/"
    echo ""
    print_info "Review these files with: ${FRAPPE_BLUE}sudo pacdiff${NC}"
    echo ""
}

# Show help
show_help() {
    local box_width=70
    echo ""
    draw_box "System Update & Sync - Help" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Usage:${NC}" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./update.sh${NC} ${FRAPPE_TEXT}[OPTIONS]${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Options:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-h, --help${NC}              Show this help message" $box_width
    draw_box_line "    ${FRAPPE_GREEN}-y, --yes${NC}               Skip all confirmation prompts" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--no-tui${NC}                Disable TUI welcome screen" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-mirrorlist${NC}       Skip mirrorlist update prompt" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-clean${NC}            Skip cache cleanup prompt" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--skip-orphans${NC}          Skip orphan removal prompt" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--aur-only${NC}              Only update AUR packages" $box_width
    draw_box_line "    ${FRAPPE_GREEN}--official-only${NC}         Only update official packages" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}What Gets Updated:${NC}" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} Official repository packages (pacman -Syu)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} AUR packages (yay/paru -Syu)" $box_width
    draw_box_line "    ${FRAPPE_GREEN}•${NC} Package databases (pacman -Syy)" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Optional Maintenance:${NC}" $box_width
    draw_box_line "    ${FRAPPE_YELLOW}•${NC} Update mirrorlist (for faster downloads)" $box_width
    draw_box_line "    ${FRAPPE_YELLOW}•${NC} Clean package cache (free up space)" $box_width
    draw_box_line "    ${FRAPPE_YELLOW}•${NC} Remove orphaned packages (cleanup)" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_MAUVE}${BOLD}Examples:${NC}" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./update.sh${NC}                      # Full update with prompts" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./update.sh -y${NC}                   # Auto-yes all prompts" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./update.sh --aur-only${NC}           # Only AUR packages" $box_width
    draw_box_line "    ${FRAPPE_BLUE}./update.sh --skip-clean${NC}         # Skip cache cleanup" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""
}

# Main update process
main() {
    local total_steps=7
    local current_step=0

    # Show welcome screen
    if [ "$SHOW_TUI" = true ]; then
        # Use Gum style welcome
        clear
        gum style \
            --foreground "$COLOR_MAUVE" --border double --border-foreground "$COLOR_LAVENDER" --padding "1 2" \
            "System Update & Sync" \
            "Catppuccin Frappe Theme"

        echo ""
        gum style --foreground "$COLOR_PEACH" "This updater will:"
        gum style --foreground "$COLOR_GREEN" "  ✓ Sync package databases"
        gum style --foreground "$COLOR_GREEN" "  ✓ Update official repository packages"
        gum style --foreground "$COLOR_GREEN" "  ✓ Update AUR packages"
        gum style --foreground "$COLOR_GREEN" "  ✓ Clean package cache (optional)"
        gum style --foreground "$COLOR_GREEN" "  ✓ Remove orphaned packages (optional)"
        echo ""

        gum confirm "Start system update?" || exit 0
        echo ""
        print_info "Starting system update..."
        echo ""
    fi

    # Check if Arch Linux
    if ! is_arch_linux; then
        print_error "This script requires Arch Linux"
        exit 1
    fi

    # Update mirrorlist (optional)
    if [ "$SKIP_MIRRORLIST" = false ]; then
        current_step=$((current_step + 1))
        print_step $current_step $total_steps "Mirrorlist optimization"
        update_mirrorlist
    fi

    # Sync databases
    current_step=$((current_step + 1))
    print_step $current_step $total_steps "Syncing package databases"
    sync_databases

    # Check for updates
    current_step=$((current_step + 1))
    print_step $current_step $total_steps "Checking for updates"
    if ! check_updates; then
        # No updates available
        echo ""
        if [ "$SKIP_CLEAN" = false ] || [ "$SKIP_ORPHANS" = false ]; then
            if ! gum confirm "System up to date. Perform maintenance anyway?"; then
                print_info "Update complete - system already up to date"
                exit 0
            fi
        else
            print_info "Update complete - system already up to date"
            exit 0
        fi
    fi

    # Update official packages
    if [ "$AUR_ONLY" = false ]; then
        current_step=$((current_step + 1))
        print_step $current_step $total_steps "Updating official packages"
        update_official
    fi

    # Update AUR packages
    if [ "$OFFICIAL_ONLY" = false ]; then
        current_step=$((current_step + 1))
        print_step $current_step $total_steps "Updating AUR packages"
        update_aur
    fi

    # Clean cache (optional)
    if [ "$SKIP_CLEAN" = false ]; then
        current_step=$((current_step + 1))
        print_step $current_step $total_steps "Package cache cleanup"
        clean_cache
    fi

    # Remove orphans (optional)
    if [ "$SKIP_ORPHANS" = false ]; then
        current_step=$((current_step + 1))
        print_step $current_step $total_steps "Orphaned package removal"
        remove_orphans
    fi

    # Check for .pacnew files
    current_step=$((current_step + 1))
    print_step $current_step $total_steps "Configuration file check"
    check_pacnew

    # Final summary
    echo ""
    echo ""
    local box_width=70
    draw_box "Update Complete!" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_GREEN}✓${NC} Package databases synced" $box_width

    if [ "$OFFICIAL_ONLY" = false ] && [ "$AUR_ONLY" = false ]; then
        draw_box_line "  ${FRAPPE_GREEN}✓${NC} All packages updated" $box_width
    elif [ "$AUR_ONLY" = true ]; then
        draw_box_line "  ${FRAPPE_GREEN}✓${NC} AUR packages updated" $box_width
    elif [ "$OFFICIAL_ONLY" = true ]; then
        draw_box_line "  ${FRAPPE_GREEN}✓${NC} Official packages updated" $box_width
    fi

    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_PEACH}Recommendations:${NC}" $box_width
    draw_box_line "" $box_width
    draw_box_line "  ${FRAPPE_TEXT}• Restart services: ${FRAPPE_BLUE}systemctl list-units | grep -i failed${NC}" $box_width
    draw_box_line "  ${FRAPPE_TEXT}• Review .pacnew files: ${FRAPPE_BLUE}sudo pacdiff${NC}" $box_width
    draw_box_line "  ${FRAPPE_TEXT}• Consider rebooting for kernel updates" $box_width
    draw_box_line "" $box_width
    draw_box_bottom $box_width
    echo ""
}

# Parse arguments
AUTO_YES=false
SHOW_TUI=true
SKIP_MIRRORLIST=false
SKIP_CLEAN=false
SKIP_ORPHANS=false
AUR_ONLY=false
OFFICIAL_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --no-tui)
            SHOW_TUI=false
            shift
            ;;
        --skip-mirrorlist)
            SKIP_MIRRORLIST=true
            shift
            ;;
        --skip-clean)
            SKIP_CLEAN=true
            shift
            ;;
        --skip-orphans)
            SKIP_ORPHANS=true
            shift
            ;;
        --aur-only)
            AUR_ONLY=true
            shift
            ;;
        --official-only)
            OFFICIAL_ONLY=true
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

# Check for conflicting options
if [ "$AUR_ONLY" = true ] && [ "$OFFICIAL_ONLY" = true ]; then
    print_error "Cannot use --aur-only and --official-only together"
    exit 1
fi

# Run update
main
