##########
# BEGIN: VPC

resource "aws_vpc" "the_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = "${var.enable_dns_support}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"

    tags {
        Name = "${var.vpc_name}"
        Environment = "${var.environment}"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.the_vpc.id}"

     tags {
        Name = "${var.vpc_name} main"
        Environment = "${var.environment}"
    }
}

# Public Subnets Tier
resource "aws_subnet" "public_subnets" {
    count = "${length( keys(var.vpc_zone_list))}"

    vpc_id = "${aws_vpc.the_vpc.id}"
    cidr_block = "${lookup(var.subnet_cidr_public, count.index)}"
    availability_zone = "${lookup(var.vpc_zone_list, count.index)}"
    map_public_ip_on_launch = true

    tags {
       Name = "${var.vpc_name} public-${count.index + 1}"
       Environment = "${var.environment}"
    }
}

# Private Subnets Tier
resource "aws_subnet" "private_subnets" {
    count = "${length( keys(var.vpc_zone_list))}"

    vpc_id = "${aws_vpc.the_vpc.id}"
    cidr_block = "${lookup(var.vpc_zone_list, count.index)}"
    availability_zone = "${lookup(var.vpc_zone_list, count.index)}"
    map_public_ip_on_launch = false

    tags {
       Name = "${var.vpc_name} private-${count.index + 1}"
       Environment = "${var.environment}"
    }
}
