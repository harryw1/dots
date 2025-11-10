#!/usr/bin/env bash
# bootstrap.sh - Remote installation entry point for dotfiles
# Downloads and executes the full installer

set -e

# Configuration (can be overridden via environment variables)
REPO_URL="${REPO_URL:-https://www.github.com/harryw1/dots.git}"
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
        print_info "Install with: pacman -S sudo"
        exit 1
    fi

    print_success "Prerequisites met"
}

# Clone repository
clone_repository() {
    print_info "Cloning dotfiles repository..."
    print_info "  URL: $REPO_URL"
    print_info "  Branch: $REPO_BRANCH"
    print_info "  Directory: $INSTALL_DIR"

    # Check if directory already exists
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Installation directory already exists"
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
            print_info "Install curl or clone manually: sudo pacman -S curl"
            return 0
        fi

        if curl -fsSL "$CONFIG_URL" -o "$INSTALL_DIR/install.conf"; then
            print_success "Configuration downloaded"
        else
            print_error "Failed to download configuration from $CONFIG_URL"
            exit 1
        fi
    fi
}

# Run installation
run_installation() {
    print_info "Starting installation..."
    echo ""

    cd "$INSTALL_DIR"

    # Make install script executable
    chmod +x install.sh

    # Run installation with any passed arguments
    ./install.sh "$@"
}

# Show usage
show_usage() {
    echo ""
    echo "Dotfiles Bootstrap Script"
    echo ""
    echo "Usage:"
    echo "  bash <(curl -sL URL) [INSTALL_OPTIONS]"
    echo ""
    echo "Environment Variables:"
    echo "  REPO_URL       Repository URL (default: https://www.github.com/harryw1/dots.git)"
    echo "  REPO_BRANCH    Branch to clone (default: main)"
    echo "  INSTALL_DIR    Installation directory (default: ~/.local/share/dots)"
    echo "  CONFIG_URL     URL to custom config file (optional)"
    echo ""
    echo "Examples:"
    echo "  # Basic installation"
    echo "  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash"
    echo ""
    echo "  # Install from feature branch"
    echo "  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \\"
    echo "    REPO_BRANCH=feature/modular-installer bash"
    echo ""
    echo "  # With custom config"
    echo "  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \\"
    echo "    CONFIG_URL=https://example.com/my-config.conf bash"
    echo ""
    echo "  # Skip package installation"
    echo "  curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \\"
    echo "    bash -s -- --skip-packages"
    echo ""
}

# Main execution
main() {
    # Handle help flag
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi

    echo ""
    print_info "Dotfiles Bootstrap Script"
    echo ""

    check_prerequisites
    clone_repository
    download_config
    run_installation "$@"
}

main "$@"
