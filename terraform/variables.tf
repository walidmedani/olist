variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "olist-pipeline-491503"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "location" {
  description = "GCP location for BigQuery"
  type        = string
  default     = "US"
}

variable "gcs_bucket_name" {
  description = "Name of the GCS data lake bucket"
  type        = string
  default     = "olist-data-lake-491503"
}

variable "bq_dataset_name" {
  description = "BigQuery dataset name"
  type        = string
  default     = "olist_dwh"
}

variable "credentials_file" {
  description = "Path to GCP service account JSON key"
  type        = string
  default     = "/home/walid/.gcp/olist-pipeline-sa.json"
}
