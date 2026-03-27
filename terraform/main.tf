terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# ── GCS Bucket (Data Lake) ──────────────────────────────────────────────────

resource "google_storage_bucket" "data_lake" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true 

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  versioning {
    enabled = true
  }
}

# ── GCS Folders ─────────────────────────────────────────────────────────────

resource "google_storage_bucket_object" "raw_folder" {
  name    = "raw/"
  content = " "
  bucket  = google_storage_bucket.data_lake.name
}

resource "google_storage_bucket_object" "processed_folder" {
  name    = "processed/"
  content = " "
  bucket  = google_storage_bucket.data_lake.name
}

# ── BigQuery Dataset (Data Warehouse) ───────────────────────────────────────

resource "google_bigquery_dataset" "dwh" {
  dataset_id                 = var.bq_dataset_name
  project                    = var.project_id
  location                   = var.location
  description                = "Olist e-commerce data warehouse"
  delete_contents_on_destroy = true
}
