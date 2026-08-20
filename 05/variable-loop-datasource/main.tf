# Provider 설정
provider "aws" {
    region = "${var.region}"
}

# VPC 생성
resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"
    tags = {
        Name = "Main"
        Location = "Seoul"
    }
}

# Subnet 생성
resource "aws_subnet" "subnets" {
    count = "${length(var.asz)}"
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${element(var.vsubnet_cidr, count.index)}"

    tags = {
        Name = "Subnet1"
    }
}