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
resource "aws_internet_gateway" "primary_igw" {
    vpc_id = "${aws_vpc.the_vpc.id}"

     tags {
        Name = "${var.vpc_name} primary"
        Environment = "${var.environment}"
    }
}

# Declare the data source
data "aws_availability_zones" "available" {}

# Public Subnets Tier
resource "aws_subnet" "public_subnets" {
    /* 
    Creates a dynamic number of subnets, 1 per AZ, with a max being equal to 
    the num of AZ available in the set region
    */
    count = "${(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones)}"

    vpc_id = "${aws_vpc.the_vpc.id}"
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, (count.index + 1))}"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = true

    tags {
       Name = "${var.vpc_name}-public-${count.index + 1}"
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

    vpc_id = "${aws_vpc.the_vpc.id}"
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, (count.index + 11))}"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = false

    tags {
       Name = "${var.vpc_name}-private-${count.index + 1}"
       Environment = "${var.environment}"
    }
}
