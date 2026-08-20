# 0. 최신 Amazon Linux 2023 AMI ID를 자동으로 조회하는 데이터 소스
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# 1. ALB용 보안 그룹 (외부 80 포트 허용)
resource "aws_security_group" "alb_sg" {
  name        = "mini-project-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mini-project-alb-sg" }
}

# 2. Web/WAS (EC2)용 보안 그룹 (오직 ALB로부터 오는 트래픽과 SSH 허용)
resource "aws_security_group" "web_sg" {
  name        = "mini-project-web-sg"
  description = "Security group for Web/WAS EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 실습용 (필요시 본인 IP로 제한 가능)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mini-project-web-sg" }
}

# 3. Application Load Balancer (ALB) 생성 (퍼블릭 서브넷 2개 배치)
resource "aws_lb" "alb" {
  name               = "mini-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = { Name = "mini-project-alb" }
}

# 4. Target Group 생성
resource "aws_lb_target_group" "tg" {
  name     = "mini-project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "mini-project-tg" }
}

# 5. ALB Listener (80 포트로 들어온 요청을 타겟 그룹으로 전달)
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# 6. Launch Template (EC2 시작 템플릿 - 동적 최신 AMI ID 및 httpd/php 자동 설치 설정)
resource "aws_launch_template" "web_lt" {
  name_prefix   = "mini-project-web-lt"
  image_id      = data.aws_ssm_parameter.al2023.value # 최신 AMI 동적 바인딩
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  # 부팅 시 httpd와 php 자동 설치 및 간단한 웹페이지 생성 쉘 스크립트
  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd php php-mysqli
              systemctl enable --now httpd
              echo "<h1>Hello from 3-Tier Architecture Web Server</h1>" > /var/www/html/index.php
              EOF
  )

  tags = { Name = "mini-project-web-lt" }
}

# 7. Auto Scaling Group (ASG) (프라이빗 서브넷 2개에 걸쳐서 인스턴스 2개 유지)
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = var.private_subnet_ids # 프라이빗 서브넷 2개 지정
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mini-project-web-asg-instance"
    propagate_at_launch = true
  }
}