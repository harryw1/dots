#!/usr/bin/env bash
# bootstrap.sh - Remote installation entry point for dotfiles
# Downloads and executes the full installer
#
# Usage:
#   # DEFAULT: TUI-only installation (headless compatible)
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash
#
#   # Interactive GUI selection
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --gui
#
#   # Full installation (all GUI components)
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --full
#
#   # Minimal (explicit, same as default)
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash -s -- --minimal
#
# With custom config:
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
#     CONFIG_URL=https://example.com/my-config.conf bash
#
# With other flags:
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
#     bash -s -- --full --force

set -e

# Configuration (can be overridden via environment variables)
REPO_URL="${REPO_URL:-https://github.com/harryw1/dots.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/share/dots}"
CONFIG_URL="${CONFIG_URL:-}" # Optional remote config file

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}●${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Banner
show_banner() {
  cat <<'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Hyprland Dotfiles Bootstrap                                  ║
║   Catppuccin Frappe Edition                                    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
  echo ""
}

# Check prerequisites
check_prerequisites() {
  print_info "Checking prerequisites..."

  # Check if running Arch Linux
  if [ ! -f /etc/arch-release ]; then
    print_error "This installer is designed for Arch Linux only"
    if [ -f /etc/os-release ]; then
      local distro
      distro=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
      print_info "Detected: $distro"
    fi
    exit 1
  fi

  # Check for git
  if ! command -v git &>/dev/null; then
    print_error "git is not installed"
    print_info "Install with: sudo pacman -S git"
    exit 1
  fi

  # Check for sudo
  if ! command -v sudo &>/dev/null; then
    print_error "sudo is not installed"
    print_info "Install with: su -c 'pacman -S sudo'"
    exit 1
  fi

  # Check for jq (needed for state management in the main installer)
  if ! command -v jq &>/dev/null; then
    print_warning "jq not found - installing for state management"
    if ! sudo pacman -S --noconfirm jq; then
      print_error "Failed to install jq"
      print_info "Install manually with: sudo pacman -S jq"
      exit 1
    fi
    print_success "Installed jq"
  else
    print_success "jq is available"
  fi

  # Check for gum (needed for TUI)
  if ! command -v gum &>/dev/null; then
    print_warning "gum not found - installing for interactive TUI"
    if ! sudo pacman -S --noconfirm gum; then
      print_error "Failed to install gum"
      print_info "Install manually with: sudo pacman -S gum"
      exit 1
    fi
    print_success "Installed gum"
  else
    print_success "gum is available"
  fi

  # Configure gum with Catppuccin Frappe
  export GUM_CONFIRM_PROMPT_FOREGROUND="#CA9EE6"
  export GUM_CONFIRM_SELECTED_BACKGROUND="#BABBF1"
  export GUM_CONFIRM_SELECTED_FOREGROUND="#303446"
  export GUM_CONFIRM_UNSELECTED_BACKGROUND="#303446"
  export GUM_CONFIRM_UNSELECTED_FOREGROUND="#C6D0F5"

  print_success "Prerequisites met"
}

# Validate sudo access
validate_sudo_access() {
  print_info "Validating sudo access..."

  # Try to validate sudo without prompting
  if sudo -n true 2>/dev/null; then
    print_success "Sudo access confirmed (cached credentials)"
    return 0
  fi

  # If not cached, provide guidance
  print_warning "Sudo authentication required"
  print_info ""
  print_info "Installation requires sudo access for package management."
  print_info ""
  print_info "To authenticate, run this command first:"
  print_info "  sudo -v"
  print_info ""
  print_info "Then re-run the bootstrap within 15 minutes while credentials are cached."
  print_info ""
  print_info "Alternatively, download and run locally:"
  print_info "  git clone -b $REPO_BRANCH $REPO_URL $INSTALL_DIR"
  print_info "  cd $INSTALL_DIR && ./install.sh"
  print_info ""

  return 1
}

# Clone repository
clone_repository() {
  print_info "Cloning dotfiles repository..."
  print_info "  URL: $REPO_URL"
  print_info "  Branch: $REPO_BRANCH"
  print_info "  Directory: $INSTALL_DIR"

  # Check if directory already exists
  if [ -d "$INSTALL_DIR" ]; then
    print_warning "Installation directory already exists: $INSTALL_DIR"

    # Auto-handle in non-interactive mode (piped input)
    if [ ! -t 0 ]; then
      print_info "Non-interactive mode: attempting to update existing repository"

      # Check if it's a valid git repository
      if [ -d "$INSTALL_DIR/.git" ]; then
        cd "$INSTALL_DIR"

        # Fetch latest changes
        print_info "Fetching latest changes..."
        if ! git fetch origin "$REPO_BRANCH" 2>/dev/null; then
          print_warning "Failed to fetch updates, using existing files"
          return 0
        fi

        # Check if there are local changes
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
          print_warning "Local changes detected, stashing before update..."
          git stash save "bootstrap auto-stash $(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
        fi

        # Pull latest changes
        print_info "Pulling latest changes..."
        if git pull origin "$REPO_BRANCH" 2>/dev/null; then
          print_success "Repository updated successfully"
        else
          print_warning "Failed to pull updates, using existing files"
        fi

        cd - > /dev/null
        return 0
      else
        print_warning "Existing directory is not a git repository"
        print_info "Removing and re-cloning..."
        rm -rf "$INSTALL_DIR"
      fi
    else
      # Interactive mode - ask user
      if gum confirm "Directory exists. Remove and re-clone?"; then
        rm -rf "$INSTALL_DIR"
        print_info "Removed existing installation"
      else
        print_info "Using existing installation directory"
        return 0
      fi
    fi
  fi

  # Clone the repository
  if ! git clone --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"; then
    print_error "Failed to clone repository"
    print_info "Check that the repository URL and branch are correct:"
    print_info "  URL: $REPO_URL"
    print_info "  Branch: $REPO_BRANCH"
    exit 1
  fi

  print_success "Repository cloned successfully"
}

# Download custom config if provided
download_config() {
  if [ -n "$CONFIG_URL" ]; then
    print_info "Downloading custom configuration..."

    if ! command -v curl &>/dev/null; then
      print_warning "curl not installed - cannot download custom config"
      print_info "Install curl or provide config manually: sudo pacman -S curl"
      return 0
    fi

    if curl -fsSL "$CONFIG_URL" -o "$INSTALL_DIR/install.conf"; then
      print_success "Configuration downloaded"
    else
      print_error "Failed to download configuration from $CONFIG_URL"
      print_warning "Continuing without custom config..."
    fi
  fi
}

# Run installation
run_installation() {
  print_info "Starting installation..."
  cd "$INSTALL_DIR"

  # Make install script executable
  chmod +x install.sh

  # Run installation with any passed arguments
  print_info "Running install.sh with arguments: $*"
  ./install.sh "$@"
}

# Install symlinks for convenience scripts
install_symlinks() {
  local target_dir="$HOME/.local/bin"
  print_info "Installing convenience scripts to $target_dir..."

  # Create target directory if it doesn't exist
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    print_info "Created directory: $target_dir"
  fi

  # Define scripts to symlink and their new names
  declare -A scripts=(
    ["manage.sh"]="dots-manage"
    ["install.sh"]="dots-install"
    ["update.sh"]="dots-update"
    ["uninstall.sh"]="dots-uninstall"
  )

  for script in "${!scripts[@]}"; do
    local source_file="$INSTALL_DIR/$script"
    local target_link="$target_dir/${scripts[$script]}"

    if [ -f "$source_file" ]; then
      # Make source executable
      chmod +x "$source_file"

      # Create or update symlink
      ln -sf "$source_file" "$target_link"
      print_success "Linked $target_link -> $source_file"
    else
      print_warning "Source script not found: $source_file"
    fi
  done
}

# Show usage information
show_usage() {
  cat <<'EOF'
Bootstrap Script Usage:

Basic installation:
  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

With environment variables:
  REPO_BRANCH=feature/test CONFIG_URL=https://example.com/config.conf \
    curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

With installation flags:
  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
    bash -s -- --skip-packages --dry-run

Environment Variables:
  REPO_URL       Repository URL (default: https://github.com/harryw1/dots.git)
  REPO_BRANCH    Branch to clone (default: main)
  INSTALL_DIR    Installation directory (default: ~/.local/share/dots)
  CONFIG_URL     URL to custom install.conf file (optional)

Installation Flags (passed after --):
  --help              Show installer help
  --dry-run           Show what would be done without doing it
  --skip-packages     Skip package installation
  --no-tui            Disable welcome screen
  --resume            Resume from last failed phase
  --reset             Reset state and start fresh
  --config FILE       Use custom configuration file

Behavior:
  - If installation directory exists, bootstrap will automatically pull latest
    changes from the repository (non-interactive mode only)
  - Local changes are automatically stashed before pulling updates
  - If git operations fail, installation continues with existing files

Examples:
  # Install from feature branch with dry-run
  REPO_BRANCH=feature/modular-installer \
    curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
    bash -s -- --dry-run

  # Install with custom config and skip packages
  CONFIG_URL=https://gist.githubusercontent.com/user/abc/raw/install.conf \
    curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
    bash -s -- --skip-packages

  # Force fresh installation (remove existing directory first)
  rm -rf ~/.local/share/dots
  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

EOF
}

# Main execution
main() {
  # Check for help flag
  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_usage
    exit 0
  fi

  show_banner
  check_prerequisites

  # Check if running in dry-run mode (skip sudo validation for dry-run)
  local skip_sudo=false
  for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
      skip_sudo=true
      break
    fi
  done

  # Validate sudo access unless in dry-run mode
  if [ "$skip_sudo" = false ]; then
    if ! validate_sudo_access; then
      exit 1
    fi
  else
    print_info "Skipping sudo validation (dry-run mode)"
  fi

  clone_repository
  download_config
  run_installation "$@"
  install_symlinks

  # Check if zsh was installed and remind about shell change
  if command -v zsh &>/dev/null; then
    local current_shell="${SHELL:-$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)}"
    if ! echo "$current_shell" | grep -q "zsh$"; then
      local zsh_path
      zsh_path="$(which zsh 2>/dev/null || command -v zsh)"
      if [ -n "$zsh_path" ]; then
        echo ""
        print_info "To set zsh as your default shell, run:"
        print_info "  chsh -s $zsh_path"
        print_info "The new shell will take effect after you log out and back in."
      fi
    fi
  fi

  print_success "Bootstrap complete!"
}

main "$@"
