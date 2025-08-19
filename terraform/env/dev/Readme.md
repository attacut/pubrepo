# Terraform VPC Template

## วิธีใช้งาน

1. กำหนดค่าในไฟล์ `variables.tfvars` เช่น

```hcl
aws_region = "ap-southeast-1"

vpc_zones = [
  {
    name = "internal"
    type = "internal"
    cidr = "10.1.0.0/16"
    vpc_config = {
      cidr_block = "10.1.0.0/16"
      enable_dns_support = true
      enable_dns_hostnames = true
      enable_internet_gateway = false
      tags = {}
    }
    subnets_config = {}
    route_tables_config = {}
  },
  {
    name = "internet-facing"
    type = "internet-facing"
    cidr = "10.2.0.0/16"
    vpc_config = {
      cidr_block = "10.2.0.0/16"
      enable_dns_support = true
      enable_dns_hostnames = true
      enable_internet_gateway = true
      tags = {}
    }
    subnets_config = {}
    route_tables_config = {}
  }
]
```

2. รันคำสั่ง
```bash
terraform init
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
```

## โครงสร้าง
- สร้าง VPC ได้หลายตัวตามที่กำหนดใน `vpc_zones`
- VPC แบบ `internet-facing` จะมี Internet Gateway
- VPC แบบ `internal` จะไม่มี Internet Gateway

## การลบ Resource
```bash
terraform destroy -var-file="variables.tfvars"
```

## หมายเหตุ
- สามารถเพิ่ม zone ใหม่ได้โดยเพิ่ม object ใน `vpc_zones`
- สามารถปรับแต่ง subnet และ route table ได้ผ่าน `subnets_config` และ `route_tables_config`
