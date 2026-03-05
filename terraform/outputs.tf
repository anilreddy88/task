# Networking
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = module.networking.network_name
}

output "gke_subnet_name" {
  description = "Name of the GKE subnet"
  value       = module.networking.subnet_name
}

# GKE
output "gke_cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "gke_cluster_location" {
  description = "Location of the GKE cluster"
  value       = module.gke.cluster_location
}

# Cloud SQL
output "cloudsql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.cloudsql.instance_name
}

output "cloudsql_connection_name" {
  description = "Connection name for the Cloud SQL instance"
  value       = module.cloudsql.instance_connection_name
}

output "cloudsql_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.cloudsql.private_ip_address
}

output "cloudsql_database_name" {
  description = "Name of the application database"
  value       = module.cloudsql.database_name
}
