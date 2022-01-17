output "gcp_instance_public_dns_1" {
  value = google_compute_instance.nginx1.network_interface.0.access_config.0.nat_ip
}

output "gcp_instance_public_dns_2" {
  value = google_compute_instance.nginx2.network_interface.0.access_config.0.nat_ip
}

output "gcp_load_balancer_external_ip" {
  value = module.gce-lb-http.external_ip
}