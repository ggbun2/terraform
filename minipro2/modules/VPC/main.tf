# 1. 새로운 VPC 생성
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  tags             = var.vpc_tag
}

# 2. 인터넷 게이트웨이 (IGW) 생성 (외부 인터넷 통신용)
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = var.vpc_igw
}

# 퍼블릭 서브넷 생성 (가용영역 2개에 걸쳐 2개 생성)
resource "aws_subnet" "pubsub" {
  count                   = 2 
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.vpc_pubsub_azs[count.index]
  map_public_ip_on_launch = true  
  tags = {
    Name = var.vpc_pubsub[count.index]
  }
}

# 프라이빗 서브넷 생성 (가용영역 2개에 걸쳐 2개 생성)
resource "aws_subnet" "privsub" {
  count                   = 2
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.vpc_privsub_azs[count.index]
  tags = {
    Name = var.vpc_privsub[count.index]
  }
}

# 퍼블릭 라우팅 테이블 생성 (인터넷 트래픽을 IGW로 라우팅)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  } 
  tags = {
    Name = var.public_rt
    }
}

# 퍼블릭 서브넷들과 퍼블릭 라우팅 테이블 연결 (Association)
resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.pubsub[count.index].id  
  route_table_id = aws_route_table.public.id         
}
