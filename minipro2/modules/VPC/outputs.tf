output "vpc_id" {
  value       = aws_vpc.myvpc.id
  description = "Created VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.pubsub[*].id
  description = "Created Public Subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.privsub[*].id
  description = "Created Private Subnet IDs"
}