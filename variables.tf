variable "environment" {
  default = "test"
}

variable "aws_region" {
  default = "us-east"
}

variable "max_zones" {
  description = "The max # of availability zones to use. If this is larger in the region supports, only the max available will be used."
  default     = "3"
}

variable "vpc_name" {
  default = "the_vpc"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
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

variable "create_rds_subnet_group" {
	default = true
}

variable "create_elasticache_subnet_group" {
	default = true
}