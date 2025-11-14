# Zsh Migration Plan

## Overview

This document outlines the plan to migrate the dotfiles repository from bash to zsh as the primary shell, while maintaining backward compatibility and ensuring all existing features work correctly.

## Goals

1. ✅ Migrate all bash configurations to zsh
2. ✅ Maintain backward compatibility (bash configs still work)
3. ✅ Preserve all existing features (Starship, fzf, Catppuccin colors, etc.)
4. ✅ Update installer to support zsh
5. ✅ Update documentation
6. ✅ Enable zsh menu selection (scrollable completion lists)

## Phase 1: Preparation & Analysis

### 1.1 Current Bash Dependencies

**Files to migrate:**
- `bash/` directory → `zsh/` directory
- `install/config/bash.sh` → `install/config/zsh.sh`
- `.bashrc` references → `.zshrc`
- `.bash_profile` → `.zprofile` (zsh equivalent)

**Bash-specific features:**
- `bash-completion` → zsh completion system (built-in)
- `bash_completion.sh` → zsh completion configuration
- `fzf_integration.sh` → needs zsh-specific paths
- Aliases (`.bash_aliases`) → compatible with zsh

### 1.2 Compatibility Check

**What works in both shells:**
- ✅ Aliases (`.bash_aliases` can be sourced in zsh)
- ✅ Starship prompt (works with both)
- ✅ fzf (has zsh support)
- ✅ Catppuccin colors (LS_COLORS works in both)
- ✅ Environment variables
- ✅ Functions (mostly compatible)

**What needs changes:**
- ⚠️ Completion system (bash-completion → zsh completion)
- ⚠️ Key bindings (bash `bind` → zsh `bindkey`)
- ⚠️ Shell-specific syntax (minimal differences)
- ⚠️ Installer scripts (detect shell, install accordingly)

## Phase 2: Create Zsh Configuration Files

### 2.1 Directory Structure

```
zsh/
├── README.md                    # Zsh configuration documentation
├── .zsh_aliases                 # Aliases (compatible with bash)
├── zsh_completion.zsh           # Zsh completion configuration
├── zsh_colors.zsh               # Catppuccin colors for zsh
├── fzf_integration.zsh          # fzf integration for zsh
├── zsh_options.zsh              # Zsh options and settings
└── ZSH_SETUP.md                 # Setup guide
```

### 2.2 File Migrations

#### `bash/bash_completion.sh` → `zsh/zsh_completion.zsh`
- Replace bash-completion with zsh completion system
- Enable menu selection (scrollable lists)
- Configure completion styles
- Add Catppuccin colors

#### `bash/fzf_integration.sh` → `zsh/fzf_integration.zsh`
- Update paths: `/usr/share/fzf/key-bindings.bash` → `/usr/share/fzf/key-bindings.zsh`
- Update paths: `/usr/share/fzf/completion.bash` → `/usr/share/fzf/completion.zsh`
- Keep all custom functions (compatible)

#### `bash/catppuccin_colors.sh` → `zsh/zsh_colors.zsh`
- Keep LS_COLORS (works in zsh)
- Add zsh-specific color variables if needed
- Configure zsh completion colors

#### `bash/.bash_aliases` → `zsh/.zsh_aliases`
- Aliases are compatible, can reuse
- Or create symlink to shared aliases file

### 2.3 New Zsh-Specific Features

#### Menu Selection Configuration
```zsh
# Enable menu selection (scrollable completion lists)
zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
```

#### Zsh Options
```zsh
# Enable useful zsh options
setopt AUTO_CD              # cd without typing cd
setopt SHARE_HISTORY        # Share history between sessions
setopt HIST_IGNORE_DUPS     # Don't record duplicates
setopt CORRECT              # Spell correction
setopt COMPLETE_IN_WORD     # Complete in middle of word
```

## Phase 3: Update Installer

### 3.1 Create `install/config/zsh.sh`

