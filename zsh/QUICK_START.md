# Quick Start - Testing Zsh Configuration

## Ready to Test!

All zsh configuration files are created and the installer is ready. Here's how to test:

## Option 1: Use the Bootstrap Script (Recommended)

This will install everything including zsh:

```bash
curl -sL https://raw.githubusercontent.com/harryw1/dots/main/bootstrap.sh | bash
```

The installer will:
1. ✅ Install zsh (from packages/core.txt)
2. ✅ Create ~/.zshrc with all configurations
3. ✅ Create ~/.zprofile for login shells
4. ✅ Set up menu selection (scrollable completions!)
5. ✅ Configure Catppuccin Frappe colors
6. ✅ Integrate fzf
7. ✅ Set up aliases

## Option 2: Manual Test (Local)

If you want to test locally first:

```bash
# 1. Install zsh
sudo pacman -S zsh

# 2. Run the test script
bash ~/.config/zsh/test_zsh.sh

# 3. Create .zshrc manually (or let installer do it)
cat > ~/.zshrc <<'EOF'
# Starship prompt
eval "$(starship init zsh)"

# Load Catppuccin Frappe colors
if [ -f ~/.config/zsh/zsh_colors.zsh ]; then
    . ~/.config/zsh/zsh_colors.zsh
fi

# Load aliases
if [ -f ~/.zsh_aliases ] || [ -f ~/.bash_aliases ]; then
    [ -f ~/.zsh_aliases ] && . ~/.zsh_aliases
    [ -f ~/.bash_aliases ] && . ~/.bash_aliases
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

# 4. Start zsh
zsh
```

## What to Test

Once zsh is running:

### 1. Menu Selection (Main Feature!)
```zsh
git <TAB>
# Should show list with cursor
# Use ↑↓ arrow keys to scroll
# Press Enter to select
```

### 2. Colors
```zsh
ls --color=auto
# Should show Catppuccin Frappe colors
```

### 3. fzf
```zsh
Ctrl+R    # History search
Ctrl+T    # File search
Alt+C     # Directory change
```

### 4. Aliases
```zsh
ll        # Should work if aliases loaded
gs        # Git status
```

## Troubleshooting

If something doesn't work:

1. **Check if files exist:**
   ```bash
   ls -la ~/.config/zsh/
   ```

2. **Check .zshrc:**
   ```bash
   cat ~/.zshrc
   ```

3. **Run test script:**
   ```bash
   bash ~/.config/zsh/test_zsh.sh
   ```

4. **Check zsh version:**
   ```bash
   zsh --version
   ```

## Next Steps

After testing:
- Set zsh as default: `chsh -s /usr/bin/zsh`
- Or just use `zsh` command to start it
- Enjoy scrollable completion lists! 🎉

