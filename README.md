# SecureBackup-GDrive

A lightweight Linux backup automation script that:
- Creates a compressed archive from a source directory
- Encrypts the backup using GPG (symmetric encryption)
- Uploads the encrypted backup to Google Drive using rclone
- Sends Telegram notifications on success/failure
- Runs automatically on a schedule (cron)

---

## Features
- ✅ Compressed backups (`.tar.gz`)
- ✅ Encrypted backups (`.tar.gz.gpg`)
- ✅ Google Drive upload via `rclone`
- ✅ Telegram alerts (SUCCESS / FAILED)
- ✅ Automatic retention (delete old backups locally)
- ✅ Simple, beginner-friendly structure but production-style workflow

---

## Project Structure

~/scripts/
backup.sh
.secrets

~/backup/
source/ # files you want to back up
dest/ # local encrypted backups output

yaml
Copy code

---

## Requirements

Install required packages:

```bash
sudo apt update
sudo apt install -y rclone gnupg curl
Setup
1) Create folders
bash
Copy code
mkdir -p ~/backup/source ~/backup/dest ~/scripts
2) Configure rclone (Google Drive)
bash
Copy code
rclone config
Create a remote named gdrive, then test:

bash
Copy code
rclone lsd gdrive:
Create a folder in Drive:

bash
Copy code
rclone mkdir gdrive:Backups
3) Create secrets file (Telegram + encryption)
Create:

bash
Copy code
nano ~/scripts/.secrets
Add:

bash
Copy code
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
GPG_PASSPHRASE="YOUR_STRONG_PASSWORD"
Secure it:

bash
Copy code
chmod 600 ~/scripts/.secrets
Usage
Run manually:

bash
Copy code
bash ~/scripts/backup.sh
Outputs:

Local encrypted file in: ~/backup/dest/backup_YYYY-MM-DD_HH-MM-SS.tar.gz.gpg

Uploaded copy in Google Drive: gdrive:Backups

Logs: ~/scripts/backup.log

Scheduling (Cron)
Edit crontab:

bash
Copy code
crontab -e
Run daily at 2:00 AM:

bash
Copy code
0 2 * * * /home/abdulsalam/scripts/backup.sh
Verify:

bash
Copy code
crontab -l
Restore (Decrypt + Extract)
Decrypt:

bash
Copy code
gpg --output backup.tar.gz --decrypt backup_YYYY-MM-DD_HH-MM-SS.tar.gz.gpg
Extract:

bash
Copy code
tar -xzf backup.tar.gz -C ./restore_output
Architecture (High Level)
Archive: tar compresses source folder into .tar.gz

Encrypt: gpg encrypts archive into .gpg

Upload: rclone copies encrypted file to Google Drive

Notify: Telegram message sent on success/failure

Retention: remove older local backups (configurable)

Skills Demonstrated
Linux CLI & file permissions

Bash scripting & automation patterns

Cron scheduling

GPG encryption (symmetric)

Cloud upload automation via rclone

REST API integration (Telegram Bot API) using curl

Logging & retention policy basics

