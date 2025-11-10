# Contributing to Hyprland Dotfiles

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Architecture Overview](#architecture-overview)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Adding New Features](#adding-new-features)

## Getting Started

### Prerequisites

- Arch Linux system (or VM for testing)
- Git
- Basic understanding of Bash scripting
- Familiarity with Hyprland and Wayland compositors (for config changes)

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the guidelines below
4. **Test thoroughly** on a clean system (VM recommended)
5. **Submit a pull request**

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/dots.git
cd dots

# Add upstream remote
git remote add upstream https://github.com/harryw1/dots.git

# Keep your fork in sync
git fetch upstream
git merge upstream/main
```

### Testing Environment

For safe testing, use a VM or test system:

```bash
# Install in dry-run mode to preview changes
./install.sh --dry-run

# Test with state tracking
./install.sh --force

# Verify resume capability
# (interrupt installation and run)
./install.sh --resume

# Check logs
tail -f ~/.local/state/dots/logs/install-*.log
```

## Architecture Overview

The repository uses a **modular, phase-based architecture**:

```
install/
├── lib/                    # Core libraries (sourced first)
│   ├── colors.sh              # Catppuccin Frappe color definitions
│   ├── tui.sh                 # TUI functions (draw_box, progress bars)
│   ├── utils.sh               # Common utilities
│   ├── logging.sh             # Logging system
│   └── state.sh               # State management
│
├── preflight/              # Phase 1: System preparation
├── packages/               # Phase 2: Package installation
├── config/                 # Phase 3: Configuration deployment
├── services/               # Phase 4: Service management
└── post-install/           # Phase 5: Final tasks
```

### Key Principles

1. **Modularity**: Each script handles one concern. Keep functions focused and small.

2. **Idempotency**: All operations should be safe to run multiple times. Check state before making changes.

3. **State Tracking**: Use state management functions for tracking progress:
   ```bash
   state_mark_phase_complete "phase_name"
   state_mark_phase_failed "phase_name"
   ```

4. **Comprehensive Logging**: Log all important operations:
   ```bash
   log_phase_start "Phase Name"
   log_info "Informational message"
   log_error "Error message"
   log_phase_end "Phase Name" "success|failure"
   ```

5. **Error Handling**: Provide clear error messages and recovery instructions:
   ```bash
   if ! some_operation; then
       print_error "Operation failed"
       print_info "Try: recovery command"
       return 1
   fi
   ```

6. **Catppuccin Frappe Theming**: All TUI elements use the Frappe color palette from `install/lib/colors.sh`.

## Coding Standards

### Bash Style Guide

```bash
#!/usr/bin/env bash
# script-name.sh - Brief description
# Part of the modular dotfiles installation system

# Use strict error handling (unless intentionally disabled)
set -euo pipefail

# Function naming: lowercase with underscores
function_name() {
    local var_name="value"  # Use local for function variables

    # Check prerequisites
    if ! command -v required_tool &> /dev/null; then
        print_error "required_tool not found"
        return 1
    fi

    # Clear success/failure indication
    return 0
}

# Constants: UPPERCASE
readonly CONSTANT_VALUE="value"

# Variables: lowercase with underscores
variable_name="value"

# Use [[ ]] instead of [ ]
if [[ "$variable" == "value" ]]; then
    echo "Good"
fi

# Quote variables unless intentionally word-splitting
echo "$variable"
echo "${array[@]}"

# Use printf for complex output
printf "%s: %s\\n" "$key" "$value"
```

### File Organization

- **One concern per file**: Don't mix package installation with config deployment
- **Logical grouping**: Related functions go in the same file
- **Clear naming**: File names should indicate their purpose
- **Header comments**: Every script should have a header explaining its purpose

### Documentation

```bash
# Brief one-line description
#
# Detailed description if needed
# Can span multiple lines
#
# Arguments:
#   $1 - Description of first argument
#   $2 - Description of second argument
#
# Returns:
#   0 - Success
#   1 - Failure with error message
#
# Example:
#   function_name "arg1" "arg2"
function_name() {
    # Implementation
}
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code restructuring without behavior change
- `test`: Testing additions or modifications
- `chore`: Maintenance tasks (dependency updates, etc.)
- `style`: Code style changes (formatting, no logic change)

### Scope

The scope indicates which part of the codebase is affected:

- `install`: Main installer orchestrator
- `preflight`: Preflight checks and preparation
- `packages`: Package installation modules
- `config`: Configuration deployment modules
- `services`: Service management modules
- `post-install`: Post-installation tasks
- `lib`: Library modules (colors, TUI, logging, state, utils)
- `docs`: Documentation
- `ci`: CI/CD and testing

### Examples

```
feat(packages): Add support for custom AUR helper

Allow users to specify their preferred AUR helper (yay, paru, pikaur)
in install.conf. Defaults to yay if not specified.

Closes #123

---

fix(state): Handle corrupted state file gracefully

If the state file is corrupted or malformed, reset it instead of
failing. Print a warning and continue with fresh installation.

Fixes #456

---

docs(readme): Update installation instructions

- Document new --resume flag
- Add troubleshooting section for state management
- Update architecture diagram

---

refactor(config): Extract symlink creation to shared function

Move symlink creation logic from individual config modules to
install/lib/utils.sh for consistency and reusability.
```

### Commit Best Practices

- **One logical change per commit**: Don't mix unrelated changes
- **Atomic commits**: Each commit should leave the codebase in a working state
- **Clear, descriptive messages**: Future contributors should understand why the change was made
- **Reference issues**: Use `Closes #123` or `Fixes #456` in commit footer

## Testing

### Pre-submission Checklist

Before submitting a PR, verify:

- [ ] Code follows style guidelines
- [ ] All functions have documentation comments
- [ ] Error handling is comprehensive
- [ ] Logging is appropriate
- [ ] State tracking is implemented (if applicable)
- [ ] Changes are idempotent (safe to run multiple times)
- [ ] Tested on a clean Arch Linux system
- [ ] Dry-run mode works correctly
- [ ] Resume capability works (if modifying phases)
- [ ] Documentation is updated (README, CLAUDE.md if needed)
- [ ] Commit messages follow guidelines
- [ ] No breaking changes (or clearly documented)

### Testing Scenarios

1. **Fresh Installation**:
   ```bash
   ./install.sh --force
   ```

2. **Config-Only Installation**:
   ```bash
   ./install.sh --skip-packages
   ```

3. **Dry Run**:
   ```bash
   ./install.sh --dry-run
   ```

4. **Resume After Failure**:
   ```bash
   # Simulate failure (Ctrl+C during installation)
   ./install.sh --resume
   ```

5. **Custom Configuration**:
   ```bash
   cp install.conf.example test.conf
   # Edit test.conf
   ./install.sh --config test.conf
   ```

6. **Bootstrap Script**:
   ```bash
   # Test remote installation
   bash bootstrap.sh
   ```

## Pull Request Process

1. **Update documentation** if you've made changes to:
   - Installation process
   - Command-line options
   - Configuration file format
   - Architecture or design

2. **Update CHANGELOG** (if exists) with your changes

3. **Ensure CI passes** (if CI is set up)

4. **Request review** from maintainers

5. **Address feedback** promptly and professionally

6. **Squash commits** if requested (keep history clean)

### PR Description Template

```markdown
## Description

Brief description of what this PR does

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update

## Testing

Describe how you tested your changes:
- [ ] Tested on clean Arch Linux VM
- [ ] Tested fresh installation
- [ ] Tested resume capability
- [ ] Tested dry-run mode
- [ ] Tested with custom config

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Testing checklist completed

## Screenshots (if applicable)

Add screenshots of TUI changes, etc.
```

## Adding New Features

### Adding a New Phase

1. **Create the phase script** in the appropriate directory:
   ```bash
   touch install/services/new-service.sh
   ```

2. **Implement the phase function**:
   ```bash
   #!/usr/bin/env bash
   # new-service.sh - Setup new service
   # Part of the modular dotfiles installation system

   setup_new_service() {
       log_info "Setting up new service..."

       # Implementation

       log_info "New service setup complete"
   }
   ```

3. **Source the script in install.sh**:
   ```bash
   # In install.sh, add:
   source "$SCRIPT_DIR/install/services/new-service.sh"
   ```

4. **Call the function in the appropriate phase**:
   ```bash
   # In setup_services() function:
   setup_new_service
   ```

5. **Update documentation**:
   - Add to README.md architecture section
   - Add to CLAUDE.md
   - Update this CONTRIBUTING.md if needed

### Adding a New Package Category

1. **Create package list file**:
   ```bash
   touch packages/new-category.txt
   ```

2. **Add packages** (one per line, comments with #):
   ```
   # New Category Packages
   package1
   package2
   ```

3. **Create installation script**:
   ```bash
   touch install/packages/new-category.sh
   ```

4. **Implement installation function**:
   ```bash
   install_new_category_packages() {
       print_info "Installing new category packages..."
       install_package_file "$SCRIPT_DIR/packages/new-category.txt"
   }
   ```

5. **Source and call** in install.sh as shown above

### Adding Configuration Files

1. **Add config to repository**:
   ```bash
   mkdir -p new-app/
   # Add config files
   ```

2. **Create deployment script**:
   ```bash
   touch install/config/new-app.sh
   ```

3. **Implement deployment function**:
   ```bash
   deploy_new_app_config() {
       local src="$SCRIPT_DIR/new-app"
       local dest="$HOME/.config/new-app"

       print_info "Deploying new-app configuration..."

       # Backup existing config
       backup_if_exists "$dest"

       # Create symlink
       ln -sf "$src" "$dest"

       log_info "new-app config deployed"
   }
   ```

4. **Source and call** in install.sh

5. **Add README** explaining the configuration:
   ```bash
   touch new-app/README.md
   ```

## Questions?

- Open an issue for general questions
- Join discussions in existing issues/PRs
- Check [CLAUDE.md](CLAUDE.md) for architecture details
- Read through existing code for examples

## Code of Conduct

- Be respectful and professional
- Provide constructive feedback
- Help others learn and improve
- Focus on what's best for the project

---

Thank you for contributing! 🎉
