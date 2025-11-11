#!/usr/bin/env bash
# bootstrap.sh - Remote installation entry point for dotfiles
# Downloads and executes the full installer
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash
#
# With custom config:
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
#     CONFIG_URL=https://example.com/my-config.conf bash
#
# With installation flags:
#   curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
#     bash -s -- --skip-packages --dry-run

set -e

# Configuration (can be overridden via environment variables)
REPO_URL="${REPO_URL:-https://github.com/harryw1/dots.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/share/dots}"
CONFIG_URL="${CONFIG_URL:-}"  # Optional remote config file

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
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   Hyprland Dotfiles Bootstrap                                 ║
║   Catppuccin Frappe Edition                                   ║
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
            local distro=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
            print_info "Detected: $distro"
        fi
        exit 1
    fi

    # Check for git
    if ! command -v git &> /dev/null; then
        print_error "git is not installed"
        print_info "Install with: sudo pacman -S git"
        exit 1
    fi

    # Check for sudo
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is not installed"
        print_info "Install with: su -c 'pacman -S sudo'"
        exit 1
    fi

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
        read -p "Remove and re-clone? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            print_info "Removed existing installation"
        else
            print_info "Using existing installation directory"
            return 0
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

        if ! command -v curl &> /dev/null; then
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

# Show usage information
show_usage() {
    cat << 'EOF'
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

Examples:
  # Install from feature branch with dry-run
  REPO_BRANCH=feature/modular-installer \
    curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
    bash -s -- --dry-run

  # Install with custom config and skip packages
  CONFIG_URL=https://gist.githubusercontent.com/user/abc/raw/install.conf \
    curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
    bash -s -- --skip-packages

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

    print_success "Bootstrap complete!"
}

main "$@"
