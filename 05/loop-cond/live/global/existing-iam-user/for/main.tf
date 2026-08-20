provider "aws" {
  region = "ap-northeast-2"
}

variable "names" {
  default = ["neo", "trinity", "morpheus"]
}

output "upper_names" {
  value = [for name in var.names : upper(name)]
}

