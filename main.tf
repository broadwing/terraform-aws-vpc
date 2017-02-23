##########
# BEGIN: VPC

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_vpc" "the_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name        = "${var.vpc_name}"
    Environment = "${var.environment}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "primary_igw" {
  vpc_id = "${aws_vpc.the_vpc.id}"

  tags {
    Name        = "${var.vpc_name} primary"
    Environment = "${var.environment}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  allocation_id = "${element(aws_eip.nat_gw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnets.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.primary_igw"]
}

resource "aws_eip" "nat_gw" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  vpc = true
}
