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
    tags                                = optional(map(string), {})
  })
  description = "VPC configuration for internal network"
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
    tags                                = optional(map(string), {})
  })
  description = "VPC configuration for internet-facing network"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}
