module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source     = "./modules/iam"
  github_org = var.github_org
  repo_name  = var.repo_name
}

module "acm" {
  source       = "./modules/acm"
  domain_name  = var.domain_name
  zone_id      = module.acm.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "db" {
  source               = "./modules/db"
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  rds_sg_id            = module.security_groups.rds_sg_id
}

module "alb" {
  source            = "./modules/alb"
  alb_sg_id         = [module.security_groups.alb_sg_id]
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  certificate_arn   = module.acm.certificate_arn

}

module "ecs" {
  source               = "./modules/ecs"
  execution_role_arn   = module.iam.iam_ecs_execution
  ecr_repo             = module.ecr.ecr_repo
  db_username          = var.db_username
  db_password          = var.db_password
  aws_region           = var.aws_region
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_sg_id            = [module.security_groups.ecs_sg_id]
  alb_target_group_arn = module.alb.target_group_arn
  db_url               = "postgres://${var.db_username}:${var.db_password}@${module.db.rds_endpoint}/airtrail?sslmode=no-verify"
    
  depends_on = [
  module.alb,
  module.iam
  ]
}