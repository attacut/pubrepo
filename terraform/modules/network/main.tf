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
      Name = each.key
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
resource "aws_internet_gateway" "main" {
  count  = var.vpc_config.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = var.vpc_config.internet_gateway_name != null ? var.vpc_config.internet_gateway_name : "${var.env}-vpc-igw"
    },
    var.vpc_config.tags
  )
}

# Route Tables
resource "aws_route_table" "custom" {
  for_each = var.route_tables_config
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.vpc_config.tags,
    each.value.tags,
    {
      Name = each.value.name != null ? each.value.name : "${each.key}-rt"
    }
  )
}

# Routes
locals {
  # Create a flat list of routes with proper target assignments
  routes_flat = flatten([
    for rt_key, rt_config in var.route_tables_config : [
      for route_idx, route in rt_config.routes : {
        key             = "${rt_key}-${route_idx}"
        route_table_key = rt_key
        route           = merge(route, {
          # Handle special "internet_gateway" value
          resolved_gateway_id = route.gateway_id == "internet_gateway" && var.vpc_config.enable_internet_gateway ? aws_internet_gateway.main[0].id : (
            route.gateway_id != null && route.gateway_id != "internet_gateway" ? route.gateway_id : null
          )
        })
      }
    ]
  ])
}

resource "aws_route" "custom" {
  for_each = {
    for route in local.routes_flat : route.key => route
  }

  route_table_id = aws_route_table.custom[each.value.route_table_key].id

  # Destination (only one should be specified)
  destination_cidr_block      = each.value.route.cidr_block
  destination_ipv6_cidr_block = each.value.route.ipv6_cidr_block
  destination_prefix_list_id  = each.value.route.destination_prefix_list_id

  # Targets - use lifecycle to ignore null values
  gateway_id                = each.value.route.resolved_gateway_id
  carrier_gateway_id        = each.value.route.carrier_gateway_id
  core_network_arn         = each.value.route.core_network_arn
  egress_only_gateway_id   = each.value.route.egress_only_gateway_id
  local_gateway_id         = each.value.route.local_gateway_id
  nat_gateway_id           = each.value.route.nat_gateway_id
  network_interface_id     = each.value.route.network_interface_id
  transit_gateway_id       = each.value.route.transit_gateway_id
  vpc_endpoint_id          = each.value.route.vpc_endpoint_id
  vpc_peering_connection_id = each.value.route.vpc_peering_connection_id
}

# Route Table Associations
resource "aws_route_table_association" "custom" {
  for_each = {
    for subnet_key, subnet in var.subnets_config :
    subnet_key => subnet if subnet.route_table_association != null
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.custom[each.value.route_table_association].id
}

# Default Network ACL
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    {
      Name = var.vpc_config.default_network_acl_name != null ? var.vpc_config.default_network_acl_name : "${var.env}-vpc-default-nacl"
    },
    var.vpc_config.tags
  )
}

# Custom Network ACLs
resource "aws_network_acl" "custom" {
  for_each = var.network_acls_config
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.vpc_config.tags,
    each.value.tags,
    {
      Name = each.value.name != null ? each.value.name : "${each.key}-nacl"
    }
  )
}

# Network ACL Rules
locals {
  nacl_rules_flat = flatten([
    for nacl_key, nacl_config in var.network_acls_config : [
      for rule_idx, rule in nacl_config.rules : {
        key         = "${nacl_key}-${rule_idx}"
        nacl_key    = nacl_key
        rule        = rule
      }
    ]
  ])
}

resource "aws_network_acl_rule" "custom" {
  for_each = {
    for rule in local.nacl_rules_flat : rule.key => rule
  }

  network_acl_id = aws_network_acl.custom[each.value.nacl_key].id
  rule_number    = each.value.rule.rule_number
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
}

# Network ACL Associations
resource "aws_network_acl_association" "custom" {
  for_each = {
    for subnet_key, subnet in var.subnets_config :
    subnet_key => subnet if subnet.network_acl_association != null
  }

  network_acl_id = aws_network_acl.custom[each.value.network_acl_association].id
  subnet_id      = aws_subnet.subnets[each.key].id
}
