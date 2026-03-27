output "gcs_bucket_name" {
  description = "Name of the created GCS data lake bucket"
  value       = google_storage_bucket.data_lake.name
}

output "bq_dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.dwh.dataset_id
}
