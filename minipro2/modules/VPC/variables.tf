# [VPC 기본 설정]
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "VPC CIDR block"
}

variable "vpc_tag" {
  default = {
    Name = "myvpc"
  }
}

# 인터넷 게이트웨이(IGW) 설정
variable "vpc_igw" {
  default = {
    Name = "myigw"
  }
}

# 퍼블릭 서브넷 설정
variable "public_subnet_cidrs" {
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
    description = "Public Subnet CIDR blocks"  
}

variable "vpc_pubsub" {
    type        = list(string)
    default     = ["pubsub_1", "pubsub_2"]
    description = "Public Subnet Name tags"
}

variable "vpc_pubsub_azs" {
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
  description = "Public Subnet Availability Zones"
}

# 프라이빗 서브넷 설정
variable "private_subnet_cidrs" {
    type = list(string)
    default = [ "10.0.10.0/24", "10.0.20.0/24" ]
    description = "Private Subnet CIDR blocks"  
}

variable "vpc_privsub" {
    type        = list(string)
    default     = ["privsub_1", "privsub_2"]
    description = "Private Subnet Name tags"
}

variable "vpc_privsub_azs" {
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
  description = "Public Subnet Availability Zones"
}

# 라우팅 테이블 설정
variable "public_rt" {
  type        = string
  default     = "public_rt"
  description = "Public Route Table Name tag"
}
