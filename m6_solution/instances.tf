##################################################################################
# DATA
##################################################################################

data "google_compute_image" "my_image" {
  family = var.compute_image_family
  # needed as base image is from public
  project = var.compute_image_project
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

  service_account {
    email  = var.instance_service_account_email
    scopes = ["storage-full"] # adding scope installs gcloud tool?
  }

  depends_on = [google_storage_bucket_iam_binding.policy]

  # No need to attached firewall rule as that is applied at VPC level
  # if needed network tags can be added to instance and that tag can be used in firewall rule

  metadata_startup_script = <<EOF
#! /bin/bash
sudo apt install -y nginx
sudo service nginx start
gsutil cp gs://${google_storage_bucket.course-test.name}/index.html /home/ubuntu/index.html
gsutil cp gs://${google_storage_bucket.course-test.name}/Globo_logo_Vert.png /home/ubuntu/Globo_logo_Vert.png
sudo rm /var/www/html/index.html
sudo cp /home/ubuntu/index.html /var/www/html/index.html
sudo cp /home/ubuntu/Globo_logo_Vert.png /var/www/html/Globo_logo_Vert.png
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

  service_account {
    email  = var.instance_service_account_email
    scopes = ["storage-full"] #adding scope installs gcloud tool?
  }

  depends_on = [google_storage_bucket_iam_binding.policy]

  # No need to attach firewall rule as that is applied at VPC level
  # if needed network tags can be added to instance and that tag can be used in firewall rule

  metadata_startup_script = <<EOF
#! /bin/bash
sudo apt install -y nginx
sudo service nginx start
gsutil cp gs://${google_storage_bucket.course-test.name}/index.html /home/ubuntu/index.html
gsutil cp gs://${google_storage_bucket.course-test.name}/Globo_logo_Vert.png /home/ubuntu/Globo_logo_Vert.png
sudo rm /var/www/html/index.html
sudo cp /home/ubuntu/index.html /var/www/html/index.html
sudo cp /home/ubuntu/Globo_logo_Vert.png /var/www/html/Globo_logo_Vert.png
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