output "gcp_instance_public_dns" {
  value = google_compute_instance.nginx1.network_interface.0.access_config.0.nat_ip
}