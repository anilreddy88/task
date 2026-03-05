variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "network_id" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "private_vpc_connection" {
  description = "The private VPC connection resource (dependency for private IP)"
  type        = any
}

variable "db_tier" {
  description = "Machine tier for the Cloud SQL instance"
  type        = string
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
}

variable "db_user" {
  description = "Database user name"
  type        = string
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}
