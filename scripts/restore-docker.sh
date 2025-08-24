#!/bin/bash
# restore-docker.sh - Restauración usando la imagen oficial de PostgreSQL

set -e

# Validar variables
required_vars=("DB_HOST" "DB_PORT" "DB_USER" "DB_PASSWORD" "DB_NAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Variable $var no definida"
        exit 1
    fi
done

BACKUP_DIR="/home/ubuntu/backups"

echo "📋 Backups disponibles:"
ls -la $BACKUP_DIR/backup_*.sql.gz

if [ $# -eq 0 ]; then
    echo "🚨 Uso: ./restore-docker.sh <archivo_backup>"
    echo "Ejemplo: ./restore-docker.sh backup_20241224_123456.sql.gz"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Archivo no encontrado: $BACKUP_FILE"
    exit 1
fi

echo "🔄 Restaurando: $BACKUP_FILE"
echo "⚠️  ADVERTENCIA: Esto borrará datos actuales de $DB_NAME"

read -p "¿Continuar? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ Cancelado"
    exit 0
fi

# Restaurar usando la imagen oficial de PostgreSQL
gunzip -c "$BACKUP_FILE" | docker run --rm -i \
  -e PGPASSWORD="$DB_PASSWORD" \
  postgres:15-alpine \
  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME

echo "✅ Restauración completada en $DB_NAME"