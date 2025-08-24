#!/bin/bash
# backup-docker.sh - Backup usando la imagen oficial de PostgreSQL

set -e

# Validar que todas las variables estén definidas
required_vars=("DB_HOST" "DB_PORT" "DB_USER" "DB_PASSWORD" "DB_NAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Variable $var no definida"
        exit 1
    fi
done

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/ubuntu/backups"
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

mkdir -p $BACKUP_DIR

echo "🔄 Iniciando backup de $DB_NAME@$DB_HOST..."

# Usar la imagen oficial de PostgreSQL SIN necesidad de Dockerfile personalizado
docker run --rm \
  -v $BACKUP_DIR:/backups \
  -e PGPASSWORD="$DB_PASSWORD" \
  postgres:15-alpine \
  pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup completado: $BACKUP_FILE"
    echo "📊 Tamaño: $(du -h $BACKUP_FILE | cut -f1)"
    
    # Mantener solo últimos 7 backups
    ls -t $BACKUP_DIR/backup_*.sql.gz | tail -n +8 | xargs rm -f --
    echo "🧹 Backups antiguos eliminados"
else
    echo "❌ Error en el backup"
    exit 1
fi