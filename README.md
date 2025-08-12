# Armbian Unified MOTD Installer

Fixes missing MOTD (Message of the Day) on Armbian systems when connecting via Tailscale SSH. In Debian Trixie now supported officially, Tailscale SSH bypasses PAM authentication, which normally displays the MOTD, leaving you with a blank login screen.

This script creates a unified handler that:
- Detects Tailscale SSH connections and always shows MOTD
- For regular SSH, only refreshes MOTD if it's stale (older than 10 seconds)
- Prevents duplicate MOTD displays

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sam0rr/motd_armbian_ssh/main/setup_motd.sh | bash
```

## What It Does

- Installs `/etc/profile.d/armbian-motd-unified.sh`
- Shows MOTD always for Tailscale SSH, only if stale (>10s) for regular SSH
- No manual configuration required

## Uninstall

```bash
sudo rm -f /etc/profile.d/armbian-motd-unified.sh
```
