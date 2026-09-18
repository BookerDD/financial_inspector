from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

default_args = {
    "owner": "admin",
    "start_date": datetime(2026, 9, 18),
    "retries": 1,
    "retry_delay": timedelta(minutes=1)
}

with DAG(
    dag_id="apply_migrations",
    default_args=default_args,
    description="Dag to create schemas, tables, indexes",
    schedule=None,
    catchup=False,
    max_active_runs=1,
    template_searchpath=["/opt/airflow/sql/migrations"],
    tags=["create schemas", "create tables", "create indexes"]
) as dag:
    start = EmptyOperator(task_id="start")

    create_schemas = SQLExecuteQueryOperator(
        task_id="create_schemas",
        conn_id="analytics",
        sql="create_schemas.sql"
    )

    create_raw_tables = SQLExecuteQueryOperator(
        task_id="create_raw_tables",
        conn_id="analytics",
        sql="raw.sql"
    )

    create_service_tables = SQLExecuteQueryOperator(
        task_id="create_service_tables",
        conn_id="analytics",
        sql="service.sql"
    )

    end = EmptyOperator(task_id="end")

    start >> create_schemas >> [create_raw_tables, create_service_tables] >> end # pyright: ignore[reportOperatorIssue]
