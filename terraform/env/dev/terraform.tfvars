env = "dev"

vpc_internal_config = {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = false
  default_security_group_name = "bifrost-one"
  default_route_table_name    = "bifrost-one"
  default_network_acl_name    = "bifrost-one"
  
  tags = {
    Name        = "bifrost-one"
    Environment = "dev"
    Type        = "internal"
    Project     = "assgard"
  }
}

subnets_internal_config = {
  "bifrost-one-subnet-a" = {
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-southeast-1a"
    map_public_ip_on_launch = false
    network_acl_association = "private"
    tags = {
      Type = "private"
    }
  }
  "bifrost-one-subnet-b" = {
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "ap-southeast-1b"
    map_public_ip_on_launch = false
    network_acl_association = "private"
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
  default_security_group_name = "bifrost-two"
  default_route_table_name    = "bifrost-two"
  default_network_acl_name    = "bifrost-two"
  enable_internet_gateway     = true
  internet_gateway_name       = "bifrost-two"
  
  tags = {
    Name        = "bifrost-two"
    Environment = "dev"
    Type        = "internet-facing"
    Project     = "assgard"
  }
}

subnets_internet_facing_config = {
  "bifrost-two-subnet-a" = {
    cidr_block              = "10.1.1.0/24"
    availability_zone       = "ap-southeast-1a"
    map_public_ip_on_launch = true
    route_table_association = "public"
    network_acl_association = "public"
    tags = {
      Type = "public"
    }
  }
  "bifrost-two-subnet-b" = {
    cidr_block              = "10.1.2.0/24"
    availability_zone       = "ap-southeast-1b"
    map_public_ip_on_launch = true
    route_table_association = "public"
    network_acl_association = "public"
    tags = {
      Type = "public"
    }
  }
}

route_tables_internet_facing_config = {
  "public" = {
    name = "bifrost-two-public-rt"
    routes = [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = "internet_gateway"
      }
    ]
    tags = {
      Type = "public"
    }
  }
}

route_tables_internal_config = {
  "private" = {
    name = "bifrost-one-private-rt"
    routes = [] 
    tags = {
      Type = "private"
    }
  }
}

network_acls_internet_facing_config = {
  "public" = {
    name = "bifrost-two-public-nacl"
    rules = [
      {
        rule_number = 100
        protocol    = "-1"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    tags = {
      Type = "public"
    }
  }
}

network_acls_internal_config = {
  "private" = {
    name = "bifrost-one-private-nacl"
    rules = [
      {
        rule_number = 100
        protocol    = "-1"
        action      = "allow"
        cidr_block  = "10.0.0.0/8"
      }
    ]
    tags = {
      Type = "private"
    }
  }
}