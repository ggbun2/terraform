terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "existing_user" {
  # Make sure to update this to your own user name!
  name = "yevgeniy.brikman"
}

#-------------------------------------------------

variable "hero_thousand_faces" {
  default = {
    neo = "hero"
    trinity = "lovw interest"
    morpheus = "mentor"
  }
}

output "bios" {
  value = [for name, role in var.var.hero_thousand_faces: "${name}: ${role}" ]
}

output "bios" {
  value = [for name, role in var.var.hero_thousand_faces: "${name}: ${role}" ]
}
