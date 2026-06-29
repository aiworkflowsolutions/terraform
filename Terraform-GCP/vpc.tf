# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc-${random_id.unique_suffix.hex}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"
  project       = var.project_id
}

# Enable Private Services Access
resource "google_compute_global_address" "private_service_access_ip_range" {
  name          = "private-service-access-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.self_link
  project       = var.project_id
}

# Establish a VPC peering connection
resource "google_service_networking_connection" "private_services_access" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access_ip_range.name]
}