**Functions needed:**
- `deploy_zsh_config()` - Main deployment function
- `setup_default_shell()` - Set zsh as default
- `setup_zprofile()` - Create .zprofile for login shells
- `setup_zsh_completion()` - Configure zsh completion
- `setup_zsh_colors()` - Setup Catppuccin colors
- `setup_fzf_zsh()` - Setup fzf for zsh

### 3.2 Update `install.sh`

**Changes:**
- Detect current shell
- Add option to choose bash or zsh
- Update phase names and steps
- Support both shells (backward compatible)

### 3.3 Shell Detection

```bash
# In install.sh
detect_shell() {
    local current_shell="${SHELL:-$(getent passwd "$USER" | cut -d: -f7)}"
    if echo "$current_shell" | grep -q "zsh$"; then
        echo "zsh"
    elif echo "$current_shell" | grep -q "bash$"; then
        echo "bash"
    else
        echo "unknown"
    fi
}
```

## Phase 4: Configuration Files

### 4.1 Create `.zshrc` Template

```zsh
# ~/.zshrc template
# Starship prompt
eval "$(starship init zsh)"

# Load Catppuccin Frappe colors
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load aliases
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Load zsh completion
if [ -f ~/.config/zsh/zsh_completion.zsh ]; then
    . ~/.config/zsh/zsh_completion.zsh
fi

# Load fzf integration
if [ -f ~/.config/zsh/fzf_integration.zsh ]; then
    . ~/.config/zsh/fzf_integration.zsh
fi
```

### 4.2 Create `.zprofile` Template

```zsh
# ~/.zprofile (login shells)
# Source .zshrc for interactive shells
if [ -f ~/.zshrc ]; then
    . ~/.zshrc
fi

# TTY optimization
if [ "$TERM" = "linux" ] && [ -z "$SSH_CONNECTION" ]; then
    if [ -e /usr/share/terminfo/x/xterm-256color ] || [ -e /lib/terminfo/x/xterm-256color ]; then
        export TERM=xterm-256color
    fi
fi

# Auto-launch kitty on TTY login
if [ -z "$SSH_CONNECTION" ] && [ -t 0 ] && ([ "$TERM" = "linux" ] || [ "$TERM" = "xterm-256color" ]); then
    if command -v kitty &> /dev/null; then
        if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] || [ -S "/tmp/.X11-unix/X0" ] 2>/dev/null; then
            exec kitty
        fi
    fi
fi
```

## Phase 5: Implementation Steps

### Step 1: Create zsh directory structure
```bash
mkdir -p zsh
```

### Step 2: Create zsh configuration files
- [ ] `zsh/zsh_completion.zsh` - Completion configuration
- [ ] `zsh/zsh_colors.zsh` - Color configuration
- [ ] `zsh/fzf_integration.zsh` - fzf integration
- [ ] `zsh/zsh_options.zsh` - Zsh options
- [ ] `zsh/.zsh_aliases` - Aliases (or symlink to shared)
- [ ] `zsh/README.md` - Documentation

### Step 3: Create installer script
- [ ] `install/config/zsh.sh` - Zsh deployment script
- [ ] Update `install.sh` to support zsh
- [ ] Add shell detection
- [ ] Add zsh package installation

### Step 4: Update documentation
- [ ] Update main README.md
- [ ] Create zsh migration guide
- [ ] Update MINIMAL_INSTALL.md
- [ ] Update package lists (add zsh)

### Step 5: Testing
- [ ] Test zsh installation
- [ ] Test completion system
- [ ] Test menu selection
- [ ] Test fzf integration
- [ ] Test aliases
- [ ] Test Starship prompt
- [ ] Test Catppuccin colors

### Step 6: Backward compatibility
- [ ] Ensure bash configs still work
- [ ] Update installer to support both shells
- [ ] Add migration helper script

## Phase 6: Migration Strategy

### Option A: Dual Support (Recommended)
- Support both bash and zsh
- Installer detects shell and installs accordingly
- Users can choose which shell to use
- Both configs maintained

### Option B: Full Migration
- Migrate everything to zsh
- Keep bash as fallback
- Update all documentation
- Mark bash as deprecated

