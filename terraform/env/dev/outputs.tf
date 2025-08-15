# Internal VPC Outputs
output "internal_vpc_id" {
  description = "The ID of the internal VPC"
  value       = module.vpc-internal.vpc_id
}

output "internal_vpc_cidr_block" {
  description = "The CIDR block of the internal VPC"
  value       = module.vpc-internal.vpc_cidr_block
}

output "internal_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on internal VPC creation"
  value       = module.vpc-internal.vpc_default_security_group_id
}

# Internet-facing VPC Outputs
output "internet_facing_vpc_id" {
  description = "The ID of the internet-facing VPC"
  value       = module.vpc-internet-facing.vpc_id
}

output "internet_facing_vpc_cidr_block" {
  description = "The CIDR block of the internet-facing VPC"
  value       = module.vpc-internet-facing.vpc_cidr_block
}

output "internet_facing_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on internet-facing VPC creation"
  value       = module.vpc-internet-facing.vpc_default_security_group_id
}
