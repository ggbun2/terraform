
terraform {
  backend "s3" {
    bucket = "bucket-yb-1234"
    key    = "terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
    region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "myDB" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.dbuser
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

# DB IP/Port
# DB User/Password
# DB/Table
output "dbIP" {
  value = aws_db_instance.myDB.address
}

output "dbPort" {
  value = aws_db_instance.myDB.port
}