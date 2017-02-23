# terraform-aws-vpc
Creates an AWS VPC using Terraform

Requires Terraform 0.9 or greater

Allows you to dynamically create 1 subnet per AZ.

TODO:
* add outputs

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
}```