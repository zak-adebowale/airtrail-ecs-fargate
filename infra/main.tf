# VPC config
resource "aws_vpc" "ecs_project_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "airtrail-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "airtrail-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "airtrail-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "airtrail-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "airtrail-private-subnet-2"
  }
}

resource "aws_db_subnet_group" "db_sub_group" {
  name = "airtrail_db_subnet_group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  tags = {
    Name = "airtrail-igw"
  }
}

resource "aws_eip" "ngw_eip_1" {
  domain = "vpc"

  tags = {
    Name = "airtrail-ngw-eip-1"
  }
}

resource "aws_eip" "ngw_eip_2" {
  domain = "vpc"

  tags = {
    Name = "airtrail-ngw-eip-2"
  }
}

resource "aws_nat_gateway" "ngw_1" { 
  allocation_id = aws_eip.ngw_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id 
  depends_on    = [aws_internet_gateway.igw] 
  
  tags = {
    Name = "ngw-1" }
} 

resource "aws_nat_gateway" "ngw_2" { 
  allocation_id = aws_eip.ngw_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id 
  depends_on    = [aws_internet_gateway.igw] 
  
  tags = { 
    Name = "ngw-2" }
}

resource "aws_route_table" "public_rt" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "airtrail-public-rt"
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1.id
  }

  tags = {
    Name = "airtrail-private-rt-1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_2.id
  }

  tags = {
    Name = "airtrail-private-rt-2"
  }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
  depends_on     = [aws_nat_gateway.ngw_1]
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
  depends_on     = [aws_nat_gateway.ngw_2]
}

# Security groups config

resource "aws_security_group" "ecs_sg" {
  vpc_id      = aws_vpc.ecs_project_vpc.id
  name        = "ecs_sg"
  description = "Allow inbound from ALB"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.ecs_project_vpc.id
  name        = "alb_sg"
  description = "Allow inbound HTTP and HTTPS from internet"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "alb-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  name = "rds-sg"
  description = "Allow inbound PostgreSQL from ECS"

    ingress {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        security_groups = [aws_security_group.ecs_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "rds-sg"
  }    
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