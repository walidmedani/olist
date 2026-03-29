import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    "owner": "walid",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "start_date": datetime(2024, 1, 1),
}

GCP_BUCKET = os.environ.get("GCP_BUCKET_NAME", "olist-data-lake-491503")
GCP_PROJECT = os.environ.get("GCP_PROJECT_ID", "olist-pipeline-491503")
BQ_DATASET = os.environ.get("GCP_BQ_DATASET", "olist_dwh")


TABLES = [
    "orders",
    "order_items",
    "order_payments",
    "order_reviews",
    "customers",
    "sellers",
    "products",
    "geolocation",
]


def run_spark_transformation():
    """Run Spark job to transform CSVs into Parquet."""
    import sys

    sys.path.insert(0, "/opt/airflow/spark/jobs")
    from process_olist import process_olist

    process_olist(GCP_BUCKET)


def load_to_bigquery():
    """Load Parquet files from GCS into BigQuery tables."""
    from google.cloud import bigquery

    client = bigquery.Client(project=GCP_PROJECT)

    for table in TABLES:
        gcs_uri = f"gs://{GCP_BUCKET}/processed/{table}/*.parquet"
        table_ref = f"{GCP_PROJECT}.{BQ_DATASET}.{table}"

        job_config = bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.PARQUET,
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            autodetect=True,
        )

        # Add partitioning for orders table
        if table == "orders":
            job_config.time_partitioning = bigquery.TimePartitioning(
                type_=bigquery.TimePartitioningType.DAY,
                field="order_purchase_date",
            )
            job_config.clustering_fields = ["order_status", "customer_id"]

        # Add clustering for order_items
        if table == "order_items":
            job_config.clustering_fields = ["seller_id", "product_id"]

        print(f"Loading {table} into BigQuery...")
        load_job = client.load_table_from_uri(gcs_uri, table_ref, job_config=job_config)
        load_job.result()
        print(f"Loaded {table} successfully.")

    print("All tables loaded into BigQuery!")


with DAG(
    dag_id="olist_warehouse",
    default_args=default_args,
    description="Transform with Spark and load to BigQuery",
    schedule_interval="@monthly",
    catchup=False,
    tags=["olist", "warehouse"],
) as dag:
    spark_task = PythonOperator(
        task_id="spark_transformation",
        python_callable=run_spark_transformation,
    )

    bigquery_task = PythonOperator(
        task_id="load_to_bigquery",
        python_callable=load_to_bigquery,
    )

    spark_task >> bigquery_task
