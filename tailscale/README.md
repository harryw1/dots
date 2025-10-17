# Tailscale Configuration

Tailscale is a mesh VPN that makes it easy to connect your devices securely, wherever they are.

## What is Tailscale?

Tailscale creates a secure network between your devices using WireGuard. It's perfect for:
- Accessing your home lab from anywhere
- Secure remote access to your machines
- Connecting devices across different networks
- Zero-config mesh networking

## What is tsui?

**tsui** is an elegant Terminal User Interface (TUI) for configuring and managing Tailscale, developed by Neuralink. It provides a more user-friendly way to manage Tailscale on Linux compared to CLI commands.

## Installation

The `install.sh` script will:
1. Install `tailscale` from the official Arch repositories
2. Download and install the `tsui` binary from GitHub releases
3. Enable the Tailscale systemd service

### Manual Installation

```bash
# Install Tailscale
sudo pacman -S tailscale

# Enable and start Tailscale
sudo systemctl enable --now tailscaled

# Download tsui (check for latest version at https://github.com/neuralinkcorp/tsui/releases)
cd /tmp
wget https://github.com/neuralinkcorp/tsui/releases/latest/download/tsui-linux-amd64
chmod +x tsui-linux-amd64
sudo mv tsui-linux-amd64 /usr/local/bin/tsui
```

## First-Time Setup

After installation, you need to authenticate Tailscale:

### Option 1: Using tsui (Recommended)
```bash
# Launch tsui
tsui

# Follow the on-screen instructions to authenticate
```

### Option 2: Using CLI
```bash
# Start Tailscale and get authentication URL
sudo tailscale up

# Open the URL in your browser to authenticate
```

## Usage

### Using tsui

```bash
# Launch the TUI
tsui
```

tsui provides a nice interface for:
- Viewing connection status
- Managing exit nodes
- Toggling routes
- Viewing peers
- Managing settings

### Using Tailscale CLI

```bash
# Check status
tailscale status

# Connect to Tailscale
sudo tailscale up

# Disconnect
sudo tailscale down

# View your Tailscale IP
tailscale ip

# View peers
tailscale status

# Use exit node
sudo tailscale up --exit-node=<peer-name>

# Stop using exit node
sudo tailscale up --exit-node=
```

## Key Commands

| Command | Description |
|---------|-------------|
| `tsui` | Launch the Terminal UI |
| `tailscale status` | Show connection status and peers |
| `tailscale ip` | Show your Tailscale IP addresses |
| `sudo tailscale up` | Connect to Tailscale |
| `sudo tailscale down` | Disconnect from Tailscale |
| `tailscale ping <peer>` | Ping a peer on your network |

## System Integration

### Systemd Service

Tailscale runs as a systemd service:

```bash
# Check service status
sudo systemctl status tailscaled

# Enable at boot
sudo systemctl enable tailscaled

# Start service
sudo systemctl start tailscaled

# Stop service
sudo systemctl stop tailscaled
```

### Waybar Integration (Optional)

You can add a Tailscale status indicator to Waybar by creating a custom module that checks `tailscale status`.

## Configuration

Tailscale configuration is managed through:
- The web admin panel at https://login.tailscale.com/admin
- CLI commands (`tailscale up` with flags)
- tsui interface

Common configurations:
- **Exit nodes**: Route all traffic through another device
- **Subnet routes**: Access other networks through a Tailscale peer
- **Magic DNS**: Use machine names instead of IPs
- **MagicDNS**: Automatic DNS for your network

## Troubleshooting

### Service not starting
```bash
# Check service status and logs
sudo systemctl status tailscaled
sudo journalctl -u tailscaled -f
```

### Can't connect to peers
```bash
# Check your status
tailscale status

# Try pinging a peer
tailscale ping <peer-name>

# Check if NAT traversal is working
tailscale netcheck
```

### Re-authenticate
```bash
# If authentication expires
sudo tailscale up
# Then visit the authentication URL
```

## Security Notes

- Tailscale uses WireGuard for encryption
- Authentication is through your identity provider (Google, GitHub, etc.)
- All connections are peer-to-peer when possible
- Keys are managed automatically
- You control access through the admin console

## Resources

- **Tailscale Documentation**: https://tailscale.com/kb/
- **tsui GitHub**: https://github.com/neuralinkcorp/tsui
- **Admin Console**: https://login.tailscale.com/admin

## Integration with Other Tools

Tailscale works seamlessly with:
- SSH (access remote machines via Tailscale IPs)
- Docker (expose containers on your Tailscale network)
- Kubernetes (connect clusters)
- File sharing (access SMB/NFS over Tailscale)
