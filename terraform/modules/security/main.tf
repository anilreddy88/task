# Dedicated GCP Service Account for the workload
resource "google_service_account" "workload_gsa" {
  account_id   = "userprofile-workload-sa"
  display_name = "User Profile Workload Service Account"
  project      = var.project_id
}

# Workload Identity binding: allow KSA to impersonate GSA
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.workload_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}

# Least-privilege IAM: Cloud SQL Client access only
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.workload_gsa.email}"
}

# Least-privilege IAM: Secret Manager accessor only
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.workload_gsa.email}"
}

# Store the Cloud SQL connection string in Secret Manager
resource "google_secret_manager_secret" "db_connection_string" {
  secret_id = "userprofile-db-connection-string"
  project   = var.project_id

  replication {
    auto {}
  }
}

# Populate the secret with the actual connection string
resource "google_secret_manager_secret_version" "db_connection_string_value" {
  secret      = google_secret_manager_secret.db_connection_string.id
  secret_data = "postgresql://${var.db_user}:${var.db_password}@${var.db_private_ip}:5432/${var.db_name}"
}
