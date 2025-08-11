# Armbian Unified MOTD Installer

Installs a unified Armbian MOTD handler that works for both Tailscale SSH and normal SSH sessions, avoids duplicates, and refreshes automatically.

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
