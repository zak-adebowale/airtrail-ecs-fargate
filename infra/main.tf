module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  app_name             = var.app_name
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  all_ip_cidr          = var.all_ip_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
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
  source      = "./modules/iam"
  environment = var.environment
  app_name    = var.app_name
}

module "acm" {
  source      = "./modules/acm"
  environment = var.environment
  app_name    = var.app_name
  domain_name = var.domain_name
  zone_id     = var.zone_id
  dns_ttl     = var.dns_ttl
}

module "route_53" {
  source       = "./modules/route_53"
  domain_name  = var.domain_name
  zone_id      = var.zone_id
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
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
  skip_final_snapshot  = var.skip_final_snapshot
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
  aws_region           = var.aws_region
  container_port       = var.container_port
  cpu                  = var.cpu
  memory               = var.memory
  health_check_path    = var.health_check_path
  log_retention_days   = var.log_retention_days
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