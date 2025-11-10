# Migration Guide

This guide helps users migrate from the old monolithic `install.sh` to the new modular installation system.

## Overview

The dotfiles repository has been restructured to use a **modular, phase-based architecture** with state tracking and resume capability. The good news: **the new system is backward compatible** with existing usage patterns.

## What's Changed

### New Architecture

The old monolithic `install.sh` (~1000 lines) has been split into modular phases:

```
Old structure:              New structure:
install.sh                  install.sh (orchestrator)
  (all code)                install/
                            ├── lib/           (shared libraries)
                            ├── preflight/     (system preparation)
                            ├── packages/      (package installation)
                            ├── config/        (config deployment)
                            ├── services/      (service management)
                            └── post-install/  (final tasks)
```

### New Features

1. **State Tracking**: Progress saved to `~/.local/state/dots/install-state.json`
2. **Resume Capability**: `--resume` flag continues from last successful phase
3. **Comprehensive Logging**: All output saved to `~/.local/state/dots/logs/`
4. **Configuration Files**: `install.conf` for customization
5. **Remote Bootstrap**: Single-command installation via curl
6. **Dry Run Mode**: `--dry-run` previews changes without making them
7. **Better Error Recovery**: Clear error messages with recovery instructions

### Command Changes

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `./install.sh --packages-all` | `./install.sh` | Full installation is now default |
| `./install.sh --packages` | _Removed_ | Interactive selection removed; all packages installed by default |
| `./install.sh` | `./install.sh --skip-packages` | Config-only installation requires explicit flag |
| _N/A_ | `./install.sh --resume` | NEW: Resume from failure |
| _N/A_ | `./install.sh --reset` | NEW: Reset state and start fresh |
| _N/A_ | `./install.sh --dry-run` | NEW: Preview without executing |
| _N/A_ | `./install.sh --config FILE` | NEW: Use custom configuration |

## Migration Scenarios

### Scenario 1: Fresh Installation (New Users)

If you're doing a fresh installation, just use the new system:

```bash
# Clone repository
git clone https://github.com/harryw1/dots.git ~/.local/share/dots
cd ~/.local/share/dots

# Full installation
./install.sh
```

Or use the remote bootstrap:

```bash
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash
```

### Scenario 2: Existing Installation (Updating)

If you already have the dotfiles installed:

1. **Pull the latest changes**:
   ```bash
   cd ~/path/to/dots
   git pull origin main
   ```

2. **Your existing symlinks still work** - No action needed for configs

3. **Optional: Re-run installer to ensure everything is current**:
   ```bash
   ./install.sh --skip-packages  # Only update configs
   ```

### Scenario 3: Custom Workflows

If you had custom installation workflows, adapt them:

#### Old: Interactive package selection
```bash
# Old command (no longer exists)
./install.sh --packages
```

#### New: Use configuration file
```bash
# Create custom config
cp install.conf.example install.conf

# Edit install.conf to customize which packages to install
# Then run:
./install.sh --config install.conf
```

#### Old: Install everything automatically
```bash
# Old command
./install.sh --packages-all
```

#### New: This is now the default
```bash
# New command (same behavior)
./install.sh
```

#### Old: Config-only installation
```bash
# Old command
./install.sh
```

#### New: Use explicit flag
```bash
# New command
./install.sh --skip-packages
```

### Scenario 4: Automation/CI Workflows

If you used the installer in scripts or CI:

#### Old automation
```bash
./install.sh --packages-all
```

#### New automation
```bash
# Use --force to skip prompts
./install.sh --force

# Or use --dry-run for testing
./install.sh --dry-run --force
```

## Understanding State Management

### State File Location

`~/.local/state/dots/install-state.json`

Contains:
- Installation progress
- Completed phases
- Installed packages
- Deployed configs
- Enabled services

### Checking State

```bash
# View current state
cat ~/.local/state/dots/install-state.json | jq .

# Check completed phases
cat ~/.local/state/dots/install-state.json | jq .completed_phases
```

### Resetting State

If you want to start fresh:

```bash
# Reset state and reinstall
./install.sh --reset

# Or manually delete state
rm -rf ~/.local/state/dots/
```

## Understanding the New Logs

### Log Location

`~/.local/state/dots/logs/install-YYYYMMDD-HHMMSS.log`

### Viewing Logs

```bash
# List all logs
ls -lt ~/.local/state/dots/logs/

# View latest log
tail -f ~/.local/state/dots/logs/install-*.log

# View specific log
less ~/.local/state/dots/logs/install-20250110-120000.log
```

### Log Contents

Each log includes:
- System information (OS, kernel, architecture)
- Installation phases and timestamps
- Package installation details
- Configuration deployment
- Service setup
- Errors and warnings

## Using the Resume Feature

If installation fails, you can resume from where it left off:

```bash
# Installation failed due to network issue...
# Fix the network issue, then:
./install.sh --resume
```

