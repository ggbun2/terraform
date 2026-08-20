variable "vpc_id" {
  type        = string
  description = "VPC ID from VPC module"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public Subnet IDs for ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs for ASG (Web/WAS)"
}