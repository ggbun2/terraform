
provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "bucket-yb-1234"
  force_destroy = true

  tags = {
    Name        = "Mybucket"
  }
}

output "s2_bucket_arn" {
  value = aws_s3_bucket.mybucket.arn
}

