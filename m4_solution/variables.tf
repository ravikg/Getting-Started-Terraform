variable "google_project" {
    type        = string
    description = "Google Cloud Project Id"
}

variable "gcp_region" {
  type        = string
  default     = "europe-west4"
  description = "Region for GCP Resources"
}

variable "gcp_zone" {
  type        = string
  default     = "europe-west4-c"
  description = "Zone for GCP Resources"
}

variable "compute_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS family name of VM / Compute Instance Image"
}

variable "compute_image_project" {
  type        = string
  default     = "ubuntu-os-cloud"
  description = "Public project name of the OS Image"
}

variable "ip_cidr_range" {
  type        = string
  default     = "10.0.0.0/24"
  description = "IPs CIDR Block for Subnet in VPC"
}

variable "route_destination_range" {
    type        = string
    default     = "0.0.0.0/0"
    description = "Destination range of IPs"
}

variable "compute_machine_type" {
    type        = string
    default     = "e2-medium"
    description = "Machine type of Compute Instance"
}

variable "disk_type" {
  type        = string
  default     = "pd-ssd"
  description = "Disk type of compute instance"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "globomantics"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}