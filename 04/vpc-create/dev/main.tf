provider "aws" {
  region = "ap-northeast-2"
}

module "myvpc" {
  source = "../modules/vpc"

  vpc_id = module.myvpc.vpc_id
}

module "myec2" {
  source = "../modules/ec2"

  subnet_id = module.myvpc.subnet_id
}


