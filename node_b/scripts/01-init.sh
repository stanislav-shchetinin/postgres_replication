#!/bin/bash
set -e

# Ожидание доступности node_a
until pg_isready -h node_a -p 5432 -U postgres; do
    echo "Waiting for node_a to be ready..."
    sleep 2
done

# Создание пользователя для репликации
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_pass';
EOSQL

# Инициализация репликации
pg_basebackup -h node_a -p 5432 -U replicator -D $PGDATA -Fp -Xs -P -R \
    --application-name=node_b \
    --primary-conninfo="host=node_a port=5432 user=replicator password=replicator_pass application_name=node_b"

# Создание recovery.conf
cat > $PGDATA/recovery.conf << EOF
standby_mode = 'on'
primary_conninfo = 'host=node_a port=5432 user=replicator password=replicator_pass application_name=node_b'
recovery_target_timeline = 'latest'
EOF 
