# Fingerprint Authentication Setup

Configuration for fingerprint authentication using fprintd on Framework laptops and other devices with fingerprint readers.

## What is fprintd?

fprintd is a D-Bus service that provides fingerprint authentication functionality on Linux. It works with various fingerprint readers including the one built into Framework laptops.

## Installation

The `install.sh` script will:
1. Install `fprintd` from official repositories
2. Create PAM configuration files for fingerprint authentication
3. Set up authentication for login, sudo, and terminal sessions

### Manual Installation

```bash
# Install fprintd
sudo pacman -S fprintd

# Verify the fingerprint reader is detected
fprintd-list <your-username>
```

## Initial Setup - Enroll Your Fingerprints

After installation, you need to enroll your fingerprints:

```bash
# Enroll a fingerprint (default: right index finger)
fprintd-enroll

# Enroll specific finger
fprintd-enroll -f left-index-finger
fprintd-enroll -f right-thumb

# Available fingers:
# left-thumb, left-index-finger, left-middle-finger, left-ring-finger, left-little-finger
# right-thumb, right-index-finger, right-middle-finger, right-ring-finger, right-little-finger
```

**Enrollment Tips:**
- You'll need to scan your finger multiple times (usually 5)
- Press firmly but not too hard
- Cover the entire sensor
- Slightly adjust finger position between scans for better coverage

## Verify Enrollment

```bash
# List enrolled fingerprints
fprintd-list <your-username>

# Test fingerprint authentication
fprintd-verify

# Delete a specific fingerprint
fprintd-delete <your-username> -f right-index-finger

# Delete all fingerprints for a user
fprintd-delete <your-username>
```

## PAM Configuration

The install script creates PAM configuration files to enable fingerprint authentication. These are placed in `/etc/pam.d/`.

### Where Fingerprint Auth Works

After setup, you can use fingerprint authentication for:
- **System login** (SDDM/GDM)
- **sudo commands** in terminal
- **polkit prompts** (system authentication dialogs)
- **Firefox** (through polkit for password management)

### PAM Files Created/Modified

The following configurations are set up:

**`/etc/pam.d/system-local-login`** - For graphical login
```pam
auth sufficient pam_fprintd.so
auth include system-login
```

**`/etc/pam.d/sudo`** - For sudo commands
```pam
#%PAM-1.0
auth sufficient pam_fprintd.so
auth include system-auth
```

**`/etc/pam.d/polkit-1`** - For system authentication dialogs
```pam
auth sufficient pam_unix.so try_first_pass likeauth nullok
auth sufficient pam_fprintd.so
auth required pam_deny.so
```

## Security Considerations

### Important Notes:
- Fingerprint authentication is **sufficient** not **required**
  - This means if fingerprint fails, you can still use password
- The configurations are designed to be **secure** and not bypass authentication
- Background processes won't silently get sudo access

### Best Practices:
1. **Always enroll backup fingers** (in case one is injured)
2. **Don't delete your password** - fingerprint is a supplement, not replacement
3. **Re-enroll periodically** if recognition degrades
4. **Keep system updated** for security patches

## Usage

Once configured, fingerprint authentication works automatically:

### Terminal (sudo)
```bash
# Run sudo command
sudo pacman -Syu

# You'll see: "Place your finger on the fingerprint reader"
# Touch the sensor instead of typing password
# If it fails or times out, you can type your password
```

### System Login (SDDM)
1. At login screen, your fingerprint reader should be active
2. Touch the sensor to authenticate
3. If it doesn't work, you can still type your password

### Firefox Password Manager
When Firefox asks for system authentication (e.g., for saved passwords), you'll be able to use your fingerprint through polkit.

## Troubleshooting

### Fingerprint reader not detected
```bash
# Check if device is recognized
lsusb | grep -i finger

# Check fprintd service
systemctl status fprintd

# Start service manually
sudo systemctl start fprintd
```

### Fingerprint authentication not working
```bash
# Verify PAM configuration
cat /etc/pam.d/sudo
cat /etc/pam.d/system-local-login

# Check for errors
journalctl -u fprintd -f

# Test fingerprint directly
fprintd-verify
```

### Enrollment fails
```bash
# Ensure service is running
sudo systemctl start fprintd

# Try re-enrolling
fprintd-delete <your-username>
fprintd-enroll
```

### Authentication timeout
The fingerprint reader has a timeout (~30 seconds). If you don't scan in time, fall back to password.

## Framework Laptop Specific

Framework laptops have excellent fingerprint reader support. The reader should work out of the box with fprintd.

**Reader Location:** Usually integrated into the power button or near the keyboard

## Advanced Configuration

### Adjust Timeout

You can modify the PAM configuration to adjust timeout behavior. Edit `/etc/pam.d/sudo` or other files to add timeout parameters.

### Require Fingerprint Only (Not Recommended)

To require fingerprint authentication (disallow password fallback), change `sufficient` to `required` in PAM files. **This is not recommended** as you could lock yourself out.

### Multiple Users

Each user must enroll their own fingerprints:
```bash
# Switch to user and enroll
su - username
fprintd-enroll
```

## Uninstallation

If you want to remove fingerprint authentication:

```bash
# Remove PAM configurations
sudo rm /etc/pam.d/fprintd-backup-*

# Restore original PAM files (if you have backups)
# Or manually remove the pam_fprintd.so lines from:
# - /etc/pam.d/sudo
# - /etc/pam.d/system-local-login
# - /etc/pam.d/polkit-1

# Optionally remove fprintd package
sudo pacman -R fprintd
```

## Resources

- **Arch Wiki**: https://wiki.archlinux.org/title/Fprint
- **Framework Community Guide**: https://community.frame.work/t/guide-solved-sudo-and-login-with-fingerprint-reader-under-kde-arch-linux/37009
- **fprintd Documentation**: https://fprint.freedesktop.org/
- **PAM Documentation**: `man pam_fprintd`

## File Locations

- **Fingerprint data**: Stored in `/var/lib/fprint/`
- **PAM configs**: `/etc/pam.d/`
- **Service**: `fprintd.service` (systemd)