The installer will:
1. Load the saved state
2. Show what was completed
3. Continue from the next phase
4. Skip already completed phases

## Configuration File System

### Creating a Configuration File

```bash
# Copy the example
cp install.conf.example install.conf

# Edit to customize
nano install.conf
```

### Example Customizations

```bash
# In install.conf

# Skip package installation
SKIP_PACKAGES=true

# Force mode (no prompts)
FORCE=true

# Disable TUI welcome screen
SHOW_TUI=false

# Feature flags
ENABLE_FINGERPRINT=true
ENABLE_TAILSCALE=false
```

### Using Configuration File

```bash
# Automatically loads install.conf if it exists
./install.sh

# Or specify a custom config
./install.sh --config my-config.conf
```

## Remote Bootstrap System

The new system supports remote installation:

```bash
# Basic installation
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash

# With custom branch
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  REPO_BRANCH=feature/my-feature bash

# With custom configuration
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  CONFIG_URL=https://example.com/my-config.conf bash

# Skip packages
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | \
  bash -s -- --skip-packages
```

## Troubleshooting Migration Issues

### Issue: "Command not found" or strange errors

**Cause**: Stale shell session or config cache

**Solution**:
```bash
# Reload shell configuration
source ~/.bashrc

# Or logout and login again
```

### Issue: State file corrupted

**Cause**: Interrupted installation or disk issues

**Solution**:
```bash
# Reset state and retry
./install.sh --reset
```

### Issue: Symlinks pointing to wrong location

**Cause**: Repository moved after initial installation

**Solution**:
```bash
# Remove old symlinks
./uninstall.sh

# Re-run installation from new location
./install.sh --skip-packages
```

### Issue: Packages not installing

**Cause**: State thinks packages already installed

**Solution**:
```bash
# Check state
cat ~/.local/state/dots/install-state.json | jq .installed_packages

# Reset and reinstall packages
./install.sh --reset
```

### Issue: Resume not working

**Cause**: State file missing or corrupted

**Solution**:
```bash
# Start fresh
rm -rf ~/.local/state/dots/
./install.sh
```

## Getting Help

If you encounter issues during migration:

1. **Check the logs**:
   ```bash
   less ~/.local/state/dots/logs/install-*.log
   ```

2. **Check the state**:
   ```bash
   cat ~/.local/state/dots/install-state.json | jq .
   ```

3. **Run dry-run to see what would happen**:
   ```bash
   ./install.sh --dry-run
   ```

4. **Try resetting and starting fresh**:
   ```bash
   ./install.sh --reset
   ```

5. **Open an issue** with:
   - Your log file
   - Your state file
   - Description of what went wrong

## Benefits of the New System

1. **Reliability**: Resume capability means failures aren't catastrophic
2. **Visibility**: State tracking and comprehensive logging
3. **Maintainability**: Modular code is easier to understand and modify
4. **Flexibility**: Configuration files and command-line options
5. **Debugging**: Detailed logs help diagnose issues
6. **Testing**: Dry-run mode previews changes safely
7. **Recovery**: Clear error messages with recovery instructions

## What Stays the Same

- **Configuration files**: Same locations, same formats
- **Symlink approach**: Configs still symlinked from repo to `~/.config/`
- **Package lists**: Same `packages/*.txt` organization
- **Catppuccin Frappe**: Same beautiful theming everywhere
- **Component READMEs**: Documentation structure unchanged
- **Backup system**: Still creates timestamped backups
- **Uninstall script**: `./uninstall.sh` works the same way

## Timeline

- **Old system**: Used until ~November 2024
- **New system**: Available from November 2024 onward
- **Backward compatibility**: Maintained indefinitely
- **Migration**: Optional but recommended

## FAQ

### Do I need to reinstall everything?

**No.** Your existing installation continues to work. The new system primarily affects how new installations and updates are performed.

### Will my configs be affected?

**No.** Configuration files remain in the same locations with the same formats. Symlinks are unchanged.

### Should I delete `~/.local/state/dots/`?

**Only if you want to start fresh.** The state directory is useful for tracking progress and resuming after failures.

### Can I still use the old command syntax?

**Partially.** Basic commands like `./install.sh` still work, but some flags like `--packages-all` and `--packages` have been removed.

### How do I go back to the old system?

**You can't.** The old monolithic script has been replaced. However, the new system maintains backward compatibility with old usage patterns.

### Will future updates require migration?

**Probably not.** The migration system (in `install/preflight/migrations.sh`) handles breaking changes automatically.

## Conclusion

The new modular system provides significant improvements in reliability, visibility, and maintainability while maintaining backward compatibility with existing installations.

**For most users**: Just `git pull` and continue using your dotfiles normally.

**For new installations**: Use the new `./install.sh` or bootstrap script.

**For custom workflows**: Adapt to new command-line flags or use configuration files.

---

**Questions?** Open an issue or check [CONTRIBUTING.md](CONTRIBUTING.md) for development details.
