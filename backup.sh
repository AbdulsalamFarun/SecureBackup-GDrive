#!/bin/bash
set -euo pipefail

SOURCE="$HOME/backup/source"
DEST="$HOME/backup/dest"
LOGFILE="$HOME/scripts/backup.log"
RETENTION_DAYS=7

source "$HOME/scripts/.secrets"

send_telegram() {
  local MSG="$1"
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d text="$MSG" > /dev/null
}


# Encryption (symmetric) - change this passphrase
GPG_PASSPHRASE="CHANGE_ME_STRONG_PASSWORD"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="backup_$DATE.tar.gz"
ARCHIVE_PATH="$DEST/$ARCHIVE"
ENC_PATH="$ARCHIVE_PATH.gpg"

mkdir -p "$SOURCE" "$DEST"

{
  echo "===== BACKUP START ====="
  echo "Date   : $(date)"
  echo "Source : $SOURCE"
  echo "Dest   : $DEST"

  echo "Creating archive: $ARCHIVE_PATH"
  tar -czf "$ARCHIVE_PATH" -C "$SOURCE" .

  echo "Encrypting: $ENC_PATH"
  gpg --batch --yes --pinentry-mode loopback \
      --passphrase "$GPG_PASSPHRASE" \
      -c -o "$ENC_PATH" "$ARCHIVE_PATH"

  # remove unencrypted archive
  rm -f "$ARCHIVE_PATH"
  echo "Encrypted backup ready: $ENC_PATH"

  # --- Upload to Google Drive ---

  if rclone copy "$ENC_PATH" gdrive:Backups; then
  echo "UPLOAD STATUS: SUCCESS"
  send_telegram "✅ Backup SUCCESS on $(hostname) at $(date)"
else
  echo "UPLOAD STATUS: FAILED"
  send_telegram "❌ Backup FAILED on $(hostname) at $(date)"
fi


  echo"Cleaning old backups (>${RETENTION_DAYS} days)..."
  find "$DEST" -type f -name "backup_*.tar.gz.gpg" -mtime +"$RETENTION_DAYS" -print -delete

  echo "===== BACKUP END ====="
  echo
} | tee -a "$LOGFILE"
exit 0
