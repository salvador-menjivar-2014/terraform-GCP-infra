provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a testing bucket
resource "google_storage_bucket" "testing_bucket" {
  name     = var.bucket_name
  location = var.region
}
