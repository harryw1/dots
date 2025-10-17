# Installer Troubleshooting Guide

## Issue: Enter Key Doesn't Start Installation

### Possible Causes

#### 1. **Not Running on Arch Linux**
The installer checks for `/etc/arch-release` and skips package installation if not found.

**Check:**
```bash
ls -la /etc/arch-release
# Should exist on Arch Linux
```

**Solution:**
- If on Arch Linux but file missing, run: `sudo pacman -S base`
- If testing on non-Arch system, use: `./install.sh --skip-packages`

#### 2. **Hyprctl Not Found (check_system blocking)**
The `check_system()` function prompts for confirmation if `hyprctl` is not installed.

**Check:**
```bash
command -v hyprctl
# Should return path if installed
```

**Solution:**
- Install Hyprland first: `sudo pacman -S hyprland`
- Or bypass check: `./install.sh -f` (force mode)

#### 3. **Script Error with set -e**
The script uses `set -e` which exits on any error. If a command fails silently, the script stops.

**Check:**
Run the debug version to see where it stops:
```bash
./install-debug-v2.sh
# Then check the log
cat install-debug-v2.log
```

**What to look for in the log:**
- `[DEBUG V2] Read completed, user pressed Enter` - confirms Enter works
- `[DEBUG V2] IS Arch Linux` vs `NOT Arch Linux` - shows OS detection
- `[DEBUG V2] SKIP_PACKAGES=false` - shows if packages will install
- Any error messages after these lines indicate where it's failing

#### 4. **Sudo Password Prompt Hidden**
Many operations require sudo. If the password prompt is hidden or waiting in background, the script appears frozen.

**Check:**
Press Enter, then try typing your password blindly and pressing Enter again.

**Solution:**
Make sure your terminal is in the foreground and visible when running the script.

### Debug Workflow

1. **Run enhanced debug script:**
   ```bash
   ./install-debug-v2.sh
   ```

2. **Press Enter when prompted**

3. **Check what happened:**
   ```bash
   cat install-debug-v2.log | grep "DEBUG V2"
   ```

4. **Look for the last successful step:**
   - If it stops after "Waiting for read..." → Enter key issue (very unlikely)
   - If it stops after "NOT Arch Linux" → OS detection issue
   - If it stops after "About to call check_repositories" → Repository check failing
   - If it stops after "check_repositories completed" → Mirrorlist or permission issue

### Quick Tests

**Test 1: Verify Enter key works**
```bash
./install-debug.sh
# Press Enter - should see "DEBUG: You pressed Enter! The script works."
```

**Test 2: Check OS detection**
```bash
[ -f /etc/arch-release ] && echo "Arch Linux detected" || echo "NOT Arch Linux"
```

**Test 3: Test with skip packages**
```bash
./install.sh --skip-packages
# Should skip to symlink creation immediately after Enter
```

**Test 4: Force mode**
```bash
./install.sh -f
# Skips the hyprctl check
```

### Expected Behavior After Enter Key

On **Arch Linux** systems:
1. Press Enter
2. See "Step 1/10 - Checking repository configuration"
3. See "Step 2/10 - Optimizing mirrorlist"
4. Proceeds through all package installation steps
5. Creates symlinks
6. Shows completion screen

On **non-Arch** systems:
1. Press Enter
2. See "Not running Arch Linux - skipping package installation"
3. Proceeds to create symlinks only
4. Shows completion screen

### Common Fixes

**Fix 1: Run on Arch Linux**
```bash
# The installer is designed for Arch Linux
# If testing elsewhere, use --skip-packages flag
```

**Fix 2: Install Hyprland first**
```bash
sudo pacman -S hyprland
# Then run installer
./install.sh
```

**Fix 3: Use force mode**
```bash
./install.sh -f
# Bypasses system checks
```

**Fix 4: Skip packages for config-only install**
```bash
./install.sh --skip-packages
# Only creates symlinks, no package installation
```

### Still Not Working?

If after all these steps the installer still hangs:

1. **Push the debug log to the repo:**
   ```bash
   git add install-debug-v2.log
   git commit -m "Add debug log for troubleshooting"
   git push
   ```

2. **Check for error messages:**
   ```bash
   # Look at the full output
   cat install-debug-v2.log

   # Look for errors
   grep -i error install-debug-v2.log
   grep -i failed install-debug-v2.log
   ```

3. **Run individual functions manually:**
   ```bash
   # Source the script to load functions
   source ./install.sh

   # Test individual components
   is_arch_linux && echo "Arch detected"
   check_repositories
   ```

### Understanding Script Flow

```
┌─ START
│
├─ Parse Arguments (--help, --skip-packages, --no-tui, -f)
│
├─ check_system() [unless -f used]
│  └─ Prompts if hyprctl not found
│
├─ main()
│  │
│  ├─ show_welcome() [if --no-tui not used]
│  │  └─ Wait for Enter ← YOU ARE HERE
│  │
│  ├─ Check: is_arch_linux()
│  │  │
│  │  ├─ YES: Install packages
│  │  │  ├─ check_repositories
│  │  │  ├─ check_mirrorlist
│  │  │  ├─ sync_package_database
│  │  │  ├─ resolve_conflicts
│  │  │  ├─ install_packages (core)
│  │  │  ├─ install_packages (hypr-ecosystem)
│  │  │  ├─ install_packages (theming)
│  │  │  ├─ install_packages (development)
│  │  │  ├─ install_packages (productivity)
│  │  │  ├─ install_aur_packages
│  │  │  └─ setup_wallpapers
│  │  │
│  │  └─ NO: Skip packages, print warning
│  │
│  ├─ Create symlinks
│  │  ├─ hyprland → ~/.config/hypr
│  │  ├─ waybar → ~/.config/waybar
│  │  ├─ kitty → ~/.config/kitty
│  │  ├─ rofi → ~/.config/rofi
│  │  ├─ mako → ~/.config/mako
│  │  ├─ zathura → ~/.config/zathura
│  │  └─ starship.toml → ~/.config/starship.toml
│  │
│  ├─ install_lazyvim()
│  │
│  └─ Show completion screen
│
└─ END
```

The most likely issue is that the script is running on a non-Arch system, so it skips package installation but continues with symlink creation silently.
