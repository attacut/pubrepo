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

output "internal_subnet_ids" {
  description = "Map of internal subnet names to their IDs"
  value       = module.vpc-internal.subnet_ids
}

output "internal_private_subnet_ids" {
  description = "List of internal private subnet IDs"
  value       = module.vpc-internal.private_subnet_ids
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

output "internet_facing_subnet_ids" {
  description = "Map of internet-facing subnet names to their IDs"
  value       = module.vpc-internet-facing.subnet_ids
}

output "internet_facing_public_subnet_ids" {
  description = "List of internet-facing public subnet IDs"
  value       = module.vpc-internet-facing.public_subnet_ids
}

output "internet_facing_private_subnet_ids" {
  description = "List of internet-facing private subnet IDs"
  value       = module.vpc-internet-facing.private_subnet_ids
}
