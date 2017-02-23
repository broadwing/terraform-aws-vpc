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

# RDS Subnet Groups
resource "aws_db_subnet_group" "main-db-subnet-group" {
  count = "${var.create_rds_subnet_group ? 1 : 0}"

  name        = "rds-subnet-group"
  description = "RDS Subnet Group"
  subnet_ids  = ["${aws_subnet.private_subnets.*.id}"]

  tags {
    Name        = "RDS Subnet Group"
    Environment = "${var.environment}"
  }
}

# Elasticache Subnet Groups
resource "aws_elasticache_subnet_group" "main-ec-subnet-group" {
  count = "${var.create_elasticache_subnet_group ? 1 : 0}"

  name        = "elasticache-subnet-group"
  description = "Elasticache Subnet Group"
  subnet_ids  = ["${aws_subnet.private_subnets.*.id}"]
}
