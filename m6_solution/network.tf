##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "google_compute_network" "vpc" {
  name                    = "vpc-network-terraform"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1-terraform"
  ip_cidr_range = var.ip_cidr_ranges[0]
  network       = google_compute_network.vpc.id
  region        = var.gcp_region
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2-terraform"
  ip_cidr_range = var.ip_cidr_ranges[1]
  network       = google_compute_network.vpc.id
  region        = var.gcp_region
}

# ROUTING #
resource "google_compute_route" "igw" {
  name             = "test-internet-gateway-terraform"
  dest_range       = var.route_destination_range
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
}

# SECURITY GROUPS / FIREWALL #
# Nginx security group 
# INGRESS
resource "google_compute_firewall" "nginx-sg" {
  name    = "nginx-sg"
  network = google_compute_network.vpc.id

  # HTTP access from anywhere
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# INGRESS
resource "google_compute_firewall" "ssh-iap-terraform" {
  name    = "ssh-iap-terraform"
  network = google_compute_network.vpc.id

  # Allow ingress from IAP for SSH
  # https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# EGRESS
# outbound internet access
# this is implied allow egress rule in GCP via:
# route (internet gateway), external ip
# https://cloud.google.com/vpc/docs/firewalls#default_firewall_rules
