terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  credentials = var.google_credentials
  project     = var.gcp_project_id
  region      = var.region
}

resource "google_compute_instance" "default" {
  name         = "my-linux-vm"
  machine_type = "e2-medium"                                   # Machine type
  zone         = "us-central1-a"                              # Specify the zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230829" # Ubuntu image
    }
  }

  network_interface {
    network = "default"                                       # Use the default network
    access_config {                                          # Create a public IP address
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
              #!/bin/bash
              echo "Hello, World!" > /var/log/startup-script.log
              EOT
}

output "ip_address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
