env = "dev"

vpc_internal_config = {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = false
  
  tags = {
    Name        = "bifrost-one-a"
    Environment = "dev"
    Type        = "internal"
    Project     = "midgard"
  }
}

subnets_internal_config = {
  "private-subnet-a" = {
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-southeast-1a"
    map_public_ip_on_launch = false
    tags = {
      Type = "private"
    }
  }
  "private-subnet-b" = {
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "ap-southeast-1b"
    map_public_ip_on_launch = false
    tags = {
      Type = "private"
    }
  }
}

vpc_internet_facing_config = {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = false
  
  tags = {
    Name        = "bifrost-one-b"
    Environment = "dev"
    Type        = "internet-facing"
    Project     = "midgard"
  }
}

subnets_internet_facing_config = {
  "public-subnet-a" = {
    cidr_block              = "10.1.1.0/24"
    availability_zone       = "ap-southeast-1a"
    map_public_ip_on_launch = true
    tags = {
      Type = "public"
    }
  }
  "public-subnet-b" = {
    cidr_block              = "10.1.2.0/24"
    availability_zone       = "ap-southeast-1b"
    map_public_ip_on_launch = true
    tags = {
      Type = "public"
    }
  }
}
