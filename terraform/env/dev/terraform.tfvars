# Environment
env = "dev"

# Internal VPC Configuration
vpc_internal_config = {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = false
  
  tags = {
    Name        = "internal-vpc"
    Environment = "dev"
    Type        = "internal"
    Project     = ""
  }
}

# Internet-facing VPC Configuration
vpc_internet_facing_config = {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = false
  
  tags = {
    Name        = "internet-facing-vpc"
    Environment = "dev"
    Type        = "internet-facing"
    Project     = "djvo"
  }
}
