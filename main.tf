provider "google" {
<<<<<<< HEAD
  credentials = env("GOOGLE_CREDENTIALS") # Use the environment variable directly
  project     = var.gcp_project_id
  region      = var.region
}


resource "google_compute_instance" "default" {
  name         = "my-new-vm-test"
  machine_type = "e2-medium"
  zone         = "us-central1-a"  # Replace with your desired zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230829" # Or your preferred image
    }
  }

  network_interface {
    network = "default"
    access_config {}  # For an ephemeral IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello, World!" > /var/log/startup-script.log
  EOT
}


output "ip_address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
=======
  project = var.project_id
  region  = var.region
>>>>>>> 0f7a15f (new updates)
}

# Create a testing bucket
resource "google_storage_bucket" "testing_bucket" {
  name     = var.bucket_name
  location = var.region
}