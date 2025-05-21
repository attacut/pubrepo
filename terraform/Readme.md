### Example var.tfvars

```
vpc_cidr   = "10.0.0.0/16"
aws_region = "ap-southeast-1"
```

### Apply Example
```
terraform apply -var-file="var.tfvars"
```