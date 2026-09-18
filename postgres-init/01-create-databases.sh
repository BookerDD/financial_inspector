#!/bin/bash
# Создаёт три логические БД проекта, у каждой — своя роль-владелец:
#   airflow   — метабаза Airflow, схему ведёт сам Airflow
#   superset  — метабаза Superset, схему ведёт сам Superset
#   analytics — наша БД: raw, service, staging, core, marts

# Выполняется образом postgres только при первом старте на ПУСТОМ volume.
# Если volume уже существует, скрипт не запустится — пересоздать с нуля:
#   docker compose down -v && docker compose up -d
set -euo pipefail

psql -v ON_ERROR_STOP=1 \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    -v airflow_pw="$AIRFLOW_DB_PASSWORD" \
    -v superset_pw="$SUPERSET_DB_PASSWORD" \
    -v analytics_pw="$ANALYTICS_DB_PASSWORD" <<'EOSQL'
CREATE ROLE airflow LOGIN PASSWORD :'airflow_pw';
CREATE ROLE superset LOGIN PASSWORD :'superset_pw';
CREATE ROLE analytics LOGIN PASSWORD :'analytics_pw';

CREATE DATABASE airflow OWNER airflow;
CREATE DATABASE superset OWNER superset;
CREATE DATABASE analytics OWNER analytics;

-- По умолчанию подключиться к любой БД может кто угодно (PUBLIC).
-- Закрываем: каждая роль ходит только в свою БД.
REVOKE CONNECT ON DATABASE airflow FROM PUBLIC;
REVOKE CONNECT ON DATABASE superset FROM PUBLIC;
REVOKE CONNECT ON DATABASE analytics FROM PUBLIC;
EOSQL
