output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.terraform-vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.terraform-vpc.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.terraform-vpc.arn
}
