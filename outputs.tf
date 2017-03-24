# Return VPC ID
output "vpc_id" {
  value = "${aws_vpc.the_vpc.id}"
}

# Returns the availability zones used by vpc
output "availability_zones" {
  # value = ["${data.aws_availability_zones.available.names}"]
  value = ["${slice(data.aws_availability_zones.available.names, 0, 
  		(var.max_zones > length(data.aws_availability_zones.available.names) ? 
        length(data.aws_availability_zones.available.names):var.max_zones))}"]
}

# Return Internet gateway ID
output "igw_id" {
  value = "${aws_internet_gateway.primary_igw.id}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnets.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private_subnets.*.id}"]
}

# output "nat_gateway_ips" {
#   value = ["${aws_eip.nat.*.public_ip}"]
# }

