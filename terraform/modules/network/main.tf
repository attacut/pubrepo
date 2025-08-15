resource "aws_vpc" "main" {
  cidr_block                           = var.vpc_config.cidr_block
  instance_tenancy                     = var.vpc_config.instance_tenancy
  enable_dns_support                   = var.vpc_config.enable_dns_support
  enable_dns_hostnames                 = var.vpc_config.enable_dns_hostnames
  enable_network_address_usage_metrics = var.vpc_config.enable_network_address_usage_metrics
  assign_generated_ipv6_cidr_block     = var.vpc_config.assign_generated_ipv6_cidr_block
  ipv4_ipam_pool_id                   = var.vpc_config.ipv4_ipam_pool_id
  ipv4_netmask_length                 = var.vpc_config.ipv4_netmask_length
  ipv6_cidr_block                     = var.vpc_config.ipv6_cidr_block
  ipv6_ipam_pool_id                   = var.vpc_config.ipv6_ipam_pool_id
  ipv6_netmask_length                 = var.vpc_config.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.vpc_config.ipv6_cidr_block_network_border_group
  
  tags = merge(
    {
      Name = "${var.env}-vpc"
    },
    var.vpc_config.tags
  )
}
