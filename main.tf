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
  credentials = var.gcp_credentials
  project     = var.gcp_project_id
  region      = var.region
}

# Generate a random string for the VPC suffix
resource "random_string" "vpc_suffix" {
  length  = 8
  upper   = false
  special = false
}

# Create a custom VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-gcp-project-vpc-${random_string.vpc_suffix.result}"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Create a custom subnetwork
resource "google_compute_subnetwork" "subnetwork" {
  name          = "my-project-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

# Create a reserved peering range for service networking
resource "google_compute_global_address" "reserved_peering_range" {
  name          = "my-reserved-peering-range-2024"
  address_type  = "INTERNAL"
  prefix_length = 16  
  purpose       = "VPC_PEERING"  
  network       = google_compute_network.vpc_network.id  
}

# Create the Backup and DR management server
resource "google_backup_dr_management_server" "ms_console" {
  provider = google-beta
  location = "us-central1"
  name     = "ms-console"
  type     = "BACKUP_RESTORE"

  networks {
    network      = google_compute_network.vpc_network.id  
    peering_mode = "PRIVATE_SERVICE_ACCESS"
  }

  depends_on = [google_service_networking_connection.default]
} 
