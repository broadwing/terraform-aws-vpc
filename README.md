# terraform-aws-vpc
Creates an AWS VPC using Terraform

Requires Terraform 0.9 or greater

Allows you to dynamically create 1 subnet per AZ. Creates a single VPC with public and private subnets. The subnet CIDRs are dynamically set based on what is set for `vpc_cidr`.

If you used a VPC CIDR of, `10.100.0.0/16`, and used 3 Availability Zones from the US-EAST-1 region, your subnet CIDRs would be the following:

| Availability Zones | us-east-1a    | us-east-1b    | us-east-1c    |
|--------------------|---------------|---------------|---------------|
| Public Subnet CIDRs       | 10.100.1.0/24 | 10.100.2.0/24 | 10.100.3.0/24 |
| Private Subnet CIDRs      | 10.100.11.0/24| 10.100.12.0/24| 10.100.13.0/24|


Example Code:

```
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

module "vpc" {
  source  = "github.com/broadwing/terraform-aws-vpc"

  aws_region  = "${var.aws_region}"
  environment = "${var.environment}"
  vpc_name = "${var.vpc_name}"
  vpc_cidr = "${var.vpc_cidr}"

  create_rds_subnet_group = "${var.create_rds_subnet_group}"
  create_elasticache_subnet_group = "${var.create_elasticache_subnet_group}"
}
```


*TODO:*
* add outputs
