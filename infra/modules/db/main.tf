terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage                     = var.allocated_storage
  db_name                               = var.db_name
  db_subnet_group_name                  = var.db_subnet_group_name
  engine                                = "postgres"
  engine_version                        = var.engine_version
  storage_type                          = var.storage_type
  identifier                            = "${var.app_name}-${var.environment}-db"
  instance_class                        = var.db_instance_class
  username                              = var.db_username
  password                              = var.db_password
  vpc_security_group_ids                = [var.rds_sg_id]
  multi_az                              = true
  publicly_accessible                   = false
  storage_encrypted                     = true
  deletion_protection                   = false
  skip_final_snapshot                   = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  auto_minor_version_upgrade            = true

  tags = {
    Name = "${var.app_name}-${var.environment}-db"
  }
}