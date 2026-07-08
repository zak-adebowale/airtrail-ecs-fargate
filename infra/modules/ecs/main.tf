resource "aws_ecs_cluster" "airtrail_ecs_cluster" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "airtrail_cloudwatch" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.retention_days
}

resource "aws_ecs_task_definition" "airtrail_task_definition" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  container_definitions    = jsonencode([
    {
      name  = "airtrail"
      image = "${var.ecr_repo}:latest"
    
      portMappings = [
        { 
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [ 
        {
          name  = "ORIGIN"
          value = "https://${var.domain_name}"
        },
        {
          name  = "DB_URL"
          value = var.db_url
        },
        {
          name  = "UPLOAD_LOCATION"
          value = "/app/uploads"
        }
      ]
  
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30 
        timeout     = 5
        startPeriod = 60
        retries     = 3
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "airtrail_ecs_service" {
  name                   = "${var.app_name}-service"
  cluster                = aws_ecs_cluster.airtrail_ecs_cluster.id
  task_definition        = aws_ecs_task_definition.airtrail_task_definition.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.ecs_sg_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}