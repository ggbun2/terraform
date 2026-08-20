
terraform {
  backend "s3" {
    bucket = "bucket-yb-1234"
    key    = "terraform.tfstat"
    region = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
    region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "myTFState" {
  bucket = "bucket-yb-1234"
  force_destroy = true

  tags = {
    Name        = "myTFState"
  }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.myTFState.arn
}