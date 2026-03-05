variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the workload"
  type        = string
  default     = "default"
}

variable "k8s_service_account" {
  description = "Kubernetes service account name"
  type        = string
  default     = "user-profile-ksa"
}

variable "cloudsql_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  type        = string
}

variable "db_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
