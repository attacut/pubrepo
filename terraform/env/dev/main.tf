module "vpc-internal" {
  source     = "../../modules/network"
  vpc_config = var.vpc_internal_config
  env        = var.env
}

module "vpc-internet-facing" {
  source     = "../../modules/network"
  vpc_config = var.vpc_internet_facing_config
  env        = var.env
}
