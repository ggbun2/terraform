provider "aws" {
  region = "ap-northeast-2"
}
# 1번 모듈: VPC 생성
module "vpc" {
  source = "./modules/VPC"
}

# 2번 모듈: DB 생성 
module "db" {
  source             = "./modules/DB"
  vpc_id             = module.vpc.vpc_id             # 1번 모듈의 VPC ID 참조
  private_subnet_ids = module.vpc.private_subnet_ids # 1번 모듈의 프라이빗 서브넷 ID들 참조

  depends_on = [module.vpc] # ★ 1번(VPC) 모듈 생성이 끝난 후 실행 보장
}

# 3번 모듈: Web / ALB 생성 (VPC와 DB기 모두 완료된 후 생성 보장)
module "web" {
  source             = "./modules/Web"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.public_subnet_ids

  depends_on = [module.vpc, module.db] # ★ 순서 강제
}