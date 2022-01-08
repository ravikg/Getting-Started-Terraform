##################################################################################
# DATA
##################################################################################

data "google_compute_image" "my_image" {
  family  = var.compute_image_family
  #needed as base image is from public
  project =  var.compute_image_project
}

data "google_compute_zones" "available" {
  status = "UP"
}

##################################################################################
# RESOURCES
##################################################################################

# INSTANCES #
resource "google_compute_instance" "nginx1" {
  name                      = "vm-terraform-1"
  machine_type              = var.compute_machine_type
  zone                      = data.google_compute_zones.available.names[0]
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

  # No need to attached firewall rule as that is applied at VPC level
  # if needed network tags can be added to instance and that tag can be used in firewall rule

  metadata_startup_script = <<EOF
#! /bin/bash
sudo apt install -y nginx
sudo service nginx start
sudo rm /var/www/html/index.html
echo '<html><head><title>Taco Team Server 1</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF

}

resource "google_compute_instance" "nginx2" {
  name                      = "vm-terraform-2"
  machine_type              = var.compute_machine_type
  zone                      = data.google_compute_zones.available.names[1]
  allow_stopping_for_update = true
  labels                    = local.common_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet2.id
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
echo '<html><head><title>Taco Team Server 2</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF

}

# INSTANCE GROUPS
## Needed for load balancer
resource "google_compute_instance_group" "serversgroup1" {
  name        = "terraform-servers-group-1"
  description = "Terraform test instance group"
  instances   = [google_compute_instance.nginx1.id]
  zone        = data.google_compute_zones.available.names[0]
  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "serversgroup2" {
  name        = "terraform-servers-group-2"
  description = "Terraform test instance group"
  instances   = [google_compute_instance.nginx2.id]
  zone        = data.google_compute_zones.available.names[1]
  named_port {
    name = "http"
    port = "80"
  }
}