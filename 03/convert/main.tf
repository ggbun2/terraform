provider "aws" {
  region = "us-east-2"
}

# ------------------------------------------------------------------------------
# 1. Variables & Data Sources
# ------------------------------------------------------------------------------
variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access"
  type        = string
}

# 최신 Amazon Linux 2 AMI ID 가져오기 (SSM Parameter)
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# 가용영역(AZ) 목록 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# ------------------------------------------------------------------------------
# 2. VPC & Networking
# ------------------------------------------------------------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My-VPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-Public-RT"
  }
}

resource "aws_route" "my_default_public_route" {
  route_table_id         = aws_route_table.my_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Subnet 1 (첫 번째 AZ)
resource "aws_subnet" "my_public_sn1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "My-Public-SN-1"
  }
}

# Subnet 2 (세 번째 AZ)
resource "aws_subnet" "my_public_sn2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "My-Public-SN-2"
  }
}

resource "aws_route_table_association" "assoc_sn1" {
  subnet_id      = aws_subnet.my_public_sn1.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "assoc_sn2" {
  subnet_id      = aws_subnet.my_public_sn2.id
  route_table_id = aws_route_table.my_public_rt.id
}

# ------------------------------------------------------------------------------
# 3. Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "WEBSG"
  description = "Enable HTTP access via port 80 and SSH access via port 22"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "WEBSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ------------------------------------------------------------------------------
# 4. EC2 Instances & Elastic IPs
# ------------------------------------------------------------------------------
resource "aws_instance" "my_ec2_1" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.my_public_sn1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              hostname EC2-1
              yum install httpd -y
              service httpd start
              chkconfig httpd on
              echo "<h1>CloudNet@ EC2-1 Web Server</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2-1"
  }
}

resource "aws_instance" "my_ec2_2" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.my_public_sn2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              hostname ELB-EC2-2
              yum install httpd -y
              service httpd start
              chkconfig httpd on
              echo "<h1>CloudNet@ EC2-2 Web Server</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2-2"
  }
}

resource "aws_eip" "my_eip1" {
  domain   = "vpc"
  instance = aws_instance.my_ec2_1.id
}

resource "aws_eip" "my_eip2" {
  domain   = "vpc"
  instance = aws_instance.my_ec2_2.id
}

# ------------------------------------------------------------------------------
# 5. Application Load Balancer (ALB) & Target Group
# ------------------------------------------------------------------------------
resource "aws_lb_target_group" "alb_target_group" {
  name     = "My-ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# EC2-1 타겟 그룹 연결
resource "aws_lb_target_group_attachment" "tg_attach_1" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.my_ec2_1.id
  port             = 80
}

# EC2-2 타겟 그룹 연결
resource "aws_lb_target_group_attachment" "tg_attach_2" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.my_ec2_2.id
  port             = 80
}

# Application Load Balancer 생성
resource "aws_lb" "application_load_balancer" {
  name               = "My-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.my_public_sn1.id, aws_subnet.my_public_sn2.id]
}

# ALB Listener 생성
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
