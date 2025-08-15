#!/bin/bash

# 📂 Carpeta local a respaldar
SOURCE="/data/00_temp"

# ☁ Carpeta remota cifrada
REMOTE="gdrivecrypt:BackupPrincipal"
REMOTE_ACTUAL="$REMOTE/Actual"

# 📜 Carpeta de logs
LOGDIR="/home/mnebot/logs/backup_gdrive"
mkdir -p "$LOGDIR"

# 📅 Fecha para el log
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# 📂 Carpeta de histórico
HISTDIR="$REMOTE/Historial"

# ➕ Crear carpetas necesarias en Drive si no existen
/usr/bin/rclone mkdir "$REMOTE"
/usr/bin/rclone mkdir "$REMOTE_ACTUAL"
/usr/bin/rclone mkdir "$HISTDIR"

# 🚀 Sincronizar backup con versionado
/usr/bin/rclone sync "$SOURCE" "$REMOTE_ACTUAL" \
    --backup-dir "$HISTDIR/$DATE" \
    --progress \
    --log-file="$LOGDIR/backup_$DATE.log" \
    --log-level INFO \
    --transfers=4 \
    --checkers=8

echo "Backup con versionado completado: $DATE"

# 🧹 Limitar historial a las 2 últimas versiones
VERSIONS=$(/usr/bin/rclone lsf "$HISTDIR" | sort)
COUNT=$(echo "$VERSIONS" | wc -l)

if [ "$COUNT" -gt 2 ]; then
    TO_DELETE=$(echo "$VERSIONS" | head -n $(($COUNT - 2)))
    for v in $TO_DELETE; do
        /usr/bin/rclone purge "$HISTDIR/$v"
        echo "Eliminada versión antigua: $v"
    done
fi