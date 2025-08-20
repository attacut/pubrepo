# Pubrepo - Infrastructure as Code Repository

## 📋 Overview

This repository contains Infrastructure as Code (IaC) configurations for deploying and managing cloud infrastructure using Terraform, Kubernetes (Kubespray), and Helm charts. The project focuses on creating scalable, secure, and maintainable infrastructure patterns.

## 🏗️ Repository Structure

```
pubrepo/
├── terraform/              # Terraform Infrastructure Modules
│   ├── env/                # Environment-specific configurations
│   │   └── dev/           # Development environment
│   └── modules/           # Reusable Terraform modules
│       └── network/       # VPC, Subnets, Security Groups, etc.
├── kubespray/             # Kubernetes cluster deployment
├── helm/                  # Helm charts for applications
│   └── argo-cd/          # ArgoCD deployment charts
├── ubuntu/                # Ubuntu-specific configurations
└── sandbox/              # Experimental configurations
```

## 🚀 Terraform Infrastructure

### Architecture Overview

The Terraform configuration deploys a **dual-VPC architecture** designed for enterprise-grade network segregation:

#### **VPC Architecture**
- **Internal VPC (bifrost-one)**: `10.0.0.0/16`
  - Private subnets across multiple AZs
  - No Internet Gateway (air-gapped)
  - Custom Network ACLs for internal traffic
  
- **Internet-facing VPC (bifrost-two)**: `10.1.0.0/16`
  - Public subnets with Internet Gateway
  - Public Network ACLs for web traffic
  - Multi-AZ deployment for high availability

#### **Network Components**
- ✅ **Multi-AZ Subnets**: High availability across `ap-southeast-1a` and `ap-southeast-1b`
- ✅ **Custom Route Tables**: Dedicated routing for private and public traffic
- ✅ **Network ACLs**: Layer 4 security controls with custom rules
- ✅ **Security Groups**: Application-level security (extensible)
- ✅ **Internet Gateway**: Managed internet connectivity for public subnets

### 🛠️ Getting Started

#### Prerequisites
- **Terraform** >= 1.0
- **AWS CLI** configured with appropriate credentials
- **AWS Account** with VPC creation permissions

#### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/attacut/pubrepo.git
   cd pubrepo/terraform/env/dev
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review the plan**
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

4. **Deploy infrastructure**
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

5. **Verify deployment**
   ```bash
   terraform show
   ```

#### Configuration

The infrastructure is configured through `terraform.tfvars`:

```hcl
# Environment
env = "dev"

# Internal VPC Configuration
vpc_internal_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  # ... additional configuration
}

# Subnets Configuration
subnets_internal_config = {
  "bifrost-one-subnet-a" = {
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-southeast-1a"
    route_table_association = "private"
    network_acl_association = "private"
  }
  # ... additional subnets
}
```

### 📊 Resource Inventory

After successful deployment, you'll have:

| Resource Type | Internal VPC | Internet-facing VPC |
|---------------|--------------|-------------------|
| **VPCs** | 1 (bifrost-one) | 1 (bifrost-two) |
| **Subnets** | 2 private | 2 public |
| **Route Tables** | 1 private | 1 public |
| **Network ACLs** | 1 private | 1 public |
| **Internet Gateway** | ❌ | ✅ |
| **Security Groups** | Default | Default |

### 🔧 Module Structure

#### Network Module (`terraform/modules/network/`)

**Purpose**: Creates comprehensive VPC infrastructure with all networking components.

**Key Features**:
- Variable-driven configuration
- Optional resource creation
- Comprehensive tagging strategy
- Multi-environment support

**Inputs**:
- `vpc_config`: VPC configuration object
- `subnets_config`: Map of subnet configurations
- `route_tables_config`: Route table definitions
- `network_acls_config`: Network ACL rules
- `env`: Environment identifier

**Outputs**:
- VPC ID and CIDR blocks
- Subnet IDs and mappings
- Route table associations
- Security group IDs

## 🔒 Security Features

