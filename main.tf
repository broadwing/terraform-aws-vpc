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

# Public Subnets Tier
resource "aws_subnet" "public_subnets" {
  /* 
            Creates a dynamic number of subnets, 1 per AZ, with a max being equal to 
            the num of AZ available in the set region
            */
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  vpc_id                  = "${aws_vpc.the_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, (count.index + 1))}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.vpc_name}-public-${count.index + 1}"
    Environment = "${var.environment}"
  }
}

# Private Subnets Tier
resource "aws_subnet" "private_subnets" {
  /* 
            Creates a dynamic number of subnets, 1 per AZ, with a max being equal to 
            the num of AZ available in the set region
            */
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  vpc_id                  = "${aws_vpc.the_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, (count.index + 11))}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.vpc_name}-private-${count.index + 1}"
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

# Public Route Table
resource "aws_route_table" "public_subnets" {
  vpc_id = "${aws_vpc.the_vpc.id}"

  tags {
    Name        = "Public Subnets Route"
    Environment = "${var.environment}"
  }
}

# Public Routes
resource "aws_route" "public_subnets" {
  route_table_id         = "${aws_route_table.public_subnets.id}"
  destination_cidr_block = "${var.public_route_cidr}"
  gateway_id             = "${aws_internet_gateway.primary_igw.id}"
}

# Public Route Table Associations
resource "aws_route_table_association" "public_subnets" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  route_table_id = "${aws_route_table.public_subnets.id}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
}

# Private Route Table
resource "aws_route_table" "private_subnets" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  vpc_id = "${aws_vpc.the_vpc.id}"

  tags {
    Name        = "Private Subnet ${count.index + 1} Route"
    Environment = "${var.environment}"
  }
}

# Private Routes
resource "aws_route" "private_subnets" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  route_table_id         = "${element(aws_route_table.private_subnets.*.id, count.index)}"
  destination_cidr_block = "${var.public_route_cidr}"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}

# Private Route Table Associations
resource "aws_route_table_association" "private_subnets" {
  count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

  route_table_id = "${element(aws_route_table.private_subnets.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
}
