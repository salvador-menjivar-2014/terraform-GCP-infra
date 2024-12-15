provider "google" {
  project = var.project_id
  region  = var.region
}


terraform {
  backend "gcs" {
    bucket = "bucket-keep-vertex-ai-tracking"  
    prefix = "terraform/state"           
  }
}

resource "random_id" "bucket_name_suffix" {
  byte_length = 8
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
  name                        = "vertex-ai-index-bucket-${random_id.bucket_name_suffix.hex}"
  location                    = "us-central1"
  uniform_bucket_level_access = true
}

# Create index content
resource "google_storage_bucket_object" "data" {
  name    = "contents/data.json"
  bucket  = google_storage_bucket.bucket.name
  content = <<EOF
{"id": "42", "embedding": [0.5, 1.0], "restricts": [{"namespace": "class", "allow": ["cat", "pet"]},{"namespace": "category", "allow": ["feline"]}]}
{"id": "43", "embedding": [0.6, 1.0], "restricts": [{"namespace": "class", "allow": ["dog", "pet"]},{"namespace": "category", "allow": ["canine"]}]}
{"id": "44", "embedding": [0.5, 1.0], "restricts": [{"namespace": "class", "allow": ["dog", "pet"]},{"namespace": "category", "allow": ["canine"]}]}
EOF
}

resource "google_vertex_ai_index" "default" {
  region       = "us-central1"
  display_name = "sample-index-batch-update"
  description  = "A sample index for batch update"
  labels = {
    foo = "bar"
  }

  metadata {
    contents_delta_uri = "gs://${google_storage_bucket.bucket.name}/contents"
    config {
      dimensions                  = 2
      approximate_neighbors_count = 150
      distance_measure_type       = "DOT_PRODUCT_DISTANCE"
      algorithm_config {
        tree_ah_config {
          leaf_node_embedding_count    = 500
          leaf_nodes_to_search_percent = 7
        }
      }
    }
  }
  index_update_method = "BATCH_UPDATE"

  timeouts {
    create = "2h"
    update = "1h"
  }
}