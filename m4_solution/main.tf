##################################################################################
# PROVIDERS
##################################################################################

provider "google" {
  project = var.google_project
  region  = var.gcp_region
}

##################################################################################
# DATA
##################################################################################

data "google_compute_image" "my_image" {
  family  = var.compute_image_family
  #needed as base image is from public
  project =  var.compute_image_project
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
  ip_cidr_range = var.ip_cidr_range
  network       = google_compute_network.vpc.id
  region        = var.gcp_region
}

# ROUTING #
resource "google_compute_route" "igw" {
  dest_range       = var.route_destination_range
  name             = "test-internet-gateway-terraform"
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
}

# SECURITY GROUPS / FIREWALL #
# Nginx security group 
# INGRESS - HTTP access from anywhere
resource "google_compute_firewall" "nginx-sg" {
  name          = "nginx-sg"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol    = "tcp"
    ports       = ["80"]
  }
}

# INGRESS - Allow SSH from IAP
# https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule
resource "google_compute_firewall" "ssh-iap-terraform" {
  name          = "ssh-iap-terraform"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
}

# EGRESS
  # outbound internet access
  # this is implied allow egress rule in GCP via:
  # route (internet gateway), external ip
  # https://cloud.google.com/vpc/docs/firewalls#default_firewall_rules

# INSTANCES #
resource "google_compute_instance" "nginx1" {
  name                      = "vm-terraform"
  machine_type              = var.compute_machine_type
  zone                      = var.gcp_zone
  allow_stopping_for_update = true
  labels                    = local.common_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.id
    access_config {
      
    }
  }

  # No need to attach firewall rule as that is applied at VPC level
  # if needed network tags can be added to instance and that tag can be used in firewall rule

  metadata_startup_script = <<EOF
#! /bin/bash
sudo apt install -y nginx
sudo service nginx start
sudo rm /var/www/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF

}
