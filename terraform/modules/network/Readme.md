# Terraform Network Module

โมดูลนี้ใช้สำหรับสร้าง VPC และ network resources บน AWS แบบ flexible และ configurable

## อธิบายโค้ดแต่ละส่วนแบบละเอียด

### 1. VPC Resource
```hcl
resource "aws_vpc" "main" {
  cidr_block                           = var.vpc_config.cidr_block
  instance_tenancy                     = var.vpc_config.instance_tenancy
  enable_dns_support                   = var.vpc_config.enable_dns_support
  enable_dns_hostnames                 = var.vpc_config.enable_dns_hostnames
  enable_network_address_usage_metrics = var.vpc_config.enable_network_address_usage_metrics
  assign_generated_ipv6_cidr_block     = var.vpc_config.assign_generated_ipv6_cidr_block
  
  tags = merge(
    {
      Name = "${var.env}-vpc"
    },
    var.vpc_config.tags
  )
}
```
**อธิบาย:**
- สร้าง Virtual Private Cloud (VPC) บน AWS
- `cidr_block`: กำหนดช่วง IP address ของ VPC เช่น "10.0.0.0/16"
- `instance_tenancy`: กำหนดว่า EC2 instances จะรันบน hardware แบบ shared หรือ dedicated
- `enable_dns_support`: เปิดการใช้งาน DNS resolution ใน VPC
- `enable_dns_hostnames`: เปิดการใช้งาน DNS hostnames สำหรับ instances
- `enable_network_address_usage_metrics`: เปิด metrics สำหรับการใช้งาน network address
- `assign_generated_ipv6_cidr_block`: กำหนดว่าจะให้ AWS สร้าง IPv6 CIDR block ให้หรือไม่
- `tags`: รวม tag จาก environment และ custom tags ที่ส่งเข้ามา

### 2. Subnet Resource
```hcl
resource "aws_subnet" "subnets" {
  for_each = var.subnets_config
  
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                    = each.value.cidr_block
  availability_zone                             = each.value.availability_zone
  map_public_ip_on_launch                       = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation               = each.value.assign_ipv6_address_on_creation
  
  tags = merge(
    {
      Name = "${var.env}-${each.key}"
    },
    each.value.tags
  )
}
```
**อธิบาย:**
- สร้าง Subnet หลายตัวใน VPC โดยใช้ `for_each` loop
- `vpc_id`: เชื่อมโยงกับ VPC ที่สร้างไว้
- `cidr_block`: กำหนดช่วง IP ของ subnet ต้องอยู่ใน VPC CIDR
- `availability_zone`: กำหนด AZ ที่ subnet จะอยู่
- `map_public_ip_on_launch`: กำหนดว่า instances ใน subnet นี้จะได้ public IP หรือไม่ (true = public subnet, false = private subnet)
- `assign_ipv6_address_on_creation`: กำหนดว่าจะให้ IPv6 address หรือไม่

### 3. Internet Gateway Resource
```hcl
resource "aws_internet_gateway" "main" {
  count  = var.vpc_config.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = var.vpc_config.internet_gateway_name != null ? var.vpc_config.internet_gateway_name : "${var.env}-vpc-igw"
    },
    var.vpc_config.tags
  )
}
```
**อธิบาย:**
- สร้าง Internet Gateway สำหรับเชื่อมต่อ VPC กับ Internet
- `count`: สร้างเฉพาะเมื่อ `enable_internet_gateway = true`
- `vpc_id`: เชื่อมโยงกับ VPC
- ตั้งชื่อแบบ conditional: ใช้ชื่อที่กำหนด หรือสร้างชื่อตาม pattern "${env}-vpc-igw"

### 4. Route Table และ Routes
```hcl
resource "aws_route_table" "custom" {
  for_each = var.route_tables_config
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.vpc_config.tags,
    each.value.tags,
    {
      Name = each.value.name != null ? each.value.name : "${var.env}-${each.key}-rt"
    }
  )
}

locals {
  routes_flat = flatten([
    for rt_key, rt_config in var.route_tables_config : [
      for route_idx, route in rt_config.routes : {
        key             = "${rt_key}-${route_idx}"
        route_table_key = rt_key
        route           = merge(route, {
          resolved_gateway_id = route.gateway_id == "internet_gateway" && var.vpc_config.enable_internet_gateway ? aws_internet_gateway.main[0].id : (
            route.gateway_id != null && route.gateway_id != "internet_gateway" ? route.gateway_id : null
          )
        })
      }
    ]
  ])
}

resource "aws_route" "custom" {
  for_each = {
    for route in local.routes_flat : route.key => route
  }

  route_table_id = aws_route_table.custom[each.value.route_table_key].id
  destination_cidr_block = each.value.route.cidr_block
  gateway_id = each.value.route.resolved_gateway_id
}
```
**อธิบาย:**
- สร้าง Route Table หลายตัวใน VPC
- `locals.routes_flat`: แปลง nested routes config ให้เป็น flat list เพื่อใช้กับ for_each
- `resolved_gateway_id`: แปลง string "internet_gateway" ให้เป็น Internet Gateway ID จริง
- สร้าง routes สำหรับแต่ละ route table ตาม config

### 5. Route Table Association
```hcl
resource "aws_route_table_association" "custom" {
  for_each = {
    for subnet_key, subnet in var.subnets_config :
    subnet_key => subnet if subnet.route_table_association != null
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.custom[each.value.route_table_association].id
}
```
**อธิบาย:**
- เชื่อมโยง subnet กับ route table ที่กำหนด
- filter เฉพาะ subnet ที่มี `route_table_association` กำหนดไว้
- เชื่อมโยง subnet_id กับ route_table_id ที่ระบุ

### 6. Default Resources
```hcl
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = var.vpc_config.default_security_group_name != null ? var.vpc_config.default_security_group_name : "${var.env}-vpc-default-sg"
    },
    var.vpc_config.tags
  )
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = merge(
    {
      Name = var.vpc_config.default_route_table_name != null ? var.vpc_config.default_route_table_name : "${var.env}-vpc-default-rt"
    },
    var.vpc_config.tags
  )
}
```
**อธิบาย:**
- จัดการ default security group และ default route table ของ VPC
- ตั้งชื่อและ tags ให้เป็นระเบียบ
- สามารถปรับแต่งชื่อได้ผ่าน config

## การใช้งาน
1. กำหนดค่าใน `variables.tfvars`
2. รัน `terraform init`
3. รัน `terraform plan -var-file="variables.tfvars"`
4. รัน `terraform apply -var-file="variables.tfvars"`
