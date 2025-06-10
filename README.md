# Настройка каскадной репликации PostgreSQL с pgpool-II

Этот проект демонстрирует настройку каскадной репликации PostgreSQL с использованием pgpool-II, где:
- Node A является первичным сервером
- Node B является синхронной репликой Node A
- Node C является асинхронной репликой Node B

## Требования

- Docker
- Docker Compose
- PostgreSQL клиент (для проверки репликации)

## Структура проекта

```
.
├── docker-compose.yml
├── node_a/
│   ├── Dockerfile
│   ├── conf/
│   │   ├── postgresql.conf
│   │   └── pg_hba.conf
│   └── scripts/
│       └── 01-init.sh
├── node_b/
│   ├── Dockerfile
│   ├── conf/
│   │   ├── postgresql.conf
│   │   └── pg_hba.conf
│   └── scripts/
│       └── 01-init.sh
├── node_c/
│   ├── Dockerfile
│   ├── conf/
│   │   ├── postgresql.conf
│   │   └── pg_hba.conf
│   └── scripts/
│       └── 01-init.sh
├── pgpool/
│   ├── Dockerfile
│   └── conf/
│       ├── pgpool.conf
│       └── pool_hba.conf
└── scripts/
    └── check_replication.sh
```

## Запуск

1. Создайте необходимые директории для данных:
```bash
mkdir -p node_a/data node_b/data node_c/data
```

2. Запустите кластер:
```bash
docker-compose up -d
```

3. Дождитесь инициализации всех узлов (может занять несколько минут):
```bash
docker-compose ps
```

## Проверка работоспособности

1. Проверка статуса репликации:
```bash
./scripts/check_replication.sh
```

Скрипт выполнит следующие проверки:
- Статус репликации на всех узлах
- Задержку репликации между узлами
- Тестовую запись данных и их репликацию

## Подключение к базе данных

- Через pgpool-II (рекомендуется для приложений):
  ```
  Host: localhost
  Port: 9999
  Database: testdb
  User: postgres
  Password: postgres
  ```

- Напрямую к узлам:
  - Node A: localhost:5432
  - Node B: localhost:5433
  - Node C: localhost:5434

## Особенности конфигурации

1. Node A (Primary):
   - Настроен как первичный сервер
   - Синхронная репликация на Node B
   - WAL архивирование включено

2. Node B (Standby):
   - Синхронная репликация с Node A
   - Асинхронная репликация на Node C
   - Настроен как промежуточный узел

3. Node C (Standby):
   - Асинхронная репликация с Node B
   - Настроен как конечный узел

4. pgpool-II:
   - Настроен для балансировки нагрузки
   - Поддерживает автоматическое переключение при отказе
   - Мониторинг состояния узлов

## Мониторинг

1. Проверка статуса узлов:
```bash
docker-compose ps
```

2. Просмотр логов:
```bash
docker-compose logs -f [node_a|node_b|node_c|pgpool]
```

3. Проверка репликации:
```bash
./scripts/check_replication.sh
```

## Остановка

```bash
docker-compose down
```

Для полной очистки данных:
```bash
docker-compose down -v
rm -rf node_a/data node_b/data node_c/data
```

## Примечания

- Все пароли в конфигурации установлены для демонстрационных целей
- В продакшн-среде необходимо использовать более сложные пароли
- Рекомендуется настроить мониторинг и оповещения
- Для продакшн-среды рекомендуется настроить SSL
- Необходимо настроить регулярное резервное копирование 
