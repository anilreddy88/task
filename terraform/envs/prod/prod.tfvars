project_id  = "my-gcp-project-prod"
region      = "us-central1"
environment = "prod"

# Networking
vpc_name      = "userprofile-prod-vpc"
subnet_cidr   = "10.8.0.0/20"
pods_cidr     = "10.48.0.0/14"
services_cidr = "10.52.0.0/20"

# GKE
gke_cluster_name       = "userprofile-prod-gke"
master_ipv4_cidr_block = "172.16.0.32/28"
master_authorized_cidr = "10.0.0.0/8"

# Cloud SQL
cloudsql_instance_name = "userprofile-prod-db"
db_tier                = "db-custom-4-8192"
db_name                = "userprofile"
db_user                = "app_user"
db_password            = "change-me-prod"
