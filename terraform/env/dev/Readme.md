# Terraform Dev Environment - Dual VPC Architecture

## 🏗️ Current Infrastructure

This environment deploys a **dual-VPC architecture** with complete network security implementation:

### **VPC Configuration**
- **Internal VPC (bifrost-one)**: `10.0.0.0/16` - Air-gapped network
- **Internet-facing VPC (bifrost-two)**: `10.1.0.0/16` - Public-facing network

### **Deployed Resources**
✅ **VPCs**: 2 VPCs with custom naming and configuration  
✅ **Subnets**: 4 subnets (2 private, 2 public) across 2 AZs  
✅ **Route Tables**: Custom route tables with proper associations  
✅ **Network ACLs**: Security rules with subnet associations  
✅ **Internet Gateway**: Public connectivity for internet-facing VPC  
✅ **Security Groups**: Default configurations with custom naming  

## 🚀 Quick Start

### **Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan -var-file=terraform.tfvars

# Deploy infrastructure
terraform apply -var-file=terraform.tfvars
```

### **Verify Deployment**
```bash
# Check Terraform state
terraform show

# View specific outputs
terraform output
```

## 📋 Configuration Overview

### **Environment Settings** (`terraform.tfvars`)
```hcl
env = "dev"

# Internal VPC - No internet access
vpc_internal_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  default_security_group_name = "bifrost-one"
  default_route_table_name    = "bifrost-one"
  default_network_acl_name    = "bifrost-one"
  # enable_internet_gateway = false (default)
}

# Internet-facing VPC - Public connectivity
vpc_internet_facing_config = {
  cidr_block              = "10.1.0.0/16"
  enable_internet_gateway = true
  internet_gateway_name   = "bifrost-two"
  # ... additional configuration
}
```

### **Network Topology**
```
Internal VPC (10.0.0.0/16) - Air-gapped
├── bifrost-one-subnet-a (10.0.1.0/24) [ap-southeast-1a]
├── bifrost-one-subnet-b (10.0.2.0/24) [ap-southeast-1b]
├── bifrost-one-private-rt (no internet route)
└── bifrost-one-private-nacl

Internet-facing VPC (10.1.0.0/16) - Public
├── bifrost-two-subnet-a (10.1.1.0/24) [ap-southeast-1a]
├── bifrost-two-subnet-b (10.1.2.0/24) [ap-southeast-1b]
├── bifrost-two-public-rt (0.0.0.0/0 → IGW)
├── bifrost-two-public-nacl
└── bifrost-two (Internet Gateway)
```

## 🔒 Security Implementation

### **Network Security Layers**
1. **VPC Isolation**: Complete separation between internal and public networks
2. **Network ACLs**: Stateless subnet-level security rules
3. **Route Tables**: Controlled traffic routing (no internet for internal)
4. **Security Groups**: Instance-level firewall (default configurations)

### **Current Security Rules**
- **Internal Network ACL**: Allows internal traffic only
- **Public Network ACL**: Allows internet traffic (configurable)
- **Route Isolation**: Internal subnets have no internet gateway route
- **Public Routes**: Internet-facing subnets route 0.0.0.0/0 to IGW

## 🛠️ Management Commands

### **Infrastructure Operations**
```bash
# Plan infrastructure changes
terraform plan -var-file=terraform.tfvars

# Apply infrastructure updates
terraform apply -var-file=terraform.tfvars

# View current state
terraform show

# Get output values
terraform output
```

### **Resource Cleanup**
```bash
# Destroy all infrastructure (DEV ONLY)
terraform destroy -var-file=terraform.tfvars
```

### **Validation & Troubleshooting**
```bash
# Validate Terraform syntax
terraform validate

# Format code
terraform fmt

# Check AWS resources
aws ec2 describe-vpcs --region ap-southeast-1
aws ec2 describe-subnets --region ap-southeast-1
aws ec2 describe-network-acls --region ap-southeast-1
```

## 📊 Resource Inventory

After successful deployment:

| Resource Type | Internal VPC | Internet-facing VPC |
|---------------|--------------|-------------------|
| **VPC** | bifrost-one | bifrost-two |
| **Subnets** | 2 private (/24) | 2 public (/24) |
| **Route Table** | bifrost-one-private-rt | bifrost-two-public-rt |
| **Network ACL** | bifrost-one-private-nacl | bifrost-two-public-nacl |
| **Internet Gateway** | ❌ | ✅ bifrost-two |
| **Availability Zones** | ap-southeast-1a, 1b | ap-southeast-1a, 1b |

## 🔧 Customization

### **Adding New Subnets**
Edit `terraform.tfvars` and add to respective subnet configuration:
```hcl
subnets_internal_config = {
  "bifrost-one-subnet-c" = {
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "ap-southeast-1c"
    route_table_association = "private"
    network_acl_association = "private"
  }
}
```

### **Modifying Network ACL Rules**
Update network ACL configurations in `terraform.tfvars`:
```hcl
network_acls_internal_config = {
  "private" = {
    name = "bifrost-one-private-nacl"
    rules = [
      {
        rule_number = 100
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "10.0.0.0/16"
        from_port   = 80
        to_port     = 80
      }
    ]
  }
}
```

## 🎯 Environment Purpose

This **development environment** is designed for:
- ✅ **Infrastructure Testing**: Safe testing of network configurations
- ✅ **Application Development**: Isolated development workloads
- ✅ **Security Validation**: Testing network security controls
- ✅ **Architecture Prototyping**: Validating dual-VPC patterns

## ⚠️ Development Notes

### **Current Limitations**
- **No NAT Gateway**: Private subnets cannot access internet (by design)
- **Basic Network ACLs**: Allow-all rules for development ease
- **No VPC Flow Logs**: Network monitoring not enabled
- **Local State**: Using local terraform.tfstate (not recommended for production)

### **Production Readiness**
Before moving to production:
- [ ] Add NAT Gateway for private subnet internet access
- [ ] Implement restrictive Network ACL rules
- [ ] Enable VPC Flow Logs for monitoring
- [ ] Configure remote state backend (S3 + DynamoDB)
- [ ] Add CloudWatch monitoring and alerting
- [ ] Implement VPC Endpoints for AWS services

## 📁 Module Usage

This environment uses the reusable network module:
```hcl
module "vpc-internal" {
  source              = "../../modules/network"
  vpc_config          = var.vpc_internal_config
  subnets_config      = var.subnets_internal_config
  route_tables_config = var.route_tables_internal_config
  network_acls_config = var.network_acls_internal_config
  env                 = var.env
}
```

## 🔗 Related Documentation

- **Module Documentation**: `../../modules/network/README.md`
- **Root Documentation**: `../../../README.md`
- **AWS VPC Guide**: [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)

---

**Environment**: Development | **Region**: ap-southeast-1 | **Last Updated**: August 20, 2025
