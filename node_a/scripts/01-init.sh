#!/bin/bash
set -e

# Создание пользователя для репликации
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_pass';
EOSQL

# Создание тестовой базы данных и таблицы
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE testdb;
    \c testdb
    CREATE TABLE test_table (
        id SERIAL PRIMARY KEY,
        data TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
EOSQL 
