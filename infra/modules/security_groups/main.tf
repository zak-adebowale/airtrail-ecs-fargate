terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Allow inbound HTTP and HTTPS from internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.app_name}-${var.environment}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  security_group_id = aws_security_group.alb_sg.id

  description = "Allow HTTP"
  cidr_ipv4   = var.all_ip_cidr
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.alb_sg.id

  description = "Allow HTTPS"
  cidr_ipv4   = var.all_ip_cidr
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id

  description = "Allow outbound traffic"
  cidr_ipv4   = var.all_ip_cidr
  ip_protocol = "-1"
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-${var.environment}-ecs-sg"
  description = "Allow inbound from ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.app_name}-${var.environment}-ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_alb_traffic" {
  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id

  description = "Allow traffic from ALB"
  from_port   = 3000
  ip_protocol = "tcp"
  to_port     = 3000
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_all_outbound" {
  security_group_id = aws_security_group.ecs_sg.id

  description = "Allow outbound traffic"
  cidr_ipv4   = var.all_ip_cidr
  ip_protocol = "-1"
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-${var.environment}-rds-sg"
  description = "Allow inbound PostgreSQL from ECS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.app_name}-${var.environment}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_allow_postgre_from_ecs" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg.id

  description = "Allow PostgreSQL from ECS"
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_allow_all_outbound" {
  security_group_id = aws_security_group.rds_sg.id

  description = "Allow outbound traffic"
  cidr_ipv4   = var.all_ip_cidr
  ip_protocol = "-1"
}