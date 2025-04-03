output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.terraform-vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "public_nacl_id" {
  description = "ID of the public Network ACL"
  value       = aws_network_acl.public_nacl.id
}

output "private_nacl_id" {
  description = "ID of the private Network ACL"
  value       = aws_network_acl.private_nacl.id
}
