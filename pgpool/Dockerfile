FROM pgpool/pgpool:4.4

# Установка дополнительных утилит
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Копирование конфигурации
COPY conf/ /usr/local/etc/

# Установка прав
RUN chown -R pgpool:pgpool /usr/local/etc

USER pgpool 
