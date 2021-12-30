##################################################################################
# PROVIDERS
##################################################################################

provider "google" {
  project = "my-project-id"
  region  = "europe-west4"
}

##################################################################################
# DATA
##################################################################################

data "google_compute_image" "my_image" {
  family  = "ubuntu-2004-lts"
  #needed as base image is from public
  project = "ubuntu-os-cloud" 
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "google_compute_network" "vpc" {
  name                    = "test-vpc-network-terraform"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "test-subnetwork-terraform"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = "europe-west4"
}

# ROUTING #
resource "google_compute_route" "igw" {
  dest_range       = "0.0.0.0/0"
  name             = "test-internet-gateway-terraform"
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
    protocol    = "tcp"
    ports       = ["80"]
  }
}

# EGRESS
  # outbound internet access
  # this is implied allow egress rule in GCP via:
  # route (internet gateway), external ip
  # https://cloud.google.com/vpc/docs/firewalls#default_firewall_rules

# INSTANCES #
resource "google_compute_instance" "nginx1" {
  name         = "vm-terraform"
  machine_type = "e2-medium"
  zone         = "europe-west4-c"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.id
    access_config {
      
    }
  }

  # No need to attached firewall rule as that is applied at VPC level
  # if needed network tags can be added to instance and that tag can be used in firewall rule

  metadata_startup_script = <<EOF
#! /bin/bash
sudo apt install -y nginx
sudo service nginx start
sudo rm /var/www/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF

}

