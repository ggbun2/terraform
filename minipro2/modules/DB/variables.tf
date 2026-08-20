variable "vpc_id" {
  type        = string
  description = "VPC ID from VPC module"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs for DB Subnet Group"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  default     = "minidb"
  description = "Initial database name"
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Database master username"
}

variable "db_password" {
  type        = string
  default     = "Admin1234!" # 실습용 비밀번호 (8자 이상)
  description = "Database master password"
  sensitive   = true
}