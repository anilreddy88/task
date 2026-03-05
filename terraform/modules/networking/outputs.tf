output "network_id" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "Self-link of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "subnet_name" {
  description = "Name of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "private_vpc_connection" {
  description = "The private VPC connection for Cloud SQL"
  value       = google_service_networking_connection.private_vpc_connection
}
