variable "google_project" {
  type        = string
  description = "Google Cloud Project Id"
}

variable "gcp_region" {
  type    = string
  default = "europe-west4"
}

variable "gcp_zone" {
  type    = string
  default = "europe-west4-c"
}

variable "compute_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "compute_image_project" {
  type    = string
  default = "ubuntu-os-cloud"
}

variable "ip_cidr_ranges" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "route_destination_range" {
  type    = string
  default = "0.0.0.0/0"
}

variable "compute_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "disk_type" {
  type    = string
  default = "pd-ssd"
}

variable "company" {
  type    = string
  default = "globomantics"
}

variable "project" {
  type = string
}

variable "billing_code" {
  type = string
}

variable "network_prefix" {
  type    = string
  default = "multi-mig-lb-http"
}