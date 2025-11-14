# Testing Zsh Configuration

This guide will help you test the zsh configuration to ensure everything works correctly.

## Quick Test

### Step 1: Install zsh (if not already installed)

```bash
sudo pacman -S zsh
```

### Step 2: Create a test .zshrc

```bash
# Backup existing .zshrc if it exists
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup

# Create test .zshrc
cat > ~/.zshrc <<'EOF'
# Starship prompt
eval "$(starship init zsh)"

# Load Catppuccin Frappe colors
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load aliases (try zsh first, fallback to bash)
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
elif [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load zsh completion (menu selection!)
if [ -f ~/.config/zsh/zsh_completion.zsh ]; then
    . ~/.config/zsh/zsh_completion.zsh
fi

# Load fzf integration
if [ -f ~/.config/zsh/fzf_integration.zsh ]; then
    . ~/.config/zsh/fzf_integration.zsh
fi
EOF
```

### Step 3: Start zsh

```bash
zsh
```

Or set it as your default shell (optional):
```bash
chsh -s /usr/bin/zsh
```

## Testing Checklist

### ✅ Test 1: Basic zsh functionality

```zsh
# Check zsh version
zsh --version

# Check if configs loaded
echo $LS_COLORS | head -c 50
# Should show color codes

# Check if completion is loaded
echo $fpath
# Should show completion paths
```

### ✅ Test 2: Menu Selection (Scrollable Completions)

This is the main feature!

```zsh
# Test command completion
git <TAB>
# Should show a list of git commands
# Use ↑↓ arrow keys to scroll through the list
# Press Enter to select

# Test file completion
ls ~/.config/<TAB>
# Should show files/directories
# Use arrow keys to scroll

# Test with multiple completions
pacman -S <TAB>
# Should show packages (if bash-completion or zsh-completions installed)
# Use arrow keys to navigate
```

**Expected behavior:**
- Tab shows completion list
- Arrow keys scroll through options
- Current selection is highlighted
- Enter selects the option
- Escape cancels

### ✅ Test 3: Catppuccin Colors

```zsh
# Test LS_COLORS
ls --color=auto
# Files should be colored with Catppuccin Frappe colors

# Test completion colors
git <TAB>
# Completion list should use terminal colors (Catppuccin Frappe if terminal is configured)
```

### ✅ Test 4: fzf Integration

```zsh
# Test history search
Ctrl+R
# Should open fzf with command history
# Type to filter, Enter to select

# Test file search
Ctrl+T
# Should open fzf file picker
# Navigate and select a file

# Test directory change
Alt+C
# Should open fzf directory picker
# Select a directory to cd into

# Test fuzzy file completion
echo **<TAB>
# Should open fzf for file selection
```

### ✅ Test 5: Custom fzf Functions

```zsh
# Test fuzzy cd
fzf-cd
# Should show directory picker

# Test fuzzy file edit
fzf-file
# Should show file picker, opens in editor

# Test git functions (if in a git repo)
fzf-git
# Should show git files

fzf-git-branch
# Should show branches for checkout
```

### ✅ Test 6: Aliases

```zsh
# Test if aliases loaded
alias | grep -E "(ls|ll|gs|pacup)"
# Should show your aliases

# Test alias functionality
ll
# Should work if aliases loaded
```

### ✅ Test 7: Starship Prompt

```zsh
# Check if Starship is loaded
echo $STARSHIP_SESSION_KEY
# Should show a value

# Prompt should show Starship with Catppuccin Frappe colors
# Should show git branch, directory, etc.
```

## Automated Test Script

Run the test script:

```bash
bash ~/.config/zsh/test_zsh.sh
```

This will check:
- zsh installation
- Configuration files exist
- Functions are defined
- Colors are set
- Completion is loaded

## Troubleshooting

### Menu selection not working

```zsh
# Check if menu selection is enabled
zstyle -L ':completion:*' menu
# Should show: menu select

# Reload completion
autoload -Uz compinit
compinit
```

### Colors not showing

```zsh
# Check LS_COLORS
echo $LS_COLORS | head -c 100

# Check terminal colors
echo $TERM
# Should be xterm-256color or similar

# Make sure terminal uses Catppuccin Frappe theme
```

### fzf not working

```zsh
# Check if fzf is installed
command -v fzf

# Check if fzf bindings loaded
bindkey | grep fzf

# Manually source fzf
source /usr/share/fzf/key-bindings.zsh
```

### Completion not working

```zsh
# Check if completion is initialized
echo $fpath

# Reinitialize completion
rm ~/.zcompdump*  # Remove old cache
autoload -Uz compinit
compinit
```

## Quick Verification Commands

```zsh
# Check all key features
echo "=== Zsh Version ==="
zsh --version

echo "=== Completion Loaded ==="
echo $fpath | grep -q completion && echo "✅ Yes" || echo "❌ No"

echo "=== Menu Selection ==="
zstyle -L ':completion:*' menu | grep -q select && echo "✅ Yes" || echo "❌ No"

echo "=== Colors Set ==="
[ -n "$LS_COLORS" ] && echo "✅ Yes" || echo "❌ No"

echo "=== fzf Available ==="
command -v fzf &>/dev/null && echo "✅ Yes" || echo "❌ No"

echo "=== Starship Loaded ==="
[ -n "$STARSHIP_SESSION_KEY" ] && echo "✅ Yes" || echo "❌ No"
```

## Next Steps

Once everything is tested and working:

1. **Set zsh as default** (optional):
   ```bash
   chsh -s /usr/bin/zsh
   ```

2. **Create .zprofile** for login shells:
   ```bash
   cat > ~/.zprofile <<'EOF'
   # Source .zshrc for interactive shells
   if [ -f ~/.zshrc ]; then
       . ~/.zshrc
   fi
   EOF
   ```

3. **Test in new terminal**:
   - Open a new terminal
   - Should automatically use zsh
   - All features should work

