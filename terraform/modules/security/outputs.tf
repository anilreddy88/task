output "workload_gsa_email" {
  description = "Email of the workload GCP service account"
  value       = google_service_account.workload_gsa.email
}

output "workload_gsa_name" {
  description = "Full name of the workload GCP service account"
  value       = google_service_account.workload_gsa.name
}

output "db_secret_id" {
  description = "Secret Manager secret ID for DB connection string"
  value       = google_secret_manager_secret.db_connection_string.secret_id
}
