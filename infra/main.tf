module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# ECR config

resource "aws_ecr_repository" "airtrail" {
  name = "airtrail"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "airtrail-ecr"
  }
}

# IAM roles

resource "aws_iam_role" "ecs_execution" {
  name = "airtrail-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

}

resource "aws_iam_role" "github_actions" {
  name = "airtrail-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }        
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:zach-adebowale/airtrail-ecs-fargate:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions" {
  name = "airtrail-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "iam:PassRole",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })     
}

# ACM config

resource "aws_acm_certificate" "airtrail_acm" {
  domain_name       = "airtrail.adebowale.co.uk"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "airtrail-acm-certificate"
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.airtrail_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.airtrail_route53_zone.id
}

resource "aws_acm_certificate_validation" "acm_cert_validation" {
  certificate_arn = aws_acm_certificate.airtrail_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

data "aws_route53_zone" "airtrail_route53_zone" {
  name = "airtrail.adebowale.co.uk"
}

# RDS config

resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  db_name                = "airtrail"
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  engine                 = "postgres"
  engine_version         = "16.14"
  storage_type           = "gp3"
  identifier             = "airtrail-db"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password 
  vpc_security_group_ids = [module.security_groups.rds_sg_id]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false 

  tags = {
    Name = "airtrail-db"
  }
}

# ALB setup

resource "aws_lb" "airtrail_alb" {
  name               = "airtrail-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_groups.alb_sg_id]
  subnets            = module.vpc.public_subnet_ids

  tags = {
    Name = "airtrail-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "airtrail-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"


  health_check {
    enabled             = true
    path                = "/api/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.airtrail_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.acm_cert_validation.certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.alb_tg.arn
      }
    }
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.airtrail_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ECS setup

resource "aws_ecs_cluster" "airtrail_ecs_cluster" {
  name = "airtrail-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "airtrail_cloudwatch" {
  name              = "/ecs/airtrail"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "airtrail_task_definition" {
  family                   = "airtrail"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_execution.arn
  container_definitions    = jsonencode([
    {
      name  = "airtrail"
      image = "${aws_ecr_repository.airtrail.repository_url}:latest"
    
      portMappings = [
        { 
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [ 
        {
          name  = "ORIGIN"
          value = "https://airtrail.adebowale.co.uk"
        },
        {
          name  = "DB_URL"
          value = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.db_instance.endpoint}/airtrail?sslmode=no-verify"
        },
        {
          name  = "UPLOAD_LOCATION"
          value = "/app/uploads"
        }
      ]
  
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/ping || exit 1"]
        interval    = 30 
        timeout     = 5
        startPeriod = 60
        retries     = 3
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/airtrail"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "airtrail_ecs_service" {
  name            = "airtrail-service"
  cluster         = aws_ecs_cluster.airtrail_ecs_cluster.id
  task_definition = aws_ecs_task_definition.airtrail_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnet_ids
    security_groups  = [module.security_groups.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "airtrail"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.ecs_execution
   ]
}

# Route 53 config

resource "aws_route53_record" "airtrail_route53_record" {
  zone_id = data.aws_route53_zone.airtrail_route53_zone.id
  name    = "airtrail.adebowale.co.uk"
  type    = "A"

  alias {
    name                   = aws_lb.airtrail_alb.dns_name
    zone_id                = aws_lb.airtrail_alb.zone_id
    evaluate_target_health = true
  }
}