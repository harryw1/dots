#!/usr/bin/env bash

# manage.sh - TUI Management Utility for System Updates and Dotfiles
# Uses 'gum' for the interface.

set -e

# Source theme configuration if available
if [ -f "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/install/lib/gum_theme.sh"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh" ]; then
    # Fallback for installed location
    source "$(dirname "${BASH_SOURCE[0]}")/../lib/gum_theme.sh"
fi

# Colors (fallback if not sourced)
COLOR_RED="${COLOR_RED:-#E78284}"
COLOR_GREEN="${COLOR_GREEN:-#A6D189}"
COLOR_YELLOW="${COLOR_YELLOW:-#E5C890}"
COLOR_BLUE="${COLOR_BLUE:-#8CAAEE}"
COLOR_MAUVE="${COLOR_MAUVE:-#CA9EE6}"
COLOR_LAVENDER="${COLOR_LAVENDER:-#BABBF1}"

# Check for gum
if ! command -v gum &> /dev/null; then
    echo "gum is required for this script."
    echo "Installing gum..."
    if ! sudo pacman -S gum --noconfirm; then
        echo "Failed to install gum."
        exit 1
    fi
fi

# Main Loop
while true; do
    # Clear screen for fresh look
    clear

    # Header
    gum style \
        --foreground "$COLOR_MAUVE" --border-foreground "$COLOR_LAVENDER" --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Dotfiles Management Utility" \
        "System Update & Maintenance"

    echo ""

    CHOICE=$(gum choose \
        --cursor.foreground "$COLOR_MAUVE" \
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
                gum style --foreground "$COLOR_BLUE" ":: Updating official packages..."
                if ! sudo pacman -Su --noconfirm; then
                    gum style --foreground "$COLOR_RED" "System update failed."
                    gum confirm "Press Enter to continue" || true
                fi

                # AUR
                if command -v yay &> /dev/null; then
                    gum style --foreground "$COLOR_BLUE" ":: Updating AUR packages (yay)..."
                    yay -Su --noconfirm
                elif command -v paru &> /dev/null; then
                    gum style --foreground "$COLOR_BLUE" ":: Updating AUR packages (paru)..."
                    paru -Su --noconfirm
                fi

                gum style --foreground "$COLOR_GREEN" "System update complete!"
                sleep 2
            fi
            ;;

        "Update Dotfiles Repo")
            echo ""
            # Check status
            if [[ -n $(git status --porcelain) ]]; then
                gum style --foreground "$COLOR_RED" "WARNING: You have local changes in your dotfiles repository."
                git status --short
                echo ""

                ACTION=$(gum choose --header "How to proceed?" "Cancel" "Stash changes & Update" "Attempt Merge (May conflict)")

                case "$ACTION" in
                    "Stash changes & Update")
                        gum spin --title "Stashing changes..." -- git stash
                        gum spin --title "Pulling updates..." -- git pull
                        if gum confirm "Restore stashed changes?"; then
                            if ! git stash pop; then
                                gum style --foreground "$COLOR_RED" "Conflict detected during stash pop! Please resolve manually."
                            else
                                gum style --foreground "$COLOR_GREEN" "Changes restored successfully."
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
                gum style --foreground "$COLOR_GREEN" "Dotfiles repository updated."
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
                gum style --foreground "$COLOR_GREEN" "Mirrorlist updated."
            fi
            sleep 1
            ;;

        "Clean Package Cache")
             if command -v paccache &> /dev/null; then
                echo "Current cache size:"
                du -sh /var/cache/pacman/pkg/
                if gum confirm "Keep only last 3 versions?"; then
                    sudo paccache -rk 3
                    gum style --foreground "$COLOR_GREEN" "Cache cleaned."
                fi
            else
                echo "paccache (pacman-contrib) not found."
            fi
            sleep 1
            ;;

        "Remove Orphaned Packages")
            ORPHANS=$(pacman -Qtdq || true)
            if [[ -z "$ORPHANS" ]]; then
                gum style --foreground "$COLOR_GREEN" "No orphaned packages found."
            else
                echo "Orphaned packages:"
                echo "$ORPHANS"
                if gum confirm "Remove these packages?"; then
                    sudo pacman -Rns $ORPHANS --noconfirm
                    gum style --foreground "$COLOR_GREEN" "Orphans removed."
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
