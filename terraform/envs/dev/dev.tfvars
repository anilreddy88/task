project_id  = "my-gcp-project-dev"
region      = "us-central1"
environment = "dev"

# Networking
vpc_name      = "userprofile-dev-vpc"
subnet_cidr   = "10.0.0.0/20"
pods_cidr     = "10.16.0.0/14"
services_cidr = "10.20.0.0/20"

# GKE
gke_cluster_name       = "userprofile-dev-gke"
master_ipv4_cidr_block = "172.16.0.0/28"
master_authorized_cidr = "0.0.0.0/0"

# Cloud SQL
cloudsql_instance_name = "userprofile-dev-db"
db_tier                = "db-f1-micro"
db_name                = "userprofile"
db_user                = "app_user"
db_password            = "change-me-dev"
