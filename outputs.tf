# Return VPC ID
output "vpc_id" {
  value = "${aws_vpc.the_vpc.id}"
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