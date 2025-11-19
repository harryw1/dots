#!/usr/bin/env bash

# manage.sh - TUI Management Utility for System Updates and Dotfiles
# Uses 'gum' for the interface.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check for gum
if ! command -v gum &> /dev/null; then
    echo -e "${BLUE}::${NC} ${YELLOW}gum${NC} is required for this script."
    read -p "Install gum? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! sudo pacman -S gum --noconfirm; then
            echo -e "${RED}Failed to install gum.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Aborting.${NC}"
        exit 1
    fi
fi

# Main Loop
while true; do
    # Clear screen for fresh look
    clear

    # Header
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Dotfiles Management Utility" \
        "System Update & Maintenance"

    echo ""

    CHOICE=$(gum choose \
        --cursor.foreground 212 \
        --header "Select an action" \
        "Update System (Pacman & AUR)" \
        "Update Dotfiles Repo" \
        "Optimize Mirrors" \
        "Clean Package Cache" \
        "Remove Orphaned Packages" \
        "Exit")

    case "$CHOICE" in
        "Update System (Pacman & AUR)")
            echo ""
            if gum confirm "Proceed with system update?"; then
                gum spin --spinner dot --title "Syncing databases..." -- sudo pacman -Sy

                # Official Packages
                echo -e "${BLUE}::${NC} Updating official packages..."
                if ! sudo pacman -Su; then
                    echo -e "${RED}System update failed.${NC}"
                    gum confirm "Press Enter to continue" || true
                fi

                # AUR
                if command -v yay &> /dev/null; then
                    echo -e "${BLUE}::${NC} Updating AUR packages (yay)..."
                    yay -Su
                elif command -v paru &> /dev/null; then
                    echo -e "${BLUE}::${NC} Updating AUR packages (paru)..."
                    paru -Su
                fi

                gum style --foreground 76 "System update complete!"
                sleep 2
            fi
            ;;

        "Update Dotfiles Repo")
            echo ""
            # Check status
            if [[ -n $(git status --porcelain) ]]; then
                gum style --foreground 196 "WARNING: You have local changes in your dotfiles repository."
                git status --short
                echo ""

                ACTION=$(gum choose --header "How to proceed?" "Cancel" "Stash changes & Update" "Attempt Merge (May conflict)")

                case "$ACTION" in
                    "Stash changes & Update")
                        gum spin --title "Stashing changes..." -- git stash
                        gum spin --title "Pulling updates..." -- git pull
                        if gum confirm "Restore stashed changes?"; then
                            if ! git stash pop; then
                                gum style --foreground 196 "Conflict detected during stash pop! Please resolve manually."
                            else
                                gum style --foreground 76 "Changes restored successfully."
                            fi
                        fi
                        ;;
                    "Attempt Merge (May conflict)")
                        git pull
                        ;;
                    "Cancel")
                        echo "Update cancelled."
                        ;;
                esac
            else
                gum spin --title "Pulling updates..." -- git pull
                gum style --foreground 76 "Dotfiles repository updated."
            fi
            sleep 2
            ;;

        "Optimize Mirrors")
            if ! command -v reflector &> /dev/null; then
                if gum confirm "Reflector not found. Install it?"; then
                    sudo pacman -S reflector --noconfirm
                else
                    continue
                fi
            fi

            if gum confirm "This will fetch the fastest mirrors. Continue?"; then
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
                gum spin --title "Finding fastest mirrors..." -- sudo reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
                gum style --foreground 76 "Mirrorlist updated."
            fi
            sleep 1
            ;;

        "Clean Package Cache")
             if command -v paccache &> /dev/null; then
                echo "Current cache size:"
                du -sh /var/cache/pacman/pkg/
                if gum confirm "Keep only last 3 versions?"; then
                    sudo paccache -rk 3
                    gum style --foreground 76 "Cache cleaned."
                fi
            else
                echo "paccache (pacman-contrib) not found."
            fi
            sleep 1
            ;;

        "Remove Orphaned Packages")
            ORPHANS=$(pacman -Qtdq || true)
            if [[ -z "$ORPHANS" ]]; then
                gum style --foreground 76 "No orphaned packages found."
            else
                echo "Orphaned packages:"
                echo "$ORPHANS"
                if gum confirm "Remove these packages?"; then
                    sudo pacman -Rns $ORPHANS
                    gum style --foreground 76 "Orphans removed."
                fi
            fi
            sleep 1
            ;;

        "Exit")
            echo "Goodbye!"
            exit 0
            ;;
    esac
done
