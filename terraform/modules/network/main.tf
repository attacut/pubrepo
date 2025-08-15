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

# Subnets
resource "aws_subnet" "subnets" {
  for_each = var.subnets_config
  
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                    = each.value.cidr_block
  availability_zone                             = each.value.availability_zone
  map_public_ip_on_launch                       = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation               = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                              = each.value.ipv6_cidr_block
  ipv6_native                                  = each.value.ipv6_native
  
  # Outpost-related arguments - only set if outpost_arn is provided
  outpost_arn                                  = each.value.outpost_arn
  customer_owned_ipv4_pool                     = each.value.outpost_arn != null ? each.value.customer_owned_ipv4_pool : null
  map_customer_owned_ip_on_launch              = each.value.outpost_arn != null ? each.value.map_customer_owned_ip_on_launch : null
  
  enable_dns64                                 = each.value.enable_dns64
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  private_dns_hostname_type_on_launch          = each.value.private_dns_hostname_type_on_launch
  
  tags = merge(
    {
      Name = "${var.env}-${each.key}"
    },
    each.value.tags
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Remove default rules (optional - uncomment if you want to remove all rules)
  # ingress = []
  # egress  = []

  tags = merge(
    {
      Name = var.vpc_config.default_security_group_name != null ? var.vpc_config.default_security_group_name : "${var.env}-vpc-default-sg"
    },
    var.vpc_config.tags
  )
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(
    {
      Name = var.vpc_config.default_route_table_name != null ? var.vpc_config.default_route_table_name : "${var.env}-vpc-default-rt"
    },
    var.vpc_config.tags
  )
}

# Internet Gateway (optional - uncomment if needed)
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#
#   tags = merge(
#     {
#       Name = "${var.env}-vpc-igw"
#     },
#     var.vpc_config.tags
#   )
# }

# Public Route Table (optional - uncomment if needed)
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#
#   tags = merge(
#     {
#       Name = "${var.env}-vpc-public-rt"
#     },
#     var.vpc_config.tags
#   )
# }
