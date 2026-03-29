import os
from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def create_spark_session():
    return (
        SparkSession.builder.appName("OlistTransformation")
        .master("local[*]")
        .getOrCreate()
    )


def process_olist(bucket_name, local_dir="/tmp/olist_spark"):
    from google.cloud import storage

    # ── Step 1: Download CSVs from GCS to local container ──────────────────
    print("Downloading CSVs from GCS to local...")
    os.makedirs(local_dir, exist_ok=True)
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    blobs = bucket.list_blobs(prefix="raw/")
    for blob in blobs:
        if blob.name.endswith(".csv"):
            filename = blob.name.split("/")[-1]
            local_path = os.path.join(local_dir, filename)
            blob.download_to_filename(local_path)
            print(f"Downloaded {filename}")

    # ── Step 2: Run Spark on local files ───────────────────────────────────
    print("Starting Spark transformation...")
    spark = create_spark_session()

    def read_csv(filename):
        return (
            spark.read.option("header", True)
            .option("inferSchema", True)
            .csv(os.path.join(local_dir, filename))
        )

    orders = read_csv("olist_orders_dataset.csv")
    order_items = read_csv("olist_order_items_dataset.csv")
    order_payments = read_csv("olist_order_payments_dataset.csv")
    order_reviews = read_csv("olist_order_reviews_dataset.csv")
    customers = read_csv("olist_customers_dataset.csv")
    sellers = read_csv("olist_sellers_dataset.csv")
    products = read_csv("olist_products_dataset.csv")
    geolocation = read_csv("olist_geolocation_dataset.csv")
    translation = read_csv("product_category_name_translation.csv")

    # Clean orders — fix timestamps and add date column
    orders = (
        orders.withColumn(
            "order_purchase_timestamp", F.to_timestamp("order_purchase_timestamp")
        )
        .withColumn("order_approved_at", F.to_timestamp("order_approved_at"))
        .withColumn(
            "order_delivered_customer_date",
            F.to_timestamp("order_delivered_customer_date"),
        )
        .withColumn(
            "order_estimated_delivery_date",
            F.to_timestamp("order_estimated_delivery_date"),
        )
        .withColumn("order_purchase_date", F.to_date("order_purchase_timestamp"))
    )

    # Add English category names to products
    products = products.join(
        translation, on="product_category_name", how="left"
    ).withColumn(
        "product_category_name_english",
        F.coalesce(F.col("product_category_name_english"), F.lit("unknown")),
    )

    # Write Parquet files locally
    output_dir = "/tmp/olist_parquet"
    print("Writing Parquet files locally...")
    orders.write.mode("overwrite").parquet(f"{output_dir}/orders")
    order_items.write.mode("overwrite").parquet(f"{output_dir}/order_items")
    order_payments.write.mode("overwrite").parquet(f"{output_dir}/order_payments")
    order_reviews.write.mode("overwrite").parquet(f"{output_dir}/order_reviews")
    customers.write.mode("overwrite").parquet(f"{output_dir}/customers")
    sellers.write.mode("overwrite").parquet(f"{output_dir}/sellers")
    products.write.mode("overwrite").parquet(f"{output_dir}/products")
    geolocation.write.mode("overwrite").parquet(f"{output_dir}/geolocation")

    spark.stop()
    print("Spark done!")

    # ── Step 3: Upload Parquet files to GCS ────────────────────────────────
    print("Uploading Parquet files to GCS...")
    for table in os.listdir(output_dir):
        table_path = os.path.join(output_dir, table)
        if os.path.isdir(table_path):
            for parquet_file in os.listdir(table_path):
                if parquet_file.endswith(".parquet"):
                    local_file = os.path.join(table_path, parquet_file)
                    gcs_path = f"processed/{table}/{parquet_file}"
                    blob = bucket.blob(gcs_path)
                    blob.upload_from_filename(local_file)
            print(f"Uploaded {table}")

    # Cleanup temp files
    import shutil

    shutil.rmtree(local_dir, ignore_errors=True)
    shutil.rmtree(output_dir, ignore_errors=True)
    print("All done! Parquet files in GCS processed/ folder.")