### Network Security
- **Network ACLs**: Stateless firewall rules at subnet level
- **Security Groups**: Stateful firewall rules at instance level
- **Private Subnets**: No direct internet access
- **Custom Route Tables**: Controlled traffic routing

### Access Control
- **IAM Integration**: AWS credentials and permissions
- **Resource Tagging**: Comprehensive resource labeling
- **Environment Isolation**: Separate configurations per environment

### Best Practices Implemented
- ✅ Least privilege networking
- ✅ Defense in depth with multiple security layers
- ✅ Infrastructure as Code for audit trails
- ✅ Consistent naming conventions

## 📈 Scalability & Extensibility

### Horizontal Scaling
- **Multi-AZ Support**: Built-in high availability
- **Subnet Expansion**: Easy addition of new subnets
- **Environment Replication**: Copy configuration for new environments

### Vertical Scaling
- **CIDR Planning**: Designed for growth within allocated ranges
- **Modular Architecture**: Add new modules without affecting existing

### Extension Points
- **Additional VPCs**: Easy integration of new VPCs
- **VPC Peering**: Connect VPCs across regions
- **Transit Gateway**: Hub-and-spoke connectivity (future)
- **VPN Connections**: Hybrid cloud connectivity

## 🛡️ Production Considerations

### Missing Components (Roadmap)
- [ ] **NAT Gateway**: Enable private subnet internet access
- [ ] **VPC Flow Logs**: Network traffic monitoring
- [ ] **CloudWatch Integration**: Monitoring and alerting
- [ ] **VPC Endpoints**: Private service connectivity
- [ ] **Database Subnets**: Dedicated data tier
- [ ] **Load Balancers**: Application delivery

### Security Enhancements
- [ ] **Restrictive Network ACLs**: Replace allow-all rules
- [ ] **Security Group Templates**: Application-specific rules
- [ ] **VPC Flow Log Analysis**: Automated threat detection
- [ ] **AWS Config Rules**: Compliance monitoring

## 🔄 Operations

### Infrastructure Management
```bash
# View current state
terraform show

# Update infrastructure
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Destroy infrastructure (careful!)
terraform destroy -var-file=terraform.tfvars
```

### Troubleshooting
```bash
# Debug Terraform issues
terraform validate
terraform fmt -check=true

# AWS resource verification
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

### State Management
- **Local State**: Currently using local `terraform.tfstate`
- **Recommended**: Migrate to S3 backend with state locking
- **Backup**: Regular state file backups essential

## 🎯 Environment Management

### Development Environment
- **Location**: `terraform/env/dev/`
- **Purpose**: Development and testing
- **Network**: `10.0.0.0/16` and `10.1.0.0/16`

### Future Environments
- **Staging**: Copy dev configuration to `env/staging/`
- **Production**: Enhanced security and monitoring in `env/prod/`
- **Disaster Recovery**: Cross-region deployment patterns

## 📚 Additional Resources

### Terraform Documentation
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### AWS Networking
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Network ACLs vs Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)

### Security Best Practices
- [AWS VPC Security Best Practices](https://aws.amazon.com/answers/networking/aws-single-vpc-design/)
- [Infrastructure Security in Amazon VPC](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/infrastructure-security.html)

## 🤝 Contributing

### Development Workflow
1. **Branch**: Create feature branch from `dev`
2. **Develop**: Make changes in appropriate environment
3. **Test**: Validate with `terraform plan`
4. **Review**: Submit pull request with detailed description
5. **Deploy**: Merge to `dev` after approval

### Code Standards
- **Formatting**: Use `terraform fmt`
- **Validation**: Run `terraform validate`
- **Documentation**: Update README for significant changes
- **Tagging**: Consistent resource tagging strategy

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: Create GitHub issues for bugs or feature requests
- **Documentation**: Refer to inline code comments and this README
- **Community**: Join project discussions in GitHub Discussions

---

**Last Updated**: August 20, 2025  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: >= 5.0  
**Maintainer**: [@attacut](https://github.com/attacut)
