sudo tee /etc/profile.d/armbian-motd-unified.sh >/dev/null <<'EOF'
# Purpose: Show full Armbian MOTD via profile for Tailscale SSH, without duplicating it on normal SSH.
# Behavior:
#  - Interactive shells only.
#  - Tailscale SSH: always run ALL /etc/update-motd.d scripts (header + sysinfo + tips, etc.).
#  - Normal SSH: run only if PAM (pam_motd) did not already print (/run/motd.dynamic absent or empty).
# Notes:
#  - Sourced by the shell; no shebang needed.
#  - Avoids double-run inside the same shell session.

# Session guard to prevent re-entry
[ -n "$_ARM_MOTD_SHOWN" ] && return 0
_ARM_MOTD_SHOWN=1
export _ARM_MOTD_SHOWN

UPDATE_MOTD_DIR="/etc/update-motd.d"
PAM_MOTD_MARKER="/run/motd.dynamic"

is_interactive() {
  case "$-" in *i*) return 0 ;; *) return 1 ;; esac
}

pam_already_printed() {
  [ -s "$PAM_MOTD_MARKER" ]
}

show_full_motd() {
  [ -d "$UPDATE_MOTD_DIR" ] || return 0

  if command -v run-parts >/dev/null 2>&1; then
    run-parts "$UPDATE_MOTD_DIR" 2>/dev/null || true
    return 0
  fi

  # Fallback if run-parts is unavailable
  for f in "$UPDATE_MOTD_DIR"/*; do
    [ -x "$f" ] || continue
    "$f" 2>/dev/null || true
  done
}

is_interactive || return 0

# Tailscale sets TAILSCALE_SSH=1 for Tailscale-SSH sessions
if [ -n "${TAILSCALE_SSH:-}" ]; then
  show_full_motd
elif [ -n "${SSH_CONNECTION:-}" ]; then
  # Normal SSH: avoid duplicates if PAM already printed MOTD
  pam_already_printed || show_full_motd
fi
EOF

sudo chmod +x /etc/profile.d/armbian-motd-unified.sh

