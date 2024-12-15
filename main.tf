provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "testing_bucket" {
  name     = var.bucket_name
  location = var.region
}