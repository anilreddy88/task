variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
}

variable "network_id" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "subnet_id" {
  description = "Self-link of the GKE subnet"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master network"
  type        = string
}

variable "master_authorized_cidr" {
  description = "CIDR block allowed to access the GKE master endpoint"
  type        = string
}
