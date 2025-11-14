# Troubleshooting Slow Login from Lock Screen

This document helps diagnose and fix slow login issues when unlocking from the lock screen (hyprlock).

## Quick Diagnosis

Run the diagnostic script:
```bash
~/.config/diagnose-login-delay.sh
```

## Common Causes and Solutions

### 1. Fingerprint Authentication Timeout ⚠️ **MOST LIKELY**

**Problem:** If you have fingerprint authentication enabled, the system waits for a fingerprint scan (default ~30 seconds) before falling back to password.

**Symptoms:**
- Login appears to hang after entering password
- Delay happens before desktop appears
- Works fine when using fingerprint directly

**Diagnosis:**
```bash
# Check if fprintd is waiting
journalctl -u fprintd -f

# Check fingerprint enrollment
fprintd-list $USER

# Check PAM timeout
grep -A2 "pam_fprintd" /etc/pam.d/system-local-login
```

**Solutions:**

**Option A: Disable fingerprint on lock screen (recommended)**
- Use fingerprint only for initial login, password for unlock
- Edit `/etc/pam.d/system-local-login` and comment out or remove the `pam_fprintd.so` line
- Or create a separate PAM config for lock screen that doesn't include fingerprint

**Option B: Reduce timeout**
- Edit `/etc/pam.d/system-local-login` and add timeout parameter:
  ```
  auth sufficient pam_fprintd.so timeout=5
  ```

**Option C: Use password directly**
- Just type your password instead of waiting for fingerprint timeout

### 2. Slow Autostart Applications

**Problem:** Applications in `~/.config/hyprland/conf/autostart.conf` may be blocking or slow to start.

**Check for slow commands:**
```bash
# Test waypaper restore time
time waypaper --restore

# Check if waybar CSS script exists
ls -la ~/.config/waybar/generate-waybar-css.sh

# Count autostart commands
grep -c "^exec-once" ~/.config/hyprland/conf/autostart.conf
```

**Common slow commands:**
- `waypaper --restore` - May check network or slow filesystem
- `~/.config/waybar/generate-waybar-css.sh` - Script execution
- Multiple `gsettings` commands (7 in your config)

**Solutions:**
- Make scripts non-blocking by adding `&` or using `exec-once = bash -c 'command &'`
- Batch gsettings commands into a single script
- Check if waybar CSS script exists and is fast
- Consider deferring non-critical apps

### 3. Network Lookups (NSS)

**Problem:** PAM may be doing network lookups for user authentication.

**Check:**
```bash
cat /etc/nsswitch.conf | grep -E "^(passwd|group|shadow):"
```

**Solution:**
- If you see `ldap`, `nis`, or `winbind`, these can cause delays
- Ensure local files are checked first: `files` should come before network sources

### 4. Network Filesystem Mounts

**Problem:** Network filesystems (NFS, CIFS) may be slow or unavailable.

**Check:**
```bash
mount | grep -E "type nfs|type cifs|type fuse"
```

**Solution:**
- Use `noauto` mount option for non-critical network filesystems
- Check network connectivity

### 5. Systemd User Services

**Problem:** User services may be blocking session startup.

**Check:**
```bash
systemctl --user list-unit-files --type=service --state=enabled
systemd-analyze --user blame
```

**Solution:**
- Disable unnecessary services
- Check service logs: `journalctl --user -u service-name`

### 6. SDDM Session Initialization

**Problem:** SDDM may be slow to start the session.

**Check SDDM logs:**
```bash
journalctl -u sddm -f
journalctl -u sddm --since '10 minutes ago' | grep -i error
```

**Common issues:**
- Slow theme loading
- Custom session command delays
- Environment variable issues

## Measuring Actual Login Time

To identify where the delay occurs:

1. **Add timing to Hyprland autostart:**
   ```bash
   # Add to ~/.config/hyprland/conf/autostart.conf
   exec-once = date +%s.%N > /tmp/hyprland_start
   ```

2. **Add timing to shell startup:**
   ```bash
   # Add to ~/.zshrc or ~/.bashrc
   if [ -f /tmp/hyprland_start ]; then
       START=$(cat /tmp/hyprland_start)
       NOW=$(date +%s.%N)
       DELAY=$(echo "$NOW - $START" | bc)
       echo "Login delay: ${DELAY}s"
       rm /tmp/hyprland_start
   fi
   ```

3. **Check PAM authentication time:**
   ```bash
   # Add to /etc/pam.d/system-local-login (before auth lines)
   auth optional pam_exec.so debug log=/tmp/pam_auth.log /bin/date +%s.%N
   ```

## Quick Fixes to Try

1. **Disable fingerprint on lock screen** (if using password to unlock)
2. **Check if waybar CSS script exists** - missing script may cause delay
3. **Test waypaper restore** - may be slow
4. **Check journal logs** for errors:
   ```bash
   journalctl --since '1 hour ago' | grep -iE "error|fail|timeout" | grep -iE "sddm|login|pam|hyprland"
   ```

## Your Current Configuration

Based on your config files:

- ✅ **Fingerprint auth enabled** - Most likely cause if you're using password
- ✅ **7 gsettings commands** - Could be optimized
- ✅ **waypaper --restore** - May be slow
- ✅ **waybar CSS script** - Check if exists
- ✅ **Multiple autostart apps** - 15+ exec-once commands

## Next Steps

1. Run the diagnostic script: `~/.config/diagnose-login-delay.sh`
2. Check journal logs for the specific delay
3. Test fingerprint vs password login times
4. Measure autostart application startup times
5. Consider optimizing autostart configuration

## Additional Resources

- SDDM logs: `journalctl -u sddm`
- User session logs: `journalctl --user`
- PAM logs: Check `/var/log/auth.log` or `journalctl -k | grep pam`
- Hyprland logs: `hyprctl logs`

