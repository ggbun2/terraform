# 1. 보안 그룹(Security Group) 생성: 오직 내부망(프라이빗 서브넷 등)에서 3306 포트 접근 허용
resource "aws_security_group" "db_sg" {
  name        = "mini-project-db-sg"
  description = "Security group for MySQL DB cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC 전체 대역 허용 (추후 웹서버 SG로 좁힐 수 있음)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mini-project-db-sg"
  }
}

# 2. DB 서브넷 그룹 (프라이빗 서브넷 2개 지정)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mini-project-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "mini-project-db-subnet-group"
  }
}

# 3. MySQL RDS 인스턴스 (DB 클러스터/인스턴스 역할)
resource "aws_db_instance" "mysql" {
  identifier             = "mini-project-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true # 실습용이므로 삭제 시 스냅샷 생략

  tags = {
    Name = "mini-project-mysql"
  }
}