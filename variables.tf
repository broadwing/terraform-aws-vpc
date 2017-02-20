variable "environment" {
  default="test"
}

variable "aws_region" {
  default="us-east"
}

variable "vpc_zone_list" {
  default = {
    "0" = "us-east-1a"
    "1" = "us-east-1b"
    "2" = "us-east-1c"
  }
}
variable "vpc_name" {
  default="the_vpc"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "subnet_cidr_public" {
  default = {
    "0" = "10.1.1.0/24"
    "1" = "10.1.2.0/24"
    "2" = "10.1.3.0/24"
  }
}

variable "subnet_cidr_private" {
  default = {
    "0" = "10.1.11.0/24"
    "1" = "10.1.12.0/24"
    "2" = "10.1.13.0/24"
  }
}

variable "public_route_cidr" {
  default = "0.0.0.0/0"
}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = false
}