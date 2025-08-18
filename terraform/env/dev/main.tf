module "vpc-internal" {
  source              = "../../modules/network"
  vpc_config          = var.vpc_internal_config
  subnets_config      = var.subnets_internal_config
  route_tables_config = var.route_tables_internal_config
  env                 = var.env
}

module "vpc-internet-facing" {
  source              = "../../modules/network"
  vpc_config          = var.vpc_internet_facing_config
  subnets_config      = var.subnets_internet_facing_config
  route_tables_config = var.route_tables_internet_facing_config
  env                 = var.env
}
