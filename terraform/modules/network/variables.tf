variable "vpc_config" {
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
  description = "VPC configuration object with all available options"
}

variable "subnets_config" {
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
    tags                               = optional(map(string), {})
  }))
  default     = {}
  description = "Map of subnet configurations where key is subnet name"
}

variable "env" {
  type        = string
  description = "Environment name"
}
