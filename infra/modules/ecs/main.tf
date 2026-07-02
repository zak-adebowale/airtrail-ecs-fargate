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
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn
  container_definitions    = jsonencode([
    {
      name  = "airtrail"
      image = "${var.ecr_repo}:latest"
    
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
          value = var.db_url
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
    subnets          = var.private_subnet_ids
    security_groups  = var.ecs_sg_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "airtrail"
    container_port   = 3000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}