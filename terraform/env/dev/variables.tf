variable "vpc_internal_config" {
  type = object({
    cidr_block                           = string
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(bool, true)
    enable_dns_hostnames                 = optional(bool, true)
    enable_network_address_usage_metrics = optional(bool, false)
    assign_generated_ipv6_cidr_block     = optional(bool, false)
    ipv4_ipam_pool_id                   = optional(string, null)
    ipv4_netmask_length                 = optional(number, null)
    ipv6_cidr_block                     = optional(string, null)
    ipv6_ipam_pool_id                   = optional(string, null)
    ipv6_netmask_length                 = optional(number, null)
    ipv6_cidr_block_network_border_group = optional(string, null)
    default_security_group_name          = optional(string, null)
    default_route_table_name             = optional(string, null)
    enable_internet_gateway              = optional(bool, false)
    internet_gateway_name                = optional(string, null)
    tags                                = optional(map(string), {})
  })
  description = "VPC configuration for internal network"
}

variable "subnets_internal_config" {
  type = map(object({
    cidr_block                          = string
    availability_zone                   = string
    map_public_ip_on_launch            = optional(bool, false)
    assign_ipv6_address_on_creation    = optional(bool, false)
    ipv6_cidr_block                    = optional(string, null)
    ipv6_native                        = optional(bool, false)
    outpost_arn                        = optional(string, null)
    customer_owned_ipv4_pool           = optional(string, null)
    map_customer_owned_ip_on_launch    = optional(bool, false)
    enable_dns64                       = optional(bool, false)
    enable_resource_name_dns_a_record_on_launch    = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    route_table_association             = optional(string, null)
    tags                               = optional(map(string), {})
  }))
  default     = {}
  description = "Map of subnet configurations for internal VPC"
}

variable "vpc_internet_facing_config" {
  type = object({
    cidr_block                           = string
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(bool, true)
    enable_dns_hostnames                 = optional(bool, true)
    enable_network_address_usage_metrics = optional(bool, false)
    assign_generated_ipv6_cidr_block     = optional(bool, false)
    ipv4_ipam_pool_id                   = optional(string, null)
    ipv4_netmask_length                 = optional(number, null)
    ipv6_cidr_block                     = optional(string, null)
    ipv6_ipam_pool_id                   = optional(string, null)
    ipv6_netmask_length                 = optional(number, null)
    ipv6_cidr_block_network_border_group = optional(string, null)
    default_security_group_name          = optional(string, null)
    default_route_table_name             = optional(string, null)
    enable_internet_gateway              = optional(bool, false)
    internet_gateway_name                = optional(string, null)
    tags                                = optional(map(string), {})
  })
  description = "VPC configuration for internet-facing network"
}

variable "subnets_internet_facing_config" {
  type = map(object({
    cidr_block                          = string
    availability_zone                   = string
    map_public_ip_on_launch            = optional(bool, false)
    assign_ipv6_address_on_creation    = optional(bool, false)
    ipv6_cidr_block                    = optional(string, null)
    ipv6_native                        = optional(bool, false)
    outpost_arn                        = optional(string, null)
    customer_owned_ipv4_pool           = optional(string, null)
    map_customer_owned_ip_on_launch    = optional(bool, false)
    enable_dns64                       = optional(bool, false)
    enable_resource_name_dns_a_record_on_launch    = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool, false)
    private_dns_hostname_type_on_launch = optional(string, "ip-name")
    route_table_association             = optional(string, null)
    tags                               = optional(map(string), {})
  }))
  default     = {}
  description = "Map of subnet configurations for internet-facing VPC"
}

variable "route_tables_internal_config" {
  type = map(object({
    name = optional(string, null)
    routes = optional(list(object({
      cidr_block                = optional(string, null)
      ipv6_cidr_block          = optional(string, null)
      destination_prefix_list_id = optional(string, null)
      carrier_gateway_id       = optional(string, null)
      core_network_arn         = optional(string, null)
      egress_only_gateway_id   = optional(string, null)
      gateway_id               = optional(string, null)
      instance_id              = optional(string, null)
      local_gateway_id         = optional(string, null)
      nat_gateway_id           = optional(string, null)
      network_interface_id     = optional(string, null)
      transit_gateway_id       = optional(string, null)
      vpc_endpoint_id          = optional(string, null)
      vpc_peering_connection_id = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of route table configurations for internal VPC"
}

variable "route_tables_internet_facing_config" {
  type = map(object({
    name = optional(string, null)
    routes = optional(list(object({
      cidr_block                = optional(string, null)
      ipv6_cidr_block          = optional(string, null)
      destination_prefix_list_id = optional(string, null)
      carrier_gateway_id       = optional(string, null)
      core_network_arn         = optional(string, null)
      egress_only_gateway_id   = optional(string, null)
      gateway_id               = optional(string, null)
      instance_id              = optional(string, null)
      local_gateway_id         = optional(string, null)
      nat_gateway_id           = optional(string, null)
      network_interface_id     = optional(string, null)
      transit_gateway_id       = optional(string, null)
      vpc_endpoint_id          = optional(string, null)
      vpc_peering_connection_id = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of route table configurations for internet-facing VPC"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}