### Option C: Gradual Migration
- Add zsh support alongside bash
- Mark bash as legacy
- Encourage zsh adoption
- Remove bash support in future version

**Recommendation: Option A (Dual Support)**

## Phase 7: Package Dependencies

### New packages needed:
- `zsh` - The shell itself
- `zsh-completions` (optional) - Additional completions

### Packages to keep:
- `fzf` - Works with zsh
- `starship` - Works with zsh
- All other packages remain the same

### Packages to remove:
- `bash-completion` - Not needed (zsh has built-in completion)

## Phase 8: File Changes Summary

### New Files:
```
zsh/
├── README.md
├── zsh_completion.zsh
├── zsh_colors.zsh
├── fzf_integration.zsh
├── zsh_options.zsh
├── .zsh_aliases
└── ZSH_SETUP.md

install/config/zsh.sh
ZSH_MIGRATION_PLAN.md (this file)
```

### Modified Files:
```
install.sh                    # Add zsh support
install/config/bash.sh        # Keep for backward compatibility
packages/core.txt             # Add zsh
README.md                     # Update documentation
MINIMAL_INSTALL.md            # Update shell section
```

### Unchanged Files:
```
bash/                        # Keep for backward compatibility
All other configs            # Work with both shells
```

## Phase 9: Testing Checklist

### Basic Functionality
- [ ] zsh installs correctly
- [ ] .zshrc loads without errors
- [ ] Aliases work
- [ ] Functions work
- [ ] Environment variables set

### Completion System
- [ ] Menu selection works (arrow keys)
- [ ] Tab completion works
- [ ] Context-aware completions work
- [ ] Colors display correctly

### Integration
- [ ] Starship prompt works
- [ ] fzf integration works
- [ ] Catppuccin colors work
- [ ] LS_COLORS work

### Installer
- [ ] Detects shell correctly
- [ ] Installs zsh configs
- [ ] Sets zsh as default (optional)
- [ ] Backward compatible with bash

## Phase 10: Documentation Updates

### README.md
- Add zsh as primary shell
- Mention bash support
- Update installation instructions

### zsh/README.md
- Zsh-specific documentation
- Menu selection guide
- Completion system guide
- Migration from bash guide

### MINIMAL_INSTALL.md
- Update shell section
- Add zsh setup instructions
- Keep bash instructions for reference

## Timeline Estimate

- **Phase 1-2**: 2-3 hours (Analysis & file creation)
- **Phase 3**: 2-3 hours (Installer updates)
- **Phase 4**: 1-2 hours (Configuration templates)
- **Phase 5**: 3-4 hours (Implementation)
- **Phase 6-7**: 1 hour (Strategy & dependencies)
- **Phase 8-9**: 2-3 hours (Testing)
- **Phase 10**: 1-2 hours (Documentation)

**Total: ~12-18 hours**

## Risk Assessment

### Low Risk:
- ✅ Aliases migration (compatible)
- ✅ Colors migration (compatible)
- ✅ fzf migration (has zsh support)
- ✅ Starship migration (works with zsh)

### Medium Risk:
- ⚠️ Completion system (different syntax)
- ⚠️ Key bindings (different commands)
- ⚠️ Installer changes (needs testing)

### High Risk:
- ❌ Breaking existing bash setups (mitigated by dual support)
- ❌ User confusion (mitigated by documentation)

## Success Criteria

1. ✅ zsh works as primary shell
2. ✅ Menu selection (scrollable lists) works
3. ✅ All existing features work
4. ✅ Installer supports both shells
5. ✅ Documentation updated
6. ✅ Backward compatibility maintained
7. ✅ No breaking changes for bash users

## Next Steps

1. Review and approve this plan
2. Create zsh directory structure
3. Start with Phase 2 (create zsh config files)
4. Test incrementally
5. Update installer
6. Update documentation
7. Final testing
8. Release

---

**Status**: Planning Phase
**Last Updated**: 2024
**Owner**: TBD

