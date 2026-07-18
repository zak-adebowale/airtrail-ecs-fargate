terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_vpc" "ecs_project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.environment}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.environment}-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-${var.environment}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-${var.environment}-private-subnet-2"
  }
}

resource "aws_db_subnet_group" "db_sub_group" {
  name = "${var.app_name}-${var.environment}_db_subnet_group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  tags = {
    Name = "${var.app_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

resource "aws_eip" "ngw_eip_1" {
  domain = "vpc"

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-eip-1"
  }
}

resource "aws_eip" "ngw_eip_2" {
  domain = "vpc"

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-eip-2"
  }
}

resource "aws_nat_gateway" "ngw_1" {
  allocation_id = aws_eip.ngw_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-1"
  }
}

resource "aws_nat_gateway" "ngw_2" {
  allocation_id = aws_eip.ngw_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = var.all_ip_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block     = var.all_ip_cidr
    nat_gateway_id = aws_nat_gateway.ngw_1.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-private-rt-1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block     = var.all_ip_cidr
    nat_gateway_id = aws_nat_gateway.ngw_2.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-private-rt-2"
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