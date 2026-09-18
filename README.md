# Персональная финансовая аналитика

Персональная финансовая аналитика: ELT-пайплайн, который превращает выписки из
банков в очищенные, категоризированные операции
в PostgreSQL и показывает их на дашборде Superset.

## Стек

| Компонент | Роль |
|---|---|
| **PostgreSQL 16** | единственное хранилище; один инстанс, три БД |
| **Airflow 2.11** (CeleryExecutor, Python 3.11) | оркестрация: схемы → загрузка → dbt |
| **Redis** | брокер очередей Celery |
| **Superset 4.1** | дашборды поверх БД `analytics` |
| **uv** | зависимости и локальное окружение |
| **dbt** | трансформации staging → core → marts |

### Базы данных


| БД | Роль | Что внутри |
|---|---|---|
| `analytics` | `analytics` | данные проекта: `raw`, `service`, позже `staging` / `core` / `marts` |
| `airflow` | `airflow` | метабаза Airflow, схему ведёт сам Airflow |
| `superset` | `superset` | метабаза Superset: дашборды, чарты, пользователи |

БД и роли создаёт [postgres-init/01-create-databases.sh](postgres-init/01-create-databases.sh)
при первом старте на пустом volume.

### Схемы БД `analytics`

| Схема | Что лежит |
|---|---|
| `raw` | строки выписок как есть, таблица на банк: `raw.tbank_transactions` |
| `service` | служебное: `service.load_history` — журнал загрузок, `service.parse_rejects` — строки, которые парсер не разобрал |

## Запуск

Нужен Docker с Compose v2.

1. Скопировать шаблон переменных и при желании сменить пароли:

   ```bash
   cp .env.example .env
   ```

   Пароли — только латиница и цифры: они подставляются в строки подключения.
   `AIRFLOW_SECRET_KEY` и `SUPERSET_SECRET_KEY` заменить на случайные строки,
   например `openssl rand -hex 32`.

   Если порты 5432 / 8080 / 8088 заняты, поменять `POSTGRES_HOST_PORT`,
   `AIRFLOW_HOST_PORT`, `SUPERSET_HOST_PORT`.

2. Поднять стек. `COMPOSE_FILE` в `.env` объединяет все три compose-файла,
   `-f` не нужен:

   ```bash
   docker compose up -d
   ```

3. Создать схемы и таблицы — запустить DAG `apply_migrations` в UI Airflow
   или из консоли:

   ```bash
   docker compose exec airflow-scheduler airflow dags trigger apply_migrations
   ```

4. Интерфейсы (порты по умолчанию):

   | Сервис | Адрес | Учётка |
   |---|---|---|
   | Airflow | http://localhost:8080 | `AIRFLOW_ADMIN_USERNAME` / `AIRFLOW_ADMIN_PASSWORD` |
   | Superset | http://localhost:8088 | `SUPERSET_ADMIN_USERNAME` / `SUPERSET_ADMIN_PASSWORD` |
   | Postgres | `localhost:5432`, БД `analytics` | роль `analytics` / `ANALYTICS_DB_PASSWORD` |

Остановить без потери данных:

```bash
docker compose down
```
