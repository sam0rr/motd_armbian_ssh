#!/usr/bin/env bash
# ==============================================================================
# Armbian MOTD Unified Installer
# ------------------------------------------------------------------------------
# Installs a unified MOTD script that:
#   - Always shows MOTD for Tailscale SSH (PAM bypassed).
#   - Shows MOTD for normal SSH only if missing/stale (avoids duplicates).
#
# Uninstall:
#   sudo rm -f /etc/profile.d/armbian-motd-unified.sh
# ==============================================================================

echo "[INFO] Creating /etc/profile.d/armbian-motd-unified.sh..."

sudo tee /etc/profile.d/armbian-motd-unified.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
# ==============================================================================
# Armbian MOTD (unified)
# ------------------------------------------------------------------------------
# Purpose:
#   Show Armbian's dynamic MOTD without duplicates on ssh tailscale and classic ssh.
#
# Behavior:
#   - Runs only for interactive shells.
#   - Tailscale SSH sessions (PAM bypassed): always show MOTD.
#   - Regular SSH sessions: show only if /run/motd.dynamic is missing or stale.
#
# Tunables:
#   MOTD_DIR              Directory containing update-motd.d scripts
#   MOTD_FILE             Path to the dynamic MOTD file PAM writes
#   MOTD_STALE_SECONDS    Consider MOTD stale after this many seconds
# ==============================================================================

# ----------------------------- Global variables -------------------------------
MOTD_DIR="/etc/update-motd.d"
MOTD_FILE="/run/motd.dynamic"
MOTD_STALE_SECONDS=10

# ------------------------------ Helper functions ------------------------------
is_interactive() {
  case "$-" in *i*) return 0 ;; *) return 1 ;; esac
}

show_armbian_motd() {
  if RUN_PARTS_BIN="$(command -v run-parts 2>/dev/null)"; then
    "$RUN_PARTS_BIN" "$MOTD_DIR" 2>/dev/null || true
  else
    for script in "$MOTD_DIR"/*; do
      [ -f "$script" ] && [ -x "$script" ] && "$script" 2>/dev/null || true
    done
  fi
}

motd_is_stale() {
  if [ ! -f "$MOTD_FILE" ]; then
    return 0
  fi
  local now epoch_file age
  now=$(date +%s)
  epoch_file=$(stat -c %Y "$MOTD_FILE" 2>/dev/null || echo 0)
  age=$(( now - epoch_file ))
  (( age > MOTD_STALE_SECONDS ))
}

# --------------------------------- Main logic ---------------------------------
if is_interactive; then
  if [ -n "$TAILSCALE_SSH" ]; then
    show_armbian_motd
  elif [ -n "$SSH_CONNECTION" ]; then
    if motd_is_stale; then
      show_armbian_motd
    fi
  fi
fi
EOF

sudo chmod +x /etc/profile.d/armbian-motd-unified.sh

echo "[INFO] MOTD script installed successfully"
echo "[INFO] To uninstall: sudo rm -f /etc/profile.d/armbian-motd-unified.sh"
