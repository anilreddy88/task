variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resource deployment"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, production)"
  type        = string
  default     = "dev"
}

# ── Networking ──

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "userprofile-vpc"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the GKE subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.16.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.20.0.0/20"
}

# ── GKE ──

variable "gke_cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
  default     = "userprofile-gke"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_cidr" {
  description = "CIDR block allowed to access the GKE master endpoint"
  type        = string
  default     = "0.0.0.0/0"
}

# ── Cloud SQL ──

variable "cloudsql_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "userprofile-db"
}

variable "db_tier" {
  description = "Machine tier for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
  default     = "userprofile"
}

variable "db_user" {
  description = "Database user name"
  type        = string
  default     = "app_user"
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}
