# Quick Fixes for Slow Login from Lock Screen

## 🔴 **PRIMARY ISSUE: Fingerprint Service Inactive**

Your PAM configuration includes fingerprint authentication, but the `fprintd.service` is **inactive**. This causes the login process to wait for the fingerprint service to respond, resulting in a delay.

### Solution Options:

#### Option 1: Start fprintd service (if you want fingerprint auth)
```bash
sudo systemctl enable --now fprintd.service
```

#### Option 2: Disable fingerprint on lock screen (recommended if using password)
Since you're logging in from the lock screen with a password, you probably don't need fingerprint authentication for unlock. You can disable it for the lock screen while keeping it for initial login.

**Create a separate PAM config for lock screen:**
```bash
# Backup current config
sudo cp /etc/pam.d/system-local-login /etc/pam.d/system-local-login.backup

# Edit to remove fingerprint (or comment it out)
sudo nano /etc/pam.d/system-local-login
```

Change from:
```
auth sufficient pam_fprintd.so
auth include system-login
```

To:
```
# auth sufficient pam_fprintd.so  # Disabled for faster unlock
auth include system-login
```

#### Option 3: Add timeout to fingerprint (compromise)
If you want to keep fingerprint but reduce delay:
```bash
sudo nano /etc/pam.d/system-local-login
```

Change:
```
auth sufficient pam_fprintd.so
```

To:
```
auth sufficient pam_fprintd.so timeout=5
```

This will only wait 5 seconds instead of the default ~30 seconds.

---

## 🟡 **SECONDARY ISSUE: Missing Waybar CSS Script**

Your autostart config references `~/.config/waybar/generate-waybar-css.sh` but this file doesn't exist. This may cause an error or delay.

### Solution:

**Option 1: Create the script (if needed)**
```bash
cat > ~/.config/waybar/generate-waybar-css.sh << 'EOF'
#!/usr/bin/env bash
# Generate Waybar CSS based on monitor configuration
# This is a placeholder - customize as needed

# Example: Generate CSS based on monitor count
MONITOR_COUNT=$(hyprctl monitors -j | jq length 2>/dev/null || echo "1")

# You can customize CSS generation here
# For now, just ensure style.css exists
if [ ! -f ~/.config/waybar/style.css ]; then
    touch ~/.config/waybar/style.css
fi
EOF

chmod +x ~/.config/waybar/generate-waybar-css.sh
```

**Option 2: Remove the line (if not needed)**
```bash
# Edit ~/.config/hyprland/conf/autostart.conf
# Comment out or remove:
# exec-once = ~/.config/waybar/generate-waybar-css.sh
```

---

## 📊 **Quick Test**

After applying fixes, test the login speed:

1. Lock your screen: `hyprlock` or use your lock keybind
2. Unlock with password
3. Time how long it takes from password entry to desktop appearing

You can also check logs:
```bash
# Watch SDDM logs in real-time
journalctl -u sddm -f

# Check for PAM delays
journalctl -k | grep -i pam | tail -20

# Check fprintd logs
journalctl -u fprintd --since "10 minutes ago"
```

---

## 🎯 **Recommended Action Plan**

1. **Immediate fix:** Disable fingerprint PAM for lock screen (Option 2 above)
2. **Secondary fix:** Either create the waybar script or remove the reference
3. **Test:** Lock and unlock to verify speed improvement
4. **Optional:** If you want fingerprint on initial login but not unlock, you may need separate PAM configs

---

## 📝 **Additional Notes**

- `waypaper --restore` is fast (0.4s) - not an issue
- Multiple gsettings commands are fine (they're fast)
- Only 1 systemd user service enabled (wireplumber) - not an issue
- No network filesystems detected - not an issue

The fingerprint service being inactive while PAM is configured to use it is almost certainly the cause of your delay.

