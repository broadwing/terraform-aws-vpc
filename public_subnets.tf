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
