module "vpc" {
  source                = "./modules/vpc"
  environment           = var.environment
  app_name              = var.app_name
  aws_region            = var.aws_region
  az_1                  = var.az_1
  az_2                  = var.az_2
  vpc_cidr              = var.vpc_cidr
  all_ip_cidr           = var.all_ip_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "security_groups" {
  source      = "./modules/security_groups"
  environment = var.environment
  app_name    = var.app_name
  vpc_id      = module.vpc.vpc_id
  all_ip_cidr = var.all_ip_cidr

}

module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
  app_name    = var.app_name
}

module "iam" {
  source            = "./modules/iam"
  environment       = var.environment
  app_name          = var.app_name
  github_org        = var.github_org
  repo_name         = var.repo_name
  oidc_provider_arn = aws_iam_openid_connect_provider.github
}

module "acm" {
  source       = "./modules/acm"
  environment  = var.environment
  app_name     = var.app_name
  domain_name  = var.domain_name
  zone_id      = module.acm.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  dns_ttl      = var.dns_ttl

}

module "db" {
  source               = "./modules/db"
  environment          = var.environment
  app_name             = var.app_name
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_instance_class    = var.db_instance_class
  rds_sg_id            = module.security_groups.rds_sg_id
  allocated_storage    = var.allocated_storage
  engine_version       = var.engine_version
  storage_type         = var.storage_type
  multi_az             = var.multi_az
  skip_final_snapshot  = var.skip_final_snapshot
  deletion_protection  = var.deletion_protection
}

module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  app_name          = var.app_name
  alb_sg_id         = [module.security_groups.alb_sg_id]
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  certificate_arn   = module.acm.certificate_arn
  container_port    = var.container_port
  health_check_path = var.health_check_path
  ssl_policy        = var.ssl_policy
}

module "ecs" {
  source               = "./modules/ecs"
  environment          = var.environment
  app_name             = var.app_name
  execution_role_arn   = module.iam.iam_ecs_execution
  ecr_repo             = module.ecr.ecr_repo
  domain_name          = var.domain_name
  db_username          = var.db_username
  db_password          = var.db_password
  aws_region           = var.aws_region
  container_port       = var.container_port
  container_cpu        = var.container_cpu
  container_memory     = var.container_memory
  health_check_path    = var.health_check_path
  retention_days       = var.retention_days
  desired_count        = var.desired_count
  private_subnet_ids   = module.vpc.private_subnet_ids
  ecs_sg_id            = [module.security_groups.ecs_sg_id]
  alb_target_group_arn = module.alb.target_group_arn
  db_url               = "postgres://${var.db_username}:${var.db_password}@${module.db.rds_endpoint}/airtrail?sslmode=no-verify"

  depends_on = [
    module.alb,
    module.iam
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

}