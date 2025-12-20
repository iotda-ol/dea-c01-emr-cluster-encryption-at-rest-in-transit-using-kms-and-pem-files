output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "emr_master_security_group_id" {
  description = "EMR master security group ID"
  value       = aws_security_group.emr_master.id
}

output "emr_core_security_group_id" {
  description = "EMR core security group ID"
  value       = aws_security_group.emr_core.id
}

output "emr_service_security_group_id" {
  description = "EMR service security group ID"
  value       = aws_security_group.emr_service.id
}
