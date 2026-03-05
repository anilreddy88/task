module "networking" {
  source = "./modules/networking"

  project_id    = var.project_id
  region        = var.region
  vpc_name      = var.vpc_name
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

module "gke" {
  source = "./modules/gke"

  project_id             = var.project_id
  region                 = var.region
  cluster_name           = var.gke_cluster_name
  network_id             = module.networking.network_id
  subnet_id              = module.networking.subnet_id
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  master_authorized_cidr = var.master_authorized_cidr

  depends_on = [module.networking]
}

module "cloudsql" {
  source = "./modules/cloudsql"

  project_id             = var.project_id
  region                 = var.region
  instance_name          = var.cloudsql_instance_name
  network_id             = module.networking.network_id
  private_vpc_connection = module.networking.private_vpc_connection
  db_tier                = var.db_tier
  db_name                = var.db_name
  db_user                = var.db_user
  db_password            = var.db_password

  depends_on = [module.networking]
}
