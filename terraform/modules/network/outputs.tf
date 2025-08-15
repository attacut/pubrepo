output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = aws_vpc.main.instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = aws_vpc.main.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = aws_vpc.main.enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.main.main_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation"
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the route table created by default on VPC creation"
  value       = aws_vpc.main.default_route_table_id
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = aws_vpc.main.ipv6_association_id
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = aws_vpc.main.ipv6_cidr_block
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = aws_vpc.main.owner_id
}

# Subnet Outputs
output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in aws_subnet.subnets : k => v.id }
}

output "subnet_arns" {
  description = "Map of subnet names to their ARNs"
  value       = { for k, v in aws_subnet.subnets : k => v.arn }
}

output "subnet_cidr_blocks" {
  description = "Map of subnet names to their CIDR blocks"
  value       = { for k, v in aws_subnet.subnets : k => v.cidr_block }
}

output "subnet_availability_zones" {
  description = "Map of subnet names to their availability zones"
  value       = { for k, v in aws_subnet.subnets : k => v.availability_zone }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (subnets with map_public_ip_on_launch = true)"
  value       = [for k, v in aws_subnet.subnets : v.id if var.subnets_config[k].map_public_ip_on_launch]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (subnets with map_public_ip_on_launch = false)"
  value       = [for k, v in aws_subnet.subnets : v.id if !var.subnets_config[k].map_public_ip_on_launch]
}

# Default Security Group Outputs
output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_default_security_group.default.id
}

output "default_security_group_arn" {
  description = "The ARN of the default security group"
  value       = aws_default_security_group.default.arn
}

# Default Route Table Outputs
output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_default_route_table.default.id
}

output "default_route_table_arn" {
  description = "The ARN of the default route table"
  value       = aws_default_route_table.default.arn
}
