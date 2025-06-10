#!/bin/bash

# Функция для проверки статуса репликации
check_replication_status() {
    local node=$1
    local port=$2
    echo "Checking replication status on $node..."
    psql -h $node -p $port -U postgres -d postgres -c "
        SELECT client_addr, state, sync_state, sent_lsn, write_lsn, flush_lsn, replay_lsn
        FROM pg_stat_replication;
    "
}

# Функция для проверки задержки репликации
check_replication_delay() {
    local primary=$1
    local standby=$2
    local port=$3
    echo "Checking replication delay between $primary and $standby..."
    
    # Получаем текущий LSN на primary
    primary_lsn=$(psql -h $primary -p $port -U postgres -d postgres -t -c "
        SELECT pg_current_wal_lsn();
    " | xargs)
    
    # Получаем последний полученный LSN на standby
    standby_lsn=$(psql -h $standby -p $port -U postgres -d postgres -t -c "
        SELECT pg_last_wal_receive_lsn();
    " | xargs)
    
    # Вычисляем задержку в байтах
    delay_bytes=$(psql -h $primary -p $port -U postgres -d postgres -t -c "
        SELECT pg_wal_lsn_diff('$primary_lsn', '$standby_lsn');
    " | xargs)
    
    echo "Replication delay: $delay_bytes bytes"
}

# Функция для тестирования репликации
test_replication() {
    local node=$1
    local port=$2
    echo "Testing replication on $node..."
    
    # Вставляем тестовые данные
    psql -h $node -p $port -U postgres -d testdb -c "
        INSERT INTO test_table (data) VALUES ('Test data at $(date)');
    "
    
    # Проверяем данные на всех узлах
    for n in node_a node_b node_c; do
        echo "Checking data on $n..."
        psql -h $n -p 5432 -U postgres -d testdb -c "
            SELECT * FROM test_table ORDER BY id DESC LIMIT 1;
        "
    done
}

# Основной скрипт
echo "Starting replication check..."

# Проверяем статус репликации на всех узлах
echo -e "\n=== Replication Status ==="
check_replication_status node_a 5432
check_replication_status node_b 5432
check_replication_status node_c 5432

# Проверяем задержку репликации
echo -e "\n=== Replication Delay ==="
check_replication_delay node_a node_b 5432
check_replication_delay node_b node_c 5432

# Тестируем репликацию
echo -e "\n=== Testing Replication ==="
test_replication node_a 5432

echo -e "\nReplication check completed." 
