# 작업 계획:
# * NAT Gateway 생성(PublicSN)
# * Private Subnet 생성
# * Private Routing Table 생성 및 연결
# * SG 생성
# * EC2 생성

# 1) NAT Gateway 생성(PublicSN)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# * EIP 생성

# * Public Subnet에 NAT Gateway 생성
resource "aws_eip" "myEIP" {
  domain = "vpc"
  #depends_on                = [aws_internet_gateway.gw]

  tags = {
    Name = "myEIP"
  }
}
resource "aws_nat_gateway" "myNAT-GW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.myPubSN.id

  tags = {
    Name = "myNAT-GW"
  }

  depends_on = [aws_internet_gateway.myIGW]
}

# 2) Private Subnet 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# * 새로 생성된 myVPC에 놓아야 한다.
resource "aws_subnet" "myPriSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "myPriSN"
  }
}

# * Private Subnet 생성
resource "aws_route_table" "myPriRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT-GW.id
  }

  tags = {
    Name = "myPriRT"
  }
}


resource "aws_route_table_association" "myPriRTassoc" {
  subnet_id      = aws_subnet.myPriSN.id
  route_table_id = aws_route_table.myPriRT.id
}



# 4) SG 생성
#
# * SG(22/tcp, 80/tcp, 443/tcp)

# 5) EC2 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "myEC2_3" {
  ami                    = "ami-048f644e868baa0e8"
  instance_type          = "t3.micro"
  key_name               = "mykeypair"
  vpc_security_group_ids = [aws_security_group.mySG.id]
  subnet_id              = aws_subnet.myPubSN.id

  user_data_replace_on_change = true
  user_data                   = <<-EOF
        #!/bin/bash
        dnf install -y httpd mod_ssl
        echo "My EC2 02" > /var/www/html/index.html
        systemctl enable --now httpd
        EOF

  tags = {
    Name = "myEC2_3"
  }
}






# * 새로 생성된 SG를 사용
# * mykeypair
# * 새로 생성 myPriSN에 놓아야 한다.
# * user_data -> user_data_replace_on_change