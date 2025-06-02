module "vpc-internal" {
  source   = "../../modules/network"
  vpc_cidr = var.vpc_cidr
  env      = var.env
}

module "vpc-internet-facing" {
  source   = "../../modules/network"
  vpc_cidr = var.vpc_cidr
  env      = var.env
}
